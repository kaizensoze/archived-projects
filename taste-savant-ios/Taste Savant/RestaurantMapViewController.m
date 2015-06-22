//
//  RestaurantMapViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 5/5/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "RestaurantMapViewController.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "Restaurant.h"

@interface RestaurantMapViewController ()
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation RestaurantMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *titleText = self.restaurant.name;
    self.navigationItem.title = titleText;
    
    CLLocationCoordinate2D zoomLocation = self.restaurant.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion];
    
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    marker.coordinate = zoomLocation;
    [self.mapView addAnnotation:marker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Restaurant Map Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goToMapsApp:(id)sender {
    float destLat = self.restaurant.location.coordinate.latitude;
    float destLong = self.restaurant.location.coordinate.longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(destLat, destLong);
    
    NSDictionary *addressDict = @{
        (NSString *) kABPersonAddressStreetKey : self.restaurant.address,
        (NSString *) kABPersonAddressCityKey : self.restaurant.city,
        (NSString *) kABPersonAddressStateKey : self.restaurant.state,
        (NSString *) kABPersonAddressZIPKey : self.restaurant.zipCode
    };
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.restaurant.name;

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString *googleMapsURLString = [[NSString stringWithFormat:@"comgooglemaps://?q=%@, %@, %@ %@&center=%f,%f&zoom=12", self.restaurant.address, self.restaurant.city, self.restaurant.state, self.restaurant.zipCode, destLat, destLong] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    } else {
        [MKMapItem openMapsWithItems:@[mapItem] launchOptions:nil];
    }
}

@end
