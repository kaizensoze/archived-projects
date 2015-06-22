//
//  ProfileViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "ProfileViewController.h"
#import "ReviewCell.h"
#import "ReviewListViewController.h"
#import "ReviewDetailViewController.h"
#import "Restaurant.h"
#import "User.h"
#import "UserReview.h"
#import "Critic.h"
#import "CriticReview.h"

@interface ProfileViewController ()
    @property (nonatomic) BOOL myProfile;
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UILabel *successfulSaveLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *imageField;
    @property (weak, nonatomic) IBOutlet UILabel *nameLabel;
    @property (weak, nonatomic) IBOutlet UITextView *userInfoTextView;
    @property (weak, nonatomic) IBOutlet UILabel *reviewCountLabel;
    @property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *divider1;
    @property (weak, nonatomic) IBOutlet UILabel *followingLabel;
    @property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *divider2;
    @property (weak, nonatomic) IBOutlet UILabel *followersLabel;
    @property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (strong, nonatomic) UIScrollView *followingScrollView;
    @property (strong, nonatomic) UIScrollView *followerScrollView;
    @property (strong, nonatomic) NSMutableDictionary *followingFollowerButtonToUsername;
    @property (strong, nonatomic) NSString *loginButtonDetail;
    @property (nonatomic) BOOL profileEdited;
    @property (nonatomic) BOOL alreadyLoaded;
    @property (strong, nonatomic) EGORefreshTableHeaderView *refreshView;
    @property (nonatomic) BOOL viewRefreshing;
    @property (nonatomic) BOOL loadingData;
@end

@implementation ProfileViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.requestedProfileId = nil;
        self.editProfile = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.loginButtonDetail = @"view profile";
    
    self.alreadyLoaded = NO;
    
    if (!self.refreshView) {
        CGRect refreshViewFrame = CGRectMake(0,
                                             0 - self.view.bounds.size.height,
                                             self.view.frame.size.width,
                                             self.view.bounds.size.height);
        self.refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:refreshViewFrame];
		self.refreshView.delegate = self;
		[self.view addSubview:self.refreshView];
    }
    
    self.tableView.scrollEnabled = NO;
    
    float initialHeight = 1200;
    
    UIView *view = ((UIView *)self.scrollView.subviews[0]);
    CGRect frame = view.frame;
    frame.size.height = initialHeight;
    view.frame = frame;
    
    [self.scrollView setContentSize:frame.size];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // viewWillAppear is getting called twice coming from login so use variable to prevent this
    if (self.loadingData) {
        return;
    }
    
    // remove not logged in screen if visible
    [appDelegate removeNotLoggedInScreen];
    
    if (self.profileEdited) {
        [self updateContent];
    } else {
        if (!self.alreadyLoaded) {
            [self setup];
        }
    }
    
    [self updateSuccessLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.editProfile) {
        self.profile = appDelegate.loggedInUser;
        [self goToProfileEdit:nil];
        self.editProfile = NO;
    }
    
    [appDelegate.tracker set:kGAIScreenName value:@"Profile Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
//    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.requestedProfileId = nil;
    self.requestedCriticId = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

- (void)setup {
    // if using as critic page
    if (self.critic || self.requestedCriticId) {
        // if going back to previously loaded critic page
        if (self.critic) {
            self.requestedCriticId = self.critic.slug;
        }
        [[Critic alloc] loadFromSlug:self.requestedCriticId delegate:self];
        self.viewRefreshing = YES;
        
        if (!self.alreadyLoaded) {
            [appDelegate removeNotLoggedInScreen];
            [appDelegate showLoadingScreen:self.view];
        }
        return;
    }
    
    // if not logged in, show login screen
    if (self.requestedProfileId == nil && appDelegate.loggedInUser == nil) {
        [self clearNavbar];
        [appDelegate removeLoadingScreen:self];
        [appDelegate showNotLoggedInScreen:self loginButtonDetail:self.loginButtonDetail];
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        self.alreadyLoaded = NO;
        return;
    }
    
    // if going back to previously loaded user page
    if (self.profile) {
        self.requestedProfileId = self.profile.username;
    }
    
    // determine if showing My Profile or another user's profile
    if (self.requestedProfileId == nil
        || (appDelegate.loggedInUser != nil
            && [self.requestedProfileId isEqualToString:appDelegate.loggedInUser.username])) {
        self.requestedProfileId = appDelegate.loggedInUser.username;
        self.myProfile = YES;
    } else {  // Other's profile.
        self.editProfile = NO;  // Just to be safe.
        self.myProfile = NO;
    }
    
    if (!self.alreadyLoaded) {
        [appDelegate removeNotLoggedInScreen];
        [appDelegate showLoadingScreen:self.view];
    }
    
    self.viewRefreshing = YES;
    self.loadingData = YES;
    
    [self getProfileInfo];
}

- (void)getProfileInfo {
    User *profile = [[User alloc] init];
    profile.delegate = self;
    [profile loadFromUsername:self.requestedProfileId];
}

#pragma mark - ProfileDelegate

- (void)profileDoneLoading:(User *)profile {
    self.profile = profile;
    
    // hack to pass info to edit profile that this is a social auth account
    if (appDelegate.loggedInUser != nil
        && [profile.username isEqualToString:appDelegate.loggedInUser.username]) {
        self.profile.viaSocialAuth = appDelegate.loggedInUser.viaSocialAuth;
    }
    
    DDLogInfo(@"%@", self.profile.username);
    
    [self updateContent];
    [self updateNavbar];
    self.requestedProfileId = nil;
    [appDelegate removeLoadingScreen:self];
    self.alreadyLoaded = YES;
    self.loadingData = NO;
    [self doneRefreshing];
    
    NSString *titleText;
    
    if (self.myProfile) {
        titleText = @"My Profile";
    } else {
        titleText = self.profile.shortName;
    }
    self.navigationItem.title = titleText;
}

#pragma mark - CriticDelegate

- (void)criticDoneLoading:(Critic *)critic {
    self.critic = critic;
    
    DDLogInfo(@"%@", self.critic.slug);
    
    self.requestedCriticId = nil;
    [self showCriticPage];
    [appDelegate removeLoadingScreen:self];
    self.alreadyLoaded = YES;
    [self doneRefreshing];
}

#pragma mark - Show critic page

- (void)showCriticPage {
    // critic image
    [self.imageField setImageWithURL:self.critic.logoLargeURL
                    placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]];
    
    // name label
    self.nameLabel.text = self.critic.name;
    
    CGRect nameLabelRect = self.nameLabel.frame;
    nameLabelRect.size.height = 63;
    self.nameLabel.frame = nameLabelRect;
    
    self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.imageField.center.y);
    
    // hide dividers
    self.divider1.hidden = YES;
    self.divider2.hidden = YES;
    
    [self.tableView reloadData];
    [self adjustTableView];
}

