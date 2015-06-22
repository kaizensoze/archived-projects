//
//  RestaurantViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 4/27/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "RestaurantViewController.h"
#import <MapKit/MapKit.h>
#import "RestaurantMapViewController.h"
#import "RestaurantMenuViewController.h"
#import "ReviewListViewController.h"
#import "ReviewFormViewController.h"
#import "WebViewController.h"
#import "Restaurant.h"
#import "AddressBook/AddressBook.h"
#import "BlackbookViewController.h"

#import "Review.h"

@interface RestaurantViewController ()
    @property (strong, nonatomic) Restaurant *restaurant;

    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

    @property (weak, nonatomic) IBOutlet UIView *criticsSayView;
    @property (weak, nonatomic) IBOutlet UILabel *criticsSayLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *criticScoreImageView;
    @property (weak, nonatomic) IBOutlet UILabel *criticScoreLabel;

    @property (weak, nonatomic) IBOutlet UIView *usersSayView;
    @property (weak, nonatomic) IBOutlet UILabel *usersSayLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *userScoreImageView;
    @property (weak, nonatomic) IBOutlet UILabel *userScoreLabel;

    @property (weak, nonatomic) IBOutlet UIView *friendsSayView;
    @property (weak, nonatomic) IBOutlet UILabel *friendsSayLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *friendScoreImageView;
    @property (weak, nonatomic) IBOutlet UILabel *friendScoreLabel;

    @property (weak, nonatomic) IBOutlet MKMapView *mapView;

    @property (strong, nonatomic) NSMutableArray *options;
    @property (weak, nonatomic) IBOutlet UITableView *optionsTableView;

    @property (nonatomic) BOOL alreadyLoaded;
@end

@implementation RestaurantViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.restaurantId = nil;
        self.options = [@[@"Make a reservation", @"View menu", @"Order delivery", @"Add to Blackbook", @"Review now", @"Get directions", @"Website"] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.alreadyLoaded = NO;
    
    // scroll view
    UIView *scrollViewSubview = ((UIView *)self.scrollView.subviews[0]);
    [self.scrollView setContentSize:scrollViewSubview.frame.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.alreadyLoaded) {
        [self setup];
    } else {
        // load restaurant info but don't show loading screen
        [self getRestaurantInfo];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Restaurant Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setup {
    [appDelegate showLoadingScreen:self.view];
    [self getRestaurantInfo];
}

- (void)getRestaurantInfo {
    Restaurant *restaurant = [[Restaurant alloc] init];
    restaurant.delegate = self;
    [restaurant loadFromSlug:self.restaurantId];
}

#pragma mark - RestaurantDelegate

- (void)restaurantDoneLoading:(Restaurant *)restaurant {
    self.restaurant = restaurant;
    
    if (!self.alreadyLoaded) {
        [self updateContent];
        [appDelegate removeLoadingScreen:self];
        self.alreadyLoaded = YES;
    } else {
        [self updateReviewScoreViews];
        [self updateOptions];
    }
}

#pragma mark - Update content

- (void)updateContent {
    // set title
    NSString *titleText = self.restaurant.name;
    self.navigationItem.title = titleText;
    
    // set and style restaurant info
    [CustomStyler setAndStyleRestaurantInfo:self.restaurant vc:self linkToRestaurant:NO];
    
    // review scores
    [self updateReviewScoreViews];
    
    // map view
    [CustomStyler setBorder:self.mapView width:1 color:[Util colorFromHex:@"cccccc"]];
    [CustomStyler roundCorners:self.mapView radius:3];
    
    CLLocationCoordinate2D zoomLocation = self.restaurant.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion];
    
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    marker.coordinate = zoomLocation;
    [self.mapView addAnnotation:marker];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToRestaurantMap:)];
    [self.mapView addGestureRecognizer:tapGestureRecognizer];
    
    // hide all unavailable options
    [self updateOptions];
    
    // adjust view
    [self adjustView];
}

- (void)updateOptions {
    self.options = [@[@"Make a reservation", @"View menu", @"Order delivery", @"Add to Blackbook", @"Review now", @"Get directions", @"Website"] mutableCopy];
    
    if (self.restaurant.openTableURL.length == 0) {
        [self.options removeObject:@"Make a reservation"];
    }
    
    if ([Util isEmpty:self.restaurant.menuURL]
        && !self.restaurant.hasLocalMenu) {
        [self.options removeObject:@"View menu"];
    }
    
    if (self.restaurant.seamlessMobileURL.length == 0) {
        [self.options removeObject:@"Order delivery"];
    }
    
    if (!appDelegate.loggedInUser) {
        [self.options removeObject:@"Add to Blackbook"];
    }
    
    if (self.restaurant.externalURL.length == 0) {
        [self.options removeObject:@"Website"];
    }
    
    [self.optionsTableView reloadData];
}

