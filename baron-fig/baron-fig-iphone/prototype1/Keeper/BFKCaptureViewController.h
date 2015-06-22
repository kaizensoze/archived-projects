//
//  BFKCaptureViewController.h
//  Keeper
//
//  Created by Joe Gallo on 10/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFKNotebook.h"
#import "BFKSection.h"

@interface BFKCaptureViewController : UIViewController <
    UITextViewDelegate,
    UIScrollViewDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UITextFieldDelegate
>

enum {
    BFKCaptureCaptureMode = 1,
    BFKImportedImageCaptureMode = 2,
    BFKNoteCaptureMode = 3,
};
typedef UInt32 BFKCaptureMode;

- (void)savedNoteForNotebook:(BFKNotebook *)notebook section:(BFKSection *)section;

@end
