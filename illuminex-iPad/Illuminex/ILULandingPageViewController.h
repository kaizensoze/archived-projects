//
//  ILULandingPageViewController.h
//  illuminex
//
//  Created by Joe Gallo on 12/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ILULandingPageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *videoPlayerOverlayView;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (strong, nonatomic) AVPlayer *videoPlayer;

@property (weak, nonatomic) IBOutlet UIView *pullTabView;


@end
