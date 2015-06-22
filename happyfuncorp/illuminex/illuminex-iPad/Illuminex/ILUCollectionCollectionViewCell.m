//
//  ILUCollectionCollectionViewCell.m
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUCollectionCollectionViewCell.h"

@implementation ILUCollectionCollectionViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collection-cell-bg"]];
    bgImageView.frame = self.bounds;
    self.backgroundView = bgImageView;
}

@end
