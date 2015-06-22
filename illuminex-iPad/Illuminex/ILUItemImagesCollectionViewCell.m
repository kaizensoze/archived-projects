//
//  ILUImageCollectionViewCell.m
//  illuminex
//
//  Created by Joe Gallo on 11/13/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUItemImagesCollectionViewCell.h"

@implementation ILUItemImagesCollectionViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"details-image-bg"]];
    bgImageView.frame = self.bounds;
    self.backgroundView = bgImageView;
}

@end
