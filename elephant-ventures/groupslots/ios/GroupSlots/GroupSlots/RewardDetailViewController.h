//
//  RewardDetailsViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/6/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reward;

@interface RewardDetailViewController : UIViewController <SocketIODelegate>

@property (strong, nonatomic) Reward *reward;

@end
