//
//  GroupPageActiveFailureViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/26/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupPageActiveFailureViewController.h"
#import "User.h"
#import "Challenge.h"
#import "Group.h"

@interface GroupPageActiveFailureViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *bummerLabel;
    @property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;
@end

@implementation GroupPageActiveFailureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util disableChat];
    
    self.bummerLabel.text = [NSString stringWithFormat:@"Bummer %@!", appDelegate.loggedInUser.challenge.group.name];
    
    [Util styleButton:self.tryAgainButton];
}

- (IBAction)tryAgain:(id)sender {
    UIViewController *vc = [Util determineActiveOrInactiveGroupVC];
    [Util setCenterViewController:vc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
