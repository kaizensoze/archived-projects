//
//  ILUSavedSearch.h
//  illuminex
//
//  Created by Joe Gallo on 11/5/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILUSearchParams.h"

@interface ILUSavedSearch : NSObject <NSCoding>

@property (strong, nonatomic) ILUSearchParams *searchParams;
@property (strong, nonatomic) NSString *title;

- (id)initWithSearchParams:(ILUSearchParams *)searchParams;

@end
