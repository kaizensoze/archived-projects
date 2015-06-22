//
//  SearchViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchFiltersViewController.h"
#import "NeighborhoodFilterViewController.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SearchViewController : UIViewController <
    UITableViewDelegate,
    UITableViewDataSource,
    UISearchBarDelegate,
    NeighborhoodFilterDelegate,
    SearchFiltersDelegate,
    MKMapViewDelegate,
    UIGestureRecognizerDelegate,
    MFMailComposeViewControllerDelegate
>

- (void)clearSearch;

@end
