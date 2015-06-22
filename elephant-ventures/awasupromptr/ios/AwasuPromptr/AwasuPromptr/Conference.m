//
//  Conference.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "Conference.h"

@implementation Conference

- (id)initWithId:(NSString *)id {
    self = [self init];
    if (self) {
        self.id = id;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.id forKey:@"id"];
    [anEncoder encodeObject:self.name forKey:@"name"];
    [anEncoder encodeObject:self.startDate forKey:@"startDate"];
    [anEncoder encodeObject:self.endDate forKey:@"endDate"];
    [anEncoder encodeObject:self.city forKey:@"city"];
    [anEncoder encodeObject:self.stateAbbrev forKey:@"stateAbbrev"];
    [anEncoder encodeObject:self.details forKey:@"details"];
    [anEncoder encodeObject:self.imageURL forKey:@"imageURL"];
    [anEncoder encodeObject:self.webURL forKey:@"webURL"];
    [anEncoder encodeObject:self.prompts forKey:@"prompts"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
        self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.stateAbbrev = [aDecoder decodeObjectForKey:@"stateAbbrev"];
        self.details = [aDecoder decodeObjectForKey:@"details"];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.webURL = [aDecoder decodeObjectForKey:@"webURL"];
        self.prompts = [aDecoder decodeObjectForKey:@"prompts"];
    }
    return self;
}

- (NSString *)startDateString {
    return [Util dateToString:self.startDate dateFormat:@"MMM dd, yyyy"];
}

- (NSString *)startDateShortString {
    return [Util dateToString:self.startDate dateFormat:@"MMM dd"];
}

- (NSString *)endDateString {
    return [Util dateToString:self.endDate dateFormat:@"MMM dd, yyyy"];
}

- (NSString *)dateRangeString {
    return [NSString stringWithFormat:@"%@ - %@", self.startDateShortString, self.endDateString];
}

- (NSString *)locationString {
    return [NSString stringWithFormat:@"%@, %@", self.city, self.stateAbbrev];
}

- (NSMutableArray *)prompts {
    if (!_prompts) {
        _prompts = [[NSMutableArray alloc] init];
    }
    return _prompts;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToConference:other];
}

- (BOOL)isEqualToConference:(Conference *)aConference {
    if (self == aConference)
        return YES;
    
    if (![(id)[self id] isEqual:[aConference id]])
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
            "Name: %@\n"
            "Start date: %@\n"
            "End date: %@\n"
            "City: %@\n"
            "State: %@\n"
            "Details: %@\n"
            "Image URL: %@\n"
            "Web URL: %@\n"
            "Prompts: %@\n"
            , self.id
            , self.name
            , self.startDate
            , self.endDate
            , self.city
            , self.stateAbbrev
            , self.details
            , self.imageURL
            , self.webURL
          ,  self.prompts
            ];
}

@end
