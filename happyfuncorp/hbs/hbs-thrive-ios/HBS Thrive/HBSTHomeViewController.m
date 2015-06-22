//
//  HBSTHomeViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTHomeViewController.h"
#import "HBSTBackgroundImage.h"
#import "HBSTMenu.h"
#import "HBSTGymSchedule.h"
#import "HBSTAnnouncement.h"
#import "HBSTTileView.h"
#import "HBSTWelcomePopupContentViewController.h"
#import "HBSTMenuPopupContentTableViewController.h"
#import "HBSTGymSchedulePopupTableContentViewController.h"
#import "HBSTAnnouncementPopupContentTableViewController.h"
#import "HBSTPollPopupContentViewController.h"
#import "HBSTLoadingViewController.h"

@interface HBSTHomeViewController ()
    @property (weak, nonatomic) IBOutlet HBSTTileView *welcomeTile;
    @property (weak, nonatomic) IBOutlet HBSTTileView *menuTile;
    @property (weak, nonatomic) IBOutlet HBSTTileView *gymScheduleTile;
    @property (weak, nonatomic) IBOutlet HBSTTileView *announcementTile;
    @property (weak, nonatomic) IBOutlet HBSTTileView *pollTile;

    @property (weak, nonatomic) IBOutlet UIImageView *announcementBadge;
    @property (weak, nonatomic) IBOutlet UIImageView *pollBadge;

    @property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

    @property (strong, nonatomic) NSString *firstName;
    @property (strong, nonatomic) NSString *lastName;

    @property (strong, nonatomic) NSMutableArray *backgroundImages;
    @property (strong, nonatomic) NSMutableArray *menus;
    @property (strong, nonatomic) NSMutableArray *gymSchedules;
    @property (strong, nonatomic) NSMutableArray *announcements;

    @property (strong, nonatomic) NSDictionary *pollJSON;

    @property (strong, nonatomic) NSMutableArray *rotatingBackgroundImages;
    @property (strong, nonatomic) NSTimer *rotatingBackgroundImageTimer;

    @property (strong, nonatomic) HBSTPopupViewController *popupController;

    @property (strong, nonatomic) HBSTLoadingViewController *loadingVC;
    @property (nonatomic) BOOL loadingTodaysData;
@end

