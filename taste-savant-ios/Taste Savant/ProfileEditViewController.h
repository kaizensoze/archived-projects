//
//  ProfileEditViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/5/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropViewController.h"

@protocol ProfileEditDelegate
@property (strong, nonatomic) User *profile;
- (void)profileEditComplete;
@end

@interface ProfileEditViewController : UIViewController
    <UIGestureRecognizerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PECropViewControllerDelegate>

@property (nonatomic) BOOL forceEdit;
@property id<ProfileEditDelegate> delegate;

@end
