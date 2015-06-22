//
//  BFKNoteCell.h
//  Mosaic
//
//  Created by Joe Gallo on 1/27/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFKNoteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end
