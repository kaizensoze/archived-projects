//
//  HBSTAnnouncement.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/12/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTAnnouncement.h"

@interface HBSTAnnouncement ()
    @property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation HBSTAnnouncement

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [[dict objectForKeyNotNull:@"id"] intValue];
        self.summary = [dict objectForKeyNotNull:@"summary"];
        self.headline = [dict objectForKeyNotNull:@"headline"];
        
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
        
        self.body = [dict objectForKeyNotNull:@"body"];
        self.location = [dict objectForKeyNotNull:@"location"];
        
        // start/end datetime
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZ"];
        
        NSString *startDateTimeString = [dict objectForKeyNotNull:@"start_time"];
        self.startDateTime = [self.dateFormatter dateFromString:startDateTimeString];
        
        NSString *endDateTimeString = [dict objectForKeyNotNull:@"end_time"];
        self.endDateTime = [self.dateFormatter dateFromString:endDateTimeString];
        // ---
        
        self.hasButton = [[dict objectForKeyNotNull:@"has_button"] boolValue];
        self.buttonText = [dict objectForKeyNotNull:@"button_text"];
        
        NSString *buttonLinkString = [dict objectForKeyNotNull:@"button_link"];
        if (buttonLinkString.length > 0) {
            self.buttonLinkURL = [NSURL URLWithString:buttonLinkString];
        }
        
        self.active = [[dict objectForKeyNotNull:@"active"] boolValue];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    // private
    [encoder encodeObject:self.dateFormatter forKey:@"dateFormatter"];
    
    // public
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.summary forKey:@"summary"];
    [encoder encodeObject:self.headline forKey:@"headline"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.image forKey:@"image"];
    [encoder encodeObject:self.body forKey:@"body"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.startDateTime forKey:@"startDateTime"];
    [encoder encodeObject:self.endDateTime forKey:@"endDateTime"];
    [encoder encodeBool:self.hasButton forKey:@"hasButton"];
    [encoder encodeObject:self.buttonText forKey:@"buttonText"];
    [encoder encodeObject:self.buttonLinkURL forKey:@"buttonLinkURL"];
    [encoder encodeBool:self.active forKey:@"active"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // private
        self.dateFormatter = [decoder decodeObjectForKey:@"dateFormatter"];
        
        // public
        self.id = [decoder decodeIntForKey:@"id"];
        self.summary = [decoder decodeObjectForKey:@"summary"];
        self.headline = [decoder decodeObjectForKey:@"headline"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.image = [decoder decodeObjectForKey:@"image"];
        self.body = [decoder decodeObjectForKey:@"body"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.startDateTime = [decoder decodeObjectForKey:@"startDateTime"];
        self.endDateTime = [decoder decodeObjectForKey:@"endDateTime"];
        self.hasButton = [decoder decodeBoolForKey:@"hasButton"];
        self.buttonText = [decoder decodeObjectForKey:@"buttonText"];
        self.buttonLinkURL = [decoder decodeObjectForKey:@"buttonLinkURL"];
        self.active = [decoder decodeBoolForKey:@"active"];
    }
    return self;
}

- (NSString *)displayStartDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, YYYY"];
    return [dateFormatter stringFromDate:self.startDateTime];
}

- (NSString *)displayStartTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mma"];
    NSString *displayStartTime = [dateFormatter stringFromDate:self.startDateTime];
    if ([displayStartTime isEqualToString:@"12:00AM"]) {
        return nil;
    } else {
        return displayStartTime;
    }
}

- (NSString *)displayEndDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, YYYY"];
    return [dateFormatter stringFromDate:self.endDateTime];
}

- (NSString *)displayEndTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mma"];
    NSString *displayEndTime = [dateFormatter stringFromDate:self.endDateTime];
    if ([displayEndTime isEqualToString:@"12:00AM"]) {
        return nil;
    } else {
        return displayEndTime;
    }
}

- (NSComparisonResult)compare:(HBSTAnnouncement *)otherObject {
    return self.id == otherObject.id;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "id: %d\n"
            "summary: %@\n"
            "headline: %@\n"
            "imageURL: %@\n"
            "body: %@\n"
            "location: %@\n"
            "startDateTime: %@\n"
            "endDateTime: %@\n"
            "hasButton: %d\n"
            "buttonText: %@\n"
            "buttonLinkURL: %@\n"
            "active: %d\n",
            self.id,
            self.summary,
            self.headline,
            self.imageURL,
            self.body,
            self.location,
            [self.dateFormatter stringFromDate:self.startDateTime],
            [self.dateFormatter stringFromDate:self.endDateTime],
            self.hasButton,
            self.buttonText,
            self.buttonLinkURL,
            self.active
            ];
}

@end
