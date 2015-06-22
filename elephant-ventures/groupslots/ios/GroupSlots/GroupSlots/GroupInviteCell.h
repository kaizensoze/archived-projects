//
//  GroupInviteCell.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/13/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInviteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *inviterImageView;
@property (weak, nonatomic) IBOutlet UILabel *inviterLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitationLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end
