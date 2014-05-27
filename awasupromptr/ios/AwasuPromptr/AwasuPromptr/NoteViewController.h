//
//  NoteViewController.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteViewDelegate.h"

@class Note;

@interface NoteViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Note *note;
@property (strong, nonatomic) id<NoteViewDelegate> delegate;

@end
