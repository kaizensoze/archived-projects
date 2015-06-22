//
//  GroupPageActiveViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/21/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupPageActiveViewController.h"
#import "User.h"
#import "Group.h"
#import "Challenge.h"
#import "Reward.h"
#import "JDFlipNumberView.h"
#import "MDRadialProgressView.h"
#include <stdlib.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GroupPageActiveFailureViewController.h"
#import "GroupPageActiveSuccessViewController.h"

@interface GroupPageActiveViewController ()
    @property (strong, nonatomic) Challenge *challenge;

    // level
    @property (weak, nonatomic) IBOutlet UILabel *levelLabel;
    @property (strong, nonatomic) JDFlipNumberView *challengeLevelNumberView;

    // challenge dial
    @property (weak, nonatomic) IBOutlet UIImageView *challengeDialImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *preRollImageView;
    @property (strong, nonatomic) JDFlipNumberView *pointsNumberView;
    @property (strong, nonatomic) MDRadialProgressView *pointsMeter;
    @property (strong, nonatomic) JDFlipNumberView *hoursNumberView;
    @property (strong, nonatomic) JDFlipNumberView *minutesNumberView;
    @property (strong, nonatomic) UIButton *startChallengeButton;
    @property (strong, nonatomic) UILabel *challengeDurationLabel;

    // big win dial
    @property (strong, nonatomic) UIImageView *bigWinDialImageView;
    @property (strong, nonatomic) JDFlipNumberView *bigWinNumberView;

    // level up dial
    @property (strong, nonatomic) UIImageView *levelUpDialImageView;
    @property (strong, nonatomic) JDFlipNumberView *levelUpNumberView;

    // thresholds
    @property (nonatomic) int countdownThreshold;
    @property (nonatomic) int bigWinThreshold;

    // previous score
    @property (nonatomic) int oldPoints;

    // leaderboard
    @property (weak, nonatomic) IBOutlet UILabel *leaderboardLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *leaderboardImageView;

    // reward
    @property (weak, nonatomic) IBOutlet UIImageView *rewardImageView;
    @property (weak, nonatomic) IBOutlet UILabel *playingForLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rewardNameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *numPlayingLabel;

    @property (strong, nonatomic) NSTimer *timer;
    @property (strong, nonatomic) NSTimer *timer2;

    @property (strong, nonatomic) NSDate *lastWinTime;

    @property (strong, nonatomic) GroupPageActiveSuccessViewController *winVC;
    @property (strong, nonatomic) GroupPageActiveFailureViewController *loseVC;
@end

