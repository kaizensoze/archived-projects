//
//  NavigationBarTitleViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/11/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "NavigationBarTitleViewController.h"

@interface NavigationBarTitleViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *inboxButton;
    @property (weak, nonatomic) IBOutlet UIButton *chatButton;
    @property (weak, nonatomic) IBOutlet UIButton *invitesButton;
@end

@implementation NavigationBarTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inboxBadgeCount = 0;
    self.chatBadgeCount = 0;
    self.invitesBadgeCount = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)toggleInbox:(id)sender {
    [Util toggleSelected:self.inboxButton];
    
    if (self.inboxButton.selected) {
        self.inboxBadgeCount = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{  // not sure if this makes a difference
        UIViewController *inboxVC = [storyboard instantiateViewControllerWithIdentifier:@"InboxNav"];
        UIViewController *centerVC = appDelegate.viewDeckController.centerController;
        if ([centerVC.restorationIdentifier isEqualToString:inboxVC.restorationIdentifier]) {
            [Util setCenterViewController:[Util determineActiveOrInactiveGroupVC]];
        } else {
            [Util setCenterViewController:inboxVC];
        }
    });
}

- (IBAction)toggleChat:(id)sender {
    [Util toggleSelected:self.chatButton];
    
    appDelegate.navbarTitleVC.chatBadgeCount = 0;
    
    UIViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"Chat"];
    appDelegate.viewDeckController.bottomController = chatVC;
    
    UIViewController *groupPageVC = [Util determineActiveOrInactiveGroupVC];
    [appDelegate.viewDeckController toggleBottomViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
        if (![appDelegate.viewDeckController.centerController.restorationIdentifier isEqualToString:groupPageVC.restorationIdentifier]) {
            [Util setCenterViewController:groupPageVC];
        }
    }];
}

- (IBAction)toggleInvites:(id)sender {
    [Util toggleSelected:self.invitesButton];
    
    if (self.invitesButton.selected) {
        self.invitesBadgeCount = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{  // not sure if this makes a difference
        UIViewController *groupInvitesVC = [storyboard instantiateViewControllerWithIdentifier:@"GroupInvitesNav"];
        UIViewController *centerVC = appDelegate.viewDeckController.centerController;
        if ([centerVC.restorationIdentifier isEqualToString:groupInvitesVC.restorationIdentifier]) {
            [Util setCenterViewController:[Util determineActiveOrInactiveGroupVC]];
        } else {
            [Util setCenterViewController:groupInvitesVC];
        }
    });
}

- (void)setInboxBadgeCount:(int)inboxBadgeCount {
    _inboxBadgeCount = inboxBadgeCount;
    [self updateBadges];
}

- (void)setChatBadgeCount:(int)chatBadgeCount {
    _chatBadgeCount = chatBadgeCount;
    [self updateBadges];
}

- (void)setInvitesBadgeCount:(int)invitesBadgeCount {
    _invitesBadgeCount = invitesBadgeCount;
    [self updateBadges];
}

- (void)updateBadges {
    UIView *badgeView;
    
    // inbox
    [[self.inboxButton viewWithTag:1] removeFromSuperview];
    if (self.inboxBadgeCount > 0) {
        badgeView = [self createBadge:self.inboxBadgeCount];
        badgeView.tag = 1;
        [self.inboxButton addSubview:badgeView];
        [self adjustBadge:badgeView];
    }
    
    // chat
    [[self.chatButton viewWithTag:2] removeFromSuperview];
    if (self.chatBadgeCount > 0) {
        badgeView = [self createBadge:self.chatBadgeCount];
        badgeView.tag = 2;
        [self.chatButton addSubview:badgeView];
        [self adjustBadge:badgeView];
    }
    
    // invites
    [[self.invitesButton viewWithTag:3] removeFromSuperview];
    if (self.invitesBadgeCount > 0) {
        badgeView = [self createBadge:self.invitesBadgeCount];
        badgeView.tag = 3;
        [self.invitesButton addSubview:badgeView];
        [self adjustBadge:badgeView];
    }
}

- (UIView *)createBadge:(int)badgeCount {
    // badge count label
    UILabel *badgeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 16, 8)];
    badgeCountLabel.text = [NSString stringWithFormat:@"%d", badgeCount];
    badgeCountLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:9];
    badgeCountLabel.textAlignment = NSTextAlignmentCenter;
    badgeCountLabel.textColor = [UIColor whiteColor];
    badgeCountLabel.backgroundColor = [UIColor clearColor];
//    [Util setBorder:badgeCountLabel width:1 color:[UIColor greenColor]];
    
    // badge view
    UIImageView *badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge.png"]];
    
    // add badge count label to badge image
    [badgeView addSubview:badgeCountLabel];
    
    return badgeView;
}

- (void)adjustBadge:(UIView *)badgeView {
    badgeView.frame = CGRectMake(34, 4, badgeView.frame.size.width, badgeView.frame.size.height);
}

@end
