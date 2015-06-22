//
//  ILUDiamond.m
//  illuminex
//
//  Created by Joe Gallo on 10/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUItem.h"

@implementation ILUItem

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.id = [decoder decodeIntForKey:@"id"];
        
        self.title = [decoder decodeObjectForKey:@"title"];
        self.shortTitle = [decoder decodeObjectForKey:@"shortTitle"];
        
        self.image = [UIImage imageWithData:[decoder decodeObjectForKey:@"image"]];
        
        self.certNumber = [decoder decodeObjectForKey:@"certNumber"];
        self.clarity = [decoder decodeObjectForKey:@"clarity"];
        self.color = [decoder decodeObjectForKey:@"color"];
        self.culetCondition = [decoder decodeObjectForKey:@"culetCondition"];
        self.culetSize = [decoder decodeObjectForKey:@"culetSize"];
        self.currencyCode = [decoder decodeObjectForKey:@"currencyCode"];
        self.cutGrade = [decoder decodeObjectForKey:@"cutGrade"];
        self.depthPercent = [decoder decodeFloatForKey:@"depthPercent"];
        self.tablePercent = [decoder decodeFloatForKey:@"tablePercent"];
        self.fancyColorDominantColor = [decoder decodeObjectForKey:@"fancyColorDominantColor"];
        self.fancyColorIntensity = [decoder decodeObjectForKey:@"fancyColorIntensity"];
        self.fancyColorOvertone = [decoder decodeObjectForKey:@"fancyColorOvertone"];
        self.fancyColorSecondaryColor = [decoder decodeObjectForKey:@"fancyColorSecondaryColor"];
        self.fluorescenceColor = [decoder decodeObjectForKey:@"fluorescenceColor"];
        self.fluorescenceIntensity = [decoder decodeObjectForKey:@"fluorescenceIntensity"];
        self.girdleCondition = [decoder decodeObjectForKey:@"girdleCondition"];
        self.girdleMin = [decoder decodeObjectForKey:@"girdleMin"];
        self.girdleMax = [decoder decodeObjectForKey:@"girdleMax"];
        self.hasCertFile = [decoder decodeBoolForKey:@"hasCertFile"];
        self.lab = [decoder decodeObjectForKey:@"lab"];
        self.measuredDepth = [decoder decodeFloatForKey:@"measuredDepth"];
        self.measuredLength = [decoder decodeFloatForKey:@"measuredLength"];
        self.measuredWidth = [decoder decodeFloatForKey:@"measuredWidth"];
        self.polish = [decoder decodeObjectForKey:@"polish"];
        self.shape = [decoder decodeObjectForKey:@"shape"];
        self.carat = [decoder decodeFloatForKey:@"carat"];
        self.stockNumber = [decoder decodeObjectForKey:@"stockNumber"];
        self.symmetry = [decoder decodeObjectForKey:@"symmetry"];
        self.status = [decoder decodeObjectForKey:@"status"];
        self.price = [decoder decodeObjectForKey:@"price"];
        
        self.onHand = [decoder decodeBoolForKey:@"onHand"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.id forKey:@"id"];
    
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.shortTitle forKey:@"shortTitle"];
    
    [encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"image"];
    
    [encoder encodeObject:self.certNumber forKey:@"certNumber"];
    [encoder encodeObject:self.clarity forKey:@"clarity"];
    [encoder encodeObject:self.color forKey:@"color"];
    [encoder encodeObject:self.culetCondition forKey:@"culetCondition"];
    [encoder encodeObject:self.culetSize forKey:@"culetSize"];
    [encoder encodeObject:self.currencyCode forKey:@"currencyCode"];
    [encoder encodeObject:self.cutGrade forKey:@"cutGrade"];
    [encoder encodeFloat:self.depthPercent forKey:@"depthPercent"];
    [encoder encodeFloat:self.tablePercent forKey:@"tablePercent"];
    [encoder encodeObject:self.fancyColorDominantColor forKey:@"fancyColorDominantColor"];
    [encoder encodeObject:self.fancyColorIntensity forKey:@"fancyColorIntensity"];
    [encoder encodeObject:self.fancyColorOvertone forKey:@"fancyColorOvertone"];
    [encoder encodeObject:self.fancyColorSecondaryColor forKey:@"fancyColorSecondaryColor"];
    [encoder encodeObject:self.fluorescenceColor forKey:@"fluorescenceColor"];
    [encoder encodeObject:self.fluorescenceIntensity forKey:@"fluorescenceIntensity"];
    [encoder encodeObject:self.girdleCondition forKey:@"girdleCondition"];
    [encoder encodeObject:self.girdleMin forKey:@"girdleMin"];
    [encoder encodeObject:self.girdleMax forKey:@"girdleMax"];
    [encoder encodeBool:self.hasCertFile forKey:@"hasCertFile"];
    [encoder encodeObject:self.lab forKey:@"lab"];
    [encoder encodeFloat:self.measuredDepth forKey:@"measuredDepth"];
    [encoder encodeFloat:self.measuredLength forKey:@"measuredLength"];
    [encoder encodeFloat:self.measuredWidth forKey:@"measuredWidth"];
    [encoder encodeObject:self.polish forKey:@"polish"];
    [encoder encodeObject:self.shape forKey:@"shape"];
    [encoder encodeFloat:self.carat forKey:@"carat"];
    [encoder encodeObject:self.stockNumber forKey:@"stockNumber"];
    [encoder encodeObject:self.symmetry forKey:@"symmetry"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.price forKey:@"price"];
    
    [encoder encodeBool:self.onHand forKey:@"onHand"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ILUItem *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.id = self.id;
        
        copy.title = self.title;
        copy.shortTitle = self.shortTitle;
        
        copy.image = self.image;
        
        copy.certNumber = self.certNumber;
        copy.clarity = self.clarity;
        copy.color = self.color;
        copy.culetCondition = self.culetCondition;
        copy.culetSize = self.culetSize;
        copy.currencyCode = self.currencyCode;
        copy.cutGrade = self.cutGrade;
        copy.depthPercent = self.depthPercent;
        copy.tablePercent = self.tablePercent;
        copy.fancyColorDominantColor = self.fancyColorDominantColor;
        copy.fancyColorIntensity = self.fancyColorIntensity;
        copy.fancyColorOvertone = self.fancyColorOvertone;
        copy.fancyColorSecondaryColor = self.fancyColorSecondaryColor;
        copy.fluorescenceColor = self.fluorescenceColor;
        copy.fluorescenceIntensity = self.fluorescenceIntensity;
        copy.girdleCondition = self.girdleCondition;
        copy.girdleMin = self.girdleMin;
        copy.girdleMax = self.girdleMax;
        copy.hasCertFile = self.hasCertFile;
        copy.lab = self.lab;
        copy.measuredDepth = self.measuredDepth;
        copy.measuredLength = self.measuredLength;
        copy.measuredWidth = self.measuredWidth;
        copy.polish = self.polish;
        copy.shape = self.shape;
        copy.carat = self.carat;
        copy.stockNumber = self.stockNumber;
        copy.symmetry = self.symmetry;
        copy.status = self.status;
        copy.price = self.price;
        
        copy.onHand = self.onHand;
    }
    
    return copy;
}

