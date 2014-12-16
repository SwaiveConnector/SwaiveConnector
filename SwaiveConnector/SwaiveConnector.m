//
//  SwaiveConnector.m
//  SwaiveConnector
//
//  Created by krishnaraj on 04/12/14.
//  Copyright (c) 2014 kliotech. All rights reserved.
//

#import "SwaiveConnector.h"
#import "STservices.h"
#import "BLEUtility.h"
#import "STcharacteristics.h"
#import "thermoSensor.h"

@interface SwaiveConnector ()

-(void)fixTimeDifference:(CBPeripheral *)peripheral characteristic: (CBCharacteristic *) character;
-(NSDate *)getlocaldate:(NSDate *)date;
-(void)readTemperature:(CBPeripheral *)peripheral characteristic: (CBCharacteristic *) character;
@end

@implementation SwaiveConnector

static  SwaiveConnector *connector;
@synthesize blueToothManager,peripherals;

+(SwaiveConnector *)sharedManager {
    if (connector !=nil) {
        return connector;
    }
    connector = [[SwaiveConnector alloc]init];
    return connector;
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [blueToothManager scanForPeripheralsWithServices:nil options:nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [blueToothManager stopScan];
    peripheral.delegate = self;
    [peripherals addObject:peripheral];
    [blueToothManager connectPeripheral:peripheral options:nil];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
        NSLog(@"%@ connected",peripheral.name);
    //    NSLog(@"pheri %@",peripheral.description);
    NSLog(@"%lu",(unsigned long)peripherals.count);
    if ([self.delegate respondsToSelector:@selector(deviceConnection:)]) {
        [self.delegate deviceConnection:peripheral];
    }
    [peripheral discoverServices:[self services]];
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@ disconnected",peripheral.name);
    [peripherals removeObject:peripheral];
    NSLog(@"%lu",(unsigned long)peripherals.count);
    if ([self.delegate respondsToSelector:@selector(deviceDisconnection:)]) {
        [self.delegate deviceDisconnection:peripheral];
    }

    [blueToothManager scanForPeripheralsWithServices:nil options:nil];
    
}

-(NSArray*)services {
    return [NSArray arrayWithObjects:[CBUUID UUIDWithString:DeviceInformationServiceID], [CBUUID UUIDWithString:HealthThermometerServiceID], [CBUUID UUIDWithString:DeviceBatteryServiceID], [CBUUID UUIDWithString:DeviceTimeServiceID] , nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in peripheral.services)    {
        [peripheral discoverCharacteristics:nil forService:aService];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *c in service.characteristics) {
        if ([c.UUID isEqual:[CBUUID UUIDWithString:NewAlert_charID]] || [c.UUID isEqual:[CBUUID UUIDWithString:AlertStatus_charID]] || [c.UUID isEqual:[CBUUID UUIDWithString:TemperatureFahrenheit_charID]] ||  [c.UUID isEqual:[CBUUID UUIDWithString:TemperatureFahrenheit_charID1F]] || [c.UUID isEqual:[CBUUID UUIDWithString:BatteryLevel_charID]] || [c.UUID isEqual:[CBUUID UUIDWithString:DigitalInput_charID]])     {
            [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:service.UUID cCBUUID:c.UUID enable:YES];
        } else if ([c.UUID isEqual:[CBUUID UUIDWithString:TemperatureType_charID]] )     {
            uint8_t data = 0x00;
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"Scale"]  isEqual: @"1"])
                data = 0xFF;
            [BLEUtility writeCharacteristic:peripheral sCBUUID:service.UUID cCBUUID:c.UUID data:[NSData dataWithBytes:&data length:1]];
        } else if ([c.UUID isEqual:[CBUUID UUIDWithString:DateTime_charID]] ||  [c.UUID isEqual:[CBUUID UUIDWithString:TemperatureMeasurement_charID]] || [c.UUID isEqual:[CBUUID UUIDWithString:DigitalInput_charID]] || [c.UUID isEqual:[CBUUID UUIDWithString:BatteryLevel_charID]]) {
            [BLEUtility readCharacteristic:peripheral sCBUUID:service.UUID cCBUUID:c.UUID];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)c error:(NSError *)error{
    
    if ([c.UUID  isEqual:[CBUUID UUIDWithString: DateTime_charID]]) {
        [self fixTimeDifference:peripheral characteristic:c];
    }
    if ([c.UUID  isEqual:[CBUUID UUIDWithString: TemperatureMeasurement_charID]] || [c.UUID  isEqual:[CBUUID UUIDWithString: TemperatureFahrenheit_charID1F]] || [c.UUID  isEqual:[CBUUID UUIDWithString: TemperatureFahrenheit_charID]]) {
        [self readTemperature:peripheral characteristic:c];
    }
    if ([c.UUID  isEqual:[CBUUID UUIDWithString: AlertStatus_charID]]) {
        if ([self.delegate respondsToSelector:@selector(getAlertStatus:)]) {
            [self.delegate getAlertStatus:[thermoSensor stringToDecimal:c.value]];
        }
        
    }
    if ([c.UUID  isEqual:[CBUUID UUIDWithString:DigitalInput_charID]]) {
        //         info.brightnessLevel =[thermoSensor stringToDecimal:c.value];
        if ([self.delegate respondsToSelector:@selector(getLEDBrightness:)]) {
            [self.delegate getLEDBrightness:[thermoSensor stringToDecimal:c.value]];
        }
        
    }
    if ([c.UUID  isEqual:[CBUUID UUIDWithString: BatteryLevel_charID]]) {
        //         info.batteryLevel = [thermoSensor stringToDecimal:c.value];
        if ([self.delegate respondsToSelector:@selector(getBatteryLevel:)]) {
            [self.delegate getBatteryLevel:[thermoSensor stringToDecimal:c.value]];
        }
    }
    
    
}

