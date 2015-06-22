//
//  Note.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "Note.h"
#import "Conference.h"

@implementation Note

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
    [anEncoder encodeObject:self.content forKey:@"content"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.conference = [aDecoder decodeObjectForKey:@"conference"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
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
    return [self isEqualToNote:other];
}

- (BOOL)isEqualToNote:(Note *)aNote {
    if (self == aNote)
        return YES;
    
    if (![(id)[self id] isEqual:[aNote id]])
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
    return [NSString stringWithFormat:@"\n"
            "Id: %@\n"
            "Conference: %@\n"
            "Content: %@\n"
            , self.id
            , self.conference
            , self.content
            ];
}

@end
