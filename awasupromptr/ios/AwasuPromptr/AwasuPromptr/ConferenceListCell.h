//
//  ConferenceListCell.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/2/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConferenceListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *conferenceImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarImageView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;

@end