- (void)adjustView {
    UIView *view = ((UIView *)self.scrollView.subviews[0]);
    
    // adjust options table view
    CGRect frame = self.optionsTableView.frame;
    frame.size.height = self.optionsTableView.contentSize.height;
    self.optionsTableView.frame = frame;
    
    // adjust view
    frame = view.frame;
    frame.size.height = self.optionsTableView.frame.origin.y + self.optionsTableView.contentSize.height + 50;
    view.frame = frame;
    
    // adjust scroll view
    [self.scrollView setContentSize:view.frame.size];
}

- (void)updateReviewScoreViews {
    // critics say
    self.criticsSayLabel.backgroundColor = [Util colorFromHex:@"534741"];
    self.criticsSayLabel.textColor = [UIColor whiteColor];
    [self addBottomBorder:self.criticsSayLabel];
    
    self.criticScoreImageView.image = [Util runWalkDitchImage:self.restaurant.criticScore];
    
    self.criticScoreLabel.text = [Util formattedScore:self.restaurant.criticScore];
    self.criticScoreLabel.textColor = [Util runWalkDitchColor:self.restaurant.criticScore];
    [Util hideShowScoreLabel:self.criticScoreLabel score:self.restaurant.criticScore];
    
    [CustomStyler setBorder:self.criticsSayView width:1 color:[Util colorFromHex:@"cccccc"]];
    [CustomStyler roundCorners:self.criticsSayView radius:3];
    
    if ([self.restaurant.numCriticReviews intValue] == 0) {
        [CustomStyler setViewEnabled:self.criticsSayView enabled:NO];
    } else {
        [CustomStyler setViewEnabled:self.criticsSayView enabled:YES];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToReviewList:)];
        [self.criticsSayView addGestureRecognizer:tapGR];
    }
    
    // users say
    self.usersSayLabel.backgroundColor = [Util colorFromHex:@"534741"];
    self.usersSayLabel.textColor = [UIColor whiteColor];
    [self addBottomBorder:self.usersSayLabel];
    
    self.userScoreImageView.image = [Util runWalkDitchImage:self.restaurant.userScore];
    
    self.userScoreLabel.text = [Util formattedScore:self.restaurant.userScore];
    self.userScoreLabel.textColor = [Util runWalkDitchColor:self.restaurant.userScore];
    [Util hideShowScoreLabel:self.userScoreLabel score:self.restaurant.userScore];
    
    [CustomStyler setBorder:self.usersSayView width:1 color:[Util colorFromHex:@"cccccc"]];
    [CustomStyler roundCorners:self.usersSayView radius:3];
    
    if ([self.restaurant.numUserReviews intValue] == 0) {
        [CustomStyler setViewEnabled:self.usersSayView enabled:NO];
    } else {
        [CustomStyler setViewEnabled:self.usersSayView enabled:YES];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToReviewList:)];
        [self.usersSayView addGestureRecognizer:tapGR];
    }
    
    // friends say
    self.friendsSayLabel.backgroundColor = [Util colorFromHex:@"534741"];
    self.friendsSayLabel.textColor = [UIColor whiteColor];
    [self addBottomBorder:self.friendsSayLabel];
    
    self.friendScoreImageView.image = [Util runWalkDitchImage:self.restaurant.friendScore];
    
    self.friendScoreLabel.text = [Util formattedScore:self.restaurant.friendScore];
    self.friendScoreLabel.textColor = [Util runWalkDitchColor:self.restaurant.friendScore];
    [Util hideShowScoreLabel:self.friendScoreLabel score:self.restaurant.friendScore];
    
    [CustomStyler setBorder:self.friendsSayView width:1 color:[Util colorFromHex:@"cccccc"]];
    [CustomStyler roundCorners:self.friendsSayView radius:3];
    
    if ([self.restaurant.numFriendReviews intValue] == 0) {
        [CustomStyler setViewEnabled:self.friendsSayView enabled:NO];
    } else {
        [CustomStyler setViewEnabled:self.friendsSayView enabled:YES];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToReviewList:)];
        [self.friendsSayView addGestureRecognizer:tapGR];
    }
    
//    DDLogInfo(@"%@ %@ %@", self.restaurant.numCriticReviews, self.restaurant.numUserReviews, self.restaurant.numFriendReviews);
}

- (void)addBottomBorder:(UIView *)view {
    CALayer *layer = [view layer];
    
    CALayer *border = [CALayer layer];
    border.borderWidth = 1;
    border.borderColor = [Util colorFromHex:@"cccccc"].CGColor;
    border.frame = CGRectMake(0, view.frame.size.height-1, view.frame.size.width, 1);
    [layer addSublayer:border];
}

- (IBAction)goToRestaurantMap:(id)sender {
    [self performSegueWithIdentifier:@"goToRestaurantMap" sender:self];
}

- (IBAction)goToReviewList:(id)sender {
    UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
    [self performSegueWithIdentifier:@"goToReviewList" sender:tapGR.view];
}