@implementation HBSTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.welcomeTile.color = [[HBSTUtil colorFromHex:@"7a9e65"] colorWithAlphaComponent:0.9f];
    
    self.loadingVC = [storyboard instantiateViewControllerWithIdentifier:@"Loading"];
    
    // request permission to set badge
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
#endif
    
    // load today's data
    self.loadingTodaysData = NO;
    [self loadTodaysData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTodaysData)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopRotatingBackgroundImageTimer)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    // update poll badge
    if (!self.loadingTodaysData) {
        [self updatePollBadge];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadTodaysData {
    DDLogInfo(@"loadTodaysData");
    
    self.loadingTodaysData = YES;
    
    // show loading view
    [self.loadingVC spin];
    [appDelegate.window.rootViewController.view addSubview:self.loadingVC.view];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/today", SITE_DOMAIN, API_PATH];
    [appDelegate.requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        self.firstName = JSON[@"first_name"];
        self.lastName = JSON[@"last_name"];
        
        // welcome tile
        [self updateWelcomeTile];

        // background images
        self.backgroundImages = [[NSMutableArray alloc] init];
        self.rotatingBackgroundImages = [[NSMutableArray alloc] init];
        
        for (NSDictionary *backgroundImageDict in JSON[@"background_images"]) {
            HBSTBackgroundImage *backgroundImage = [[HBSTBackgroundImage alloc] initWithDict:backgroundImageDict];
            [self.backgroundImages addObject:backgroundImage];
            
            // add the image to the rotating background images
            [self.rotatingBackgroundImages addObject:backgroundImage.image];
            
            // remove loading view (after first image is downloaded)
            [self.loadingVC.view removeFromSuperview];
        }
        
        // in case there were no background images
        [self.loadingVC.view removeFromSuperview];
        
        // start background image rotation
        [self startBackgroundImageRotation];

        // menus
        self.menus = [[NSMutableArray alloc] init];
        for (NSDictionary *menuDict in JSON[@"menus"]) {
            HBSTMenu *menu = [[HBSTMenu alloc] initWithDict:menuDict];
            [self.menus addObject:menu];
        }

        // gym schedules
        self.gymSchedules = [[NSMutableArray alloc] init];
        for (NSDictionary *gymScheduleDict in JSON[@"gym_schedules"]) {
            HBSTGymSchedule *gymSchedule = [[HBSTGymSchedule alloc] initWithDict:gymScheduleDict];
            [self.gymSchedules addObject:gymSchedule];
        }

        // announcements
        BOOL newAnnouncement = NO;
        NSMutableArray *existingAnnouncements = [[userDefaults objectForKey:@"announcements"] mutableCopy];
        DDLogInfo(@"existing announcements: %@", existingAnnouncements);
        
        self.announcements = [[NSMutableArray alloc] init];
        for (NSDictionary *announcementDict in JSON[@"announcements"]) {
            HBSTAnnouncement *announcement = [[HBSTAnnouncement alloc] initWithDict:announcementDict];
            [self.announcements addObject:announcement];
            
            NSString *announcementId = announcementDict[@"id"];
            
            if (!existingAnnouncements || ![existingAnnouncements containsObject:announcementId]) {
                if (!existingAnnouncements) {
                    [userDefaults setObject:@[] forKey:@"announcements"];
                    [userDefaults synchronize];
                }
                existingAnnouncements = [[userDefaults objectForKey:@"announcements"] mutableCopy];
                [existingAnnouncements addObject:announcementId];
                [userDefaults setObject:[existingAnnouncements copy] forKey:@"announcements"];
                [userDefaults synchronize];
                
                newAnnouncement = YES;
            }
        };
        
        if (newAnnouncement) {
            [self updateAnnouncementBadge:newAnnouncement];
        }
        
        // poll
        self.pollJSON = JSON[@"poll"];
        
        NSString *pollId = [self.pollJSON objectForKeyNotNull:@"PollID"];
        
        // check if the poll is new
        if (pollId) {
            NSDictionary *answeredPolls = [userDefaults objectForKey:@"answeredPolls"];
            if (answeredPolls && answeredPolls[pollId]) {
            } else {
                if (![userDefaults objectForKey:@"unansweredPolls"]) {
                    [userDefaults setObject:@[] forKey:@"unansweredPolls"];
                    [userDefaults synchronize];
                }

                NSMutableArray *unansweredPolls = [[userDefaults objectForKey:@"unansweredPolls"] mutableCopy];
                if (![unansweredPolls containsObject:pollId]) {
                    [unansweredPolls addObject:pollId];
                    [userDefaults setObject:[unansweredPolls copy] forKey:@"unansweredPolls"];
                    [userDefaults synchronize];
                }
            }
        }
        DDLogInfo(@"unanswered polls: %@", [userDefaults objectForKey:@"unansweredPolls"]);
        DDLogInfo(@"answered polls: %@", [userDefaults objectForKey:@"answeredPolls"]);
        
        // update poll badge if necessary
        [self updatePollBadge];

//        [self checkData];
        
        self.loadingTodaysData = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {
            [HBSTUtil showErrorAlert:@"Device does not match the one associated with account." delegate:self];
        }
        DDLogError(@"%@", error);
    }];
}

