//
//  User.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithId:(NSString *)id {
    self = [self init];
    if (self) {
        self.id = id;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.id forKey:@"id"];
    [anEncoder encodeObject:self.favorites forKey:@"favorites"];
    [anEncoder encodeObject:self.prompts forKey:@"prompts"];
    [anEncoder encodeObject:self.notes forKey:@"notes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.favorites = [aDecoder decodeObjectForKey:@"favorites"];
        self.prompts = [aDecoder decodeObjectForKey:@"prompts"];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
    }
    return self;
}

- (NSMutableArray *)favorites {
    if (!_favorites) {
        _favorites = [[NSMutableArray alloc] init];
    }
    return _favorites;
}

- (NSMutableArray *)prompts {
    if (!_prompts) {
        _prompts = [[NSMutableArray alloc] init];
    }
    return _prompts;
}

- (NSMutableArray *)notes {
    if (!_notes) {
        _notes = [[NSMutableArray alloc] init];
    }
    return _notes;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToUser:other];
}

- (BOOL)isEqualToUser:(User *)aUser {
    if (self == aUser)
        return YES;
    
    if (![(id)[self id] isEqual:[aUser id]])
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
            "Favorites: %@\n"
            "Prompts: %@\n"
            "Notes: %@\n"
            , self.id
            , self.favorites
            , self.prompts
            , self.notes
            ];
}

@end
