//
//  BlackbookViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "BlackbookViewController.h"
#import "User.h"
#import "RestaurantViewController.h"
#import "BlackbookRestaurantAddCell.h"

@interface BlackbookViewController ()
    @property (strong, nonatomic) NSString *blackbookName;

    @property (strong, nonatomic) IBOutlet UITableView *tableView;

    @property (strong, nonatomic) NSString *blackbookId;
    @property (strong, nonatomic) NSMutableArray *restaurants;

    @property (strong, nonatomic) UITextField *addRestaurantTextField;

    @property (nonatomic) BOOL alreadyLoaded;

    // refresh view
    @property (strong, nonatomic) EGORefreshTableHeaderView *refreshView;
    @property (nonatomic) BOOL viewRefreshing;

    // login button detail
    @property (strong, nonatomic) NSString *loginButtonDetail;

    // autocomplete
    @property (strong, nonatomic) IBOutlet UITableView *autocompleteTableView;
    @property (strong, nonatomic) IBOutlet UIView *autocompleteBackLayer;
    @property (strong, nonatomic) NSMutableArray *autocompleteResults;
@end

@implementation BlackbookViewController


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // restaurants
        self.restaurants = [[NSMutableArray alloc] init];
        
        // blackbook name
        self.blackbookName = @"iOS Blackbook List";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.sectionIndexColor = [Util colorFromHex:@"f26c4f"];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    self.alreadyLoaded = NO;
    
    self.loginButtonDetail = @"blackbook a restaurant";
    
    // add tap gesture recognizer so tapping on tableview dismisses keyboard
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGR.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGR];
    
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
    
    [appDelegate.tracker set:kGAIScreenName value:@"Blackbook"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)setup {
    // Show login if not logged in.
    if (!appDelegate.loggedInUser) {
        [appDelegate removeLoadingScreen:self];
        [appDelegate showNotLoggedInScreen:self loginButtonDetail:self.loginButtonDetail];
        return;
    }
    
//    if (!self.alreadyLoaded) {
        [appDelegate removeNotLoggedInScreen];
        [appDelegate showLoadingScreen:self.view];
        [self loadBlackbooks];
//    }
}

