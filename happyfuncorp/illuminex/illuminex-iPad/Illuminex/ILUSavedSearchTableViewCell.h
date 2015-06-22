//
//  ILUSavedSearchesTableViewCell.h
//  illuminex
//
//  Created by Joe Gallo on 11/5/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILUSavedSearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *theImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *titleTextFieldBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
