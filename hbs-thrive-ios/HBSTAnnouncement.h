//
//  HBSTAnnouncement.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/12/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTAnnouncement : NSObject <NSCoding>

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *headline;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSDate *startDateTime;
@property (strong, nonatomic) NSDate *endDateTime;
@property (nonatomic) BOOL hasButton;
@property (strong, nonatomic) NSString *buttonText;
@property (strong, nonatomic) NSURL *buttonLinkURL;
@property (nonatomic) BOOL active;

- (id)initWithDict:(NSDictionary *)dict;
- (NSString *)displayStartDate;
- (NSString *)displayStartTime;
- (NSString *)displayEndDate;
- (NSString *)displayEndTime;

@end
