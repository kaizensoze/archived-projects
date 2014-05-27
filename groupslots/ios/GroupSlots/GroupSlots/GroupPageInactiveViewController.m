//
//  GroupPageViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/29/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupPageInactiveViewController.h"
#import "User.h"

@interface GroupPageInactiveViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *nameLabel;
    @property (strong, nonatomic) UIViewController *tutorialVC;
@end

@implementation GroupPageInactiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util loadMainViewControllers];
    
    [Util addChatTab:self];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@", appDelegate.loggedInUser.shortName];
    
    // determine whether or not to show tutorial
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL skipTutorial = [userDefaults boolForKey:@"skipTutorial"];
    if (!skipTutorial) {
        [self showTutorial];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [appDelegate useMainNav:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Util disableChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goToRewardSelect:(id)sender {
    UIViewController *rewardSelectVC = [storyboard instantiateViewControllerWithIdentifier:@"RewardSelect"];
    [self.navigationController pushViewController:rewardSelectVC animated:YES];
}

- (IBAction)toggleChat:(id)sender {
    [appDelegate.viewDeckController toggleBottomViewAnimated:YES];
}

- (void)showTutorial {
    self.tutorialVC = [storyboard instantiateViewControllerWithIdentifier:@"Tutorial1"];
    self.tutorialVC.view.frame = [[UIScreen mainScreen] bounds];
    [appDelegate.viewDeckController.centerController.view addSubview:self.tutorialVC.view];
}

@end