- (void)updatePollBadge {
    BOOL isNonstudent = [userDefaults boolForKey:@"isNonstudent"];
    NSArray *unansweredPolls = [userDefaults objectForKey:@"unansweredPolls"];
    if (unansweredPolls && unansweredPolls.count > 0 && !isNonstudent) {
        self.pollBadge.hidden = NO;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    } else {
        self.pollBadge.hidden = YES;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)updateAnnouncementBadge:(BOOL)newAnnouncement {
    if (newAnnouncement) {
        self.announcementBadge.hidden = NO;
    } else {
        self.announcementBadge.hidden = YES;
    }
}

- (void)checkData {
    for (HBSTBackgroundImage *backgroundImage in self.backgroundImages) {
        DDLogInfo(@"%@", backgroundImage);
    }
    
    for (HBSTMenu *menu in self.menus) {
        DDLogInfo(@"%@", menu);
    }
    
    for (HBSTGymSchedule *gymSchedule in self.gymSchedules) {
        DDLogInfo(@"%@", gymSchedule);
    }
    
    for (HBSTAnnouncement *announcement in self.announcements) {
        DDLogInfo(@"%@", announcement);
    }
}

- (void)updateWelcomeTile {
    UIFont *font1 = [UIFont fontWithName:@"Helvetica" size:14.0];
    NSDictionary *font1Dict = [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:@"Welcome,\n" attributes: font1Dict];
    
    UIFont *spacingFont = [UIFont fontWithName:@"Helvetica" size:1.0];
    NSDictionary *spacingDict = [NSDictionary dictionaryWithObject:spacingFont forKey:NSFontAttributeName];
    NSMutableAttributedString *spacingString = [[NSMutableAttributedString alloc]initWithString:@" \n" attributes:spacingDict];
    [attrString1 appendAttributedString:spacingString];
    
    UIFont *font2 = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    NSDictionary *font2Dict = [NSDictionary dictionaryWithObject:font2 forKey:NSFontAttributeName];
    NSString *shortName = [HBSTUtil getShortName:self.firstName lastName:self.lastName];
    shortName = [shortName stringByAppendingString:@"\n"];
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc]initWithString:shortName attributes:font2Dict];
    [attrString1 appendAttributedString:attrString2];
    
    UIFont *font3 = [UIFont fontWithName:@"Helvetica" size:12.0];
    NSDictionary *font3Dict = [NSDictionary dictionaryWithObject:font3 forKey:NSFontAttributeName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableAttributedString *attrString3 = [[NSMutableAttributedString alloc]initWithString:today attributes:font3Dict];
    [attrString1 appendAttributedString:attrString3];
    
    self.welcomeTile.label.attributedText = attrString1;
}

- (void)startBackgroundImageRotation {
    if (self.rotatingBackgroundImages.count == 0) {
        [self stopRotatingBackgroundImageTimer];
        self.rotatingBackgroundImageTimer = nil;
        return;
    }
    
    UIImage *initialBackgroundImage = self.rotatingBackgroundImages[0];
    self.backgroundImageView.image = initialBackgroundImage;
    
    if (self.rotatingBackgroundImages.count > 1) {
        self.rotatingBackgroundImageTimer = [NSTimer timerWithTimeInterval:5.0f
                                                                     target:self
                                                                   selector:@selector(rotateBackgroundImage)
                                                                  userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.rotatingBackgroundImageTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)rotateBackgroundImage {
    // from
    NSUInteger fromIndex = [self.rotatingBackgroundImages indexOfObject:self.backgroundImageView.image];
    UIImage *fromImage = self.rotatingBackgroundImages[fromIndex];
    
    // to
    NSUInteger toIndex = (fromIndex + 1) % self.rotatingBackgroundImages.count;
    UIImage *toImage = self.rotatingBackgroundImages[toIndex];
    
    // cross fade animation
    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossFade.duration = 0.75;
    crossFade.fromValue = (id)fromImage.CGImage;
    crossFade.toValue = (id)toImage.CGImage;
    [self.backgroundImageView.layer addAnimation:crossFade forKey:@"animateContents"];
    self.backgroundImageView.image = toImage;
}

- (void)stopRotatingBackgroundImageTimer {
    if (self.rotatingBackgroundImageTimer) {
        [self.rotatingBackgroundImageTimer invalidate];
        self.rotatingBackgroundImageTimer = nil;
    }
}

- (void)hideTiles {
    [UIView animateWithDuration:0.5 animations:^{
        self.welcomeTile.alpha = 0;
        self.menuTile.alpha = 0;
        self.gymScheduleTile.alpha = 0;
        self.announcementTile.alpha = 0;
        self.pollTile.alpha = 0;
        self.logoImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.welcomeTile.hidden = YES;
        self.menuTile.hidden = YES;
        self.gymScheduleTile.hidden = YES;
        self.announcementTile.hidden = YES;
        self.pollTile.hidden = YES;
        self.logoImageView.hidden = YES;
    }];
}

- (void)showTiles {
    self.welcomeTile.hidden = NO;
    self.menuTile.hidden = NO;
    self.gymScheduleTile.hidden = NO;
    self.announcementTile.hidden = NO;
    self.pollTile.hidden = NO;
    self.logoImageView.hidden = NO;
    
    self.welcomeTile.alpha = 0;
    self.menuTile.alpha = 0;
    self.gymScheduleTile.alpha = 0;
    self.announcementTile.alpha = 0;
    self.pollTile.alpha = 0;
    self.logoImageView.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^{ // 0.3
        self.welcomeTile.alpha = 1;
        self.menuTile.alpha = 1;
        self.gymScheduleTile.alpha = 1;
        self.announcementTile.alpha = 1;
        self.pollTile.alpha = 1;
        self.logoImageView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)showPopup:(id)sender {
    // get which tile was tapped
    UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
    HBSTTileView *tile = (HBSTTileView *)tapGR.view;
    
    self.popupController = [storyboard instantiateViewControllerWithIdentifier:@"Popup"];
    [self passDataToPopup:self.popupController tile:tile];
    self.popupController.delegate = self;
    self.popupController.view.frame = CGRectMake(20, 27, 280, self.view.frame.size.height - 27 - 20);
    
    // fade in popup view
    [self.view addSubview:self.popupController.view];
    self.popupController.view.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.popupController.view.alpha = 1.0;
    } completion:nil];
    
    [self hideTiles];
    
    if (tile == self.announcementTile) {
        [self updateAnnouncementBadge:NO];
    }
}

- (void)popupClosed {
    // fade out popup view
    self.popupController.view.alpha = 1.0;
    [UIView animateWithDuration:0.4 animations:^{
        self.popupController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.popupController.view removeFromSuperview];
        self.popupController = nil;
        
        
    }];
    
    [self updatePollBadge];
    [self showTiles];
}

