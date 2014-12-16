//
//  SwaiveConnector.h
//  SwaiveConnector
//
//  Created by krishnaraj on 04/12/14.
//  Copyright (c) 2014 kliotech. All rights reserved.
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
@property (readonly,nonatomic) NSMutableArray *peripherals;

+(SwaiveConnector *)sharedManager;
-(void)initialize;
@end