@implementation GroupPageActiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util loadMainViewControllers];
    
    [Util addChatTab:self];
    
    self.winVC = [storyboard instantiateViewControllerWithIdentifier:@"GroupPageActiveSuccess"];
    self.loseVC = [storyboard instantiateViewControllerWithIdentifier:@"GroupPageActiveFailure"];
    
    // current challenge
    self.challenge = appDelegate.loggedInUser.challenge;
    
    // challenge level
    JDFlipNumberView *challengeLevelNumberView = [[JDFlipNumberView alloc] init];
    [self.view addSubview:challengeLevelNumberView];
    challengeLevelNumberView.frame = CGRectMake(286, 16, 52, 52);
    self.challengeLevelNumberView = challengeLevelNumberView;
    
    // points
    JDFlipNumberView *pointsNumberView = [[JDFlipNumberView alloc] initWithDigitCount:5];
    [self.view addSubview:pointsNumberView];
    pointsNumberView.frame = CGRectMake(84, 142, 175, 70);
    self.pointsNumberView = pointsNumberView;
    
    // hours
    JDFlipNumberView *hoursNumberView = [[JDFlipNumberView alloc] initWithDigitCount:2];
    hoursNumberView.hidden = YES;
    [self.view addSubview:hoursNumberView];
    hoursNumberView.frame = CGRectMake(102, 231, 100, 50);
    self.hoursNumberView = hoursNumberView;
    
    // minutes
    JDFlipNumberView *minutesNumberView = [[JDFlipNumberView alloc] initWithDigitCount:2];
    [self.view addSubview:minutesNumberView];
    minutesNumberView.hidden = YES;
    minutesNumberView.frame = CGRectMake(165, 231, 100, 50);
    self.minutesNumberView = minutesNumberView;
    
    // set time left
    [self updateTimeLeft:NO];
    
    // points meter
    [self createPointsMeter];
    
    // countdown threshold
    self.countdownThreshold = 30;  // in seconds
    
    // big win threshold
    self.bigWinThreshold = 300;
    
    // previous score
    self.oldPoints = 0;
    
    // label text colors
    self.playingForLabel.textColor = [Util colorFromHex:@"f0f0f0"];
    self.rewardNameLabel.textColor = [Util colorFromHex:@"f8f8f8"];
    self.numPlayingLabel.textColor = [Util colorFromHex:@"f8f8f8"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [appDelegate useMainNav:self];
    
    // update page
    [self update];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self killTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Util disableChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createPointsMeter {
    MDRadialProgressView *radialProgressView = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(42, 66, 237, 237)];
    radialProgressView.incompletedColor = [Util colorFromHex:@"414141"];
    radialProgressView.completedColor = [Util colorFromHex:@"49fc02"];
    radialProgressView.sliceDividerColor = [Util colorFromHex:@"232323"];
    radialProgressView.backgroundColor = [UIColor clearColor];
    radialProgressView.progressTotal = 60;
    radialProgressView.startingSlice = 31;
    radialProgressView.clockwise = YES;
    radialProgressView.thickness = 16;
    [self.pointsMeter removeFromSuperview];
    [self.view insertSubview:radialProgressView belowSubview:self.challengeDialImageView];
    self.pointsMeter = radialProgressView;
}

- (void)update {
    // current challenge
    self.challenge = appDelegate.loggedInUser.challenge;
    
    // set challenge level
    self.challengeLevelNumberView.value = self.challenge.currentStage;
    
    // clear pre start dial stuff
    [self clearPreStartChallengeDial];
    
    // challenge dial
    [self updateChallengeDial];
    
    // time left
    [self updateTimeLeft:YES];
    
    // update points
    [self updatePoints];
    
    // reward
    [self updateRewardInfo];
}

# pragma mark - Time left

- (void)updateTimeLeft:(BOOL)animate {
    if (!self.challenge.active) {
        // don't show time left
        self.hoursNumberView.hidden = YES;
        self.minutesNumberView.hidden = YES;
    } else {
        NSTimeInterval secondsSinceActivation = [[NSDate date] timeIntervalSinceDate:self.challenge.activationTime];
        double challengeDuration = (double)self.challenge.timeLimit;
        
        double timeLeft = challengeDuration - secondsSinceActivation;
        timeLeft = (timeLeft < 0) ? 0 : timeLeft; // don't let it go below 0
        
        int hoursLeft = timeLeft / 60;  // timeLeft / (60*60)
        int minutesLeft = (int)timeLeft % 60;  // ((int)timeLeft % (60*60)) / 60;
        
        if (timeLeft <= 0) {
            [self lostChallenge];
            return;
        }
        
        if (!animate) {
            self.hoursNumberView.value = hoursLeft;
            self.minutesNumberView.value = minutesLeft;
        } else {
            [self.hoursNumberView animateToValue:hoursLeft duration:0.15];
            [self.minutesNumberView animateToValue:minutesLeft duration:0.15];
        }
        
        self.hoursNumberView.hidden = NO;
        self.minutesNumberView.hidden = NO;
    }
}

- (BOOL)shouldStartCountdown {
    NSTimeInterval secondsSinceActivation = [[NSDate date] timeIntervalSinceDate:self.challenge.activationTime];
    int challengeDuration = self.challenge.timeLimit;
    int timeRemaining = challengeDuration - secondsSinceActivation;
    return timeRemaining <= self.countdownThreshold;
}

#pragma mark - Update points

