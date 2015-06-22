//
//  SearchViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchFilters.h"
#import "Neighborhood.h"
#import "Cuisine.h"
#import "Occasion.h"
#import "Price.h"
#import "SearchResultCell.h"
#import "Restaurant.h"
#import "RestaurantViewController.h"
#import "CustomAnnotationView.h"
#import "CustomSegmentedControl.h"

@interface SearchViewController ()
    @property (strong, nonatomic) NSString *currentViewMode;

    // search bars
    @property (strong, nonatomic) UISearchBar *searchBar;
    @property (strong, nonatomic) UISearchBar *keywordSearchBar;
    @property (strong, nonatomic) UISearchBar *locationSearchBar;

    // sort filter
    @property (weak, nonatomic) IBOutlet CustomSegmentedControl *sortBySegmentedControl;

    // autocomplete
    @property (strong, nonatomic) IBOutlet UITableView *autocompleteTableView;
    @property (strong, nonatomic) IBOutlet UIView *autocompleteBackLayer;
    @property (strong, nonatomic) NSMutableArray *autocompleteResults;

    // list/map
    @property (weak, nonatomic) IBOutlet UITableView *listView;
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;

    // help view
    @property (weak, nonatomic) IBOutlet UIView *helpView;
    @property (weak, nonatomic) IBOutlet UIImageView *initialImageView;
    @property (weak, nonatomic) IBOutlet UIView *noResultsView;

    @property (strong, nonatomic) SearchFilters *searchFilters;

    // search results
    @property (strong, nonatomic) NSMutableArray *searchResults;
    @property (strong, nonatomic) NSNumber *numSearchResults;
    @property (strong, nonatomic) NSNumber *pageNumber;

    // data structure to keep track of data to plot on map
    @property (strong, nonatomic) NSMutableDictionary *nameRestaurantMapping;

    // browse more
    @property (strong, nonatomic) UITableViewCell *loadMoreTableCell;

    // friend sort login redirect
    @property (nonatomic) BOOL redirectedToLoginForFriendSort;
@end

@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // initialize search stuff
    self.searchFilters = [[SearchFilters alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    self.pageNumber = @1;
    
    self.nameRestaurantMapping = [[NSMutableDictionary alloc] init];
    
    self.currentViewMode = @"list";
    
    // keyword search bar
    self.keywordSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.keywordSearchBar.text = @"";
    self.keywordSearchBar.placeholder = @"Keyword";
    self.keywordSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.keywordSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keywordSearchBar.delegate = self;
    [CustomStyler customizeSearchBar:self.keywordSearchBar];
    [self.view addSubview:self.keywordSearchBar];
    
    // location search bar
    self.locationSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
    self.locationSearchBar.placeholder = @"Neighborhood";
    self.locationSearchBar.delegate = self;
    [CustomStyler customizeSearchBar:self.locationSearchBar];
    [self.view addSubview:self.locationSearchBar];
    
    // autocomplete
    self.autocompleteResults = [[NSMutableArray alloc] init];
    
    // initialize view with inactive search
    [self showInactiveSearch];
    
    // initialize neighborhood to Current Location
    [self neighborhoodSelected:[Neighborhood currentLocation]];
    
    // sort by segmented control
    [self.sortBySegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [CustomStyler styleSegmentedControl:self.sortBySegmentedControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Restaurant Search Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    if (self.redirectedToLoginForFriendSort) {
        [appDelegate removeNotLoggedInScreen];
        [self sortBySelected:self.sortBySegmentedControl];
        self.redirectedToLoginForFriendSort = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.listView deselectRowAtIndexPath:[self.listView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Active/inactive search

- (void)showInactiveSearch {
    // Hide keyboard if visible.
    [self.view endEditing:YES];
    
    // Filter button.
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showFilterOptions:)];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    // Search bar.
    if (!self.searchBar) {
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 200, 22)];
        self.searchBar.placeholder = @"Search";
        self.searchBar.showsCancelButton = NO;
        self.searchBar.backgroundColor = [UIColor clearColor];
        self.searchBar.delegate = self;
    }
    self.navigationItem.titleView = self.searchBar;
    
    // List/Map button.
    UIBarButtonItem *listMapButton;
    if ([self.currentViewMode isEqualToString:@"list"]) {
        listMapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showMapView:)];
    } else {
        listMapButton = [[UIBarButtonItem alloc] initWithTitle:@"List"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(showListView:)];
    }
    self.navigationItem.rightBarButtonItem = listMapButton;
    
    // Hide search bars.
    [self hideSearchBars];
}

