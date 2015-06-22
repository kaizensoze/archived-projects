//
//  RestaurantMenuViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 5/19/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "RestaurantMenuViewController.h"
#import "MenuItemCell.h"
#import "Restaurant.h"

@interface RestaurantMenuViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;

    @property (strong, nonatomic) NSMutableArray *menuSections;
    @property (strong, nonatomic) NSMutableArray *menuItems;
@end

@implementation RestaurantMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *titleText = [NSString stringWithFormat:@"Menu: %@", self.restaurant.name];
    self.navigationItem.title = titleText;
    
    [CustomStyler setAndStyleRestaurantInfo:self.restaurant vc:self linkToRestaurant:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.menuItems == nil) {
        [appDelegate showLoadingScreen:self.view];
        [self loadMenuItems];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Restaurant Menu Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadMenuItems {
    self.menuSections = [[NSMutableArray alloc] init];
    self.menuItems = [[NSMutableArray alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/restaurants/%@/menu", API_URL_PREFIX, self.restaurant.slug];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *tempArray;
        
        for (NSDictionary *menu in JSON) {
            for (NSDictionary *menuItem in menu[@"entry_set"]) {
                NSString *type = menuItem[@"type"];
                if ([type isEqualToString:@"section"]) {
                    [self.menuSections addObject:menuItem[@"title"]];
                    tempArray = [[NSMutableArray alloc] init];
                    [self.menuItems addObject:tempArray];
                } else if ([type isEqualToString:@"item"]) {
                    NSMutableDictionary *item = [@{
                                          @"title" : menuItem[@"title"],
                                          @"description" : menuItem[@"desc"],
                                          } mutableCopy];
                    if (((NSArray *)menuItem[@"price_set"]).count > 0) {
                        item[@"price"] = menuItem[@"price_set"][0][@"price"];
                    }
                    [tempArray addObject:item];
                }
            }
        }
        
        [self.tableView reloadData];
        
        [appDelegate removeLoadingScreen:self];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray *)self.menuItems[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MenuItemCell";
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MenuItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *menuItem = [self.menuItems[indexPath.section][indexPath.row] copy];
    
    cell.titleLabel.text = menuItem[@"title"];
    
    cell.descriptionLabel.text = menuItem[@"description"];
    
    NSString *priceString = @"";
    if (menuItem[@"price"]) {
        priceString = [NSString stringWithFormat:@"$%@", menuItem[@"price"]];
    }
    cell.priceLabel.text = priceString;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuItem = [self.menuItems[indexPath.section][indexPath.row] copy];
    
    CGFloat height = 0;
    
    // top padding
    height += 14;
    
    // title label height
    CGSize titleLabelSize = [Util textSize:menuItem[@"title"] font:[UIFont fontWithName:@"Georgia" size:14.0]
                                     width:232 height:MAXFLOAT];
    height += titleLabelSize.height;
    
    // description label height
    if ([Util clean:menuItem[@"description"]].length > 0) {
        // spacing between title and escription
        height += 6;
        
        CGSize descriptionLabelSize = [Util textSize:menuItem[@"description"]
                                                font:[UIFont fontWithName:@"HelveticaNeue" size:12.0]
                                               width:232 height:MAXFLOAT];
        height += descriptionLabelSize.height;
    }
    
    // bottom padding
    height += 15;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text = self.menuSections[section];
    
    UIView *view = [CustomStyler createTableHeaderView:tableView str:text];
    return view;
}

@end
