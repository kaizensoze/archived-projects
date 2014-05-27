//
//  Prompt.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "Prompt.h"
#import "Conference.h"

@implementation Prompt

- (id)initWithId:(NSString *)id {
    self = [self init];
    if (self) {
        self.id = id;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.id forKey:@"id"];
    [anEncoder encodeObject:self.conference forKey:@"conference"];
    [anEncoder encodeObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [anEncoder encodeObject:self.detail forKey:@"detail"];
    [anEncoder encodeObject:self.shortDetail forKey:@"shortDetail"];
    [anEncoder encodeObject:self.numDaysLeft forKey:@"numDaysLeft"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.conference = [aDecoder decodeObjectForKey:@"conference"];
        self.type = [[aDecoder decodeObjectForKey:@"type"] intValue];
        self.detail = [aDecoder decodeObjectForKey:@"detail"];
        self.shortDetail = [aDecoder decodeObjectForKey:@"shortDetail"];
        self.numDaysLeft = [aDecoder decodeObjectForKey:@"numDaysLeft"];
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToPrompt:other];
}

- (BOOL)isEqualToPrompt:(Prompt *)aPrompt {
    if (self == aPrompt)
        return YES;
    
    if (![(id)[self id] isEqual:[aPrompt id]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.id hash];
    return result;
}

- (NSString *)description {
    #warning FIXME: running into issue due to conference redundancy
    return [NSString stringWithFormat:@"\n"
            "Id: %@\n"
//            "Conference: %@\n"
            "Type: %@\n"
            "Name: %@\n"
            "Detail: %@\n"
            "Num days left: %@"
            , self.id
//            , self.conference
            , [Util enumToString:self.type]
            , self.detail
            , self.shortDetail
            , self.numDaysLeft
            ];
}

@end
