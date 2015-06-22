//
//  CuisineFilterViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 12/27/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "CuisineFilterViewController.h"
#import "Cuisine.h"

@interface CuisineFilterViewController ()
    @property (strong, nonatomic) NSArray *cuisineData;
@end

@implementation CuisineFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CachedData *cachedData = appDelegate.cachedData;
    if (!cachedData.cuisines) {
        [appDelegate showLoadingScreen:self.view];
        [self loadCuisines];
    } else {
        self.cuisineData = cachedData.cuisines;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Cuisine Filter Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadCuisines {
    NSString *url = [NSString stringWithFormat: @"%@/cuisines", API_URL_PREFIX];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *cuisineTempData = [[NSMutableArray alloc] init];
        for (id cuisineDict in JSON) {
            NSArray *cuisineParent = [cuisineDict objectForKeyNotNull:@"parent"];
            
            BOOL isLeafNode = YES;
            if (!cuisineParent) {
                isLeafNode = NO;
            }
            
            if (isLeafNode) {
                Cuisine *cuisine = [[Cuisine alloc] initWithDict:cuisineDict];
                [cuisineTempData addObject:cuisine];
            }
        }
        [cuisineTempData sortUsingSelector:@selector(compare:)];
        self.cuisineData = cuisineTempData;

        // Reload table.
        [self.tableView reloadData];
        
        // Cache cuisine data.
        CachedData *cachedData = appDelegate.cachedData;
        cachedData.cuisines = self.cuisineData;
        
        [appDelegate removeLoadingScreen:self];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cuisineData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = ((Cuisine *)self.cuisineData[indexPath.row]).name;
    [CustomStyler styleOptionCell:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Cuisine *selectedCuisine = self.cuisineData[indexPath.row];
    [self.delegate cuisineSelected:selectedCuisine];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