- (IBAction)showActiveSearch:(id)sender {
    // Cancel button.
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelSearch:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Navbar title.
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"Search";
    
    // Search button.
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(search:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    // Show search bars.
    [self showSearchBars];
}

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.pageNumber = @1;
    [self setDefaultSortBy];
    [self resetFilters];
    [self search];
}

- (IBAction)search:(id)sender {
    self.pageNumber = @1;
    [self setDefaultSortBy];
    [self resetFilters];
    [self search];
}

- (void)search {
    // remove initial help view
    self.helpView.hidden = YES;
    
    // get what's currently in keyword search bar
    self.searchFilters.keywordText = self.keywordSearchBar.text;
    
    if (self.searchFilters.selectedNeighborhood == nil) {
        self.searchFilters.selectedNeighborhood = [Neighborhood currentLocation];
    }
    [self neighborhoodSelected:self.searchFilters.selectedNeighborhood];
    
    [appDelegate overrideCity:self.searchFilters.selectedNeighborhood.city];
    
    // if this is a new search, clear search results
    if ([self.pageNumber intValue] == 1) {
        [self showInactiveSearch];
        
        // clear results
        [self clearSearchResults];
        
        if ([self.searchFilters.selectedNeighborhood isEqual:[Neighborhood currentLocation]]) {
            self.searchBar.text = [NSString stringWithFormat:@"%@", self.searchFilters.keywordText];
        } else {
            NSString *neighborhoodName = self.searchFilters.selectedNeighborhood.name;
            if ([neighborhoodName isEqualToString:@"All"]) {
                neighborhoodName = self.searchFilters.selectedNeighborhood.parentName;
            }
            self.searchBar.text = [NSString stringWithFormat:@"%@ near %@",
                                   self.searchFilters.keywordText, neighborhoodName];
        }
    }
    
    // params
    NSMutableDictionary *params = [self setAndReturnParams];
    NSString *paramString = [Util generateParamString:params];
    
    DDLogInfo(@"%@", params);
    
    NSString *url = [NSString stringWithFormat: @"%@/%@/restaurant-combined-search/%@&page=%d",
                     SITE_DOMAIN, API_URL_PREFIX_PARTIAL, paramString, [self.pageNumber intValue]];
//    DDLogInfo(@"%@", url);
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        self.numSearchResults = [NSNumber numberWithInt:[JSON[@"count"] intValue]];
        
        // if no results or there are results but the backup search was used, show "sorry no results" view
        if ([self.numSearchResults intValue] == 0 || [JSON[@"backup_searched"] boolValue]) {
            self.noResultsView.hidden = NO;
            self.initialImageView.hidden = YES;
            self.helpView.hidden = NO;
        } else {
            // otherwise, gather results
            self.noResultsView.hidden = YES;
            self.initialImageView.hidden = NO;
            
            for (NSDictionary *searchResult in JSON[@"results"]) {
                Restaurant *restaurant = [[Restaurant alloc] init];
                restaurant.includeReviews = NO;
                [restaurant import:searchResult];
                [self.searchResults addObject:restaurant];
                [self addRestaurantToMap:restaurant];
            }
        }
        
        [self.listView reloadData];
        [self updateMapViewRegion];
        
        if ([self.pageNumber intValue] == 1) {
            [self.listView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
        
        [appDelegate removeLoadingScreen:self];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
    
    if ([self.pageNumber intValue] == 1) {
        [appDelegate showLoadingScreen:self.listView];
    }
}

#pragma mark - Clear/cancel search

- (void)clearSearch {
    // show initial view
    self.helpView.hidden = NO;

    // clear search bars
    [self clearSearchBars];
    
    // clear sort bar
    [self.sortBySegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];

    // clear search results
    [self clearSearchResults];

    // clear filters
    [self resetFilters];
}

- (IBAction)cancelSearch:(id)sender {
    [self showInactiveSearch];
}

- (void)clearSearchResults {
    [self.searchResults removeAllObjects];
    [self.listView reloadData];
    [self clearMapAnnotations];
    [self.nameRestaurantMapping removeAllObjects];
}

#pragma mark - Sort

- (IBAction)sortBySelected:(UISegmentedControl *)segmentedControl {
    NSString *selectededSegmentTitle = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    BOOL friendSortSelected = [selectededSegmentTitle isEqualToString:@"Friend\nScore"];
    if (friendSortSelected && !appDelegate.loggedInUser) {
        if (!self.redirectedToLoginForFriendSort) {
            self.redirectedToLoginForFriendSort = YES;
            [appDelegate showLogin:self];
        }
        return;
    }
    
    [self.searchFilters setSortBy:segmentedControl.selectedSegmentIndex];
    self.pageNumber = @1;
    [self search];
}

- (void)setDefaultSortBy {
    if ([self.searchFilters.selectedNeighborhood isEqual:[Neighborhood currentLocation]]
        || self.searchFilters.selectedNeighborhood == nil
        || self.sortBySegmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        self.sortBySegmentedControl.selectedSegmentIndex = 0;
    } else {
        self.sortBySegmentedControl.selectedSegmentIndex = 1;
    }
    [self.searchFilters setSortBy:self.sortBySegmentedControl.selectedSegmentIndex];
}

#pragma mark - Params

- (NSMutableDictionary *)setAndReturnParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // keyword
    if ([Util clean:self.searchFilters.keywordText].length > 0) {
        [params setValue:self.searchFilters.keywordText forKey:@"q"];
    }
    
    // neighborhood
    if ([self.searchFilters.selectedNeighborhood isEqual:[Neighborhood currentLocation]]) {
        // don't add explicit neighborhood param for current location
    } else if ([self.searchFilters.selectedNeighborhood.name isEqualToString:@"All"]) { // all neighborhood case
        Neighborhood *allNeighborhood = self.searchFilters.selectedNeighborhood;
        NSMutableArray *neighborhoods = [[NSMutableArray alloc] init];
        for (Neighborhood *neighborhood in [self childNeighborhoods:allNeighborhood.parentId]) {
            [neighborhoods addObject:[NSNumber numberWithInt:neighborhood.id]];
        }
        [params setValue:neighborhoods forKey:@"neighborhood"];
    } else {
        NSMutableArray *neighborhoods = [[NSMutableArray alloc] init];
        [neighborhoods addObject:[NSNumber numberWithInt:self.searchFilters.selectedNeighborhood.id]];
        [params setValue:neighborhoods forKey:@"neighborhood"];
    }
    
    // cuisine
    if (self.searchFilters.selectedCuisine) {
        [params setValue:[NSNumber numberWithInt:self.searchFilters.selectedCuisine.id] forKey:@"cuisine"];
    }
    
    // occasion
    if (self.searchFilters.selectedOccasion) {
        [params setValue:[NSNumber numberWithInt:self.searchFilters.selectedOccasion.id] forKey:@"occasion"];
    }
    
    // price
    NSMutableArray *priceIds = [[NSMutableArray alloc] init];
    for (Price *price in self.searchFilters.selectedPrices) {
        [priceIds addObject:[NSNumber numberWithInt:price.id]];
    }
    [params setValue:priceIds forKey:@"price"];
    
    // open now
    if (self.searchFilters.openNow) {
        [params setValue:@1 forKey:@"open_now"];
    }
    
    // device location
    NSString *latStr = [[NSString alloc] initWithFormat:@"%f", appDelegate.lastLocation.coordinate.latitude];
    NSString *lngStr = [[NSString alloc] initWithFormat:@"%f", appDelegate.lastLocation.coordinate.longitude];
    
    if (latStr && lngStr) {
        [params setValue:latStr forKey:@"lat"];
        [params setValue:lngStr forKey:@"lng"];
    }
    
    // city
    [params setValue:[Util encodeString:appDelegate.cachedData.nearestCity] forKey:@"city"];
    
    // distance
    if (self.searchFilters.selectedDistance) {
        [params setValue:self.searchFilters.selectedDistance forKey:@"distance_in_miles"];
    }
    
    // sort by
    NSMutableArray *sorts = [[NSMutableArray alloc] init];
    [sorts addObject:self.searchFilters.selectedSortBy];
    if (![self.searchFilters.selectedSortBy isEqualToString:@"distance_in_miles"]) {
        [sorts addObject:@"distance_in_miles"];
    }
    [params setValue:sorts forKey:@"sort"];
    
    return params;
}

#pragma mark - Neighborhoods

- (NSMutableArray *)childNeighborhoods:(int)parentNeighborhoodId {
    NSMutableArray *neighborhoods = [[NSMutableArray alloc] init];
    
    Neighborhood *parentNeighborhood = [[Neighborhood alloc] initWithId:parentNeighborhoodId name:nil];
    
    // add parent neighborhood
//    [neighborhoods addObject:parentNeighborhood];
    
    for (Neighborhood *neighborhood in appDelegate.cachedData.neighborhoodData[parentNeighborhood]) {
        // don't include the 'All' neighborhood
        if ([neighborhood.name isEqualToString:@"All"]) {
            continue;
        }
        
        // add child neighborhood
        [neighborhoods addObject:neighborhood];
        
        // if child is also a parent, recurse
        if (appDelegate.cachedData.neighborhoodData[neighborhood]) {
            [neighborhoods addObjectsFromArray:[self childNeighborhoods:neighborhood.id]];
        }
    }
    
    // remove duplicates
    [neighborhoods setArray:[[NSSet setWithArray:neighborhoods] allObjects]];
    
    return neighborhoods;
}

#pragma mark - Autocomplete

- (void)updateAutocompleteSuggestions:(NSString *)keyword {
    if (keyword.length <= 1) {
        [self removeAutocompleteResults];
        return;
    }
    
    NSString *url = [NSString stringWithFormat: @"%@/%@/search-autocomplete",
                     SITE_DOMAIN, API_URL_PREFIX_PARTIAL];
    
    NSString *city;
    if ([self.searchFilters.selectedNeighborhood isEqual:[Neighborhood currentLocation]]) {
        city = appDelegate.cachedData.supportedCities[appDelegate.lastCurrentLocationCity][@"name"];
    } else {
        city = appDelegate.cachedData.supportedCities[self.searchFilters.selectedNeighborhood.city][@"name"];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.keywordSearchBar.text forKey:@"s"];
    [params setValue:city forKey:@"city"];
    
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

#pragma mark - Filters

- (IBAction)showFilterOptions:(id)sender {
    if (self.searchResults.count == 1) {
        self.searchFilters.keywordText = nil;
        self.keywordSearchBar.text = @"";
    }
    [self performSegueWithIdentifier:@"goToSearchFilter" sender:self];
}

- (void)filter:(SearchFilters *)searchFilters {
    self.searchFilters = searchFilters;
    self.pageNumber = @1;
    [self setDefaultSortBy];
    [self search];
}

- (void)resetFilters {
    NSString *savedKeywordText = self.searchFilters.keywordText;
    Neighborhood *savedNeighborhood = self.searchFilters.selectedNeighborhood;
    self.searchFilters = [[SearchFilters alloc] init];
    self.searchFilters.keywordText = savedKeywordText;
    self.searchFilters.selectedNeighborhood = savedNeighborhood;
    [self.searchFilters setSortBy:self.sortBySegmentedControl.selectedSegmentIndex];
}

#pragma mark - Mapview

- (void)addRestaurantToMap:(Restaurant *)restaurant {
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    marker.coordinate = restaurant.location.coordinate;
    marker.title = restaurant.name;
    [self.mapView addAnnotation:marker];
    
    [self.nameRestaurantMapping setObject:restaurant forKey:restaurant.name];
}

- (void)clearMapAnnotations {
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    [self.mapView removeAnnotations:pins];
}

- (void)updateMapViewRegion {
    CLLocationCoordinate2D zoomLocation;
    
    if (self.searchResults.count > 0) {
        Restaurant *restaurantResult = self.searchResults[self.searchResults.count/2];
        zoomLocation = restaurantResult.location.coordinate;
    } else {
        zoomLocation = CLLocationCoordinate2DMake(appDelegate.lastLocation.coordinate.latitude,
                                                  appDelegate.lastLocation.coordinate.longitude);
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2*METERS_PER_MILE, 2*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion];
}

- (CustomAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    
    CustomAnnotationView *annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.image = [UIImage imageNamed:@"map-pin"];
    
    // add restaurant
    Restaurant *restaurant = [self.nameRestaurantMapping objectForKey:annotation.title];
    annotationView.restaurant = restaurant;
    
    // add index
    NSUInteger index = [self.searchResults indexOfObject:restaurant] + 1;
    annotationView.index = index;
    [annotationView addIndexLabel];
    
//    DDLogInfo(@"%d: %@", index, restaurant.name);
    
    // create custom callout
    [annotationView createCallout];
    
    // callout tap gesture recognizer
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToRestaurant:)];
    tapGR.delegate = self;
    [annotationView.callout addGestureRecognizer:tapGR];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (![view.annotation isKindOfClass:MKUserLocation.class]) {
        // adjust map
        CustomAnnotationView *annotationView = (CustomAnnotationView *)view;
        Restaurant *restaurant = annotationView.restaurant;
        
        CLLocationCoordinate2D coordinate = restaurant.location.coordinate;
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(coordinate))) {
            self.mapView.centerCoordinate = coordinate;
        }
    }
}

