//
//  Tutorial5ViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 10/9/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "Tutorial5ViewController.h"

@interface Tutorial5ViewController ()

@end

@implementation Tutorial5ViewController

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
    // re-enable chat and viewdeck panning
    UIViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"Chat"];
    appDelegate.viewDeckController.bottomController = chatVC;
    
    appDelegate.viewDeckController.panningMode = IIViewDeckFullViewPanning;
    
    // make a note that user has viewed tutorial
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"skipTutorial"];
    [userDefaults synchronize];
    
    [self.view removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