#pragma mark - Import

- (void)import:(NSDictionary *)dict {
    self.id = [dict[@"diamond_id"] intValue];
    
    self.image = [UIImage imageNamed:@"search-result-diamond-example"];
    
    self.certNumber = dict[@"cert_num"];
    self.clarity = dict[@"clarity"];
    self.color = dict[@"color"];
    self.culetCondition = dict[@"culet_condition"];
    self.culetSize = dict[@"culet_size"];
    self.currencyCode = dict[@"currency_code"];
    self.cutGrade = dict[@"cut"];
    self.depthPercent = [dict[@"depth_percent"] floatValue];
    self.tablePercent = [dict[@"table_percent"] floatValue];
    self.fancyColorDominantColor = dict[@"fancy_color_dominant_color"];
    self.fancyColorIntensity = dict[@"fancy_color_intensity"];
    self.fancyColorOvertone = dict[@"fancy_color_overtone"];
    self.fancyColorSecondaryColor = dict[@"fancy_color_secondary_color"];
    self.fluorescenceColor = dict[@"fluor_color"];
    self.fluorescenceIntensity = dict[@"fluor_intensity"];
    self.girdleCondition = dict[@"girdle_condition"];
    self.girdleMin = dict[@"girdle_min"];
    self.girdleMax = dict[@"girdle_max"];
    self.hasCertFile = [dict[@"has_cert_file"] boolValue];
    self.lab = dict[@"lab"];
    self.measuredDepth = [dict[@"meas_depth"] floatValue];
    self.measuredLength = [dict[@"meas_length"] floatValue];
    self.measuredWidth = [dict[@"meas_width"] floatValue];
    self.polish = dict[@"polish"];
    self.shape = dict[@"shape"];
    self.carat = [dict[@"size"] floatValue];
    self.stockNumber = dict[@"stock_num"];
    self.symmetry = dict[@"symmetry"];
    self.price = [NSDecimalNumber decimalNumberWithDecimal:
                  [[NSNumber numberWithFloat:[dict[@"total_sales_price"] floatValue]] decimalValue]];
    
    self.title = [NSString stringWithFormat:@"Diamond #%@", self.stockNumber];
    self.shortTitle = [NSString stringWithFormat:@"#%@", self.stockNumber];
    
    self.status = @"On-Hand";
    self.onHand = YES;
}

- (NSString *)formattedPrice {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.maximumFractionDigits = 0;
    
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:self.currencyCode];
//    formatter.locale = locale;
    
    NSString *priceStr = [formatter stringFromNumber:self.price];
    
    return priceStr;
}

- (BOOL)isEqualToItem:(ILUItem *)aItem {
    if (self == aItem)
        return YES;
    if (self.id != aItem.id)
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToItem:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + self.id;
    return result;
}

- (NSString *)description {
    return self.title;
}

@end
