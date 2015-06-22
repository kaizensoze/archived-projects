//
//  CustomAnnotationView.h
//  TasteSavant
//
//  Created by Joe Gallo on 11/2/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CustomCalloutView.h"

@interface CustomAnnotationView : MKAnnotationView

@property (strong, nonatomic) CustomCalloutView *callout;
@property (strong, nonatomic) Restaurant *restaurant;
@property (nonatomic) NSUInteger index;

- (void)addIndexLabel;
- (void)createCallout;

@end
