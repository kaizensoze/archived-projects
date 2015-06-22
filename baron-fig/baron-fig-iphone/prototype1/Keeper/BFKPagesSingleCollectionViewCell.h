//
//  BFKPagesSingleCollectionViewCell.h
//  Keeper
//
//  Created by Joe Gallo on 11/29/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFKPagesSingleCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *pageImageView;
@property (weak, nonatomic) IBOutlet UIButton *slideForNoteButton;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIImageView *noteBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveNoteButton;

@end
