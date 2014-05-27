//
//  RewardDetailsViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/6/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardDetailViewController.h"
#import "Reward.h"
#import "ChallengeSetupViewController.h"

@interface RewardDetailViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UILabel *rewardNameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rewardPointsLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *rewardImageView;
    @property (weak, nonatomic) IBOutlet UILabel *rewardDetailsLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rewardTermsLabel;
    @property (weak, nonatomic) IBOutlet UIButton *rewardSelectButton;
@end

@implementation RewardDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    float viewHeight = ((UIView *)self.scrollView.subviews[0]).frame.size.height;
    [self.scrollView setContentSize: CGSizeMake(320, viewHeight)];
    ((UIView *)self.scrollView.subviews[0]).backgroundColor = [UIColor clearColor];
    
    [Util styleButton2:self.rewardSelectButton];
    
    [self fillInView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)fillInView {
    [self.rewardImageView setImageWithURL:[Util makeURL:self.reward.imageURL]
                         placeholderImage:[UIImage imageNamed:self.reward.testImagePath]];
    
    self.rewardNameLabel.text = self.reward.name;
    self.rewardPointsLabel.text = [NSString stringWithFormat:@"%@ pts", [self.reward formattedPoints]];
    
    // separator
    UIImage *image = [[UIImage imageNamed:@"table-separator"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *separatorView = [[UIImageView alloc] initWithImage:image];
    
    float imageHeight = image.size.height;
    float cellWidth = self.view.frame.size.width;
    separatorView.frame = CGRectMake(0, 154, cellWidth, imageHeight);
    [self.view addSubview:separatorView];
    
    // reward details
    self.rewardDetailsLabel.text = self.reward.details;
    CGRect rewardDetailsLabelFrame = [self.rewardDetailsLabel textRectForBounds:CGRectMake(23, 213, 260, 77)
                                                         limitedToNumberOfLines:0];
    self.rewardDetailsLabel.frame = rewardDetailsLabelFrame;
    
    // reward terms
    self.rewardTermsLabel.text = self.reward.terms;
    CGRect rewardTermsLabelFrame = [self.rewardTermsLabel textRectForBounds:CGRectMake(23, 315, 260, 77)
                                                         limitedToNumberOfLines:0];
    self.rewardTermsLabel.frame = rewardTermsLabelFrame;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToChallengeSetup"]) {
        ChallengeSetupViewController *vc = (ChallengeSetupViewController *)segue.destinationViewController;
        vc.reward = self.reward;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
