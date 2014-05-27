//
//  ChatCell.h
//  GroupSlots
//
//  Created by Joe Gallo on 9/14/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIView *chatBubbleView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
