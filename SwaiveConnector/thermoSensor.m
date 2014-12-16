//
//  thermoSensor.m
//  TestlibObjectc
//
//  Created by krishnaraj on 15/12/14.
//  Copyright (c) 2014 kliotech. All rights reserved.
//

#import "thermoSensor.h"

@implementation thermoSensor

+(NSString *)getCurrentDateHex:(NSDate *)date{
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"ssmmHHddeeMMyy"];
    //NSLog(@"Current date string:%@",[dateFormatter stringFromDate:[NSDate date]]);
    return [dateFormatter stringFromDate:[NSDate date]];
}
+(NSData *) hexStringToHexData:(NSString *)str{
    NSMutableData* data3 = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data3 appendBytes:&intValue length:1];
    }
    return data3;
}

+ (NSString *) hexToString:(NSData *)data
{
    NSUInteger capacity = [data length] * 2;
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [data bytes];
    NSInteger i;
    for (i=0; i<[data length]; ++i) {
        // [stringBuffer appendFormat:@"%02x", (NSUInteger)dataBuffer[i]];
        [stringBuffer appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
    }
    return  stringBuffer;
}
+ (NSString *) stringToDecimal:(NSData *)data
{
    NSUInteger capacity = [data length] * 2;
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [data bytes];
    NSInteger i;
    for (i=0; i<[data length]; ++i) {
        [stringBuffer appendFormat:@"%i", dataBuffer[i]];
    }
    return  stringBuffer;
}
+(NSString *)celisusToFaherentit:(NSString *)temp{
    float Fah= ([temp doubleValue]*9)/5 + 32;
    return [NSString stringWithFormat:@"%.1f",Fah] ;
}
+ (int) hexToDecimal:(NSString *)str
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    unsigned int intValue;
    [scanner scanHexInt:&intValue];
    return intValue;
}
+ (NSString *) hexDataByTwoDigitToDecimal:(NSData *)data
{
    NSMutableString *returnStr;
    for (int i=0; i<[data length];i++) {
        // [data getBytes:&str length:i];
        NSString *str;
        [data getBytes:&str range:NSMakeRange(i, 1)];
        NSScanner* scanner = [NSScanner scannerWithString:str];
        unsigned int intValue;
        [returnStr appendFormat:@"%i", [scanner scanHexInt:&intValue]];
    }
    return  returnStr;
}

@end