#pragma mark - Update view content

- (void)updateContent {
    // profile image
    if (self.profile.image) {
        self.imageField.image = self.profile.image;
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.profile.imageURL]];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        
        [self.imageField setImageWithURLRequest:request
                               placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            self.imageField.image = image;
                                            self.profile.image = image;
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            DDLogInfo(@"%@", error);
                                        }];
    }
    
    // name label
    self.nameLabel.text = self.profile.shortName;
    self.nameLabel.textColor = [Util colorFromHex:@"f26c4f"];
//    [Util adjustText:self.nameLabel width:188 height:21];
    
    CGRect nameLabelRect = self.nameLabel.frame;
    nameLabelRect.origin.y = 23;
    nameLabelRect.size.height = 21;
    self.nameLabel.frame = nameLabelRect;
    
    // user info text view
    self.userInfoTextView.text = @"";
    self.userInfoTextView.textColor = [Util colorFromHex:@"362f2d"];
    self.userInfoTextView.layoutManager.delegate = self;

    [Util adjustTextView:self.userInfoTextView];
    
    if (![Util isEmpty:self.profile.typeExpert]) {
        self.userInfoTextView.text = [self.userInfoTextView.text stringByAppendingString:
                                      [NSString stringWithFormat:@"%@ Expert\n", self.profile.typeExpert]];
    }
    
    if (![Util isEmpty:self.profile.reviewerTypeDisplay]) {
        self.userInfoTextView.text = [self.userInfoTextView.text stringByAppendingString:
                                      [NSString stringWithFormat:@"%@\n", self.profile.reviewerTypeDisplay]];
    }
    
    if (![Util isEmpty:self.profile.location]) {
        self.userInfoTextView.text = [self.userInfoTextView.text stringByAppendingString:
                                      [NSString stringWithFormat:@"%@ resident\n", self.profile.location]];
    }
    
    // review count
    NSString *reviewCountStr = [NSString stringWithFormat: @"%ld", (long)self.profile.numReviews];
    self.reviewCountLabel.text = reviewCountStr;
    self.reviewCountLabel.textColor = [Util colorFromHex:@"f26c4f"];
    
    self.reviewsLabel.textColor = [Util colorFromHex:@"362f2d"];
