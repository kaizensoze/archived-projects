//
//  ILUSavedSearchesTableViewCell.m
//  illuminex
//
//  Created by Joe Gallo on 11/5/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSavedSearchTableViewCell.h"

@implementation ILUSavedSearchTableViewCell

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
    
    self.backgroundColor = [UIColor clearColor];
    
    UIView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield-clear"]];
    rightView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearTextField:)];
    [rightView addGestureRecognizer:tapGR];
    
    self.titleTextField.rightView = rightView;
    self.titleTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (IBAction)clearTextField:(id)sender {
    self.titleTextField.text = @"";
    [self.titleTextField becomeFirstResponder];
}

@end
