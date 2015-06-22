//
//  ReviewTableViewCell.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/26/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewBodyTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishDateLabel;

@end
