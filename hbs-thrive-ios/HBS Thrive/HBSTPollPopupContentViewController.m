//
//  HBSTPollPopupContentViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 9/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTPollPopupContentViewController.h"
#import "HBSTPollChoiceTableViewCell.h"

@interface HBSTPollPopupContentViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UILabel *questionLabel;
    @property (weak, nonatomic) IBOutlet UITableView *choicesTableView;
    @property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
    @property (weak, nonatomic) IBOutlet UIView *resultsView;

    @property (strong, nonatomic) NSDictionary *choices;
@end

@implementation HBSTPollPopupContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.questionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    self.questionLabel.textColor = [UIColor whiteColor];
    
    self.choicesTableView.layer.cornerRadius = 7;
    
    if ([self.pollJSON[@"Meta"][@"Status"] isEqualToString:@"Success"]) {
        // question
        self.questionLabel.text = self.pollJSON[@"Result"][@"Definition"][@"Question"];
        [HBSTUtil adjustText:self.questionLabel width:238 height:MAXFLOAT];
        
        // choices
        self.choices = self.pollJSON[@"Result"][@"Definition"][@"Choices"];
        
        // adjust choices table view
        CGRect frame = self.choicesTableView.frame;
        frame.origin.y = self.questionLabel.frame.origin.y + self.questionLabel.frame.size.height + 30;
        self.choicesTableView.frame = frame;
    }
    
    // if user already answered poll or is nonstudent, just show results
    NSString *pollId = self.pollJSON[@"PollID"];
    NSDictionary *answeredPolls = [userDefaults objectForKey:@"answeredPolls"];
    
    BOOL isNonstudent = [userDefaults boolForKey:@"isNonstudent"];
    
    if ((answeredPolls && answeredPolls[pollId]) || isNonstudent) {
        self.choicesTableView.hidden = YES;
        self.activityImageView.hidden = NO;
        [HBSTUtil rotateLayerInfinite:self.activityImageView.layer];
        
        [self getPollResults];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.choicesTableView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.choicesTableView removeObserver:self forKeyPath:@"contentSize" context:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGRect frame = self.choicesTableView.frame;
    frame.size = self.choicesTableView.contentSize;
    self.choicesTableView.frame = frame;
    
    float scrollViewHeight = self.choicesTableView.frame.origin.y + self.choicesTableView.contentSize.height;
    if (IS_3_5_SCREEN) {
        scrollViewHeight += 120; // DISCLAIMER: I'm honestly not sure why a +120 is required here.
    }
    [self.scrollView setContentSize:CGSizeMake(280, scrollViewHeight)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.choices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PollChoiceCell";
    HBSTPollChoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HBSTPollChoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *key = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    cell.choiceLabel.text = self.choices[key];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *choice = [NSString stringWithFormat:@"%ld", indexPath.row+1];
    [self submitPollChoice:choice];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    HBSTPollChoiceTableViewCell *cell = (HBSTPollChoiceTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.choiceLabel.textColor = [HBSTUtil colorFromHex:@"64964b"];
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

#pragma mark - Submit Poll Choice

- (void)submitPollChoice:(NSString *)choice {
    NSString *pollId = self.pollJSON[@"PollID"];
    
    // hide choices and show loading indicator
    self.choicesTableView.hidden = YES;
    self.activityImageView.hidden = NO;
    [HBSTUtil rotateLayerInfinite:self.activityImageView.layer];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/poll-submit", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = @{ @"poll_id": pollId, @"choice": choice };
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        BOOL submitSuccessful = [JSON[@"success"] boolValue];
        if (submitSuccessful) {
            // store answered poll on device
            if (![userDefaults objectForKey:@"answeredPolls"]) {
                [userDefaults setObject:@{} forKey:@"answeredPolls"];
                [userDefaults synchronize];
            }
            
            [Flurry logEvent:@"Poll:Answer" withParameters:@{ @"pollid": pollId }];
            
            NSMutableDictionary *answeredPolls = [[userDefaults objectForKey:@"answeredPolls"] mutableCopy];
            [answeredPolls setObject:choice forKey:pollId];
            [userDefaults setObject:[answeredPolls copy] forKey:@"answeredPolls"];
            [userDefaults synchronize];
            
            // remove poll from unanswered polls on device
            NSMutableArray *unansweredPolls = [[userDefaults objectForKey:@"unansweredPolls"] mutableCopy];
            if (unansweredPolls) {
                [unansweredPolls removeObject:pollId];
                [userDefaults setObject:[unansweredPolls copy] forKey:@"unansweredPolls"];
                [userDefaults synchronize];
                
                if (unansweredPolls.count == 0) {
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }
            }
            
            [self getPollResults];
        } else {
            self.activityImageView.hidden = YES;
            
            if (JSON[@"errors"]) {
                [HBSTUtil showErrorAlert:JSON[@"errors"][0] delegate:self];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
    }];
}

#pragma mark - Get Poll Results

- (void)getPollResults {
    NSString *pollId = self.pollJSON[@"PollID"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/poll-results", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = @{
                                 @"poll_id": pollId,
                                 @"server_no_adjust": @"blah"
                                 };
    [appDelegate.requestManager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        if (JSON[@"errors"]) {
            [HBSTUtil showErrorAlert:JSON[@"errors"][0] delegate:self];
        } else {
//            DDLogInfo(@"%@", JSON);
            
            NSDictionary *pollResults;
            if ([JSON[@"Result"][@"Payload"] isKindOfClass:[NSString class]]) {  // handle case for brand new poll [with no results]
                pollResults = @{};
            } else {
                pollResults = JSON[@"Result"][@"Payload"];
            }
            
            [self drawPollResults:pollResults pollId:pollId];
        }
        
        self.activityImageView.hidden = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
    }];
}

#pragma mark - Draw Poll Results

- (void)drawPollResults:(NSDictionary *)pollResults pollId:(NSString *)pollId {
    int TOP_STEM_HEIGHT = 8;
    int CHOICE_HEIGHT = 45;
    int BOTTOM_STEM_HEIGHT = 4;
    int LINE_X_POS = 38;
    int MAX_BAR_WIDTH = 160;
    
    // remove all subviews
    [self.resultsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // adjust height of results view
    CGRect frame = self.resultsView.frame;
    frame.origin.y = self.questionLabel.frame.origin.y + self.questionLabel.frame.size.height + 35;
    frame.size.height = TOP_STEM_HEIGHT + (45 * self.choices.count) + BOTTOM_STEM_HEIGHT;
    self.resultsView.frame = frame;
    
    // adjust scrollview
    float scrollViewHeight = self.resultsView.frame.origin.y + self.resultsView.frame.size.height;
    if (IS_3_5_SCREEN) {
        scrollViewHeight += 120;
    }
    [self.scrollView setContentSize:CGSizeMake(280, scrollViewHeight)];
    
    // get selected choice
    BOOL isNonstudent = [userDefaults boolForKey:@"isNonstudent"];
    if (!isNonstudent) {
        NSString *selectedChoice = [userDefaults objectForKey:@"answeredPolls"][pollId];
        int selectedChoiceInt = [selectedChoice intValue];
        
        // add selected choice icon
        int yPos = TOP_STEM_HEIGHT + (selectedChoiceInt - 1) * CHOICE_HEIGHT + 3;
        UIImageView *selectedChoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPos, 25, 25)];
        selectedChoiceImageView.image = [UIImage imageNamed:@"poll-choice-icon.png"];
        [self.resultsView addSubview:selectedChoiceImageView];
    }
    
    // add vertical line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(LINE_X_POS, 0, 1, self.resultsView.bounds.size.height)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.resultsView addSubview:lineView];
    
    // get max votes
    NSArray *sortedVoteKeys = [pollResults keysSortedByValueUsingSelector:@selector(compare:)];
    NSString *maxVoteKey = [sortedVoteKeys lastObject];
    NSString *maxVotes = pollResults[maxVoteKey];
    int maxVotesInt = [maxVotes intValue];
    
    // add choices
    NSArray *sortedChoices = [self.choices.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (int i=0; i < sortedChoices.count; i++) {
        NSString *choice = sortedChoices[i];
        NSString *choiceTitle = self.choices[choice];
        
        int yPos = TOP_STEM_HEIGHT + (i * CHOICE_HEIGHT);
        
        // add choice label
        UILabel *choiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, yPos, 190, 16)];
        choiceLabel.text = choiceTitle;
        choiceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        choiceLabel.textColor = [UIColor whiteColor];
        [self.resultsView addSubview:choiceLabel];
        
        // add bar
        NSString *choiceVotes = pollResults[choice];
        int choiceVotesInt = [choiceVotes intValue];

        int barWidth;
        if (maxVotesInt == 0) {
            barWidth = 0;
        } else {
            barWidth = ((float)choiceVotesInt / (float)maxVotesInt) * MAX_BAR_WIDTH;
        }
        int barYPos = yPos + choiceLabel.frame.size.height + 5;
        
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(LINE_X_POS + 1, barYPos, barWidth, 10)];
        barView.backgroundColor = [UIColor whiteColor];
        [self.resultsView addSubview:barView];
        
        // add votes label
        int xPos = LINE_X_POS + 1 + barWidth + 5;
        
        UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, barYPos + 1, 50, 8)];
        votesLabel.text = [NSString stringWithFormat:@"%d Votes", choiceVotesInt];
        votesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        votesLabel.textColor = [UIColor whiteColor];
        [self.resultsView addSubview:votesLabel];
    }
    
    // show
    self.resultsView.hidden = NO;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.choicesTableView.hidden = NO;
    [self.choicesTableView reloadData];
}

@end
