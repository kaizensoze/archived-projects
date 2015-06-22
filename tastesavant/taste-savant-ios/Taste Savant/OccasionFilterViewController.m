//
//  OccasionFilterViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 12/27/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "OccasionFilterViewController.h"
#import "Occasion.h"

@interface OccasionFilterViewController ()
    @property (strong, nonatomic) NSArray *occasionData;
@end

@implementation OccasionFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CachedData *cachedData = appDelegate.cachedData;
    if (!cachedData.occasions) {
        [appDelegate showLoadingScreen:self.view];
        [self loadOccasions];
    } else {
        self.occasionData = cachedData.occasions;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Occasion Filter Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadOccasions {
    NSString *url = [NSString stringWithFormat: @"%@/occasions", API_URL_PREFIX];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *occasionTempData = [[NSMutableArray alloc] init];
        for (id occasionDict in JSON) {
            Occasion *occasion = [[Occasion alloc] initWithDict:occasionDict];
            [occasionTempData addObject:occasion];
        }
        [occasionTempData sortUsingSelector:@selector(compare:)];
        self.occasionData = occasionTempData;
        
        // Reload table.
        [self.tableView reloadData];
        
        // Cache occasion data.
        CachedData *cachedData = appDelegate.cachedData;
        cachedData.occasions = self.occasionData;
        
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
    return self.occasionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = ((Occasion *)self.occasionData[indexPath.row]).name;
    [CustomStyler styleOptionCell:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Occasion *selectedOccasion = self.occasionData[indexPath.row];
    [self.delegate occasionSelected:selectedOccasion];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
