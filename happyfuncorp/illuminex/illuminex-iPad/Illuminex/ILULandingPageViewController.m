//
//  ILULandingPageViewController.m
//  illuminex
//
//  Created by Joe Gallo on 12/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILULandingPageViewController.h"

@interface ILULandingPageViewController ()

@end

@implementation ILULandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // video player
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *sampleURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"beach" ofType:@"mp4"]];
        AVAsset *asset = [AVAsset assetWithURL:sampleURL];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        
        self.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.videoPlayer.volume = 0;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        playerLayer.videoGravity = AVLayerVideoGravityResize;
        playerLayer.frame = self.videoPlayerView.bounds;
        [self.videoPlayerView.layer addSublayer:playerLayer];
        [self.videoPlayer play];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    appDelegate.viewDeckController.panningMode = IIViewDeckNoPanning;
    
    [self.videoPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.videoPlayer.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:self.videoPlayer.currentItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    appDelegate.viewDeckController.panningMode = IIViewDeckFullViewPanning;
    
    [self.videoPlayer pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Repeat video

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}

#pragma mark - App entered foreground

- (void)appEnteredForeground:(NSNotification *)notification {
//    [self.videoPlayer seekToTime:kCMTimeZero];
    [self.videoPlayer play];
}

#pragma mark - Go to search

- (IBAction)goToSearch:(id)sender {
    UIViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"Search"];
    appDelegate.viewDeckController.centerController = searchVC;
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

@end
