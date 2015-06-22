//
//  BFKNotebook.m
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKNotebook.h"
#import "BFKSection.h"


@implementation BFKNotebook

@dynamic name;
@dynamic sortOrder;
@dynamic sections;

- (int)numPages {
    int pageCount = 0;
    for (BFKSection *section in self.sections) {
        pageCount += section.pages.count;
    }
    return pageCount;
}

- (NSString *)description {
    return self.name;
}

@end
