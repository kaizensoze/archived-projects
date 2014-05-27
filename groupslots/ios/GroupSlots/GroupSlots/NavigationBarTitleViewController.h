//
//  NavigationBarTitleViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/11/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBarTitleViewController : UIViewController

@property (nonatomic) int inboxBadgeCount;
@property (nonatomic) int chatBadgeCount;
@property (nonatomic) int invitesBadgeCount;

- (void)updateBadges;

@end
