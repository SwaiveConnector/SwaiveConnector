//
//  thermoSensor.h
//  TestlibObjectc
//
//  Created by Victor
//  Developer
//  Copyright (c) 2014 Kliotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface thermoSensor : NSObject
+(NSString *)getCurrentDateHex:(NSDate *)date;
+(NSString *) hexToString:(NSData *)data;
+(NSString *)celisusToFaherentit:(NSString *)temp;
+ (NSString *) stringToDecimal:(NSData *)data;
+ (int) hexToDecimal:(NSString *)str;
+(NSData *) hexStringToHexData:(NSString *)str;
+ (NSString *) hexDataByTwoDigitToDecimal:(NSData *)data;
@end
