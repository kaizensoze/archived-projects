//
//  LocationFilterViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 12/13/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "NeighborhoodFilterViewController.h"
#import "Neighborhood.h"

@interface NeighborhoodFilterViewController ()
    @property (strong, nonatomic) NSMutableArray *neighborhoods;
    @property (strong, nonatomic) CachedData *cachedData;
@end

@implementation NeighborhoodFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.cachedData = appDelegate.cachedData;
    
    NSString *titleText = self.selectedNeighborhood.name;
    self.navigationItem.title = titleText;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // show cancel button if accessing from search view
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancel:)];
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
    
    if (!self.cachedData.neighborhoodData) {
        [appDelegate showLoadingScreen:self.view];
        [self loadNeighborhoodData];
    } else {
        [self setNeighborhoodList];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Neighborhood Filter Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadNeighborhoodData {
    NSString *url = [NSString stringWithFormat: @"%@/neighborhoods", API_URL_PREFIX];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableDictionary *neighborhoodMapping = [[NSMutableDictionary alloc] init];
        
        // need to iterate over everything for one pass to associate neighborhood objects with their ids
        for (id neighborhoodDict in JSON) {
            Neighborhood *neighborhood = [[Neighborhood alloc] initWithDict:neighborhoodDict];
            NSString *key = [NSString stringWithFormat:@"%@:%@", neighborhood.parentName, neighborhood.name];
            neighborhoodMapping[key] = neighborhood;
        }
        
        NSMutableDictionary *neighborhoodTempData = [[NSMutableDictionary alloc] init];
        NSMutableArray *rootNeighborhoods = [[NSMutableArray alloc] init];
        
        for (id key in neighborhoodMapping) {
            Neighborhood *parentNeighborhood = (Neighborhood *)neighborhoodMapping[key];
            if (!parentNeighborhood.parentName) {
                [rootNeighborhoods addObject:parentNeighborhood];
            }
            
            for (NSString *childNeighborhoodName in parentNeighborhood.children) {
                NSString *childKey = [NSString stringWithFormat:@"%@:%@", parentNeighborhood.name, childNeighborhoodName];
                Neighborhood *childNeighborhood = neighborhoodMapping[childKey];
                childNeighborhood.parentId = parentNeighborhood.id;
                
                id parentKey = parentNeighborhood;
                if (!neighborhoodTempData[parentKey]) {
                    [neighborhoodTempData setObject:[@[] mutableCopy] forKey:parentKey];
                }
                [neighborhoodTempData[parentKey] addObject:childNeighborhood];
            }
        }
        
        // add root neighborhoods
        neighborhoodTempData[[NSNull null]] = rootNeighborhoods;
        
        // adjust ordering of root neighborhoods
        [neighborhoodTempData[[NSNull null]] exchangeObjectAtIndex:0 withObjectAtIndex:3];
        [neighborhoodTempData[[NSNull null]] exchangeObjectAtIndex:1 withObjectAtIndex:3];
        [neighborhoodTempData[[NSNull null]] exchangeObjectAtIndex:1 withObjectAtIndex:2];
        
//        DDLogInfo(@"%@", neighborhoodTempData);
        
        // add All at top of each list of children
        for (Neighborhood *neighborhood in neighborhoodTempData) {
            if ([neighborhood isEqual:[NSNull null]]) {
                continue;
            }
            
            Neighborhood *allNeighborhood = [[Neighborhood alloc] initWithId:0 name:@"All" parentName:neighborhood.name];
            allNeighborhood.borough = neighborhood.borough;
            allNeighborhood.city = neighborhood.city;
            allNeighborhood.parentId = neighborhood.id;

            [neighborhoodTempData[neighborhood] insertObject:allNeighborhood atIndex:0];
        }

//        DDLogInfo(@"%@", neighborhoodTempData);

        self.cachedData.neighborhoodData = [neighborhoodTempData copy];

        // set which neighborhoods are to be displayed
        [self setNeighborhoodList];
        
        [appDelegate removeLoadingScreen:self];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)setNeighborhoodList {
    NSDictionary *neighborhoodData = self.cachedData.neighborhoodData;
    
    self.neighborhoods = [[NSMutableArray alloc] init];
    
    if (!self.selectedNeighborhood) {
        [self.neighborhoods addObjectsFromArray:neighborhoodData[[NSNull null]]];
        
        Neighborhood *currentLocation = [Neighborhood currentLocation];
        [self.neighborhoods insertObject:currentLocation atIndex:0];
    } else {
        [self.neighborhoods addObjectsFromArray:neighborhoodData[self.selectedNeighborhood]];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.neighborhoods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = ((Neighborhood *)self.neighborhoods[indexPath.row]).name;
    [CustomStyler styleOptionCell:cell];
    
    // Current Location
    if ([cell.textLabel.text isEqualToString:@"Current Location"]) {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        cell.textLabel.textColor = [Util colorFromHex:@"362f2d"];
    } else if ([cell.textLabel.text isEqualToString:@"All"]) {  // All
//        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Neighborhood *selectedNeighborhood = self.neighborhoods[indexPath.row];
    
    // if selected neighborhood is a parent, drill down, otherwise use selected neighborhood
    if (!self.cachedData.neighborhoodData[selectedNeighborhood]) {
        [self.delegate neighborhoodSelected:selectedNeighborhood];
        if ([self.referrer isEqualToString:@"search"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if ([self.referrer isEqualToString:@"filter"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        NeighborhoodFilterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NeighborhoodFilter"];
        vc.selectedNeighborhood = selectedNeighborhood;
        vc.delegate = self.delegate;
        vc.referrer = self.referrer;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
