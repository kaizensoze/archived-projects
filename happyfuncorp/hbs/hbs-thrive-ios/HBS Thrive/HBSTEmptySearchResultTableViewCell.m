//
//  HBSTEmptySearchResultTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 9/10/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTEmptySearchResultTableViewCell.h"

@implementation HBSTEmptySearchResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.customTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    NSString *text = @"Can't find what you are looking for? Tap here to contact our team for help.";
    self.customTextLabel.text = text;
}

@end