- (void)updatePoints {
    if (self.challenge.active) {
        // update number view
        [self.pointsNumberView animateToValue:self.challenge.currentPoints duration:0.25 completion:^(BOOL finished) {
            // update meter
            [self updatePointsMeter];
            
            // check for level up (even if team got big win to level up, just skip it and show level up)
            if (self.challenge.currentPoints >= self.challenge.reward.points) {
                double delayInSeconds = 1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    if (!self.levelUpDialImageView) {
                        [self wonChallenge];
                    }
                });
            } else {
                // check for big win
                int pointsWon = self.challenge.currentPoints - self.oldPoints;  // FIXME: for demo only
                if (pointsWon >= self.bigWinThreshold) {
                    double delayInSeconds = 0.4;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                        if (!self.bigWinDialImageView) {
                            [self showBigWin:pointsWon];
                        }
                    });
                }
            }
        }];
    }
    
//    DDLogInfo(@"Points: %@/%d", self.challenge.currentPoints, self.challenge.reward.points);
}

- (void)updatePointsMeter {
    if (!self.challenge.active) {
        self.pointsMeter.progressCounter = 0;
    } else {
        double currentPoints = (double)self.challenge.currentPoints;
        double rewardPoints = (double)self.challenge.reward.points;
        
        double pointsCompletePercent =  currentPoints / rewardPoints;
        pointsCompletePercent = (pointsCompletePercent < 1) ? pointsCompletePercent : 1;
        
        int numPointsComplete = pointsCompletePercent * self.pointsMeter.progressTotal;
        
        [self createPointsMeter];
        self.pointsMeter.progressCounter = numPointsComplete;
    }
}

# pragma mark - Clear pre start dial

- (void)clearPreStartChallengeDial {
    [self.startChallengeButton removeFromSuperview];
    [self.challengeDurationLabel removeFromSuperview];
}

#pragma mark - Update challenge dial

- (void)updateChallengeDial {
    if (!self.challenge.active) {
        [self setPreStartChallengeDial];
    } else if ([self shouldStartCountdown]) {
        [self setRedChallengeDial];
    } else {
        [self setBlackChallengeDial];
    }
}

- (void)setPreStartChallengeDial {
    // dial image
    self.challengeDialImageView.image = [UIImage imageNamed:@"challenge-dial-black-pre-start.png"];
    
    // start button
    UIButton *startChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startChallengeButton setImage:[UIImage imageNamed:@"challenge-dial-start-button.png"] forState:UIControlStateNormal];
    [startChallengeButton addTarget:self action:@selector(startChallenge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startChallengeButton];
    startChallengeButton.frame = CGRectMake(109, 192, 103, 55);
    self.startChallengeButton = startChallengeButton;
    
    // challenge duration
    UILabel *challengeDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(123, 251, 100, 21)];
    challengeDurationLabel.text = [NSString stringWithFormat:@"%d min challenge", self.challenge.timeLimit / 60];
    challengeDurationLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    challengeDurationLabel.textColor = [UIColor whiteColor];
    challengeDurationLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:challengeDurationLabel];
    self.challengeDurationLabel = challengeDurationLabel;
    
    // set points to points needed
    self.pointsNumberView.value = self.challenge.reward.points;
}

- (void)setBlackChallengeDial {
    // dial image
    self.challengeDialImageView.image = [UIImage imageNamed:@"challenge-dial-black.png"];
    
    // stop pre-roll animation
    [self stopPreRoll];
}

- (void)setRedChallengeDial {
    // dial image
    self.challengeDialImageView.image = [UIImage imageNamed:@"challenge-dial-red.png"];
    
    // start pre-roll animation
    [self startPreRoll];
}

# pragma mark - Pre-roll

- (void)startPreRoll {
    if (![self.preRollImageView.layer animationForKey:@"SpinAnimation"]) {
        self.preRollImageView.hidden = NO;
        self.preRollImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:2*M_PI];
        animation.duration = 1.0f;
        animation.repeatCount = INFINITY;
        [self.preRollImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
    }
}

