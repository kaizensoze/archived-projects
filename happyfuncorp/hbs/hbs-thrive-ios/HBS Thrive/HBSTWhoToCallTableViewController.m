//
//  HBSTWhoToCallTableViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/25/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTWhoToCallTableViewController.h"
#import "HBSTWhoToCallTableViewCell.h"
#import "HBSTWhoToCallItem.h"
#import "HBSTEmptySearchResultTableViewCell.h"

@interface HBSTWhoToCallTableViewController ()
    @property (strong, nonatomic) NSMutableDictionary *whoToCallItems;
    @property (strong, nonatomic) NSMutableArray *sections;

    @property (strong, nonatomic) NSMutableDictionary *sectionStates;
    @property (strong, nonatomic) NSMutableDictionary *rowStates;

    @property (strong, nonatomic) NSArray *searchResults;
    @property (strong, nonatomic) NSMutableDictionary *searchResultStates;

    @property (strong, nonatomic) UIView *loadingOverlayView;

    @property (strong, nonatomic) MFMailComposeViewController *mailVC;
    @property (nonatomic) BOOL doNotLoadAgain;
@end

@implementation HBSTWhoToCallTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation bar
    self.navigationController.navigationBar.barTintColor = [HBSTUtil colorFromHex:@"64964b"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 15, 277, 44)];
    titleLabel.text = @"Who To Call If...";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    
    // table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // search bar
    self.searchDisplayController.searchBar.placeholder = @"Search who to call";
    
    // search results table view
    self.searchDisplayController.searchResultsTableView.backgroundColor = [HBSTUtil colorFromHex:@"e0e0e0"];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"Who to call"];
    
    if (self.doNotLoadAgain) {
        self.doNotLoadAgain = NO;
        return;
    }
    
    // add loading overlay
    self.loadingOverlayView = [HBSTUtil loadingOverlayView:self.view];
    if (!self.whoToCallItems) {
        [self.view addSubview:self.loadingOverlayView];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/who-to-call", SITE_DOMAIN, API_PATH];
    [appDelegate.requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        self.sections = [[NSMutableArray alloc] init];
        self.whoToCallItems = [[NSMutableDictionary alloc] init];
        for (NSDictionary *dict in JSON) {
            HBSTWhoToCallItem *whoToCallItem = [[HBSTWhoToCallItem alloc] initWithDict:dict];
            
            // add section
            NSString *subject = whoToCallItem.subject;
            NSUInteger section_idx = [self.sections indexOfObject:subject];
            if (section_idx == NSNotFound) {
                [self.sections addObject:subject];
            }
            section_idx = [self.sections indexOfObject:subject];
            
            // add row
            if (!self.whoToCallItems[@(section_idx)]) {
                self.whoToCallItems[@(section_idx)] = [[NSMutableArray alloc] init];
            }
            [self.whoToCallItems[@(section_idx)] addObject:whoToCallItem];
        }
//        DDLogInfo(@"%@", self.sections);
//        DDLogInfo(@"%@", self.whoToCallItems);
        
        // initialize everything as unexpanded
        self.sectionStates = [[NSMutableDictionary alloc] init];
        self.rowStates = [[NSMutableDictionary alloc] init];
        for (int section_idx=0; section_idx < self.sections.count; section_idx++) {
            self.sectionStates[@(section_idx)] = @0;
            NSArray *rows = self.whoToCallItems[@(section_idx)];
            for (int row_idx=0; row_idx < rows.count; row_idx++) {
                if (!self.rowStates[@(section_idx)]) {
                    self.rowStates[@(section_idx)] = [[NSMutableDictionary alloc] init];
                }
                self.rowStates[@(section_idx)][@(row_idx)] = @0;
            }
        }
//        DDLogInfo(@"%@", self.sectionStates);
//        DDLogInfo(@"%@", self.rowStates);
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return self.sections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.text.length > 0 && self.searchResults.count == 0) {
            return 1;
        }
        return self.searchResults.count;
    }
    
    BOOL sectionExpanded = [self.sectionStates[@(section)] boolValue];
    if (sectionExpanded) {
        return ((NSArray *)self.whoToCallItems[@(section)]).count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"WhoToCallCell";
    
    // empty search cell
    if (tableView == self.searchDisplayController.searchResultsTableView
        && self.searchDisplayController.searchBar.text.length > 0
        && self.searchResults.count == 0) {
        
        HBSTEmptySearchResultTableViewCell *emptyCell = [self.tableView dequeueReusableCellWithIdentifier:@"EmptySearchCell"];
        if (!emptyCell) {
            emptyCell = [[HBSTEmptySearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                  reuseIdentifier:@"EmptySearchCell"];
        }
        return emptyCell;
    }
    
    HBSTWhoToCallTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HBSTWhoToCallTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                 reuseIdentifier:cellIdentifier];
    }
    
    HBSTWhoToCallItem *whoToCallItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        whoToCallItem = self.searchResults[indexPath.row];
    } else {
        whoToCallItem = ((NSArray *)self.whoToCallItems[@(indexPath.section)])[indexPath.row];
    }
    
    cell.label.text = whoToCallItem.title;
    cell.nameLabel.text = whoToCallItem.name;
    cell.emailLabel.text = whoToCallItem.email;
    cell.phoneLabel.text = whoToCallItem.phoneNumber;
    
    [HBSTUtil makeEmailLink:cell.emailLabel];
    [HBSTUtil makePhoneNumberLink:cell.phoneLabel];

    // if expanded, show extra content, otherwise hide it
    BOOL isExpanded;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        isExpanded = [self.searchResultStates[@(indexPath.row)] boolValue];
    } else {
        isExpanded = [self.rowStates[@(indexPath.section)][@(indexPath.row)] boolValue];
    }
    
    if (isExpanded) {
        cell.extraView.hidden = NO;
        cell.contentView.backgroundColor = [HBSTUtil colorFromHex:@"eff4ed"];
    } else {
        cell.extraView.hidden = YES;
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBSTWhoToCallItem *whoToCallItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.text.length > 0 && self.searchResults.count == 0) {
            return 57;
        }
        whoToCallItem = self.searchResults[indexPath.row];
    } else {
        whoToCallItem = ((NSArray *)self.whoToCallItems[@(indexPath.section)])[indexPath.row];
    }
    
    CGSize textSize = [HBSTUtil textSize:whoToCallItem.title font:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
                                   width:259 height:MAXFLOAT];
    float topPadding = 15;
    float bottomPadding = 5;
    float height = topPadding + textSize.height + bottomPadding;
    
    // if expanded, add expanded height
    BOOL isExpanded;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        isExpanded = [self.searchResultStates[@(indexPath.row)] boolValue];
    } else {
        isExpanded = [self.rowStates[@(indexPath.section)][@(indexPath.row)] boolValue];
    }
    
    if (isExpanded) {
        float adjustedHeight = 0;
        if (whoToCallItem.name.length > 0) {
            adjustedHeight += (21 + 7);
        }
        if (whoToCallItem.email.length > 0) {
            adjustedHeight += (21 + 7);
        }
        if (whoToCallItem.phoneNumber.length > 0) {
            adjustedHeight += (21 + 7);
        }
        adjustedHeight += 10;
        
        height += adjustedHeight;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    
    if (section == self.sections.count) {
        return 57;
    }
    
    NSString *sectionText = self.sections[section];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize textSize = [HBSTUtil textSize:sectionText font:font width:236 height:MAXFLOAT];
    float topPadding = 16;
    float bottomPadding = 17;
    float height = topPadding + textSize.height + bottomPadding;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    if (section == self.sections.count) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 57)];
        
        // top border
        CALayer *topLine = [CALayer layer];
        topLine.frame = CGRectMake(0, 0, tableView.frame.size.width, 1);
        topLine.backgroundColor = [HBSTUtil colorFromHex:@"cccccc"].CGColor;
        [view.layer addSublayer:topLine];
        
        // label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 57)];
        label.text = @"Can't find what you are looking for? Tap here to contact our team for help.";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        [view addSubview:label];
        
        // button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(cantFind:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, tableView.frame.size.width, 57);
        [view addSubview:button];
        
        return view;
    }
    
    CGFloat sectionHeaderHeight = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, sectionHeaderHeight)];
    view.backgroundColor = [UIColor whiteColor];
    
    // top border
    CALayer *topLine = [CALayer layer];
    topLine.frame = CGRectMake(0, 0, tableView.frame.size.width, 1);
    topLine.backgroundColor = [HBSTUtil colorFromHex:@"cccccc"].CGColor;
    [view.layer addSublayer:topLine];
    
    // label
    NSString *sectionText = self.sections[section];
    UIFont *sectionFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    CGSize sectionTextSize = [HBSTUtil textSize:sectionText font:sectionFont width:236 height:MAXFLOAT];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 18, 236, sectionTextSize.height)];
    label.text = sectionText;
    label.font = sectionFont;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    [view addSubview:label];
    
    // expand/collapse image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(277, label.center.y - 5, 18, 11)];
    if ([self.sectionStates[@(section)] boolValue]) {
        imageView.image = [UIImage imageNamed:@"collapse.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"expand.png"];
    }
    [view addSubview:imageView];
    
    if ([self.sectionStates[@(section)] boolValue]) {
        CALayer *bottomLine = [CALayer layer];
        bottomLine.frame = CGRectMake(20, sectionHeaderHeight, 280, 1);
        bottomLine.backgroundColor = [HBSTUtil colorFromHex:@"cccccc"].CGColor;
        [view.layer addSublayer:bottomLine];
    }
    
    // button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(collapseExpandSection:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, tableView.frame.size.width, sectionHeaderHeight);
    button.tag = section;
    [view addSubview:button];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    BOOL oldState, newState;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.text.length > 0 && self.searchResults.count == 0) {
            [self cantFind:nil];
            return;
        }
        
        oldState = [self.searchResultStates[@(row)] boolValue];
        newState = !oldState;
        self.searchResultStates[@(row)] = @(newState);
    } else {
        oldState = [self.rowStates[@(section)][@(row)] boolValue];
        newState = !oldState;
        self.rowStates[@(section)][@(row)] = @(newState);
    }
    
    UIColor *color;
    if (newState) {
        color = [HBSTUtil colorFromHex:@"eff4ed"];
        
        HBSTWhoToCallItem *item = self.whoToCallItems[@(section)][row];
        NSString *title = item.title;
        [Flurry logEvent:@"Evergreen Read" withParameters:@{ @"title": title }];
    } else {
        color = [UIColor whiteColor];
    }
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        HBSTWhoToCallTableViewCell *cell = (HBSTWhoToCallTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = color;
        cell.backgroundColor = color;
        cell.extraView.backgroundColor = color;
    }];
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [CATransaction commit];
}

