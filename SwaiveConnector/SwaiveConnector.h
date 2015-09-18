//
//  SwaiveConnector.h
//  SwaiveConnector
//
//  Created by Victor
//  Developer
//  Copyright (c) 2014 Kliotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@protocol SwaiveConnectorDelegate<NSObject>
-(void)deviceConnection:(CBPeripheral*)peripheral;
-(void)deviceDisconnection:(CBPeripheral*)peripheral;
-(void)getBatteryLevel:(NSString*)value;
-(void)getTemperature:(NSString*)value date:(NSString*) temperartureDate;
-(void)getLEDBrightness:(NSString*)value;
-(void)getAlertStatus:(NSString*)value;
@end

@interface SwaiveConnector : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>{
    id <SwaiveConnectorDelegate> _delegate;
}

@property (nonatomic,strong) id<SwaiveConnectorDelegate> delegate;
@property (readonly,nonatomic) CBCentralManager *blueToothManager;
@property (weak,nonatomic) CBPeripheral *currentPeripheral;
@property (readonly,nonatomic) NSMutableArray *peripherals;

-(NSString *)getBatteryLevel;
+(SwaiveConnector *)sharedManager;
-(void)initialize;
-(void)setBrightness:(double)value;
-(NSString *)getCurrentBrightnessValue;
-(int)getStoredReadingCount;
-(void)setTemperatureFormat:(int)type;
@end


