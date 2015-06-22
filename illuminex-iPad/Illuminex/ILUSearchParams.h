//
//  ILUSearchParams.h
//  illuminex
//
//  Created by Joe Gallo on 11/2/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILUSearchParams : NSObject <NSCoding>

// budget
@property (strong, nonatomic) NSDecimalNumber *minBudget;
@property (strong, nonatomic) NSDecimalNumber *maxBudget;

// shape
@property (strong, nonatomic) NSMutableArray *shapes;

// carat
@property (nonatomic) float minCarat;
@property (nonatomic) float maxCarat;

// color
@property (strong, nonatomic) NSMutableArray *simpleColors;
@property (strong, nonatomic) NSMutableArray *fancyColors1;
@property (strong, nonatomic) NSMutableArray *fancyColors2;

// clarity
@property (strong, nonatomic) NSMutableArray *clarities;

// polish
@property (strong, nonatomic) NSMutableArray *polishes;

// symmetry
@property (strong, nonatomic) NSMutableArray *symmetries;

// cut grade
@property (strong, nonatomic) NSMutableArray *cutGrades;

// lab
@property (strong, nonatomic) NSMutableArray *labs;

// depth
@property (nonatomic) int minDepth;
@property (nonatomic) int maxDepth;

// table
@property (nonatomic) int minTable;
@property (nonatomic) int maxTable;

// fluorescence
@property (strong, nonatomic) NSMutableArray *fluorescences;

@end
