//
//  BFKIntro4ViewController.m
//  Mosaic
//
//  Created by Joe Gallo on 2/1/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import "BFKIntro3ViewController.h"
#import "BFKAppDelegate.h"

@interface BFKIntro3ViewController ()

@end

@implementation BFKIntro3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)next:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro4"];
}

- (IBAction)prev:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro2"];
}

@end
