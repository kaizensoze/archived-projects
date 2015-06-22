//
//  ReviewDetailViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 5/12/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "ReviewDetailViewController.h"
#import "ProfileViewController.h"
#import "RestaurantViewController.h"
#import "ReviewDetailCell.h"
#import "User.h"
#import "Restaurant.h"
#import "Review.h"
#import "UserReview.h"
#import "CriticReview.h"
#import "Critic.h"
#import "ReviewFormViewController.h"

@interface ReviewDetailViewController ()
    @property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    NSString *titleText = self.review.restaurant.name;
    self.navigationItem.title = titleText;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Review Detail Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            static NSString *cellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            CGRect nameLabelFrame;
            NSURL *imageURL;
            
            if ([self.review isKindOfClass:[UserReview class]]) {
                // name label frame
                nameLabelFrame = CGRectMake(10, 16, 238, 21);
                
                UserReview *userReview = (UserReview *)self.review;
                User *user = userReview.user;
                
                // reviewer type / location label
                if (![Util isEmpty:user.reviewerType] && ![Util isEmpty:user.location]) {
                    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 41, 238, 17)];
                    subLabel.text = [NSString stringWithFormat:@"%@ / %@ Resident", user.reviewerTypeDisplay, user.location];
                    subLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
                    subLabel.textColor = [Util colorFromHex:@"362f2d"];
                    [cell.contentView addSubview:subLabel];
                } else {
                    // name label frame
                    nameLabelFrame = CGRectMake(10, 26, 238, 21);
                    
                    // image url
                    imageURL = nil;
                }
                
                // image url
                imageURL = [NSURL URLWithString:userReview.user.imageURL];
            } else {
                // name label frame
                nameLabelFrame = CGRectMake(10, 26, 238, 21);
                
                // image url
                Critic *critic = ((CriticReview *)self.review).critic;
                imageURL = critic.logoURL;
            }
            
            // name label
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
            nameLabel.text = self.review.reviewerName;
            nameLabel.font = [UIFont fontWithName:@"Georgia" size:18];
            nameLabel.textColor = [Util colorFromHex:@"362f2d"];
            [cell.contentView addSubview:nameLabel];
            
            // image view
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 10, 50, 50)];
            imageView.contentMode = UIViewContentModeScaleToFill;
            [imageView setImageWithURL:imageURL
                      placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]];
            [cell.contentView addSubview:imageView];
            self.imageView = imageView;
            
            // background color
            cell.backgroundColor = [Util colorFromHex:@"f7f7f7"];
            
            return cell;
        }
        case 1: {
            static NSString *cellIdentifier = @"ReviewDetailCell";
            ReviewDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ReviewDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            // restaurant name
            cell.restaurantNameLabel.text = self.review.restaurant.name;
            
            // score image
            UIImage *image = [Util runWalkDitchImage:self.review.score];
            cell.scoreImageView.image = image;
            
            // score label
            cell.scoreLabel.text = [Util formattedScore:self.review.score];
            cell.scoreLabel.textColor = [Util runWalkDitchColor:self.review.score];
            if ([self.review isKindOfClass:[CriticReview class]]) {
                cell.scoreLabel.hidden = YES;
            } else {
                cell.scoreLabel.hidden = NO;
            }
            
            // review body text
            cell.reviewBodyTextLabel.text = self.review.reviewText;
            
            // if user review, show additional info
            if ([self.review isKindOfClass:[UserReview class]]) {
                // user review info
                cell.userReviewInfoView.hidden = NO;
                
                UserReview *userReview = (UserReview *)self.review;
                
                // food score
                NSNumber *foodScoreObj = [NSNumber numberWithFloat:userReview.foodScore];
                cell.foodScoreLabel.text = [Util formattedScore:foodScoreObj];
                cell.foodScoreLabel.textColor = [Util runWalkDitchColor:foodScoreObj];
                
                // ambience score
                NSNumber *ambienceScoreObj = [NSNumber numberWithFloat:userReview.ambienceScore];
                cell.ambienceScoreLabel.text = [Util formattedScore:ambienceScoreObj];
                cell.ambienceScoreLabel.textColor = [Util runWalkDitchColor:ambienceScoreObj];
                
                // service score
                NSNumber *serviceScoreObj = [NSNumber numberWithFloat:userReview.serviceScore];
                cell.serviceScoreLabel.text = [Util formattedScore:serviceScoreObj];
                cell.serviceScoreLabel.textColor = [Util runWalkDitchColor:serviceScoreObj];
                
                // edit review button
                if (appDelegate.loggedInUser && [userReview.user isEqual:appDelegate.loggedInUser]) {
                    cell.editReviewButton.hidden = NO;
                } else {
                    cell.editReviewButton.hidden = YES;
                }
            } else {
                // user review info
                cell.userReviewInfoView.hidden = YES;
                
                // edit review button
                cell.editReviewButton.hidden = YES;
            }
            
            // good dishes
            if (self.review.goodDishes.count == 0) {
                cell.goodDishesLabel.hidden = YES;
            } else {
                cell.goodDishesLabel.hidden = NO;
                
                NSString *prefix = @"OUTSTANDING DISHES:\n";
                NSString *goodDishesStr = [self.review.goodDishes componentsJoinedByString:@", "];
                
                UIFont *font1 = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
                UIFont *font2 = [UIFont fontWithName:@"Helvetica" size:12.0];
                
                NSString *str = [NSString stringWithFormat:@"%@%@", prefix, goodDishesStr];
                
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
                [attrStr addAttribute:NSFontAttributeName value:font1 range:(NSMakeRange(0, prefix.length))];
                [attrStr addAttribute:NSFontAttributeName value:font2 range:(NSMakeRange(prefix.length, goodDishesStr.length))];
                
                cell.goodDishesLabel.attributedText = attrStr;
                
                [Util adjustText:cell.goodDishesLabel width:217 height:MAXFLOAT];
                
                // issue with newline for adjustText so enforce a minimum width
                float minWidth = 150.0;
                if (cell.goodDishesLabel.frame.size.width < minWidth) {
                    CGRect frame = cell.goodDishesLabel.frame;
                    frame.size.width = minWidth;
                    cell.goodDishesLabel.frame = frame;
                }
                
                // update y position of good dishes label
                CGSize reviewBodyTextLabelSize = [Util textSize:cell.reviewBodyTextLabel.text
                                                           font:cell.reviewBodyTextLabel.font
                                                          width:217 height:MAXFLOAT];
                
                float newY = cell.reviewBodyTextLabel.frame.origin.y + reviewBodyTextLabelSize.height + 15;
                
                CGRect goodDishesFrame = cell.goodDishesLabel.frame;
                goodDishesFrame.origin.y = newY;
                cell.goodDishesLabel.frame = goodDishesFrame;
                
                newY = cell.goodDishesLabel.frame.origin.y + cell.goodDishesLabel.frame.size.height + 15;
                
                // update y position of edit review button
                CGRect editButtonFrame = cell.editReviewButton.frame;
                editButtonFrame.origin.y = newY;
                cell.editReviewButton.frame = editButtonFrame;
            }
            
            return cell;
        }
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 70;
    } else {
        ReviewDetailCell *cell = (ReviewDetailCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        float height = 80;
        
        // review body label
        CGSize reviewTextLabelSize = [Util textSize:self.review.reviewText
                                               font:cell.reviewBodyTextLabel.font
                                              width:217 height:MAXFLOAT];
        float reviewTextLabelHeight = reviewTextLabelSize.height;
        
        if ([self.review isKindOfClass:[UserReview class]]) {
            height += MAX(reviewTextLabelHeight, 226);
        } else {
            height += MAX(reviewTextLabelHeight, 85);
        }
        
        height += 15;
        
        // good dishes label
        if (self.review.goodDishes.count > 0) {
            CGSize goodDishesLabelSize = [Util textSize:cell.goodDishesLabel.text
                                                   font:[UIFont systemFontOfSize:12.0]
                                                  width:217
                                                 height:MAXFLOAT];
            
            height += goodDishesLabelSize.height;
        }
        
        height += 15;
        
        // edit review button
        height += cell.editReviewButton.frame.size.height;
        
        height += 10;
        
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // removes last separator
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"goToProfile" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"goToRestaurant" sender:nil];
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToProfile"]) {
        ProfileViewController *profileVC = (ProfileViewController *)segue.destinationViewController;
        
        if ([self.review class] == [UserReview class]) {
            profileVC.requestedProfileId = ((UserReview *)self.review).user.username;
        } else {
            profileVC.requestedCriticId = ((CriticReview *)self.review).slug;
            
        }
    }
    
    if ([[segue identifier] isEqualToString:@"goToRestaurant"]) {
        RestaurantViewController *restaurantVC = (RestaurantViewController *)segue.destinationViewController;
        restaurantVC.restaurantId = self.review.restaurant.slug;
    }
    
    if ([[segue identifier] isEqualToString:@"goToReviewForm"]) {
        ReviewFormViewController *reviewFormVC = (ReviewFormViewController *)segue.destinationViewController;
        reviewFormVC.restaurant = self.review.restaurant;
    }
}

@end