#pragma mark - Get directions

- (void)getDirections {
    float srcLat = appDelegate.lastLocation.coordinate.latitude;
    float srcLong = appDelegate.lastLocation.coordinate.longitude;
    
    float destLat = self.restaurant.location.coordinate.latitude;
    float destLong = self.restaurant.location.coordinate.longitude;
    
    NSDictionary *addressDict = @{(NSString *)kABPersonAddressStreetKey: self.restaurant.address
                                  , (NSString *)kABPersonAddressCityKey: self.restaurant.city
                                  , (NSString *)kABPersonAddressStateKey: self.restaurant.state
                                  , (NSString *)kABPersonAddressZIPKey: self.restaurant.zipCode
                                  };
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(destLat, destLong);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:addressDict];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.restaurant.name;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString *googleMapsURLString = [[NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%@,%@,%@ %@&directionsmode=driving", srcLat, srcLong, self.restaurant.address, self.restaurant.city, self.restaurant.state, self.restaurant.zipCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    } else {
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RestaurantButtonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.options[indexPath.row];
    [CustomStyler styleOptionCell:cell];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *option = self.options[indexPath.row];
    
    if ([option isEqualToString:@"Make a reservation"]) {
        [self performSegueWithIdentifier:@"goToWebview" sender:selectedCell];
    } else if ([option isEqualToString:@"View menu"]) {
        if (self.restaurant.hasLocalMenu) {
            [self performSegueWithIdentifier:@"goToRestaurantMenu" sender:selectedCell];
        } else {
            [self performSegueWithIdentifier:@"goToWebview" sender:selectedCell];
        }
    } else if ([option isEqualToString:@"Order delivery"]) {
        [self performSegueWithIdentifier:@"goToWebview" sender:selectedCell];
    } else if ([option isEqualToString:@"Add to Blackbook"]) {
//        [self performSegueWithIdentifier:@"goToBlackbook" sender:selectedCell];
        
        // add restaurant to blackbook
        BlackbookViewController *vc = (BlackbookViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Blackbook"];
        [vc addBlackbookEntry:self.restaurant.slug];
        
        // show modal dialog
        NSString *message = [NSString stringWithFormat:@"%@ has been added to your blackbook.", self.restaurant.name];
        [Util showAlert:@"" message:message delegate:nil];
    } else if ([option isEqualToString:@"Review now"]) {
        [self performSegueWithIdentifier:@"goToReviewForm" sender:self];
    } else if ([option isEqualToString:@"Get directions"]) {
        [self getDirections];
    } else if ([option isEqualToString:@"Website"]) {
        [self performSegueWithIdentifier:@"goToWebview" sender:selectedCell];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Go to map view
    if ([[segue identifier] isEqualToString:@"goToRestaurantMap"]) {
        RestaurantMapViewController *vc = (RestaurantMapViewController *)segue.destinationViewController;
        vc.restaurant = self.restaurant;
    }
    
    // Go to menu view
    if ([[segue identifier] isEqualToString:@"goToRestaurantMenu"]) {
        RestaurantMenuViewController *vc = (RestaurantMenuViewController *)segue.destinationViewController;
        vc.restaurant = self.restaurant;
    }
    
    // Go to review list.
    if ([[segue identifier] isEqualToString:@"goToReviewList"]) {
        UIView *view = (UIView *)sender;
        
        ReviewListViewController *reviewListVC = (ReviewListViewController *)segue.destinationViewController;
        reviewListVC.restaurant = self.restaurant;
        if (view == self.criticsSayView) {
            reviewListVC.restaurantReviewType = @"critic";
        } else if (view == self.usersSayView) {
            reviewListVC.restaurantReviewType = @"user";
        } else {
            reviewListVC.restaurantReviewType = @"friend";
        }
    }
    
    // Go to web view.
    if ([[segue identifier] isEqualToString:@"goToWebview"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        
        WebViewController *vc = (WebViewController *)segue.destinationViewController;
        if ([cell.textLabel.text isEqualToString:@"Make a reservation"]) {
            vc.url = self.restaurant.openTableURL;
        } else if ([cell.textLabel.text isEqualToString:@"View menu"]) {
            vc.url = self.restaurant.menuURL;
        } else if ([cell.textLabel.text isEqualToString:@"Order delivery"]) {
            vc.url = self.restaurant.seamlessMobileURL;
        } else if ([cell.textLabel.text isEqualToString:@"Website"]) {
            vc.url = self.restaurant.externalURL;
        }
    }
    
    // Go to review form.
    if ([[segue identifier] isEqualToString:@"goToReviewForm"]) {
        ReviewFormViewController *vc = segue.destinationViewController;
        vc.restaurant = self.restaurant;
    }
    
    if ([[segue identifier] isEqualToString:@"goToBlackbook"]) {
        BlackbookViewController *vc = segue.destinationViewController;
        [vc addBlackbookEntry:self.restaurant.slug];
    }
}

@end
