//
//  ReviewFormViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 4/7/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "ReviewFormViewController.h"
#import "User.h"
#import "Restaurant.h"
#import "Review.h"
#import "UserReview.h"
#import "RestaurantViewController.h"
#import "ReviewFormScoreCell.h"
#import "ReviewFormTextCell.h"
#import "ReviewFormText2Cell.h"
#import "ReviewFormSubmitCell.h"

@interface ReviewFormViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) UITextView *activeTextView;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (strong, nonatomic) NSString *loginButtonDetail;
    @property (nonatomic) BOOL updateReview;
@end

@implementation ReviewFormViewController

@synthesize numReviewsToImport = _numReviewsToImport;
@synthesize numReviewsImported = _numReviewsImported;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.loginButtonDetail = @"write a review";
    
    // scroll view
    UIView *scrollViewSubview = ((UIView *)self.scrollView.subviews[0]);
    [self.scrollView setContentSize:scrollViewSubview.frame.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [CustomStyler setAndStyleRestaurantInfo:self.restaurant vc:self linkToRestaurant:YES];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesEnded:)];
    [self.tableView addGestureRecognizer:tapGR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Review Form Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setup {
    if (appDelegate.loggedInUser == nil) {
        [appDelegate showNotLoggedInScreen:self loginButtonDetail:self.loginButtonDetail];
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    } else {
        [appDelegate removeNotLoggedInScreen];
        [self loadExistingReview];
    }
}

#pragma mark - Load existing review

- (void)loadExistingReview {
    NSString *url = [NSString stringWithFormat: @"%@/restaurants/%@/reviews/", API_URL_PREFIX, self.restaurant.slug];
    NSDictionary *params = @{@"user": appDelegate.loggedInUser.username};
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray *reviews = JSON[@"results"];
        
        // no existing review
        if (reviews.count == 0) {
            self.updateReview = NO;
            return;
        }
        
        self.updateReview = YES;
        
        NSDictionary *reviewJSON = reviews[0];
        
        UserReview *review = [[UserReview alloc] init];
        review.includeRestaurant = NO;
        review.includeUser = NO;
        review.delegate = self;
        
        [review import:reviewJSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)reviewDoneLoading:(UserReview *)review {
    ReviewFormScoreCell *cell;

    // overall score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.scoreSlider setValue:review.overallScore];
    [self updateReviewFormCell1:cell];

    // food score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell.scoreSlider setValue:review.foodScore];
    [self updateReviewFormCell1:cell];

    // ambience score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell.scoreSlider setValue:review.ambienceScore];
    [self updateReviewFormCell1:cell];

    // service score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [cell.scoreSlider setValue:review.serviceScore];
    [self updateReviewFormCell1:cell];

    // review text
    ReviewFormTextCell *cell2;
    cell2 = (ReviewFormTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell2.textView.text = review.body;

    // good dishes
    ReviewFormText2Cell *cell3;
    cell3 = (ReviewFormText2Cell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    cell3.textView.text = [review.goodDishes componentsJoinedByString:@", "];

    // bad dishes
    ReviewFormText2Cell *cell4;
    cell4 = (ReviewFormText2Cell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    cell4.textView.text = [review.badDishes componentsJoinedByString:@", "];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    UITableViewCell *thisCell;
    
    NSInteger section = indexPath.section;
    if (section == 0) {
        cellIdentifier = @"ReviewFormScoreCell";
        ReviewFormScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ReviewFormScoreCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        // score type
        NSArray *scoreTypes = @[@"Overall", @"Food", @"Ambience", @"Service"];
        cell.scoreTypeLabel.text = scoreTypes[indexPath.row];
        cell.scoreTypeLabel.textColor = [Util colorFromHex:@"362f2d"];
        
        [self updateReviewFormCell1:cell];
        
        // background color
        if (indexPath.row % 2 == 1) {
            cell.backgroundColor = [Util colorFromHex:@"f7f7f7"];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        thisCell = cell;
    } else if (section == 4) {
        cellIdentifier = @"ReviewFormSubmitCell";
        ReviewFormSubmitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ReviewFormSubmitCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        // remove bottom border
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        
        // submit button
        [CustomStyler styleButton:cell.submitButton];
        
        thisCell = cell;
    } else if (section == 1) {
        cellIdentifier = @"ReviewFormTextCell";
        ReviewFormTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ReviewFormTextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        // review body text view
        [CustomStyler setBorder:cell.textView width:1 color:[Util colorFromHex:@"cccccc"]];
        [CustomStyler roundCorners:cell.textView radius:3];
        
        cell.textView.delegate = self;
        
        thisCell = cell;
    } else {
        cellIdentifier = @"ReviewFormText2Cell";
        ReviewFormText2Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ReviewFormText2Cell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        // review body text view
        [CustomStyler setBorder:cell.textView width:1 color:[Util colorFromHex:@"cccccc"]];
        [CustomStyler roundCorners:cell.textView radius:3];
        
        cell.textView.delegate = self;
        
        if (section == 3) {
            // remove bottom border
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        }
        
        thisCell = cell;
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section == 0) {
        return 69;
    } else if (section == 1) {
        return 190;
    } else if (section == 4) {
        return 76;
    } else {
        return 200;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 4) {
        return 0;
    } else {
        return TABLE_HEADER_HEIGHT;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text;
    if (section == 0) {
        text = @"Your Score";
    } else if (section == 1) {
        text = @"Your Review";
    } else if (section == 2) {
        text = @"Good Dishes";
    } else if (section == 3) {
        text = @"Bad Dishes";
    }
    
    if (!text) {
        return nil;
    } else {
        UIView *view = [CustomStyler createTableHeaderView:tableView str:text];
        return view;
    }
}

#pragma mark - UISlider

- (IBAction)valueChanged:(UISlider *)slider {
    NSUInteger index = (NSUInteger)(slider.value + 0.5);
    
    // update score slider value
    [slider setValue:index animated:NO];
    
    // update containing review form cell
    id view = [slider superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    ReviewFormScoreCell *cell = (ReviewFormScoreCell *)view;
    [self updateReviewFormCell1:cell];
}

- (void)updateReviewFormCell1:(ReviewFormScoreCell *)cell {
    int sliderVal = (int)cell.scoreSlider.value;
    
    UIColor *rwdColor = [Util runWalkDitchColor:[NSNumber numberWithInt:sliderVal]];
    
    // update color of slider
    cell.scoreSlider.minimumTrackTintColor = rwdColor;
    
    // update text and text color of score label
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d/10", sliderVal];
    cell.scoreLabel.textColor = rwdColor;
    
    // update position of score label
    float xPos = [self sliderThumbCenterXPosition:cell.scoreSlider];
    
    CGRect frame = cell.scoreLabel.frame;
    frame.origin.x = xPos - cell.scoreLabel.frame.size.width/2;
    cell.scoreLabel.frame = frame;
}

- (float)sliderThumbCenterXPosition:(UISlider *)slider {
    CGRect trackRect = [slider trackRectForBounds:slider.bounds];
    CGRect thumbRect = [slider thumbRectForBounds:slider.bounds
                                        trackRect:trackRect
                                            value:slider.value];
    float thumbCenterXPos = slider.frame.origin.x + thumbRect.origin.x + thumbRect.size.width/2;
    return thumbCenterXPos;
}

#pragma mark - Submit review

- (IBAction)submitReview:(UIButton *)button {
    // hide keyboard
    [self.view endEditing:YES];
    
    UserReview *review = [[UserReview alloc] init];
    review.user = appDelegate.loggedInUser;
    review.restaurant = self.restaurant;
    review.active = YES;
    
    ReviewFormScoreCell *cell;
    
    // overall score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    review.overallScore = cell.scoreSlider.value;
    
    // food score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    review.foodScore = cell.scoreSlider.value;
    
    // ambience score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    review.ambienceScore = cell.scoreSlider.value;
    
    // service score
    cell = (ReviewFormScoreCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    review.serviceScore = cell.scoreSlider.value;
    
    // general score
    review.score = [NSNumber numberWithFloat:(float)review.overallScore];
    [review setRunWalkDitchValue];
    
    // review text
    ReviewFormTextCell *cell2;
    cell2 = (ReviewFormTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    review.body = cell2.textView.text;
    
    review.summary = review.body;
    
    // publish date
    review.publishDate = [[NSDate alloc] init];
    
    // good dishes
    ReviewFormText2Cell *cell3;
    cell3 = (ReviewFormText2Cell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    NSString *goodDishes = cell3.textView.text;
    
    // bad dishes
    ReviewFormText2Cell *cell4;
    cell4 = (ReviewFormText2Cell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    NSString *badDishes = cell4.textView.text;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:review.restaurant.url forKey:@"restaurant"];
    [params setValue:review.user.url forKey:@"user"];
    [params setValue:review.score forKey:@"score"];
    [params setValue:review.runWalkDitch forKey:@"rwd"];
    [params setValue:[NSNumber numberWithBool:review.active] forKey:@"active"];
    [params setValue:[NSNumber numberWithInt:review.foodScore] forKey:@"food_score"];
    [params setValue:[NSNumber numberWithInt:review.ambienceScore] forKey:@"ambience_score"];
    [params setValue:[NSNumber numberWithInt:review.serviceScore] forKey:@"service_score"];
    [params setValue:[NSNumber numberWithInt:review.overallScore] forKey:@"overall_score"];
    [params setValue:review.summary forKey:@"summary"];
    [params setValue:review.body forKey:@"body"];
    [params setValue:goodDishes forKey:@"good_dishes"];
    [params setValue:badDishes forKey:@"bad_dishes"];
    
    NSString *url = [NSString stringWithFormat: @"%@/restaurants/%@/reviews/", API_URL_PREFIX, review.restaurant.slug];
    
    // either POST (create new review) or PUT (update existing review)
    NSString *method;
    if (self.updateReview) {
        method = @"PUT";
        
        // send some extra params
        [params setValue:review.user.username forKey:@"username"];
        [params setValue:review.restaurant.slug forKey:@"restaurant_slug"];
    } else {
        method = @"POST";
    }
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:method path:url parameters:params];
    
    DDLogInfo(@"%@ %@", request, params);
    
    [Util showHUDWithTitle:@"Submitting review"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Util hideHUD];
        [self performSegueWithIdentifier:@"goToRestaurant" sender:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util hideHUD];
        [Util showNetworkingErrorAlert:operation.response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (IBAction)goToRestaurant:(id)sender {
    [self performSegueWithIdentifier:@"goToRestaurant" sender:self];
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // get table y position
    float tableY = self.tableView.frame.origin.y;
    
    // get row y position
    id view = [self.activeTextView superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    float rowY = ((UIView *)view).frame.origin.y;
    
    // get new y position to scroll to
    float newY = tableY + rowY - TABLE_HEADER_HEIGHT;
    
    CGPoint scrollPoint = CGPointMake(0, newY);
    
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)touchesEnded:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.activeTextView = nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToRestaurant"]) {
        RestaurantViewController *vc = (RestaurantViewController *)segue.destinationViewController;
        vc.restaurantId = self.restaurant.slug;
    }
}

@end