- (void)passDataToPopup:(HBSTPopupViewController *)popup tile:(HBSTTileView *)tile {
    if ([tile isEqual:self.welcomeTile]) {
        popup.title = @"Welcome";
        HBSTWelcomePopupContentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomePopupContent"];
        vc.firstName = self.firstName;
        popup.contentViewControllers = @[vc];
        [Flurry logEvent:@"Welcome"];
    } else if ([tile isEqual:self.menuTile]) {
        popup.title = @"Spangler Menu";
        
        NSMutableArray *contentViewControllers = [[NSMutableArray alloc] init];
        for (HBSTMenu *menu in self.menus) {
            HBSTMenuPopupContentTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MenuPopupContent"];
            vc.menu = menu;
            [contentViewControllers addObject:vc];
        }
        popup.contentViewControllers = contentViewControllers;
        
        popup.emptyMessage = @"Check back later for forthcoming Spangler Menus.";
        
        [Flurry logEvent:@"Spangler"];
    } else if ([tile isEqual:self.gymScheduleTile]) {
        popup.title = @"Shad Group Exercise Schedule";
        
        NSMutableArray *contentViewControllers = [[NSMutableArray alloc] init];
        for (HBSTGymSchedule *gymSchedule in self.gymSchedules) {
            HBSTGymSchedulePopupTableContentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GymSchedulePopupContent"];
            vc.gymSchedule = gymSchedule;
            [contentViewControllers addObject:vc];
        }
        popup.contentViewControllers = contentViewControllers;
        
        popup.emptyMessage = @"Check back later for forthcoming Shad Exercise Schedules.";
        
        [Flurry logEvent:@"Shad"];
    } else if ([tile isEqual:self.announcementTile]) {
        popup.title = @"Don't Miss";
        
        NSMutableArray *contentViewControllers = [[NSMutableArray alloc] init];
        for (HBSTAnnouncement *announcement in self.announcements) {
            HBSTAnnouncementPopupContentTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AnnouncementPopupContent"];
            vc.announcement = announcement;
            [contentViewControllers addObject:vc];
        }
        popup.contentViewControllers = contentViewControllers;
        
        popup.emptyMessage = @"Check back later for forthcoming Don't Miss.";
        
        [Flurry logEvent:@"Announcement"];
    } else if ([tile isEqual:self.pollTile]) {
        popup.title = @"Flash Poll";
        HBSTPollPopupContentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PollPopupContent"];
        vc.pollJSON = self.pollJSON;
        popup.contentViewControllers = @[vc];
        
        [Flurry logEvent:@"Poll:Start" withParameters:@{ @"pollid": self.pollJSON[@"PollID"] }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNav"];
}

@end
