//
//  FirstTimeUsersViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/24/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "FirstTimeUsersViewController.h"
#import "LoginViewController.h"
#import "PreSignUpViewController.h"

@interface FirstTimeUsersViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *yesButton;
    @property (weak, nonatomic) IBOutlet UIButton *noButton;
@end

@implementation FirstTimeUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // buttons
    [CustomStyler styleButton:self.yesButton];
    [CustomStyler styleButton:self.noButton];
    
    // adjust height of buttons for iphone 4 resolution and smaller
    if (!IS_IPHONE_5) {
        float adjustedHeight = 387;
        
        // yes button
        CGRect buttonFrame = self.yesButton.frame;
        buttonFrame.origin.y = adjustedHeight;
        self.yesButton.frame = buttonFrame;
        
        // no button
        buttonFrame = self.noButton.frame;
        buttonFrame.origin.y = adjustedHeight;
        self.noButton.frame = buttonFrame;
    }
    
    // custom status bar background
    [self addStatusBarBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"First Time Users Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addStatusBarBackground {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    view.backgroundColor = [Util colorFromHex:@"362f2d"];
    [self.view addSubview:view];
}

@end
