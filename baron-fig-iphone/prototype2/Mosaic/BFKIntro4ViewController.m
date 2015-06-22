//
//  BFKIntro5ViewController.m
//  Mosaic
//
//  Created by Joe Gallo on 2/1/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import "BFKIntro4ViewController.h"
#import "BFKAppDelegate.h"

@interface BFKIntro4ViewController ()

@end

@implementation BFKIntro4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)advance:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = appDelegate.viewDeckController;
}

- (IBAction)prev:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro3"];
}

@end
