//
//  InboxMessageDetailViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/12/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InboxMessage;

@interface InboxMessageDetailViewController : UIViewController <SocketIODelegate>

@property (strong, nonatomic) InboxMessage *message;

@end