// NO LONGER USED
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Restaurant *restaurant = [self.nameRestaurantMapping objectForKey:view.annotation.title];
    [self performSegueWithIdentifier:@"goToRestaurant" sender:restaurant];
}

- (IBAction)goToRestaurant:(id)sender {
    UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
    CustomAnnotationView *annotationView = (CustomAnnotationView *)tapGR.view.superview;
    Restaurant *restaurant = annotationView.restaurant;
    [self performSegueWithIdentifier:@"goToRestaurant" sender:restaurant];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Toggle list/mapview

- (IBAction)showMapView:(id)sender {
    self.currentViewMode = @"map";
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithTitle:@"List"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showListView:)];
    self.navigationItem.rightBarButtonItem = listButton;
    
    self.listView.hidden = YES;
    self.mapView.hidden = NO;
}

- (IBAction)showListView:(id)sender {
    self.currentViewMode = @"list";
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showMapView:)];
    self.navigationItem.rightBarButtonItem = mapButton;
    
    self.mapView.hidden = YES;
    self.listView.hidden = NO;
}

#pragma mark - Search bars

- (void)showSearchBars {
    self.keywordSearchBar.hidden = NO;
    self.locationSearchBar.hidden = NO;
    self.autocompleteBackLayer.hidden = NO;
    
    [self.keywordSearchBar becomeFirstResponder];
    
    [CustomStyler setSearchBarIcon:self.locationSearchBar];
}