- (void)stopPreRoll {
    self.preRollImageView.hidden = YES;
    [self.preRollImageView.layer removeAnimationForKey:@"SpinAnimation"];
}

#pragma mark - Start challenge

- (IBAction)startChallenge:(id)sender {
    // activate challenge
    appDelegate.loggedInUser.challenge.active = YES;
    [appDelegate saveLoggedInUserToDevice];
    
    // initialize points to 0
    self.pointsNumberView.value = self.challenge.currentPoints;
    
    // set time left
    [self updateTimeLeft:NO];
    
    [self update];
    
    // timer
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(update)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    if (!self.timer2) {
        self.timer2 = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(checkForNewSlotMachineWin)
                                                     userInfo:nil
                                                     repeats:YES];
    }
}

# pragma mark - Reward info

- (void)updateRewardInfo {
    // reward image
    self.rewardImageView.image = [UIImage imageNamed:self.challenge.reward.testImagePath];
    
    // reward name
    self.rewardNameLabel.text = self.challenge.reward.name;
    
    // num playing
    self.numPlayingLabel.text = [NSString stringWithFormat:@"%d People", self.challenge.group.members.count + 1];
}

#pragma mark - Big win

- (void)showBigWin:(int)bigWinPoints {
    // big win view
    UIImage *image = [UIImage imageNamed:@"big-win.png"];
    self.bigWinDialImageView = [[UIImageView alloc] initWithImage:image];
    self.bigWinDialImageView.userInteractionEnabled = YES;
    self.bigWinDialImageView.hidden = YES;
    [self.view addSubview:self.bigWinDialImageView];
    self.bigWinDialImageView.frame = CGRectMake(21, 60, 275, 275);
    
    // points meter
    MDRadialProgressView *pointsMeter = [self copyPointsMeter];
    pointsMeter.progressCounter = self.pointsMeter.progressCounter;
    [self.bigWinDialImageView addSubview:pointsMeter];
    pointsMeter.frame = CGRectMake(16, 6, 243, 243);
    
    // close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage imageNamed:@"big-win-close.png"];
    [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeScaledDial) forControlEvents:UIControlEventTouchUpInside];
    [self.bigWinDialImageView addSubview:closeButton];
    closeButton.frame = CGRectMake(191, 12, 31, 32);
    
    // big win number view
    JDFlipNumberView *bigWinNumberView = [[JDFlipNumberView alloc] initWithDigitCount:3];
    [self.bigWinDialImageView addSubview:bigWinNumberView];
    bigWinNumberView.frame = CGRectMake(66, 82, 152, 106);
    self.bigWinNumberView = bigWinNumberView;
    
    // pick a winner at random [for demo]
    NSString *randomUserKey = appDelegate.testUsers.allKeys[arc4random() % appDelegate.testUsers.allKeys.count];
    User *randomWinner = appDelegate.testUsers[randomUserKey];
    
    // label
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%@ just won\n%d points!", randomWinner.shortName, bigWinPoints];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.bigWinDialImageView addSubview:label];
    label.frame = CGRectMake(75, 168, 125, 25);
//    [Util setBorder:label width:1 color:[UIColor greenColor]];
    
    // format points remaining
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *pointsRemaining = [NSNumber numberWithInt:(self.challenge.reward.points - self.challenge.currentPoints)];
    NSString *formattedPointsRemaining = [formatter stringFromNumber:pointsRemaining];
    
    label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"Keep going! You're only %@ points\nfrom winning %@.",
                  formattedPointsRemaining,
                  self.challenge.reward.name];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:6];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.bigWinDialImageView addSubview:label];
    label.frame = CGRectMake(75, 192, 125, 25);
//    [Util setBorder:label width:1 color:[UIColor greenColor]];
    
    // facebook share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *shareImage = [UIImage imageNamed:@"facebook-share.png"];
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bigWinDialImageView addSubview:shareButton];
    shareButton.frame = CGRectMake(100, 220, 70, 12);
    
    self.bigWinDialImageView.hidden = NO;
    
    [self playBigWinSound];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:(void (^)(void)) ^{
                         self.bigWinDialImageView.transform=CGAffineTransformMakeScale(1.55, 1.55);
                     }
                     completion:^(BOOL finished){
                         [self.bigWinNumberView animateToValue:bigWinPoints duration:0.3];
                     }];
}

