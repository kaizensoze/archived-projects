//
//  CachedData.m
//  Taste Savant
//
//  Created by Joe Gallo on 1/23/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "CachedData.h"

@implementation CachedData {
//    NSString *_nearestCity;
}

- (id)init {
    self = [super init];
    if (self) {
        self.priceData = @{
            @"$" : @2,
            @"$$" : @4,
            @"$$$" : @14,
            @"$$$$" : @8,
            @"$$$$$" : @3
        };
        
        self.brooklynNeighborhoods = @[@"11201", @"11203", @"11204", @"11205", @"11206", @"11207", @"11208", @"11209", @"11210", @"11211", @"11212", @"11213", @"11214", @"11215", @"11216", @"11217", @"11218", @"11219", @"11220", @"11221", @"11222", @"11223", @"11224", @"11225", @"11226", @"11228", @"11229", @"11230", @"11231", @"11232", @"11233", @"11234", @"11235", @"11236", @"11238", @"11239"];
    }
    
    return self;
}

- (void)loadSupportedCities {
    NSString *url = [NSString stringWithFormat: @"%@/cities", API_URL_PREFIX];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableDictionary *cities = [[NSMutableDictionary alloc] init];
        for (id cityDict in JSON) {
            // create Location object from lat,lng values
            NSArray *latLng = cityDict[@"lat_lng"];
            double lat = [latLng[0] doubleValue];
            double lng = [latLng[1] doubleValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            
            // replace lat_lng key with location key
            [cityDict removeObjectForKey:@"lat_lng"];
            cityDict[@"location"] = location;
            
            NSString *name = cityDict[@"name"];
            cities[name] = cityDict;
        }
        // set supported cities
        self.supportedCities = cities;
        
        // find nearest city
        [appDelegate findNearestCity:appDelegate.lastLocation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [operation setJSONReadingOptions:NSJSONReadingMutableContainers];
    [appDelegate.httpClient.operationQueue addOperation:operation];
//    [operation waitUntilFinished];
}

- (void)setNearestCity:(NSString *)nearestCity {
    _nearestCity = nearestCity;
    DDLogInfo(@"%@", _nearestCity);
}

//- (NSString *)nearestCity {
//    if (!_nearestCity) {
//        return @"Los Angeles";
//    }
//    return _nearestCity;
//}

@end
