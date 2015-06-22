//
//  HBSTBackgroundImage.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/12/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTBackgroundImage.h"

@implementation HBSTBackgroundImage

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [[dict objectForKeyNotNull:@"id"] intValue];
        
        if ([dict objectForKeyNotNull:@"image"]) {
            NSString *urlString = [[dict objectForKeyNotNull:@"image"] objectForKeyNotNull:@"url"];
            if (urlString) {
                #ifdef LOCAL
                urlString = [NSString stringWithFormat:@"%@%@", SITE_DOMAIN, urlString];
                #endif
                self.imageURL = [NSURL URLWithString:urlString];
            }
        }
        
        // get/cache image
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.imageURL.absoluteString];
        if (cachedImage) {
            self.image = cachedImage;
        } else {
            self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
            [[SDImageCache sharedImageCache] storeImage:self.image forKey:self.imageURL.absoluteString];
        }
        
        self.active = [[dict objectForKeyNotNull:@"active"] boolValue];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    // public
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.image forKey:@"image"];
    [encoder encodeBool:self.active forKey:@"active"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // public
        self.id = [decoder decodeIntForKey:@"id"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.image = [decoder decodeObjectForKey:@"image"];
        self.active = [decoder decodeBoolForKey:@"active"];
    }
    return self;
}

- (NSComparisonResult)compare:(HBSTBackgroundImage *)otherObject {
    return self.id == otherObject.id;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "id: %d\n"
            "image url: %@\n"
            "active: %d\n",
            self.id,
            self.imageURL,
            self.active
            ];
}

@end