- (void)playBigWinSound {
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"level-up-2" ofType:@"mp3"];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL fileURLWithPath:soundPath], &sound);
    AudioServicesPlaySystemSound(sound);
}

#pragma mark - Level up

- (void)showLevelUp:(int)completedStage {
    // level up view
    UIImage *image = [UIImage imageNamed:@"level-up.png"];
    self.levelUpDialImageView = [[UIImageView alloc] initWithImage:image];
    self.levelUpDialImageView.userInteractionEnabled = YES;
    self.levelUpDialImageView.hidden = YES;
    [self.view addSubview:self.levelUpDialImageView];
    self.levelUpDialImageView.frame = CGRectMake(21, 60, 275, 275);
    
    // points meter
    MDRadialProgressView *pointsMeter = [self copyPointsMeter];
    pointsMeter.progressCounter = pointsMeter.progressTotal;
    [self.levelUpDialImageView addSubview:pointsMeter];
    pointsMeter.frame = CGRectMake(16, 6, 243, 243);
    
    // close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage imageNamed:@"big-win-close.png"];
    [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeScaledDial) forControlEvents:UIControlEventTouchUpInside];
    [self.levelUpDialImageView addSubview:closeButton];
    closeButton.frame = CGRectMake(191, 12, 31, 32);
    
    // level up number view
    JDFlipNumberView *levelUpNumberView = [[JDFlipNumberView alloc] init];
    levelUpNumberView.value = completedStage;
    [self.levelUpDialImageView addSubview:levelUpNumberView];
    levelUpNumberView.frame = CGRectMake(109, 82, 125, 96);
    self.levelUpNumberView = levelUpNumberView;
    
    // label
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Congratulations";
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:9];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.levelUpDialImageView addSubview:label];
    label.frame = CGRectMake(97, 184, 79, 15);
//    [Util setBorder:label width:1 color:[UIColor greenColor]];
    
    label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%@", self.challenge.group.name];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.levelUpDialImageView addSubview:label];
    label.frame = CGRectMake(85, 192, 105, 27);
//    [Util setBorder:label width:1 color:[UIColor greenColor]];
    
    // facebook share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *shareImage = [UIImage imageNamed:@"facebook-share.png"];
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.levelUpDialImageView addSubview:shareButton];
    shareButton.frame = CGRectMake(100, 220, 70, 12);
    
    self.levelUpDialImageView.hidden = NO;
    
    [self playLevelUpSound];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:(void (^)(void)) ^{
                         self.levelUpDialImageView.transform=CGAffineTransformMakeScale(1.55, 1.55);
                     }
                     completion:^(BOOL finished){
                         [self.levelUpNumberView animateToValue:(completedStage + 1) duration:0.3];
                     }];
}

- (void)playLevelUpSound {
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"level-up" ofType:@"mp3"];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL fileURLWithPath:soundPath], &sound);
    AudioServicesPlaySystemSound(sound);
}

- (MDRadialProgressView *)copyPointsMeter {
    MDRadialProgressView *radialProgressView = [[MDRadialProgressView alloc] init];
    radialProgressView.incompletedColor = self.pointsMeter.incompletedColor;
    radialProgressView.completedColor = self.pointsMeter.completedColor;
    radialProgressView.sliceDividerColor = self.pointsMeter.sliceDividerColor;
    radialProgressView.backgroundColor = self.pointsMeter.backgroundColor;
    radialProgressView.progressTotal = self.pointsMeter.progressTotal;
    radialProgressView.startingSlice = self.pointsMeter.startingSlice;
    radialProgressView.clockwise = self.pointsMeter.clockwise;
    radialProgressView.thickness = self.pointsMeter.thickness;
    return radialProgressView;
}

