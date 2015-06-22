//
//  ILUDiamond.h
//  illuminex
//
//  Created by Joe Gallo on 10/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILUItem : NSObject <NSCoding, NSCopying>

@property (nonatomic) int id;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortTitle;

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *stockNumber;
@property (strong, nonatomic) NSString *certNumber;

@property (strong, nonatomic) NSDecimalNumber *price;
@property (nonatomic) float carat;
@property (strong, nonatomic) NSString *shape;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *clarity;
@property (strong, nonatomic) NSString *lab;
@property (strong, nonatomic) NSString *cutGrade;
@property (strong, nonatomic) NSString *polish;
@property (strong, nonatomic) NSString *symmetry;
@property (nonatomic) float depthPercent;
@property (nonatomic) float tablePercent;
@property (strong, nonatomic) NSString *culetCondition;
@property (strong, nonatomic) NSString *culetSize;
@property (strong, nonatomic) NSString *fancyColorDominantColor;
@property (strong, nonatomic) NSString *fancyColorIntensity;
@property (strong, nonatomic) NSString *fancyColorOvertone;
@property (strong, nonatomic) NSString *fancyColorSecondaryColor;
@property (strong, nonatomic) NSString *fluorescenceColor;
@property (strong, nonatomic) NSString *fluorescenceIntensity;
@property (strong, nonatomic) NSString *girdleCondition;
@property (strong, nonatomic) NSString *girdleMin;
@property (strong, nonatomic) NSString *girdleMax;
@property (nonatomic) float measuredDepth;
@property (nonatomic) float measuredLength;
@property (nonatomic) float measuredWidth;

@property (nonatomic) BOOL hasCertFile;
@property (strong, nonatomic) NSString *currencyCode;

@property (strong, nonatomic) NSString *status;
@property (nonatomic) BOOL onHand;

- (void)import:(NSDictionary *)dict;
- (NSString *)formattedPrice;

@end