-(void)fixTimeDifference:(CBPeripheral *)peripheral characteristic: (CBCharacteristic *) character{
    
    NSMutableString *stringBuffer = [NSMutableString stringWithString:[thermoSensor hexToString:character.value]];
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger i = 0; i < [[thermoSensor getCurrentDateHex:[NSDate date]] length]; i += 2) {
        
        NSString *hex = [[thermoSensor getCurrentDateHex:[NSDate date]] substringWithRange:NSMakeRange(i, 2)];
        NSString *hex4 =[NSString stringWithFormat:@"%lx",(long)[hex integerValue]];
        //NSString *hex4 =[NSString stringWithFormat:@"%x",[hex integerValue]];
        if (hex4.length<2) {
            hex4 =[NSString stringWithFormat:@"0%@",hex4];
        }
        [string appendString:hex4];
    }
    
    
    NSMutableData* data3 = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= string.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [string substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data3 appendBytes:&intValue length:1];
    }
    
    //NSLog(@"data3:%@",data3);012A
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:@"ssmmHHddeeMMyy"];
    
    NSMutableString *fromdateStr=[[NSMutableString alloc] init];
    for (int idx = 0; idx+2 <= stringBuffer.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [stringBuffer substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        NSString *str = [NSString stringWithFormat:@"%d",intValue];
        if (str.length<=1) {
            str =[NSString stringWithFormat:@"0%d",intValue];
        }
        [fromdateStr appendString:str ];
    }
    NSDate *fromDate =[self getlocaldate:[dateFormatter dateFromString:fromdateStr]];
    NSDate *toDate =[self getlocaldate:[NSDate date]];
    if(![toDate isEqualToDate:fromDate]){
        
        //--------------------------------------------------------------------------------------------------------------------------------------------------------------
        //                                                      Update Timestamp
        //--------------------------------------------------------------------------------------------------------------------------------------------------------------
        
        [BLEUtility writeCharacteristic:peripheral sCBUUID:[CBUUID UUIDWithString: @"1805"] cCBUUID:[CBUUID UUIDWithString: @"2A08"] data:data3];
        
    }
}
-(void)readTemperature:(CBPeripheral *)peripheral characteristic: (CBCharacteristic *) character{
    NSString *valueString=[thermoSensor hexToString:character.value];
    int tempt = [thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(4,2)]];
    
    if (tempt > 0) {
        //[[[UIAlertView alloc]initWithTitle:@"Received" message:[NSString stringWithFormat:@"Temperature received : %d",tempt] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        NSString *temp =[NSString stringWithFormat:@"%d.%d",[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(4,2)]],[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(6,2)]]];
        NSString *dateStr =[NSString stringWithFormat:@"20%02d-%02d-%02d %02d:%02d:%02d",[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(20,2)]],[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(18,2)]],[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(14,2)]],[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(12,2)]],[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(10,2)]],[thermoSensor hexToDecimal:[valueString substringWithRange:NSMakeRange(8,2)]]];
        if ([self.delegate respondsToSelector:@selector(getTemperature:date:)]) {
            [self.delegate getTemperature:temp date:dateStr];
        }
        if ([temp floatValue] > 105.0) {
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:incorrect_temperature delegate:nil cancelButtonTitle:@"Okay !" otherButtonTitles:nil];
            //            [alertView show];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
            //            return;
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"connnection FAiled");
}

-(NSDate *)getlocaldate:(NSDate *)date{
    NSDate* sourceDate = date;
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    return destinationDate;
}

-(void)initialize{
    peripherals = [[NSMutableArray alloc]init];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"Scale"];
    blueToothManager     = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerOptionShowPowerAlertKey]];
    NSLog(@"Welcome Swaive Connector in ");
}
@end
