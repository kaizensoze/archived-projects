//
//  ReviewViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "ReviewViewController.h"
#import "ReviewFormViewController.h"
#import "SearchResultCell.h"
#import "Restaurant.h"
#import "Neighborhood.h"
#import "Cuisine.h"

@interface ReviewViewController ()
    @property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

    // no results label
    @property (weak, nonatomic) IBOutlet UIView *noResultsView;

    // search results
    @property (strong, nonatomic) IBOutlet UITableView *searchResultsTableView;
    @property (strong, nonatomic) NSMutableArray *searchResults;
    @property (strong, nonatomic) NSNumber *numSearchResults;
    @property (strong, nonatomic) NSNumber *pageNumber;

    // autocomplete
    @property (strong, nonatomic) IBOutlet UITableView *autocompleteTableView;
    @property (strong, nonatomic) IBOutlet UIView *autocompleteBackLayer;
    @property (strong, nonatomic) NSMutableArray *autocompleteResults;

    // load more button
    @property (strong, nonatomic) UITableViewCell *loadMoreTableCell;

    @property (nonatomic) BOOL userClearedText;
@end

@implementation ReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // search bar
    [CustomStyler customizeSearchBar:self.searchBar];
    
    // search results
    self.searchResults = [[NSMutableArray alloc] init];
    self.pageNumber = @1;
    
    // autocomplete
    self.autocompleteResults = [[NSMutableArray alloc] init];
    
    [self search];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Review Search Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.searchResultsTableView deselectRowAtIndexPath:[self.searchResultsTableView indexPathForSelectedRow]
                                               animated:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showLogin:(id)sender {
    [appDelegate showLogin:self];
}

#pragma mark - Search