#pragma mark - Can't find

- (IBAction)cantFind:(id)sender {
    self.mailVC = nil;
    self.mailVC = [[MFMailComposeViewController alloc] init];
    self.mailVC.mailComposeDelegate = self;
    [self.mailVC setToRecipients:@[@"sas@hbs.edu"]];
    [self.mailVC setSubject:@""];
    [self.mailVC setMessageBody:@"" isHTML:NO];
    
    [self presentViewController:self.mailVC animated:YES completion:nil];
    
    [Flurry logEvent:@"Cant Find"];
}

# pragma mark - Collapse/expand section

- (IBAction)collapseExpandSection:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger section = button.tag;
    
    // toggle section state
    BOOL oldState = [self.sectionStates[@(section)] boolValue];
    BOOL newState = !oldState;
    self.sectionStates[@(section)] = @(newState);
    
    // reload section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

# pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchResultStates = [[NSMutableDictionary alloc] init];
}

# pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    
    // convert items dict to array
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(id key in self.whoToCallItems) {
        NSArray *array = self.whoToCallItems[key];
        [items addObjectsFromArray:array];
    }
    self.searchResults = [items filteredArrayUsingPredicate:resultPredicate];
    
    // clear out search result states on each search
    self.searchResultStates = [[NSMutableDictionary alloc] init];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    self.doNotLoadAgain = YES;
    [self.mailVC dismissViewControllerAnimated:YES completion:^(void){
    }];
}

@end
