//
//  FriendCell.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/28/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *unfriendButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteToGroupButton;

@end