//    [Util adjustText:self.reviewsLabel width:50 height:15];
    
    // following count
    NSString *followingCountStr = [NSString stringWithFormat: @"%lu", (unsigned long)self.profile.following.count];
    self.followingCountLabel.text = followingCountStr;
    self.followingCountLabel.textColor = [Util colorFromHex:@"f26c4f"];
    
    self.followingLabel.textColor = [Util colorFromHex:@"362f2d"];
//    [Util adjustText:self.followingLabel width:56 height:15];
    
    // follower count
    NSString *followerCountStr = [NSString stringWithFormat: @"%lu", (unsigned long)self.profile.followers.count];
    self.followerCountLabel.text = followerCountStr;
    self.followerCountLabel.textColor = [Util colorFromHex:@"f26c4f"];
    
    self.followersLabel.textColor = [Util colorFromHex:@"362f2d"];
//    [Util adjustText:self.followersLabel width:58 height:15];
    
    // following/follower
    [self createFollowingFollowerSections];
    
    [self.tableView reloadData];
    [self adjustTableView];
}

- (void)adjustTableView {
    // calculate table origin [based on critic/profile usage]
    float tableOriginY;
    if (self.critic) {
        tableOriginY = 140;
    } else {
        tableOriginY = 187;
    }
    
    // get new heights
    float newTableHeight = self.tableView.contentSize.height;
    float newViewHeight = tableOriginY + newTableHeight;
    
    // adjust scroll view
    UIView *subview = ((UIView *)self.scrollView.subviews[0]);
    subview.frame = CGRectMake(0, 0, 320, newViewHeight);
//    [CustomStyler setBorder:subview];
    
    [self.scrollView setContentSize:CGSizeMake(320, newViewHeight)];
//    [CustomStyler setBorder:self.scrollView width:1 color:[UIColor blueColor]];
    
    // adjust table height
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y = tableOriginY;
    tableFrame.size.height = newTableHeight;
    self.tableView.frame = tableFrame;
//    [CustomStyler setBorder:self.tableView width:1 color:[UIColor redColor]];
}

- (void)createFollowingFollowerSections {
    self.followingFollowerButtonToUsername = [[NSMutableDictionary alloc] init];
    
    // following
    self.followingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, 320, 88)];
    [self createFollowingFollowerSection:[self.profile.following copy] scrollView:self.followingScrollView];
    
    // follower
    self.followerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, 320, 88)];
    [self createFollowingFollowerSection:[self.profile.followers copy] scrollView:self.followerScrollView];
}

- (void)createFollowingFollowerSection:(NSArray *)followingFollowerList scrollView:(UIScrollView *)scrollView {
    // clear
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int i = 0;
    int contentWidth = 0;
    int imageWidth = 60, imageHeight = 60;
    
    for (User *profile in followingFollowerList) {
        int xPos = 10 + i*(imageWidth+10);
        
        NSURL *imageURL = [NSURL URLWithString:profile.imageURL];
        
        // image button
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(xPos, 0, imageWidth, imageHeight)];
        button.imageView.contentMode = UIViewContentModeScaleToFill;
        [button setImageWithURL:imageURL
               placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                       forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goToProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        // name label
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, imageHeight+10, imageWidth, 15)];
        nameLabel.text = profile.shortName;
        nameLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        nameLabel.textColor = [Util colorFromHex:@"362f2d"];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        
        [scrollView addSubview:button];
        [scrollView addSubview:nameLabel];
        
        // keep reference to button
        [self.followingFollowerButtonToUsername setObject:profile.username forKey:[NSValue valueWithNonretainedObject:button]];
        
        i++;
        contentWidth = 10 + i*(imageWidth+10);
    }
    
    [scrollView setContentSize:CGSizeMake(contentWidth, scrollView.frame.size.height)];
    scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)updateSuccessLabel {
    if (self.profileEdited) {
//        self.successfulSaveLabel.hidden = NO;
        self.profileEdited = NO;
    } else {
        self.successfulSaveLabel.hidden = YES;
    }
}

- (IBAction)goToProfile:(id)sender {
    UIButton *b = (UIButton *)sender;
    NSString *username = [self.followingFollowerButtonToUsername objectForKey:[NSValue valueWithNonretainedObject:b]];
    ProfileViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"Profile"];
    pvc.requestedProfileId = username;
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)updateNavbar {
    if (self.myProfile) {
        // don't show my profile navbar if this vc isn't the root of the tabbar controller
        if (self.navigationController.viewControllers.count == 1) {
            [self setMyProfileNavbar];
        }
    } else {
        [self setOtherProfileNavbar];
    }
}

