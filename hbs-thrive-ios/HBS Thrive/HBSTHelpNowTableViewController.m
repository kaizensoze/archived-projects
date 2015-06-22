//
//  HBSTHelpNowTableViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTHelpNowTableViewController.h"
#import "HBSTHelpNowTableViewCell.h"
#import "HBSTHelpNowItem.h"

@interface HBSTHelpNowTableViewController ()
    @property (strong, nonatomic) NSMutableArray *helpNowItems;
    @property (strong, nonatomic) UIView *loadingOverlayView;
@end

@implementation HBSTHelpNowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation bar
    self.navigationController.navigationBar.barTintColor = [HBSTUtil colorFromHex:@"64964b"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 15, 277, 44)];
    titleLabel.text = @"Help Now";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    
    // table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"Get Help"];
    
    // add loading overlay
    self.loadingOverlayView = [HBSTUtil loadingOverlayView:self.view];
    if (!self.helpNowItems) {
        [self.view addSubview:self.loadingOverlayView];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/help-now", SITE_DOMAIN, API_PATH];
    [appDelegate.requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        self.helpNowItems = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in JSON) {
            HBSTHelpNowItem *helpNowItem = [[HBSTHelpNowItem alloc] initWithDict:dict];
            [self.helpNowItems addObject:helpNowItem];
        }
        
        // remove loading overlay
        [self.loadingOverlayView removeFromSuperview];
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.helpNowItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HelpNowCell";
    
    HBSTHelpNowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HBSTHelpNowTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    HBSTHelpNowItem *helpNowItem = self.helpNowItems[indexPath.row];
    
    cell.titleLabel.text = helpNowItem.title;
    cell.bodyLabel.text = helpNowItem.body;
    cell.phoneLabel.text = helpNowItem.phoneNumber;
    
    [HBSTUtil makePhoneNumberLink:cell.phoneLabel];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBSTHelpNowItem *helpNowItem = self.helpNowItems[indexPath.row];
    
    float titleHeight = [HBSTUtil textSize:helpNowItem.title font:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
                                     width:277 height:MAXFLOAT].height;
    float bodyHeight = [HBSTUtil textSize:helpNowItem.body font:[UIFont fontWithName:@"HelveticaNeue" size:11]
                                    width:277 height:MAXFLOAT].height;
                         
    return 15 + titleHeight + 3 + bodyHeight + 38;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
#endif
}

@end