- (void)search {
    self.noResultsView.hidden = YES;
    
    [self hideAutocomplete];
    
    // if this is a new search, clear search results
    if ([self.pageNumber intValue] == 1) {
        [self.searchResults removeAllObjects];
        [self.searchResultsTableView reloadData];
    }
    
    // params
    NSMutableDictionary *params = [self setAndReturnParams];
    NSString *paramString = [Util generateParamString:params];
    
    NSString *url = [NSString stringWithFormat: @"%@/%@/restaurant-combined-search/%@&page=%d",
                     SITE_DOMAIN, API_URL_PREFIX_PARTIAL, paramString, [self.pageNumber intValue]];
//    DDLogInfo(@"%@", url);
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        self.numSearchResults = [NSNumber numberWithInt:[JSON[@"count"] intValue]];
        
        if ([self.numSearchResults intValue] == 0 || [JSON[@"backup_searched"] boolValue]) {
            self.noResultsView.hidden = NO;
        } else {
            self.noResultsView.hidden = YES;
            
            for (NSDictionary *searchResult in JSON[@"results"]) {
                Restaurant *restaurant = [[Restaurant alloc] init];
                restaurant.includeReviews = NO;
                [restaurant import:searchResult];
                [self.searchResults addObject:restaurant];
            }
        }
        
//        DDLogInfo(@"RESULTS: %d", [JSON[@"count"] intValue]);
        
        [self.searchResultsTableView reloadData];
        
        if ([self.pageNumber intValue] == 1) {
            [self.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
        
        [appDelegate removeLoadingScreen:self];
        self.userClearedText = NO;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
    if ([self.pageNumber intValue] == 1) {
        [appDelegate showLoadingScreen:self.searchResultsTableView];
    }
}

#pragma mark - Params

- (NSMutableDictionary *)setAndReturnParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if ([Util clean:self.searchBar.text].length > 0) {
        [params setValue:self.searchBar.text forKey:@"q"];
    }
    
    // location
    NSString *latStr = [[NSString alloc] initWithFormat:@"%f", appDelegate.lastLocation.coordinate.latitude];
    NSString *lngStr = [[NSString alloc] initWithFormat:@"%f", appDelegate.lastLocation.coordinate.longitude];
    [params setValue:latStr forKey:@"lat"];
    [params setValue:lngStr forKey:@"lng"];
    
    // city
    [params setValue:[Util encodeString:appDelegate.cachedData.nearestCity] forKey:@"city"];
    
    // distance
    [params setValue:@"distance_in_miles" forKey:@"sort"];
    
    return params;
}

#pragma mark - Autocomplete

- (void)updateAutocompleteSuggestions:(NSString *)keyword {
    if (keyword.length <= 1) {
        [self removeAutocompleteResults];
        return;
    }
    
    NSString *url = [NSString stringWithFormat: @"%@/%@/search-autocomplete",
                     SITE_DOMAIN, API_URL_PREFIX_PARTIAL];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.searchBar.text forKey:@"s"];
    [params setValue:appDelegate.cachedData.nearestCity forKey:@"city"];
    
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

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self removeAutocompleteResults];
    self.autocompleteBackLayer.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateAutocompleteSuggestions:searchText];
    
    // user cleared text
    if(![searchBar isFirstResponder]) {
        self.userClearedText = YES;
        [self search];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return !self.userClearedText;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.pageNumber = @1;
    [self search];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.autocompleteTableView) {
        return self.autocompleteResults.count;
    } else {
        if (self.searchResults.count < [self.numSearchResults intValue]) {
            return self.searchResults.count + 1;
        } else {
            return self.searchResults.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    UITableViewCell *thisCell;
    
    if (tableView == self.autocompleteTableView) {
        cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = [self.autocompleteResults objectAtIndex:indexPath.row];
        cell.tag = 2;
        [CustomStyler styleOptionCell:cell];
        
        thisCell = cell;
    } else {
        NSInteger index = indexPath.row;
        if (index == self.searchResults.count) {
            if (!self.loadMoreTableCell) {
                self.loadMoreTableCell = [CustomStyler createLoadMoreTableCell:tableView vc:self];
            }
            thisCell = self.loadMoreTableCell;
        } else {
            cellIdentifier = @"SearchResultCell";
            SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[SearchResultCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            Restaurant *restaurant = self.searchResults[indexPath.row];
            
            // restaurant image
            NSURL *imageURL = [NSURL URLWithString:restaurant.imageURL];
            
            if (imageURL) {
                [cell.restaurantImageView setImageWithURL:imageURL
                                         placeholderImage:nil];
            } else {
                cell.restaurantImageView.image = [UIImage imageNamed:@"restaurant-placeholder.png"];
            }
            
            [CustomStyler addSearchResultIndexView:cell.restaurantImageView index:(index+1)];
            
            // name
            cell.nameLabel.text = restaurant.name;
            
            // price and cuisine
            cell.priceAndCuisineLabel.text = @"";
            if (restaurant.cuisines.count > 0) {
                cell.priceAndCuisineLabel.text = [NSString stringWithFormat:@"%@ | %@",
                                                  restaurant.price,
                                                  ((Cuisine *)restaurant.cuisines[0]).name];
            }
            
            // address
            cell.addressLabel.text = @"";
            if (restaurant.neighborhoods.count > 0) {
                cell.addressLabel.text = [NSString stringWithFormat:@"%@, %@",
                                          restaurant.address,
                                          ((Neighborhood *)restaurant.neighborhoods[0]).name];
            }
            
            // distance
            cell.distanceLabel.text = @"";
            if (restaurant.distance) {
                cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", [restaurant.distance floatValue]];
            }
            
            // review score image
            cell.reviewScoreImageView.image = [Util runWalkDitchImage:restaurant.criticScore];
            
            thisCell = cell;
        }
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchResultsTableView) {
        NSUInteger index = indexPath.row;
        if (index < self.searchResults.count) {
            return 80;
        } else {
            return LOAD_MORE_CELL_HEIGHT;
        }
    } else if (tableView == self.autocompleteTableView) {
        return 34;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchResultsTableView) {
        return TABLE_HEADER_HEIGHT;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchResultsTableView) {
        NSString *text;
        if (self.searchResults.count > 0) {
            text = [NSString stringWithFormat:@"%lu of %d results",
                    (unsigned long)self.searchResults.count, [self.numSearchResults intValue]];
        } else {
            text = @"";
        }
        return [CustomStyler createTableHeaderView:tableView str:text];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchResultsTableView) {
        [self performSegueWithIdentifier:@"goToReviewForm" sender:self];
    } else {
        NSString *selectedSuggestion = [self.autocompleteResults objectAtIndex:indexPath.row];
        self.searchBar.text = selectedSuggestion;
        self.autocompleteTableView.hidden = YES;
    }
}

#pragma mark - Load more

- (IBAction)loadMore:(id)sender {
    // show spinner
    [CustomStyler showLoadMoreSpinner:self.loadMoreTableCell];
    self.loadMoreTableCell = nil;
    
    self.pageNumber = [NSNumber numberWithInt:[self.pageNumber intValue] + 1];
    [self search];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    [mailVC setToRecipients:@[@"admin@tastesavant.com"]];
    [mailVC setSubject:@"Restaurant Suggestion for Taste Savant"];
    mailVC.mailComposeDelegate = self;
    [self presentViewController:mailVC animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    return NO;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - touchesEnded

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideAutocomplete];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Go to profile.
    if ([[segue identifier] isEqualToString:@"goToReviewForm"]) {
        NSIndexPath *indexPath = [self.searchResultsTableView indexPathForSelectedRow];
        Restaurant *restaurant = self.searchResults[indexPath.row];
        ReviewFormViewController *vc = segue.destinationViewController;
        vc.restaurant = restaurant;
    }
}

@end
