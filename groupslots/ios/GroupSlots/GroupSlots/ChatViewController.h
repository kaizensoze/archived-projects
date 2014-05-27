//
//  ChatViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/2/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <SocketIODelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *chatMessages;

- (void)updateMessagesTable;

@end
