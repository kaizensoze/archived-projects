//
//  FeedViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCell.h"
#import "ProfileViewController.h"
#import "User.h"

@interface FeedViewController ()
    @property (strong, nonatomic) NSString *loggedInProfileId;
    @property (strong, nonatomic) NSMutableArray *feedEntries;
    @property (strong, nonatomic) NSMutableArray *friendsFeedEntries;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (nonatomic) BOOL friendsFeedFinished;
    @property (nonatomic) int numFeedEntriesToDisplay;
    @property (strong, nonatomic) NSString *nextFriendsFeedEntriesURL;
    @property (strong, nonatomic) UITableViewCell *loadMoreTableCell;
    @property (strong, nonatomic) NSString *loginButtonDetail;
    @property (nonatomic) BOOL alreadyLoaded;
    @property (strong, nonatomic) EGORefreshTableHeaderView *refreshView;
    @property (nonatomic) BOOL viewRefreshing;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.loginButtonDetail = @"view friends' feed";
    
    self.alreadyLoaded = NO;
    
    if (!self.refreshView) {
        CGRect refreshViewFrame = CGRectMake(0,
                                             0 - self.tableView.bounds.size.height,
                                             self.view.frame.size.width,
                                             self.tableView.bounds.size.height);
        self.refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:refreshViewFrame];
		self.refreshView.delegate = self;
		[self.tableView addSubview:self.refreshView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Feed Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setup {
    User *myProfile = appDelegate.loggedInUser;
    if (myProfile != nil) {
        if (![myProfile.username isEqualToString:self.loggedInProfileId]) {
            self.alreadyLoaded = NO;
        }
        self.loggedInProfileId = myProfile.username;
    } else {
        self.loggedInProfileId = nil;
    }
    
    // Show login if not logged in.
    if (self.loggedInProfileId == nil) {
        [appDelegate removeLoadingScreen:self];
        [appDelegate showNotLoggedInScreen:self loginButtonDetail:self.loginButtonDetail];
        return;
    }

    if (!self.alreadyLoaded) {
        [appDelegate removeNotLoggedInScreen];
        [appDelegate showLoadingScreen:self.view];
        [self resetFeedData];
        [self grabFriendsFeed];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedEntries.count == 0
        || (self.nextFriendsFeedEntriesURL == nil)) {
        return self.feedEntries.count;
    } else {
        return self.feedEntries.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *thisCell;
    static NSString *cellIdentifier;
    
    NSUInteger index = indexPath.row;
    if (index == self.feedEntries.count) {
        if (!self.loadMoreTableCell) {
            self.loadMoreTableCell = [CustomStyler createLoadMoreTableCell:tableView vc:self];
        }
        thisCell = self.loadMoreTableCell;
    } else {
        cellIdentifier = @"FeedCell";
        FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        NSMutableDictionary *feedEntryDict = self.feedEntries[indexPath.row];
        NSString *feedEntryDate = [self getFeedEntryDate:feedEntryDict];
        NSString *feedEntryDescription = [self getFeedEntryDescription:feedEntryDict];
        
        NSURL *imageURL = [self getFeedEntryImageURL:feedEntryDict];
        
        // image
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        
        [cell.feedImageView setImageWithURLRequest:request
                                  placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            cell.feedImageView.image = image;
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            DDLogInfo(@"%@", error);
                                        }];
        
        // date label
        cell.dateLabel.text = [feedEntryDate uppercaseString];
        
        // entry description label
        cell.entryDescriptionLabel.text = feedEntryDescription;
        
        thisCell = cell;
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    if (index < self.feedEntries.count) {
        return 80;
    } else {
        return LOAD_MORE_CELL_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"goToProfile" sender:self];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView setLayoutMargins:UIEdgeInsetsZero];
//    cell.layoutMargins = UIEdgeInsetsZero;
//}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self resetFeedData];
	[self grabFriendsFeed];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return self.viewRefreshing;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date];
}

