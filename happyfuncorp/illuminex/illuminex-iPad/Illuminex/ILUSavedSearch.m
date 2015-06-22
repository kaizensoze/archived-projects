//
//  ILUSavedSearch.m
//  illuminex
//
//  Created by Joe Gallo on 11/5/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSavedSearch.h"

@interface ILUSavedSearch ()
    @property (strong, nonatomic) NSString *defaultTitle;
@end

@implementation ILUSavedSearch

- (id)initWithSearchParams:(ILUSearchParams *)searchParams {
    self = [super init];
    if (self) {
        self.searchParams = searchParams;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.searchParams = [decoder decodeObjectForKey:@"searchParams"];
        self.title = [decoder decodeObjectForKey:@"title"];
        
        self.defaultTitle = [decoder decodeObjectForKey:@"defaultTitle"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.searchParams forKey:@"searchParams"];
    [encoder encodeObject:self.title forKey:@"title"];
    
    [encoder encodeObject:self.defaultTitle forKey:@"defaultTitle"];
}

- (NSString *)title {
    if (!_title || _title.length == 0) {
        return _defaultTitle;
    }
    return _title;
}

- (NSString *)defaultTitle {
    NSMutableString *title = [NSMutableString stringWithString:@""];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // budget
    [title appendString:[NSString stringWithFormat:@"$%@ - $%@",
                         [numberFormatter stringFromNumber:self.searchParams.minBudget],
                         [numberFormatter stringFromNumber:self.searchParams.maxBudget]]];
    
    // shape
    if (self.searchParams.shapes.count > 0) {
        [title appendString:@", "];
        
        for (NSString *shape in self.searchParams.shapes) {
            [title appendString:shape];
            
            if (shape != self.searchParams.shapes.lastObject) {
                [title appendString:@", "];
            }
        }
    }
    
    // carat
    [title appendString:@", "];
    [title appendString:[NSString stringWithFormat:@"%.02fct. - %.02fct.",
                         self.searchParams.minCarat, self.searchParams.maxCarat]];
    
    // color
    [title appendString:@", "];
    [title appendString:[NSString stringWithFormat:@"%@ - %@",
                         self.searchParams.simpleColors.firstObject, self.searchParams.simpleColors.lastObject]];
    
    if (self.searchParams.fancyColors1.count > 0) {
        [title appendString:@", "];
        
        for (NSString *fancyColor1 in self.searchParams.fancyColors1) {
            [title appendString:fancyColor1];
            
            if (fancyColor1 != self.searchParams.fancyColors1.lastObject) {
                [title appendString:@", "];
            }
        }
    }
    
    if (self.searchParams.fancyColors2.count > 0) {
        [title appendString:@", "];
        
        for (NSString *fancyColor2 in self.searchParams.fancyColors2) {
            [title appendString:fancyColor2];
            
            if (fancyColor2 != self.searchParams.fancyColors2.lastObject) {
                [title appendString:@", "];
            }
        }
    }
    
    // clarity
    if (self.searchParams.fancyColors2.count > 0) {
        [title appendString:@", "];
        
        for (NSString *clarity in self.searchParams.clarities) {
            [title appendString:clarity];
            
            if (clarity != self.searchParams.clarities.lastObject) {
                [title appendString:@", "];
            }
        }
    }
    
    // polish
    if (self.searchParams.polishes.count > 0) {
        [title appendString:@", "];
        [title appendString:[NSString stringWithFormat:@"polish: %@ - %@",
                             self.searchParams.polishes.firstObject, self.searchParams.polishes.lastObject]];
    }
    
    // symmetry
    if (self.searchParams.symmetries.count > 0) {
        [title appendString:@", "];
        [title appendString:[NSString stringWithFormat:@"symmetry: %@ - %@",
                             self.searchParams.symmetries.firstObject, self.searchParams.symmetries.lastObject]];
    }
    
    // cut grade
    if (self.searchParams.cutGrades.count > 0) {
        [title appendString:@", "];
        [title appendString:[NSString stringWithFormat:@"cut grade: %@ - %@",
                             self.searchParams.cutGrades.firstObject, self.searchParams.cutGrades.lastObject]];
    }
    
    // lab
    if (self.searchParams.labs.count > 0) {
        [title appendString:@", "];
        
        for (NSString *lab in self.searchParams.labs) {
            [title appendString:lab];
            
            if (lab != self.searchParams.labs.lastObject) {
                [title appendString:@", "];
            }
        }
    }
    
    // depth
    [title appendString:@", "];
    [title appendString:[NSString stringWithFormat:@"depth: %d-%d%%",
                         self.searchParams.minDepth, self.searchParams.maxDepth]];
    
    // table
    [title appendString:@", "];
    [title appendString:[NSString stringWithFormat:@"table: %d-%d%%",
                         self.searchParams.minTable, self.searchParams.maxTable]];
    
    // fluorescence
    if (self.searchParams.fluorescences.count > 0) {
        [title appendString:@", "];
        [title appendString:[NSString stringWithFormat:@"%@ - %@",
                             self.searchParams.fluorescences.firstObject, self.searchParams.fluorescences.lastObject]];
    }
    
    return [title copy];
}

@end
