//
//  ILUSearchParams.m
//  illuminex
//
//  Created by Joe Gallo on 11/2/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSearchParams.h"

@implementation ILUSearchParams

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.minBudget = [decoder decodeObjectForKey:@"minBudget"];
        self.maxBudget = [decoder decodeObjectForKey:@"maxBudget"];
        self.shapes = [decoder decodeObjectForKey:@"shapes"];
        self.minCarat = [decoder decodeFloatForKey:@"minCarat"];
        self.maxCarat = [decoder decodeFloatForKey:@"maxCarat"];
        self.simpleColors = [decoder decodeObjectForKey:@"simpleColors"];
        self.fancyColors1 = [decoder decodeObjectForKey:@"fancyColors1"];
        self.fancyColors2 = [decoder decodeObjectForKey:@"fancyColors2"];
        self.clarities = [decoder decodeObjectForKey:@"clarities"];
        self.polishes = [decoder decodeObjectForKey:@"polishes"];
        self.symmetries = [decoder decodeObjectForKey:@"symmetries"];
        self.cutGrades = [decoder decodeObjectForKey:@"cutGrades"];
        self.labs = [decoder decodeObjectForKey:@"labs"];
        self.minDepth = [decoder decodeIntForKey:@"minDepth"];
        self.maxDepth = [decoder decodeIntForKey:@"maxDepth"];
        self.minTable = [decoder decodeIntForKey:@"minTable"];
        self.maxTable = [decoder decodeIntForKey:@"maxTable"];
        self.fluorescences = [decoder decodeObjectForKey:@"fluorescences"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.minBudget forKey:@"minBudget"];
    [encoder encodeObject:self.maxBudget forKey:@"maxBudget"];
    [encoder encodeObject:self.shapes forKey:@"shapes"];
    [encoder encodeFloat:self.minCarat forKey:@"minCarat"];
    [encoder encodeFloat:self.maxCarat forKey:@"maxCarat"];
    [encoder encodeObject:self.simpleColors forKey:@"simpleColors"];
    [encoder encodeObject:self.fancyColors1 forKey:@"fancyColors1"];
    [encoder encodeObject:self.fancyColors2 forKey:@"fancyColors2"];
    [encoder encodeObject:self.clarities forKey:@"clarities"];
    [encoder encodeObject:self.polishes forKey:@"polishes"];
    [encoder encodeObject:self.symmetries forKey:@"symmetries"];
    [encoder encodeObject:self.cutGrades forKey:@"cutGrades"];
    [encoder encodeObject:self.labs forKey:@"labs"];
    [encoder encodeInt:self.minDepth forKey:@"minDepth"];
    [encoder encodeInt:self.maxDepth forKey:@"maxDepth"];
    [encoder encodeInt:self.minTable forKey:@"minTable"];
    [encoder encodeInt:self.maxTable forKey:@"maxTable"];
    [encoder encodeObject:self.fluorescences forKey:@"fluorescences"];
}

- (NSMutableArray *)shapes {
    if (!_shapes) {
        _shapes = [[NSMutableArray alloc] init];
    }
    return _shapes;
}

- (NSMutableArray *)simpleColors {
    if (!_simpleColors) {
        _simpleColors = [[NSMutableArray alloc] init];
    }
    return _simpleColors;
}

- (NSMutableArray *)fancyColors1 {
    if (!_fancyColors1) {
        _fancyColors1 = [[NSMutableArray alloc] init];
    }
    return _fancyColors1;
}

- (NSMutableArray *)fancyColors2 {
    if (!_fancyColors2) {
        _fancyColors2 = [[NSMutableArray alloc] init];
    }
    return _fancyColors2;
}

- (NSMutableArray *)clarities {
    if (!_clarities) {
        _clarities = [[NSMutableArray alloc] init];
    }
    return _clarities;
}

- (NSMutableArray *)polishes {
    if (!_polishes) {
        _polishes = [[NSMutableArray alloc] init];
    }
    return _polishes;
}

- (NSMutableArray *)symmetries {
    if (!_symmetries) {
        _symmetries = [[NSMutableArray alloc] init];
    }
    return _symmetries;
}

- (NSMutableArray *)cutGrades {
    if (!_cutGrades) {
        _cutGrades = [[NSMutableArray alloc] init];
    }
    return _cutGrades;
}

- (NSMutableArray *)labs {
    if (!_labs) {
        _labs = [[NSMutableArray alloc] init];
    }
    return _labs;
}

- (NSMutableArray *)fluorescences {
    if (!_fluorescences) {
        _fluorescences = [[NSMutableArray alloc] init];
    }
    return _fluorescences;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "min budget: %@\n"
            "max budget: %@\n"
            "shape: %@\n"
            "min carat: %f\n"
            "max carat: %f\n"
            "simple color: %@\n"
            "fancy color 1: %@\n"
            "fancy color 2: %@\n"
            "clarity: %@\n"
            "polish: %@\n"
            "symmetry: %@\n"
            "cut grade: %@\n"
            "lab: %@\n"
            "min depth: %d\n"
            "max depth: %d\n"
            "min table: %d\n"
            "max table: %d\n"
            "fluorescence: %@\n",
            self.minBudget,
            self.maxBudget,
            self.shapes,
            self.minCarat,
            self.maxCarat,
            self.simpleColors,
            self.fancyColors1,
            self.fancyColors2,
            self.clarities,
            self.polishes,
            self.symmetries,
            self.cutGrades,
            self.labs,
            self.minDepth,
            self.maxDepth,
            self.minTable,
            self.maxTable,
            self.fluorescences
            ];
}

@end
