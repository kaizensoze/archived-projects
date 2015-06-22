//
//  Tutorial3ViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 10/9/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "Tutorial3ViewController.h"

@interface Tutorial3ViewController ()
    @property (strong, nonatomic) UIViewController *tutorialVC;
@end

@implementation Tutorial3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util disableChat];
    
    self.view.backgroundColor = [Util colorFromHex:@"090100"];
    self.view.alpha = 0.94;
    
    self.view.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNext:)];
    swipeGR.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGR.delegate = self;
    [self.view addGestureRecognizer:swipeGR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)swipeNext:(id)sender {
    [self.view removeFromSuperview];
    
    self.tutorialVC = [storyboard instantiateViewControllerWithIdentifier:@"Tutorial4"];
    self.tutorialVC.view.frame = [[UIScreen mainScreen] bounds];
    [appDelegate.viewDeckController.centerController.view addSubview:self.tutorialVC.view];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