- (void)hideSearchBars {
    self.keywordSearchBar.hidden = YES;
    self.locationSearchBar.hidden = YES;
    self.autocompleteTableView.hidden = YES;
    self.autocompleteBackLayer.hidden = YES;
}

- (void)clearSearchBars {
    self.searchBar.text = @"";
    self.keywordSearchBar.text = @"";
    [self neighborhoodSelected:[Neighborhood currentLocation]];
}

- (void)updateSearchBars {
    UITextField *searchTextField = [self.searchBar valueForKey:@"_searchField"];
    searchTextField.clearButtonMode = UITextFieldViewModeNever;
    [CustomStyler customizeLocationSearchBar:self.locationSearchBar neighborhood:self.searchFilters.selectedNeighborhood];
}

- (void)neighborhoodSelected:(Neighborhood *)neighborhood {
    self.searchFilters.selectedNeighborhood = neighborhood;
    
    if ([neighborhood.name isEqualToString:@"All"]) {
        self.locationSearchBar.text = neighborhood.parentName;
    } else {
        self.locationSearchBar.text = neighborhood.name;
    }
    [self updateSearchBars];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
        [self showActiveSearch:nil];
        return NO;
    }
    
    if (searchBar == self.locationSearchBar) {
        [self.locationSearchBar resignFirstResponder];
        [self performSegueWithIdentifier:@"goToNeighborhoodFilter" sender:self];
        return NO;
    }
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == self.keywordSearchBar) {
        [self removeAutocompleteResults];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self updateSearchBars];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == self.keywordSearchBar) {
        [self updateAutocompleteSuggestions:self.keywordSearchBar.text];
    }
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
        NSUInteger index = indexPath.row;
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
            
            [CustomStyler addSearchResultIndexView:cell.restaurantImageView index:(indexPath.row+1)];
            
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
            UIImage *reviewScoreImage;
            if ([self.searchFilters.selectedSortBy isEqualToString:@"-savants_say"]) {
                reviewScoreImage = [Util runWalkDitchImage:restaurant.userScore];
            } else if ([self.searchFilters.selectedSortBy isEqualToString:@"-friends_say"]) {
                reviewScoreImage = [Util runWalkDitchImage:restaurant.friendScore];
            } else {
                reviewScoreImage = [Util runWalkDitchImage:restaurant.criticScore];
            }
            cell.reviewScoreImageView.image = reviewScoreImage;
            
            thisCell = cell;
        }
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.listView) {
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
    if (tableView == self.listView) {
        return TABLE_HEADER_HEIGHT;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.listView) {
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
    if (tableView == self.autocompleteTableView) {
        NSString *selectedSuggestion = [self.autocompleteResults objectAtIndex:indexPath.row];
        self.keywordSearchBar.text = selectedSuggestion;
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self showInactiveSearch];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToSearchFilter"]) {
        UINavigationController *nvc = segue.destinationViewController;
        SearchFiltersViewController *vc = (SearchFiltersViewController *)nvc.viewControllers[0];
        vc.searchFilters = self.searchFilters;
        vc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"goToNeighborhoodFilter"]) {
        UINavigationController *nvc = segue.destinationViewController;
        NeighborhoodFilterViewController *vc = (NeighborhoodFilterViewController *)nvc.viewControllers[0];
        vc.delegate = self;
        vc.referrer = @"search";
    }
    
    if ([[segue identifier] isEqualToString:@"goToRestaurant"]) {
        [self showInactiveSearch];
        
        Restaurant *selectedRestaurant;
        
        if ([sender isKindOfClass:[Restaurant class]]) {
            selectedRestaurant = (Restaurant *)sender;
        } else {
            NSIndexPath *indexPath = [self.listView indexPathForCell:(SearchResultCell *)sender];
            selectedRestaurant = (Restaurant *)[self.searchResults objectAtIndex:indexPath.row];
        }
        
        RestaurantViewController *vc = (RestaurantViewController *)segue.destinationViewController;
        vc.restaurantId = selectedRestaurant.slug;
    }
}

@end
