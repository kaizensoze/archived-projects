//
//  SearchFilterViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 12/27/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "SearchFiltersViewController.h"
#import "SearchFilters.h"
#import "Cuisine.h"
#import "Price.h"
#import "Occasion.h"
#import "Neighborhood.h"

@interface SearchFiltersViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

    @property (weak, nonatomic) IBOutlet UILabel *filterResultsByLabel;

    @property (weak, nonatomic) IBOutlet UIButton *distanceButton1;
    @property (weak, nonatomic) IBOutlet UIButton *distanceButton2;
    @property (weak, nonatomic) IBOutlet UIButton *distanceButton3;
    @property (weak, nonatomic) IBOutlet UIButton *distanceButton4;
    @property (strong, nonatomic) NSMutableArray *distanceButtons;

    @property (weak, nonatomic) IBOutlet UIButton *neighborhoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *cuisineButton;

    @property (weak, nonatomic) IBOutlet UIButton *price$Button;
    @property (weak, nonatomic) IBOutlet UIButton *price$$Button;
    @property (weak, nonatomic) IBOutlet UIButton *price$$$Button;
    @property (weak, nonatomic) IBOutlet UIButton *price$$$$Button;
    @property (weak, nonatomic) IBOutlet UIButton *price$$$$$Button;
    @property (strong, nonatomic) NSMutableArray *priceButtons;

    @property (weak, nonatomic) IBOutlet UIButton *occasionButton;
    @property (weak, nonatomic) IBOutlet UIButton *openNowButton;

    @property (weak, nonatomic) IBOutlet UIButton *searchButton;
    @property (weak, nonatomic) IBOutlet UIButton *resetButton;

    @property (strong, nonatomic) Cuisine *pendingSelectedCuisine;
    @property (nonatomic) BOOL pendingOpenNow;
    @property (strong, nonatomic) Occasion *pendingSelectedOccasion;
    @property (strong, nonatomic) Neighborhood *pendingSelectedNeighborhood;
    @property (strong, nonatomic) NSMutableArray *pendingPriceRemovals;
    @property (strong, nonatomic) NSMutableArray *pendingPriceAdditions;
    @property (strong, nonatomic) NSNumber *pendingDistanceIndex;
@end

