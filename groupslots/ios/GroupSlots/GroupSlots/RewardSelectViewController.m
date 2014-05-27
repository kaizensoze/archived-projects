//
//  RewardSelectViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/6/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardSelectViewController.h"
#import "Reward.h"
#import "RewardCell.h"
#import "RewardFilters.h"
#import "RewardDetailViewController.h"
#import "RewardPointsRange.h"

@interface RewardSelectViewController ()
    @property (strong, nonatomic) NSMutableArray *rewardSearchResults;
    @property (strong, nonatomic) NSMutableArray *filteredRewards;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (weak, nonatomic) IBOutlet UIButton *searchButton;
    @property (strong, nonatomic) UIButton *nameSortButton;
    @property (strong, nonatomic) UIButton *pointsSortButton;
    @property (strong, nonatomic) UIButton *categorySortButton;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RewardSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // background
    self.view.backgroundColor = [Util colorFromHex:@"585757"];
    
    [Util checkForBackButton:self];
    
    // search bar
    [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
    
    // search button
    [Util styleButton2:self.searchButton];
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    
    // table view
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    [self addTestRewards];
    
    if (self.rewardFilters == nil) {
        self.rewardFilters = [[RewardFilters alloc] init];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addTestRewards {
    self.rewardSearchResults = [[NSMutableArray alloc] init];
    [self.rewardSearchResults addObjectsFromArray:appDelegate.testRewards.allValues];
    
    [self.rewardSearchResults sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
    
    self.filteredRewards = [self.rewardSearchResults mutableCopy];
}

- (IBAction)sortRewards:(UIButton *)button {
    // unselect all buttons
    for (UIView *subview in button.superview.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton *)subview).selected = NO;
        }
    }
    
    // select this one
    button.selected = YES;
    
    NSString *sortType = [button.titleLabel.text lowercaseString];
    
    [self.filteredRewards sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:sortType ascending:YES], nil]];
    
    [self.tableView reloadData];
}

- (IBAction)goToRewardFilter:(id)sender {
//    UIViewController *rewardFilterVC = [storyboard instantiateViewControllerWithIdentifier:@"RewardFilter"];
//    appDelegate.deckController.centerController = rewardFilterVC;
//    [self.navigationController pushViewController:rewardFilterVC animated:YES];
    
    [self performSegueWithIdentifier:@"goToRewardFilter" sender:self];
}

- (void)rewardFiltersSelected:(RewardFilters *)rewardFilters {
    self.rewardFilters = rewardFilters;
    
    NSMutableArray *predicates = [NSMutableArray array];
    if (self.rewardFilters.category) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"category = %@", self.rewardFilters.category]];
    }
    if (self.rewardFilters.pointsRange) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"points BETWEEN %@", @[self.rewardFilters.pointsRange.minValue, self.rewardFilters.pointsRange.maxValue]]];
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    self.filteredRewards = [[self.rewardSearchResults filteredArrayUsingPredicate:compoundPredicate] mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredRewards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RewardCell";
    RewardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RewardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Reward *reward = [self.filteredRewards objectAtIndex:indexPath.row];
    
    // image
    [cell.rewardImageView setImageWithURL:[Util makeURL:reward.imageURL]
                         placeholderImage:[UIImage imageNamed:reward.testImagePath]];
    [Util roundCorners:cell.rewardImageView radius:5];
    [Util setBorder:cell.rewardImageView width:1 color:[UIColor whiteColor]];
    
    // name
    cell.nameLabel.text = reward.name;
    
    // points
    cell.pointsLabel.text = [NSString stringWithFormat:@"%@ pts", [reward formattedPoints]];
    
    // category
    cell.categoryLabel.text = reward.category;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // bottom separator
    [Util addSeparator:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 46;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // view
    UIImage *image = [[UIImage imageNamed:@"filter-panel.png"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(46, 5, 46, 5)];
    UIView *view = [[UIImageView alloc] initWithImage:image];
    view.userInteractionEnabled = YES;
    
    // name sort
    if (!self.nameSortButton) {
        UIButton *nameSortButton = [self createSortButton:@"Name"];
        [view addSubview:nameSortButton];
        nameSortButton.frame = CGRectMake(10, 9, 48, 29);
        self.nameSortButton = nameSortButton;
        self.nameSortButton.selected = YES;
    } else {
        [view addSubview:self.nameSortButton];
    }
    
    // points sort
    if (!self.pointsSortButton) {
        UIButton *pointsSortButton = [self createSortButton:@"Points"];
        [view addSubview:pointsSortButton];
        pointsSortButton.frame = CGRectMake(76, 9, 52, 29);
        self.pointsSortButton = pointsSortButton;
    } else {
        [view addSubview:self.pointsSortButton];
    }
    
    // category sort
    // points sort
    if (!self.categorySortButton) {
        UIButton *categorySortButton = [self createSortButton:@"Category"];
        [view addSubview:categorySortButton];
        categorySortButton.frame = CGRectMake(145, 9, 62, 29);
        self.categorySortButton = categorySortButton;
    } else {
        [view addSubview:self.categorySortButton];
    }
    
    // filter button
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton addTarget:self action:@selector(goToRewardFilter:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [Util styleButton2:filterButton];
    filterButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    [view addSubview:filterButton];
    filterButton.frame = CGRectMake(245, 8, 60, 30);
    
    return view;
}

- (UIButton *)createSortButton:(NSString *)title {
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // normal
    [sortButton setTitle:title forState:UIControlStateNormal];
    [sortButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImage *filterSelectedImage = [[UIImage imageNamed:@"filter-selected.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(14, 5, 14, 5)];
    
    // highlighted
    [sortButton setTitle:title forState:UIControlStateHighlighted];
    [sortButton setTitleColor:[Util colorFromHex:@"18ff00"] forState:UIControlStateHighlighted];
    [sortButton setBackgroundImage:filterSelectedImage forState:UIControlStateHighlighted];
    
    // selected
    [sortButton setTitle:title forState:UIControlStateSelected];
    [sortButton setTitleColor:[Util colorFromHex:@"18ff00"] forState:UIControlStateSelected];
    [sortButton setBackgroundImage:filterSelectedImage forState:UIControlStateSelected];
    
    // all states
    [sortButton addTarget:self action:@selector(sortRewards:) forControlEvents:UIControlEventTouchUpInside];
    sortButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    sortButton.adjustsImageWhenHighlighted = NO;
    
    return sortButton;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToRewardFilter"]) {
        RewardFilterViewController *vc = (RewardFilterViewController *)segue.destinationViewController;
        vc.rewardFilters = [self.rewardFilters copy];
        vc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"goToRewardDetail"]) {
        RewardDetailViewController *vc = (RewardDetailViewController *)segue.destinationViewController;
        vc.reward = [self.filteredRewards objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

@end