- (void)setMyProfileNavbar {
    // Logout button.
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    // Edit button.
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(goToProfileEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)setOtherProfileNavbar {
    // Follow/unfollow button.
    UIBarButtonItem *followUnfollowButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(followUnfollow:)];
    self.navigationItem.rightBarButtonItem = followUnfollowButton;
    
    // initialize follow/unfollow button title
    if ([appDelegate.loggedInUser.following containsObject:self.profile]) {
        self.navigationItem.rightBarButtonItem.title = @"Unfollow";
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Follow";
    }
}

- (void)clearNavbar {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = nil;
}

- (IBAction)followUnfollow:(id)sender {
    if (appDelegate.loggedInUser == nil) {
        [appDelegate showNotLoggedInScreen:self loginButtonDetail:self.loginButtonDetail];
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        return;
    }
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Follow"]) {
        [Util follow:self.profile.username];
        self.navigationItem.rightBarButtonItem.title = @"Unfollow";
    } else {
        [Util unfollow:self.profile.username];
        self.navigationItem.rightBarButtonItem.title = @"Follow";
    }
}

- (IBAction)goToProfileEdit:(id)sender {
    [self performSegueWithIdentifier:@"goToProfileEdit" sender:self];
}

- (void)profileEditComplete {
    self.profileEdited = YES;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0) animated:YES];
}

- (IBAction)logout:(id)sender {
    [appDelegate logout];
    
    self.requestedProfileId = nil;
    self.profile = nil;
    
    [self clearNavbar];
    
    [self setup];
}

- (IBAction)loadMore:(id)sender {
    [self goToMoreReviews];
}

- (void)goToMoreReviews {
    [self performSegueWithIdentifier:@"goToReviewList" sender:self];
}