@implementation SearchFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // scroll view
    UIView *scrollViewSubview = ((UIView *)self.scrollView.subviews[0]);
    [self.scrollView setContentSize:scrollViewSubview.frame.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // filter results by label
    self.filterResultsByLabel.textColor = [Util colorFromHex:@"999999"];
    
    // distance select
    [CustomStyler customizeDistanceButton:self.distanceButton1];
    [CustomStyler customizeDistanceButton:self.distanceButton2];
    [CustomStyler customizeDistanceButton:self.distanceButton3];
    [CustomStyler customizeDistanceButton:self.distanceButton4];
    
    [CustomStyler styleSelectButton:self.distanceButton1 corners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)];
    [CustomStyler styleSelectButton:self.distanceButton2 corners:-1];
    [CustomStyler styleSelectButton:self.distanceButton3 corners:-1];
    [CustomStyler styleSelectButton:self.distanceButton4 corners:(UIRectCornerTopRight|UIRectCornerBottomRight)];
    
    // neighborhood button
    [CustomStyler styleButton2:self.neighborhoodButton];
    
    // cuisine button
    [CustomStyler styleButton2:self.cuisineButton];
    
    // price select
    [CustomStyler styleSelectButton:self.price$Button corners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)];
    [CustomStyler styleSelectButton:self.price$$Button corners:-1];
    [CustomStyler styleSelectButton:self.price$$$Button corners:-1];
    [CustomStyler styleSelectButton:self.price$$$$Button corners:-1];
    [CustomStyler styleSelectButton:self.price$$$$$Button corners:(UIRectCornerTopRight|UIRectCornerBottomRight)];
    
    // occasion buton
    [CustomStyler styleButton2:self.occasionButton];
    
    // open now button
    [CustomStyler styleButton2:self.openNowButton];
    
    // search button
    [CustomStyler styleButton:self.searchButton];
    
    self.pendingPriceRemovals = [[NSMutableArray alloc] init];
    self.pendingPriceAdditions = [[NSMutableArray alloc] init];
    
    self.priceButtons = [[NSMutableArray alloc] init];
    [self.priceButtons addObject:self.price$Button];
    [self.priceButtons addObject:self.price$$Button];
    [self.priceButtons addObject:self.price$$$Button];
    [self.priceButtons addObject:self.price$$$$Button];
    [self.priceButtons addObject:self.price$$$$$Button];
    
    self.distanceButtons = [[NSMutableArray alloc] init];
    [self.distanceButtons addObject:self.distanceButton1];
    [self.distanceButtons addObject:self.distanceButton2];
    [self.distanceButtons addObject:self.distanceButton3];
    [self.distanceButtons addObject:self.distanceButton4];
    
    self.pendingDistanceIndex = [NSNumber numberWithInt:-1];
    
    if (self.searchFilters != nil) {
        [self updateUI];
    } else {
        self.searchFilters = [[SearchFilters alloc] init];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Search Filters Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateUI {
    // neighborhood
    [self neighborhoodSelected:self.searchFilters.selectedNeighborhood];
    
    // distance
    [self clearDistanceButtons];
    if (![self actualNeighborhoodSelected]) {
        if (self.searchFilters.selectedDistance) {
            [self distanceSelected:((UIButton *)self.distanceButtons[[self.searchFilters.selectedDistanceIndex intValue]])];
        }
    }
    
    // cuisine
    [self cuisineSelected:self.searchFilters.selectedCuisine];
    
    // price
    [self clearPriceButtons];
    for (Price *price in self.searchFilters.selectedPrices) {
        UIButton *priceButton = [self valueForKey:[NSString stringWithFormat:@"price%@Button", price.name]];
        priceButton.selected = YES;
    }
    
    // occasion
    [self occasionSelected:self.searchFilters.selectedOccasion];
    
    // open now
    [self.openNowButton setSelected:self.searchFilters.openNow];
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Distance

- (BOOL)actualNeighborhoodSelected {
    return ![self.pendingSelectedNeighborhood isEqual:[Neighborhood currentLocation]];
}

- (void)clearDistanceButtons {
    for (UIButton *distanceButton in self.distanceButtons) {
        distanceButton.selected = NO;
    }
}

- (void)disableDistanceButtons {
    [self clearDistanceButtons];
    
    for (UIButton *distanceButton in self.distanceButtons) {
        [CustomStyler setViewEnabled:distanceButton enabled:NO];
    }
}

- (void)enableDistanceButtons {
    //    [self clearDistanceButtons];
    
    for (UIButton *distanceButton in self.distanceButtons) {
        [CustomStyler setViewEnabled:distanceButton enabled:YES];
    }
}

- (IBAction)distanceSelected:(UIButton *)distanceButton {
    NSUInteger buttonIndex = [self.distanceButtons indexOfObject:distanceButton];
    BOOL buttonSelected = distanceButton.selected;
    
    [self clearDistanceButtons];
    
    if (buttonSelected) {
        self.pendingDistanceIndex = [NSNumber numberWithInt:-1];
    } else {
        self.pendingDistanceIndex = [NSNumber numberWithInteger:buttonIndex];
    }
    distanceButton.selected = !buttonSelected;
    
    [self neighborhoodSelected:[Neighborhood currentLocation]];
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Neighborhood

- (IBAction)neighborhoodButtonPressed:(id)sender {
    if (self.neighborhoodButton.selected) {
        self.neighborhoodButton.selected = NO;
        self.pendingSelectedNeighborhood = nil;
        
        [self enableDistanceButtons];
    } else {
        [self performSegueWithIdentifier:@"goToNeighborhoodFilter" sender:self];
    }
}

- (void)neighborhoodSelected:(Neighborhood *)neighborhood {
    if (neighborhood == nil) {
        self.neighborhoodButton.selected = NO;
    } else {
        self.neighborhoodButton.selected = YES;
        
        NSString *neighborhoodName;
        if ([neighborhood.name isEqualToString:@"All"]) {
            neighborhoodName = neighborhood.parentName;
        } else {
            neighborhoodName = neighborhood.name;
        }
        [self.neighborhoodButton setTitle:neighborhoodName forState:UIControlStateSelected];
    }
    self.pendingSelectedNeighborhood = neighborhood;
    
    if (self.neighborhoodButton.selected) {
        // update distance filter which is dependent on selected neighborhood (disable if not using current location)
        if ([self actualNeighborhoodSelected]) {
            self.pendingDistanceIndex = [NSNumber numberWithInt:-1];
            [self disableDistanceButtons];
        } else {
            [self enableDistanceButtons];
        }
    }
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Cuisine

- (IBAction)cuisineButtonPressed:(id)sender {
    if (self.cuisineButton.selected) {
        self.cuisineButton.selected = NO;
        self.pendingSelectedCuisine = nil;
    } else {
        [self performSegueWithIdentifier:@"goToCuisineFilter" sender:self];
    }
}

- (void)cuisineSelected:(Cuisine *)cuisine {
    if (cuisine == nil) {
        self.cuisineButton.selected = NO;
    } else {
        self.cuisineButton.selected = YES;
        [self.cuisineButton setTitle:cuisine.name forState:UIControlStateSelected];
    }
    self.pendingSelectedCuisine = cuisine;
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Price

- (void)clearPriceButtons {
    for (UIButton *priceButton in self.priceButtons) {
        priceButton.selected = NO;
    }
}

- (IBAction)pricePressed:(UIButton *)priceButton {
    Price *price = [[Price alloc] initWithName:priceButton.currentTitle];
    
    if (priceButton.selected) {
        [self.pendingPriceRemovals addObject:price];
    } else {
        [self.pendingPriceAdditions addObject:price];
    }
    priceButton.selected = !priceButton.selected;
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Occasion

- (IBAction)occasionButtonPressed:(id)sender {
    if (self.occasionButton.selected) {
        self.occasionButton.selected = NO;
        self.pendingSelectedOccasion = nil;
    } else {
        [self performSegueWithIdentifier:@"goToOccasionFilter" sender:self];
    }
}

- (void)occasionSelected:(Occasion *)occasion {
    if (occasion == nil) {
        self.occasionButton.selected = NO;
    } else {
        self.occasionButton.selected = YES;
        [self.occasionButton setTitle:occasion.name forState:UIControlStateSelected];
    }
    self.pendingSelectedOccasion = occasion;
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Open Now

- (IBAction)openNowButtonPressed:(id)sender {
    if (self.openNowButton.selected) {
        self.openNowButton.selected = NO;
        self.pendingOpenNow = NO;
    } else {
        self.openNowButton.selected = YES;
        self.pendingOpenNow = YES;
    }
    
    // update reset button
    [self updateResetButton];
}

#pragma mark - Reset

- (IBAction)reset:(id)sender {
    // distance
    [self.searchFilters setDistance:-1];
    self.pendingDistanceIndex = [NSNumber numberWithInt:-1];
    
    // neighborhood
    self.searchFilters.selectedNeighborhood = nil;
    
    // cuisine
    self.searchFilters.selectedCuisine = nil;
    
    // prices
    self.searchFilters.selectedPrices = nil;
    self.pendingPriceAdditions = nil;
    
    // occasion
    self.searchFilters.selectedOccasion = nil;
    
    // open now
    self.searchFilters.openNow = NO;
    
    [self updateUI];
}

- (void)updateResetButton {
    BOOL setActive = (self.distanceButton1.selected || self.distanceButton2.selected || self.distanceButton3.selected
                      || self.distanceButton4.selected)
                  || self.neighborhoodButton.selected
                  || self.cuisineButton.selected
                  || (self.price$Button.selected || self.price$$Button.selected || self.price$$$Button.selected
                      || self.price$$$$Button.selected || self.price$$$$$Button.selected)
                  || self.occasionButton.selected
                  || self.openNowButton.selected;
    
    if (setActive) {
        [self.resetButton setImage:[UIImage imageNamed:@"button-reset-active.png"] forState:UIControlStateNormal];
    } else {
        [self.resetButton setImage:[UIImage imageNamed:@"button-reset-inactive.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Apply

- (void)applyPendingFilters {
    self.searchFilters.selectedCuisine = self.pendingSelectedCuisine;
    self.searchFilters.selectedOccasion = self.pendingSelectedOccasion;
    self.searchFilters.selectedNeighborhood = self.pendingSelectedNeighborhood;
    self.searchFilters.openNow = self.pendingOpenNow;
    
    for (Price *price in self.pendingPriceRemovals) {
        [self.searchFilters.selectedPrices removeObject:price];
    }
    for (Price *price in self.pendingPriceAdditions) {
        [self.searchFilters.selectedPrices addObject:price];
    }
    
    [self.searchFilters setDistance:[self.pendingDistanceIndex intValue]];
}

#pragma mark - Filter

- (IBAction)filter:(id)sender {
    [self applyPendingFilters];
    
    __block SearchFiltersViewController *_self = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [_self.delegate filter:_self.searchFilters];
//        [_self.delegate resetFilters];
    }];
}

#pragma mark - Cancel

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToCuisineFilter"]) {
        CuisineFilterViewController *vc = (CuisineFilterViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"goToOccasionFilter"]) {
        OccasionFilterViewController *vc = (OccasionFilterViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"goToNeighborhoodFilter"]) {
        NeighborhoodFilterViewController *vc = (NeighborhoodFilterViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.referrer = @"filter";
    }
}

@end
