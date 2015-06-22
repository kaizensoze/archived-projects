//
//  HBSTDidYouKnowTableViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTDidYouKnowTableViewController.h"
#import "HBSTDidYouKnowTableViewCell.h"
#import "HBSTDidYouKnowItem.h"
#import "HBSTEmptySearchResultTableViewCell.h"

@interface HBSTDidYouKnowTableViewController ()
    @property (strong, nonatomic) NSMutableDictionary *didYouKnowItems;
    @property (strong, nonatomic) NSMutableArray *sections;
    @property (strong, nonatomic) NSMutableDictionary *sectionStates;

    @property (strong, nonatomic) NSArray *searchResults;
    @property (strong, nonatomic) NSMutableDictionary *searchResultStates;

    @property (strong, nonatomic) UIView *loadingOverlayView;

    @property (strong, nonatomic) MFMailComposeViewController *mailVC;
    @property (nonatomic) BOOL doNotLoadAgain;
@end

@implementation HBSTDidYouKnowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation bar
    self.navigationController.navigationBar.barTintColor = [HBSTUtil colorFromHex:@"64964b"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 15, 277, 44)];
    titleLabel.text = @"Did You Know...";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    
    // table view
    self.tableView.backgroundColor = [HBSTUtil colorFromHex:@"e0e0e0"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // search bar
    self.searchDisplayController.searchBar.placeholder = @"Search did you know";
    
    // search results table view
    self.searchDisplayController.searchResultsTableView.backgroundColor = [HBSTUtil colorFromHex:@"e0e0e0"];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"Did you know"];
    
    if (self.doNotLoadAgain || self.searchDisplayController.searchBar.text.length > 0) {
        self.doNotLoadAgain = NO;
        return;
    }
    
    // add loading overlay
    self.loadingOverlayView = [HBSTUtil loadingOverlayView:self.view];
    if (!self.didYouKnowItems) {
        [self.view addSubview:self.loadingOverlayView];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/did-you-know", SITE_DOMAIN, API_PATH];
    [appDelegate.requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        self.sections = [[NSMutableArray alloc] init];
        self.didYouKnowItems = [[NSMutableDictionary alloc] init];
        for (NSDictionary *dict in JSON) {
            HBSTDidYouKnowItem *didYouKnowItem = [[HBSTDidYouKnowItem alloc] initWithDict:dict];
            
            // add section
            NSString *subject = didYouKnowItem.subject;
            NSUInteger section_idx = [self.sections indexOfObject:subject];
            if (section_idx == NSNotFound) {
                [self.sections addObject:subject];
            }
            section_idx = [self.sections indexOfObject:subject];
            
            // add row
            if (!self.didYouKnowItems[@(section_idx)]) {
                self.didYouKnowItems[@(section_idx)] = [[NSMutableArray alloc] init];
            }
            [self.didYouKnowItems[@(section_idx)] addObject:didYouKnowItem];
        }
//        DDLogInfo(@"%@", self.sections);
        
        // initialize everything as unexpanded
        self.sectionStates = [[NSMutableDictionary alloc] init];
        for (int section_idx=0; section_idx < self.sections.count; section_idx++) {
            self.sectionStates[@(section_idx)] = @0;
        }
        
        // remove loading overlay
        [self.loadingOverlayView removeFromSuperview];
        
        [self.tableView reloadData];
        [self.searchDisplayController.searchResultsTableView reloadData];
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
    
    return self.sections.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.text.length > 0 && self.searchResults.count == 0) {
            return 1;
        }
        return self.searchResults.count;
    }
    
    BOOL sectionExpanded = [self.sectionStates[@(section-1)] boolValue];
    if (sectionExpanded) {
        return ((NSArray *)self.didYouKnowItems[@(section-1)]).count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DidYouKnowCell";
    
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
    
    HBSTDidYouKnowTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HBSTDidYouKnowTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                  reuseIdentifier:cellIdentifier];
    }
    
    HBSTDidYouKnowItem *didYouKnowItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        didYouKnowItem = self.searchResults[indexPath.row];
    } else {
        didYouKnowItem = ((NSArray *)self.didYouKnowItems[@(indexPath.section-1)])[indexPath.row];
    }
    
    cell.titleLabel.text = didYouKnowItem.title;
    cell.websiteLabel.text = didYouKnowItem.website;
    cell.emailLabel.text = didYouKnowItem.email;
    cell.phoneLabel.text = didYouKnowItem.phoneNumber;
    
    [HBSTUtil makeLink:cell.websiteLabel];
    [HBSTUtil makeEmailLink:cell.emailLabel];
    [HBSTUtil makePhoneNumberLink:cell.phoneLabel];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBSTDidYouKnowItem *didYouKnowItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.text.length > 0 && self.searchResults.count == 0) {
            return 57;
        }
        didYouKnowItem = self.searchResults[indexPath.row];
    } else {
        didYouKnowItem = ((NSArray *)self.didYouKnowItems[@(indexPath.section-1)])[indexPath.row];
    }
    
    CGSize textSize = [HBSTUtil textSize:didYouKnowItem.title font:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
                                   width:268 height:MAXFLOAT];
    
    float height = 15 + textSize.height;
    if (didYouKnowItem.website.length > 0) {
        height += (15 + 12);
    }
    if (didYouKnowItem.email.length > 0) {
        height += (15 + 12);
    }
    if (didYouKnowItem.phoneNumber.length > 0) {
        height += (15 + 12);
    }
    height += 15;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    
    if (section == 0) {
        return 77;
    }
    
    if (section == self.sections.count + 1) {
        return 57;
    }
    
    NSString *sectionText = self.sections[section-1];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize textSize = [HBSTUtil textSize:sectionText font:font width:236 height:MAXFLOAT];
    float topPadding = 17;
    float bottomPadding = 14;
    float height = topPadding + textSize.height + bottomPadding;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    if (section == 0) {
        CGFloat sectionHeaderHeight = [self tableView:tableView heightForHeaderInSection:section];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, sectionHeaderHeight)];
        view.backgroundColor = [HBSTUtil colorFromHex:@"e0e0e0"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, 274, 50)];
        label.text = @"There are a range of resources, events, and programs available at HBS and throughout Harvard University for you to access.";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        [HBSTUtil adjustText:label width:274 height:MAXFLOAT];
        [view addSubview:label];
        return view;
    }
    
    if (section == self.sections.count + 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 57)];
        
        view.backgroundColor = [UIColor whiteColor];
        
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
    NSString *sectionText = self.sections[section-1];
    UIFont *sectionFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 18, 236, 33)];
    label.text = sectionText;
    label.font = sectionFont;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    [HBSTUtil adjustText:label width:236 height:MAXFLOAT];
    [view addSubview:label];
    
    // expand/collapse image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(277, label.center.y - 5, 18, 11)];
    if ([self.sectionStates[@(section-1)] boolValue]) {
        imageView.image = [UIImage imageNamed:@"collapse.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"expand.png"];
    }
    [view addSubview:imageView];
    
    if ([self.sectionStates[@(section-1)] boolValue]) {
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchDisplayController.searchBar.text.length > 0 && self.searchResults.count == 0) {
            [self cantFind:nil];
            return;
        }
    }
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
    BOOL oldState = [self.sectionStates[@(section-1)] boolValue];
    BOOL newState = !oldState;
    self.sectionStates[@(section-1)] = @(newState);
    
    if (newState) {
        NSString *subject = self.sections[section-1];
        [Flurry logEvent:@"Evergreen Read" withParameters:@{ @"subject": subject }];
    }
    
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
    for(id key in self.didYouKnowItems) {
        NSArray *array = self.didYouKnowItems[key];
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