#pragma mark - NSLayoutManagerDelegate

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 3;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.profile) {
        return 3;
    } else {
        return 2;  // as critic page
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    
    if (self.profile) {
        NSInteger reviewCount = self.profile.numReviews;
        NSUInteger followingCount = self.profile.following.count;
        NSUInteger followerCount = self.profile.followers.count;
        
        if (section == 0) {
            numberOfRows = (followingCount > 0) ? 1 : 0;
        } else if (section == 1) {
            numberOfRows = (followerCount > 0) ? 1 : 0;
        } else {
            numberOfRows = (reviewCount < 5) ? reviewCount : 5+1;  // include load more cell
        }
    } else {  // critic
        int reviewCount = self.critic.totalReviewCount;
        if (section == 0) {
            numberOfRows = 1;
        } else {
            numberOfRows = (reviewCount < 5) ? reviewCount : 5+1;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    UITableViewCell *thisCell;
    
    NSInteger section = indexPath.section;
    
    if (self.profile && (section == 0 || section == 1)) {
        cellIdentifier = @"FollowingFollowerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        // clear
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if (section == 0) {
            [cell.contentView addSubview:self.followingScrollView];
        } else {
            [cell.contentView addSubview:self.followerScrollView];
        }
        
        thisCell = cell;
    } else if ((self.profile && section == 2) || (self.critic && section == 1)) {
        NSUInteger index = indexPath.row;
        
        if (index == 5) {
            thisCell = [CustomStyler createLoadMoreTableCell:tableView vc:self];
        } else {
            cellIdentifier = @"ReviewCell";
            ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ReviewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            Review *review;
            
            if (self.critic) {
                review = (CriticReview *)self.critic.reviews[indexPath.row];
            } else {
                review = (UserReview *)self.profile.reviews[indexPath.row];
            }
            
            // score image
            cell.scoreImageView.image = [Util runWalkDitchImage:review.score];
            
            // score label
            cell.scoreLabel.text = [Util formattedScore:review.score];
            cell.scoreLabel.textColor = [Util runWalkDitchColor:review.score];
            
            if (self.critic) {
                cell.scoreLabel.hidden = YES;
            }
            
            // publish date
            cell.publishDateLabel.text = [[Util dateToString:review.publishDate dateFormat:@"MMM. dd, yyyy"] uppercaseString];
            
            // subject label
            cell.subjectLabel.text = review.restaurant.name;
            
            // review body text
            cell.reviewBodyTextLabel.text = review.reviewText;
            
            thisCell = cell;
        }
    } else { // critic description
        cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = self.critic.summary;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        thisCell = cell;
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float rowHeight;
    
    NSInteger section = indexPath.section;
    
    if (self.profile && (section == 0 || section == 1)) {
        rowHeight = 119;
    } else if ((self.profile && section == 2) || (self.critic && section == 1)) {
        NSInteger index = indexPath.row;
        if (index == 5) {
            rowHeight = LOAD_MORE_CELL_HEIGHT;
        } else {
            rowHeight = 105;
        }
    } else {  // critic description
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:13.0];
        CGSize labelSize = [Util textSize:self.critic.summary font:cellFont width:280 height:MAXFLOAT];
        rowHeight = labelSize.height + 15;
    }
    
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    
    if (self.profile) {
        if (section == 0) {
            NSUInteger followingCount = self.profile.following.count;
            NSString *part1 = @"Following";
            NSString *part2 = [NSString stringWithFormat:@"(%lu)", (unsigned long)followingCount];
            NSAttributedString *attrStr = [CustomStyler createAttributedStringForTableHeaderView:part1 and:part2];
            view = [CustomStyler createTableHeaderView2:tableView attrStr:attrStr];
        } else if (section == 1) {
            NSUInteger followerCount = self.profile.followers.count;
            NSString *part1 = @"Followers";
            NSString *part2 = [NSString stringWithFormat:@"(%lu)", (unsigned long)followerCount];
            NSAttributedString *attrStr = [CustomStyler createAttributedStringForTableHeaderView:part1 and:part2];
            view = [CustomStyler createTableHeaderView2:tableView attrStr:attrStr];
        } else {
            NSInteger reviewCount = self.profile.numReviews;
            NSString *part1 = @"Reviews";
            NSString *part2 = [NSString stringWithFormat:@"(%ld)", (long)reviewCount];
            NSAttributedString *attrStr = [CustomStyler createAttributedStringForTableHeaderView:part1 and:part2];
            view = [CustomStyler createTableHeaderView2:tableView attrStr:attrStr];
        }
    } else {  // critic
        if (section == 0) {
            NSAttributedString *attrStr = [CustomStyler createAttributedStringForTableHeaderView:@"Description" and:@""];
            view = [CustomStyler createTableHeaderView2:tableView attrStr:attrStr];
        } else {
            int reviewCount = [self.critic.totalReviewCount intValue];
            NSString *part1 = @"Reviews";
            NSString *part2 = [NSString stringWithFormat:@"(%d)", reviewCount];
            NSAttributedString *attrStr = [CustomStyler createAttributedStringForTableHeaderView:part1 and:part2];
            view = [CustomStyler createTableHeaderView2:tableView attrStr:attrStr];
        }
    }
    
    return view;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.profile && indexPath.section == 2) || (self.critic && indexPath.section == 1)) {
        [self performSegueWithIdentifier:@"goToReviewDetail" sender:nil];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self setup];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return self.viewRefreshing;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return [NSDate date];
}

- (void)doneRefreshing {
    self.viewRefreshing = NO;
    [self.refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self updateSuccessLabel];
    
    if ([[segue identifier] isEqualToString:@"goToProfileEdit"]) {
        UINavigationController *nc = segue.destinationViewController;
        ProfileEditViewController *profileEditVC = (ProfileEditViewController *)nc.viewControllers[0];
        profileEditVC.delegate = self;
        if (self.editProfile) {
            profileEditVC.forceEdit = YES;
        }
    }
    
    if ([[segue identifier] isEqualToString:@"goToReviewList"]) {
        ReviewListViewController *reviewListVC = (ReviewListViewController *)segue.destinationViewController;
        if (self.critic) {
            reviewListVC.critic = self.critic;
        } else {
            reviewListVC.profile = self.profile;
        }
    }
    
    if ([[segue identifier] isEqualToString:@"goToReviewDetail"]) {
        NSInteger selectedRow = self.tableView.indexPathForSelectedRow.row;
        
        ReviewDetailViewController *reviewDetailVC = (ReviewDetailViewController *)segue.destinationViewController;
        if (self.profile) {
            reviewDetailVC.review = self.profile.reviews[selectedRow];
            ((UserReview *)reviewDetailVC.review).user = self.profile;
        } else if (self.critic) {
            reviewDetailVC.review = self.critic.reviews[selectedRow];
            ((CriticReview *)reviewDetailVC.review).critic = self.critic;
        }
    }
}

@end
