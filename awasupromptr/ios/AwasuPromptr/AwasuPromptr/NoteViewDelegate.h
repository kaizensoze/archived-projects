//
//  NoteViewDelegate.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/8/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Note;

@protocol NoteViewDelegate <NSObject>

- (void)noteDeleted:(Note *)note;
- (void)noteSaved:(Note *)note;

@end
