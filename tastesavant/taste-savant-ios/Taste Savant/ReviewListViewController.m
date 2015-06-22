//
//  ReviewListViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 2/3/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "ReviewListViewController.h"
#import "ReviewCell.h"
#import "ReviewDetailViewController.h"
#import "User.h"
#import "Restaurant.h"
#import "Review.h"
#import "UserReview.h"
#import "CriticReview.h"
#import "Critic.h"

@interface ReviewListViewController ()
    @property (strong, nonatomic) NSArray *reviews;
    @property (nonatomic) NSInteger totalReviews;
    @property (strong, nonatomic) UITableViewCell *loadMoreTableCell;
@end

@implementation ReviewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self updateReviewsReference];
    
    NSString *titleText;
    
    if (self.restaurant) {
        titleText = self.restaurant.name;
    } else if (self.profile) {
        titleText = self.profile.shortName;
    } else if (self.critic) {
        titleText = self.critic.name;
    }
    
    if (self.restaurantReviewType) {
        titleText = [NSString stringWithFormat:@"%@ Reviews - %@",
                     [self.restaurantReviewType capitalizedString],
                     self.restaurant.name];
    }
    self.navigationItem.title = titleText;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Review List Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.critic = nil;
//    self.profile = nil;
//    self.restaurant = nil;
//    self.restaurantReviewType = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ProfileDelegate

- (void)profileDoneLoading:(User *)profile {
    self.profile = profile;
    [self updateReviewsReference];
    [self.tableView reloadData];
}

#pragma mark - RestaurantDelegate

- (void)restaurantDoneLoading:(Restaurant *)restaurant {
    self.restaurant = restaurant;
    [self updateReviewsReference];
    [self.tableView reloadData];
}

#pragma mark - CriticDelegate

- (void)criticDoneLoading:(Critic *)critic {
    self.critic = critic;
    [self updateReviewsReference];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.reviews.count == 0 || self.reviews.count >= self.totalReviews) {
        return self.reviews.count;
    } else {
        return self.reviews.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *thisCell;
    static NSString *cellIdentifier;
    
    NSUInteger index = indexPath.row;
    if (index == self.reviews.count && self.reviews.count < self.totalReviews) {
        if (!self.loadMoreTableCell) {
            self.loadMoreTableCell = [CustomStyler createLoadMoreTableCell:tableView vc:self];
        }
        thisCell = self.loadMoreTableCell;
    } else {
        cellIdentifier = @"ReviewCell";
        ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ReviewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        Review *review = self.reviews[indexPath.row];
        
        // score image
        cell.scoreImageView.image = [Util runWalkDitchImage:review.score];
        
        // score label
        cell.scoreLabel.text = [Util formattedScore:review.score];
        cell.scoreLabel.textColor = [Util runWalkDitchColor:review.score];
        
        if ([review isKindOfClass:[CriticReview class]]) {
            cell.scoreLabel.hidden = YES;
        } else {
            cell.scoreLabel.hidden = NO;
        }
        
        // publish date
        cell.publishDateLabel.text = [[Util dateToString:review.publishDate dateFormat:@"MMM. dd, yyyy"] uppercaseString];
        
        // subject label
        if (self.profile || self.critic) {
            cell.subjectLabel.text = review.restaurant.name;
        } else {
            cell.subjectLabel.text = review.reviewerName;
        }
        
        // review body text
        cell.reviewBodyTextLabel.text = review.reviewText;
        
        thisCell = cell;
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    if (index < self.reviews.count) {
        return 125;
    } else {
        return LOAD_MORE_CELL_HEIGHT;
    }
}

#pragma mark - Load more

- (IBAction)loadMore:(id)sender {
    // show spinner
    [CustomStyler showLoadMoreSpinner:self.loadMoreTableCell];
    self.loadMoreTableCell = nil;
    
    [self getNextBatch];
}

- (void)getNextBatch {
    if (self.profile) {
        self.profile.delegate = self;
        [self.profile getNextBatchOfReviews];
    } else if (self.restaurant) {
        self.restaurant.delegate = self;
        [self.restaurant getNextBatchOfReviews];
    } else {
        self.critic.delegate = self;
        [self.critic getNextBatchOfReviews];
    }
}

#pragma mark - Update reviews

- (void)updateReviewsReference {
    if (self.critic) {
        self.reviews = self.critic.reviews;
        self.totalReviews = [self.critic.totalReviewCount intValue];
    } else if (self.profile) {
        self.reviews = self.profile.reviews;
        self.totalReviews = self.profile.numReviews;
    } else {
        if ([self.restaurantReviewType isEqualToString:@"critic"]) {
            self.reviews = self.restaurant.criticReviews;
            self.totalReviews = [self.restaurant.numCriticReviews intValue];
        } else if ([self.restaurantReviewType isEqualToString:@"user"]) {
            self.reviews = self.restaurant.userReviews;
            self.totalReviews = [self.restaurant.numUserReviews intValue];
        } else {
            self.reviews = self.restaurant.friendReviews;
            self.totalReviews = [self.restaurant.numFriendReviews intValue];
        }
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToReviewDetail"]) {
        ReviewDetailViewController *reviewDetailVC = (ReviewDetailViewController *)segue.destinationViewController;
        reviewDetailVC.review = self.reviews[self.tableView.indexPathForSelectedRow.row];
        
        // hack to stuff missing data into review object
        if (self.restaurant) {
            reviewDetailVC.review.restaurant = self.restaurant;
        }
        if (self.profile) {
            ((UserReview *)reviewDetailVC.review).user = self.profile;
        }
        if (self.critic) {
            ((CriticReview *)reviewDetailVC.review).critic = self.critic;
        }
    }
}

@end