#pragma mark - Challenge concluded

- (void)wonChallenge {
    // advance to next level
    if (self.challenge.currentStage < self.challenge.numStages) {
        int completedStage = self.challenge.currentStage;
        
        appDelegate.loggedInUser.challenge.currentStage += 1;
        appDelegate.loggedInUser.challenge.currentPoints = 0;
        appDelegate.loggedInUser.challenge.timeLimit = 30*60;
        [appDelegate saveLoggedInUserToDevice];
        
        [self showLevelUp:completedStage];
    } else {
        // show win screen
        self.winVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.winVC.view];
        
        [self endOfChallenge];
    }
}

- (void)lostChallenge {
    // show lose screen
    self.loseVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.loseVC.view];
    
    [self endOfChallenge];
}

- (void)endOfChallenge {
    [self killTimer];
    appDelegate.loggedInUser.challenge = nil;
    [appDelegate saveLoggedInUserToDevice];
}

- (void)killTimer {
    [self.timer invalidate];
    self.timer = nil;
    
    [self.timer2 invalidate];
    self.timer2 = nil;
}

# pragma mark - Simulate

- (IBAction)simulateCountdown:(id)sender {
    if (self.challenge.active) {
        // fast forward to countdown
        NSTimeInterval secondsSinceActivation = [[NSDate date] timeIntervalSinceDate:self.challenge.activationTime];
        appDelegate.loggedInUser.challenge.timeLimit = secondsSinceActivation + self.countdownThreshold + 5;
        [appDelegate saveLoggedInUserToDevice];
        [self update];
        
        // advance forward in time
//        int timeLimitInt = [self.challenge.timeLimit intValue];
//        appDelegate.loggedInUser.challenge.timeLimit = [NSNumber numberWithInt:timeLimitInt - 1*60];
//        [self update];
        
    }
}

- (void)checkForNewSlotMachineWin {
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%d", SITE_DOMAIN, PORT]];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:baseURL];
    
    NSString *url = [NSString stringWithFormat:@"%@:%d/api/v1/lastwin", SITE_DOMAIN, PORT];
    
    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
        NSString *dateStr = JSON[@"timestamp"];
        NSDate *date = [Util stringToDate:dateStr dateFormat:dateFormat];
        
        if (!self.lastWinTime) {
            self.lastWinTime = date;
        }
        
        if ([date compare:self.lastWinTime] == NSOrderedDescending) {  // newly acquired date is more recent
            self.lastWinTime = date;
            int amount = [JSON[@"amount"] intValue];
            [self scorePoints:amount];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        DDLogInfo(@"%@", [error description]);
    }];
    [operation start];
}

- (void)scorePoints:(int)points {
    self.oldPoints = self.challenge.currentPoints;
    appDelegate.loggedInUser.challenge.currentPoints = self.challenge.currentPoints + points;
    [appDelegate saveLoggedInUserToDevice];
    [self update];
}

- (IBAction)simulatePoints:(id)sender {
    if (self.challenge.active) {
        [self scorePoints:200];
    }
}

- (IBAction)simulateBigWin:(id)sender {
    if (self.challenge.active) {
        // score points between big win threshold and 950
        int randomPoints = self.bigWinThreshold + arc4random() % (999 - self.bigWinThreshold);
        
        // make divisible by 10 for aesthetic reasons
        randomPoints = (randomPoints / 10) * 10;
        
        [self scorePoints:randomPoints];
    }
}

- (IBAction)simulateLevelUp:(id)sender {
    if (self.challenge.active) {
        [self scorePoints:(self.challenge.reward.points - self.challenge.currentPoints)];
    }
}

- (void)closeScaledDial {
    [self.bigWinDialImageView removeFromSuperview];
    self.bigWinDialImageView = nil;
    
    [self.levelUpDialImageView removeFromSuperview];
    self.levelUpDialImageView = nil;
}

- (IBAction)triggerIncomingMessage:(id)sender {
    [Util triggerIncomingMessage];
}

@end