- (void)loadBlackbooks {
    NSString *url = [NSString stringWithFormat:@"%@/blackbook/", API_URL_PREFIX];
    NSDictionary *params = @{@"user": appDelegate.loggedInUser.username };
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        // clear blackbook restaurants
        [self.restaurants removeAllObjects];
        
        // iterate over blackbooks to find ios blackbook list
        for (id blackbook in JSON) {
            // add restaurants from ios blackbook list
            if ([blackbook[@"title"] isEqualToString:self.blackbookName]) {
                for (id entry in blackbook[@"entries"]) {
                    self.blackbookId = blackbook[@"id"];
                    [self.restaurants addObject:entry];
                }
                break;
            }
        }
        
        // sort restaurants by name
        [self.restaurants sortUsingFunction:compareBlackbookItems context:NULL];
        
//        DDLogInfo(@"%@", self.restaurants);
        
        // reload table
        [self.tableView reloadData];
        [appDelegate removeLoadingScreen:self];
        self.alreadyLoaded = YES;
        
        // signal to refresh view
        [self doneRefreshing];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.autocompleteTableView) {
        return 1;
    } else {
        return 1 + self.restaurants.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.autocompleteTableView) {
        return self.autocompleteResults.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    UITableViewCell *thisCell;
    
    if (tableView == self.autocompleteTableView) {
        cellIdentifier = @"AutocompleteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = [self.autocompleteResults objectAtIndex:indexPath.row][@"name"];
        cell.tag = 2;
        [CustomStyler styleOptionCell:cell];
        
        thisCell = cell;
    } else {
        if (indexPath.section == 0) {
            cellIdentifier = @"AddCell";
            BlackbookRestaurantAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[BlackbookRestaurantAddCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            self.addRestaurantTextField = cell.textField;
            self.addRestaurantTextField.delegate = self;
            
            [self.addRestaurantTextField addTarget:self
                                            action:@selector(textFieldDidChange:)
                                  forControlEvents:UIControlEventEditingChanged];
            
            thisCell = cell;
        } else {
            cellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.text = self.restaurants[indexPath.section-1][@"name"];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
            cell.textLabel.textColor = [UIColor blackColor];
            
            thisCell = cell;
        }
        thisCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return thisCell;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    if (tableView == self.autocompleteTableView) {
//        return nil;
//    }
//    
//    NSMutableArray *titles = [[NSMutableArray alloc] init];
//    for (char a = 'A'; a <= 'Z'; a++) {
//        [titles addObject:[NSString stringWithFormat:@"%c", a]];
//    }
//    [titles addObject:@"#"];
//    
//    return titles;
//}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    if (tableView == self.autocompleteTableView) {
//        return 0;
//    }
//    
//    NSString *pattern;
//    if ([title isEqualToString:@"#"]) {
//        pattern = [NSString stringWithFormat:@"name MATCHES \"^[0-9].*\""];
//    } else {
//        pattern = [NSString stringWithFormat:@"name beginswith[c] \"%@\"", title];
//    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:pattern];
//    NSArray *matches = [self.restaurants filteredArrayUsingPredicate:predicate];
//    
//    return 1 + [self.restaurants indexOfObject:[matches firstObject]];
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.autocompleteTableView) {
        return NO;
    }
    
    if (indexPath.section == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.autocompleteTableView) {
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *entryToDelete = self.restaurants[indexPath.section - 1];
        [self deleteBlackbookEntry:entryToDelete];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.autocompleteTableView) {
        return 34;
    } else {
        return 44;
    }
}

//- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self inEditMode:YES];
//}
//
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self inEditMode:NO];
//}
//
//- (void)inEditMode:(BOOL)inEditMode {
//    if (inEditMode) { // hide index while in edit mode
//        self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
//    } else {
//        self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMin;
//    }
//    [self.tableView reloadSectionIndexTitles];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.autocompleteTableView) {
        NSString *restaurantURI = self.autocompleteResults[indexPath.row][@"api_uri"];
        NSArray *restaurantURIParts = [restaurantURI componentsSeparatedByString:@"/"];
        NSString *restaurantSlug = restaurantURIParts[restaurantURIParts.count-2];
        
        [self addBlackbookEntry:restaurantSlug];
        self.addRestaurantTextField.text = @"";
        [self resetAddRestaurant];
    } else {
        if (indexPath.section != 0) {
            [self performSegueWithIdentifier:@"goToRestaurant" sender:self];
        }
    }
}

#pragma mark - Get blackbook id