- (void)doneRefreshing {
    self.viewRefreshing = NO;
    [self.refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Get feed data

- (void)grabFriendsFeed {
    self.viewRefreshing = YES;
    self.friendsFeedFinished = NO;
    
    NSString *url = [self getNextFriendsFeedEntriesURL];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self.friendsFeedEntries addObjectsFromArray:[JSON objectForKeyNotNull:@"results"]];
        self.nextFriendsFeedEntriesURL = [JSON objectForKeyNotNull:@"next"];
        
        self.friendsFeedFinished = YES;
        [self doneGrabbingFeeds];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Reset feed data

- (void)resetFeedData {
    self.friendsFeedEntries = [[NSMutableArray alloc] init];
    self.numFeedEntriesToDisplay = 20;
    self.nextFriendsFeedEntriesURL = nil;
}

#pragma mark - Done grabbing feed data

- (void)doneGrabbingFeeds {
    if (!self.friendsFeedFinished) {
        return;
    }
    
    self.feedEntries = [[NSMutableArray alloc] init];
    [self.feedEntries addObjectsFromArray:self.friendsFeedEntries];
    
    [self.feedEntries sortUsingFunction:compareFeedEntryDates context:NULL];
    
    // Restrict to limit.
    if (self.feedEntries.count > self.numFeedEntriesToDisplay) {
        NSRange range;
        range.location = 0;
        range.length = self.numFeedEntriesToDisplay;
        
        self.feedEntries = [[self.feedEntries subarrayWithRange:range] mutableCopy];
    }
    
    [self resetFinishedFlags];
    
    [self.tableView reloadData];
    [appDelegate removeLoadingScreen:self];
    
    self.alreadyLoaded = YES;
    
    // signal to refresh view
    [self doneRefreshing];
}

- (void)resetFinishedFlags {
    self.friendsFeedFinished = NO;
}

#pragma mark - Get feed entry data parts

- (NSURL *)getFeedEntryImageURL:(NSMutableDictionary *)feedEntry {
    NSString *avatarURL = [[feedEntry objectForKeyNotNull:@"user"] objectForKeyNotNull:@"avatar"];
    return [NSURL URLWithString:avatarURL];
}

- (NSString *)getFeedEntryDescription:(NSMutableDictionary *)feedEntry {
    NSString *username = [[feedEntry objectForKeyNotNull:@"user"] objectForKeyNotNull:@"username"];
    
    NSString *firstName = [[feedEntry objectForKeyNotNull:@"user"] objectForKeyNotNull:@"first_name"];
    NSString *lastName = [[feedEntry objectForKeyNotNull:@"user"] objectForKeyNotNull:@"last_name"];
    
    NSString *shortName = [Util getShortName:firstName lastName:lastName];
    if ([Util isEmpty:shortName]) {
        shortName = username;
    }
    
    NSString *action = [self getFeedEntryAction:feedEntry];
    NSString *actionSubject = [self getFeedEntryActionSubject:feedEntry];
    
    return [NSString stringWithFormat:@"%@ %@ %@", shortName, action, actionSubject];
}

- (NSString *)getFeedEntryAction:(NSMutableDictionary *)feedEntry {
    NSString *prependStr = @"";
    NSString *actionName = [[feedEntry objectForKeyNotNull:@"action"] objectForKeyNotNull:@"action_name"];
    if ([actionName isEqualToString:@"follow"]) {
        prependStr = @"is ";
    } else {
        prependStr = @"has ";
    }
    NSString *action = [[feedEntry objectForKeyNotNull:@"action"] objectForKeyNotNull:@"message"];
    NSString *searchTerm = @"<a href=";
    NSString *cleanAction = [action substringToIndex:[action rangeOfString:searchTerm].location-1];
    
    return [NSString stringWithFormat:@"%@%@", prependStr, cleanAction];
}

- (NSString *)getFeedEntryActionSubject:(NSMutableDictionary *)feedEntry {
    NSString *metadataStr = [feedEntry objectForKeyNotNull:@"meta_data"];
    NSData *jsonData = [metadataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSString *actionSubject = [metadata objectForKeyNotNull:@"name"];
    return actionSubject;
}

- (NSString *)getFeedEntryDate:(NSMutableDictionary *)feedEntry {
    NSString *dateStr = [feedEntry objectForKeyNotNull:@"occurred"];
    NSDate *date = [Util stringToDate:dateStr dateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *displayDate = [Util dateToString:date dateFormat:@"MMM. dd, yyyy"];
    return displayDate;
}

#pragma mark - Load more

- (IBAction)loadMore:(id)sender {
    // show spinner
    [CustomStyler showLoadMoreSpinner:self.loadMoreTableCell];
    self.loadMoreTableCell = nil;
    
    self.numFeedEntriesToDisplay += self.numFeedEntriesToDisplay;
    [self grabFriendsFeed];
}

- (NSString *)getNextFriendsFeedEntriesURL {
    NSString *url;
    if (self.nextFriendsFeedEntriesURL == nil) {
        url = [NSString stringWithFormat:@"%@/users/%@/friendsfeed/", API_URL_PREFIX, self.loggedInProfileId];
    } else {
        url = self.nextFriendsFeedEntriesURL;
    }
    return url;
}

#pragma mark - Compare feed entry dates

NSInteger compareFeedEntryDates(id obj1, id obj2, void *context) {
    NSString *dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    
    NSString *date1Str = [(NSMutableDictionary *)obj1 objectForKeyNotNull:@"occurred"];
    NSDate *date1 = [Util stringToDate:date1Str dateFormat:dateFormat];
    
    NSString *date2Str = [(NSMutableDictionary *)obj2 objectForKeyNotNull:@"occurred"];
    NSDate *date2 = [Util stringToDate:date2Str dateFormat:dateFormat];
    
    return [date1 compare:date2] * -1;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Go to profile.
    if ([[segue identifier] isEqualToString:@"goToProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSMutableDictionary *feedEntryDict = self.feedEntries[indexPath.row];
        NSString *requestedProfileId = feedEntryDict[@"user"][@"username"];
        
        ProfileViewController *profileVC = segue.destinationViewController;
        profileVC.requestedProfileId = requestedProfileId;
    }
}

@end
