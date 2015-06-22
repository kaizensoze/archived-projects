//
//  ReviewFormCell1.h
//  TasteSavant
//
//  Created by Joe Gallo on 10/30/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewFormScoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *scoreTypeLabel;
@property (weak, nonatomic) IBOutlet UISlider *scoreSlider;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end
