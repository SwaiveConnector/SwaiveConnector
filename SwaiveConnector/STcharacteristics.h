//
//  STcharacteristics.h
//  TestlibObjectc
//
//  Created by Victor
//  Developer
//  Copyright (c) 2014 Kliotech. All rights reserved.
//

#ifndef TestlibObjectc_STcharacteristics_h
#define TestlibObjectc_STcharacteristics_h

//------------------------------Device Information Service 180A--------------------------------
#define DEVICE_INFORMATION_SERVICE @"180A"
#define ManufactureName_charID @"2A29"
#define FirmwareRevision_charID @"2A26"
#define DigitalInput_charID @"2A56"

//------------------------------Battery Service 180F---------------------------------------------
#define BATTERY_SERVICE @"180F"
#define BatteryLevel_charID @"2A19"

//------------------------------Health Thermometer 1809---------------------------------------------
#define HEALTH_THERMOMETER_SERVICE @"1809"
#define NewAlert_charID @"2A46"
#define AlertStatus_charID @"2A3F"
#define TemperatureType_charID @"2A1D"
#define TemperatureFahrenheit_charID @"2A20"
#define TemperatureFahrenheit_charID1F @"2A1F"
#define TemperatureMeasurement_charID @"2A1C"

//------------------------------Current Time 1805---------------------------------------------
#define DATE_TIME_SERVICE @"1805"
#define DateTime_charID @"2A08"
#define ReferenceTimeInformation_charID @"2A14"

#endif
