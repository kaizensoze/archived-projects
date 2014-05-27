//
//  GroupPageActiveSuccessViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/26/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupPageActiveSuccessViewController.h"
#import "User.h"
#import "Challenge.h"
#import "Group.h"
#import "Reward.h"

@interface GroupPageActiveSuccessViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *wayToGoLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rewardInfoLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *rewardImageView;
    @property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@end

@implementation GroupPageActiveSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util disableChat];
    
    Challenge *challenge = appDelegate.loggedInUser.challenge;
    
    self.wayToGoLabel.text = [NSString stringWithFormat:@"Way to go %@!", challenge.group.name];
    
    self.rewardInfoLabel.text = [NSString stringWithFormat:@"%@ for %d", challenge.reward.name, challenge.group.members.count + 1];
    
    [self.rewardImageView setImageWithURL:[Util makeURL:challenge.reward.imageURL]
                         placeholderImage:[UIImage imageNamed:challenge.reward.testImagePath]];
    
    [Util styleButton:self.playAgainButton];
}

- (IBAction)playAgain:(id)sender {
    UIViewController *vc = [Util determineActiveOrInactiveGroupVC];
    [Util setCenterViewController:vc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