- (void)getBlackbookId:(void (^)(id result, NSError *error))block {
    NSString *url = [NSString stringWithFormat:@"%@/blackbook/", API_URL_PREFIX];
    NSDictionary *params = @{ @"user": appDelegate.loggedInUser.username };
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *blackbookId;
        
        // iterate over blackbooks to find ios blackbook list
        for (id blackbook in JSON) {
            // add restaurants from ios blackbook list
            if ([blackbook[@"title"] isEqualToString:self.blackbookName]) {
                blackbookId = blackbook[@"id"];
//                DDLogInfo(@"got blackbook id: %@", blackbookId);
                break;
            }
        }
        block(blackbookId, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        block(nil, error);
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Create blackbook

- (void)createBlackbook:(void (^)(id result, NSError *error))block {
    NSString *url = [NSString stringWithFormat: @"%@/blackbook/", API_URL_PREFIX];
    NSDictionary *params = @{@"title": self.blackbookName};
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *blackbookId = JSON[@"id"];
//        DDLogInfo(@"created blackbook with id: %@", blackbookId);
        block(blackbookId, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        block(nil, error);
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Add blackbook entry
- (void)addBlackbookEntry:(NSString *)restaurantSlug {
    // get the blackbook id
    [self getBlackbookId:^(id blackbookId, NSError *error) {
        // if blackbook doesn't exist, create it and then add to it
        if (!blackbookId) {
            self.blackbookId = nil;
            
            [self createBlackbook:^(id newBlackbookId, NSError *error) {
                self.blackbookId = newBlackbookId;
                [self _addBlackbookEntry:restaurantSlug];
            }];
        } else { // otherwise just add to existing blackbook
            self.blackbookId = blackbookId;
            [self _addBlackbookEntry:restaurantSlug];
        }
    }];
}

- (void)_addBlackbookEntry:(NSString *)restaurantSlug {
    NSString *url = [NSString stringWithFormat:@"%@/blackbook/%@/entries/", API_URL_PREFIX, self.blackbookId];
    NSDictionary *params = @{
                             @"entry": @"Added from restaurant page",
                             @"restaurant": [NSString stringWithFormat:@"/api/1/restaurants/%@/", restaurantSlug]
                             };
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id entry = JSON;
        [self.restaurants addObject:entry];
        [self.restaurants sortUsingFunction:compareBlackbookItems context:NULL];
        [self.tableView reloadData];
        
//        DDLogInfo(@"added restaurant to blackbook");
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if ([JSON[@"message"] rangeOfString:@"already in list"].location == NSNotFound) {
            [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
        }
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Delete blackbook entry

- (void)deleteBlackbookEntry:(NSDictionary *)blackbookEntry {
    NSString *entryId = blackbookEntry[@"id"];
    
    NSString *url = [NSString stringWithFormat: @"%@/blackbook/%@/entries/%@/", API_URL_PREFIX, self.blackbookId, entryId];
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"DELETE" path:url parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.restaurants removeObject:blackbookEntry];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util showNetworkingErrorAlert:operation.response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Autocomplete

- (void)updateAutocompleteSuggestions:(NSString *)keyword {
    if (keyword.length <= 1) {
        [self removeAutocompleteResults];
        return;
    }
    
    NSString *url = [NSString stringWithFormat: @"%@/%@/restaurant-autocomplete",
                     SITE_DOMAIN, API_URL_PREFIX_PARTIAL];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:keyword forKey:@"s"];
    [params setValue:@"all" forKey:@"city"];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:params];
//    DDLogInfo(@"%@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.autocompleteResults = [JSON mutableCopy];
        [self.autocompleteTableView reloadData];
        if (self.autocompleteResults.count > 0) {
            self.autocompleteTableView.hidden = NO;
        } else {
            self.autocompleteTableView.hidden = YES;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)removeAutocompleteResults {
    [self.autocompleteResults removeAllObjects];
    [self.autocompleteTableView reloadData];
    self.autocompleteTableView.hidden = YES;
}

- (void)hideAutocomplete {
    self.autocompleteBackLayer.hidden = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // change placeholder color
    [self.addRestaurantTextField setValue:[Util colorFromHex:@"b5b5b5"] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self removeAutocompleteResults];
//    self.autocompleteBackLayer.hidden = NO;
}

- (IBAction)textFieldDidChange:(UITextField *)textField {
    [self updateAutocompleteSuggestions:textField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self resetAddRestaurant];
}

#pragma mark - Compare blackbook items

NSInteger compareBlackbookItems(id obj1, id obj2, void *context) {
    return [obj1[@"name"] compare:obj2[@"name"]];
}

#pragma mark - Dismiss keyboard

- (IBAction)dismissKeyboard:(id)sender {
    [self resetAddRestaurant];
}

#pragma mark - touchesEnded

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resetAddRestaurant];
}

- (void)resetAddRestaurant {
    [self.addRestaurantTextField setValue:[Util colorFromHex:@"f26c4f"] forKeyPath:@"_placeholderLabel.textColor"];
    [self hideAutocomplete];
    [self.view endEditing:YES];
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self loadBlackbooks];
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToRestaurant"]) {
        // get selected restaurant
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        id restaurantObject = self.restaurants[selectedIndexPath.section - 1];
        NSString *restaurantSlug = restaurantObject[@"slug"];
        
        RestaurantViewController *vc = (RestaurantViewController *)segue.destinationViewController;
        vc.restaurantId = restaurantSlug;
    }
}

@end
