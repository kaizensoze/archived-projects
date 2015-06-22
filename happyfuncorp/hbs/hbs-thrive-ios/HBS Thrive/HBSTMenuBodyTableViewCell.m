//
//  HBSTMenuBodyTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTMenuBodyTableViewCell.h"

@implementation HBSTMenuBodyTableViewCell

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
    
    self.bodyTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.bodyTextView.textColor = [UIColor whiteColor];
    self.bodyTextView.backgroundColor = [UIColor clearColor];
    self.bodyTextView.editable = NO;
    self.bodyTextView.scrollEnabled = NO;
    self.bodyTextView.dataDetectorTypes = UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink;
    [HBSTUtil removeTextViewPadding:self.bodyTextView];
    [self.bodyTextView sizeToFit];
}

@end
