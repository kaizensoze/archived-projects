//
//  HBSTAnnouncementDateTableViewCell.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBSTAnnouncementDateTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startEndLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dateImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
