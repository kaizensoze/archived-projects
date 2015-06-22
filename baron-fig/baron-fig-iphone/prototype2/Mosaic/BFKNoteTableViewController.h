//
//  BFKNoteTableViewController.h
//  Mosaic
//
//  Created by Joe Gallo on 1/18/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFKNote.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface BFKNoteTableViewController : UITableViewController <
    UITextFieldDelegate,
    AVAudioPlayerDelegate,
    UIActionSheetDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>

@property (strong, nonatomic) BFKNote *note;

@end
