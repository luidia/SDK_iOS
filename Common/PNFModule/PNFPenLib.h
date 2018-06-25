//
//  PNFPenLib.h
//  PNFPenLib
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "PNFDefine.h"
@class _PenController;

@interface PNFPenController : NSObject
{
@protected
    _PenController* m_PenController;
}
@property(readonly) CGPoint     ptRaw;
@property(readonly) CGPoint     ptConv;
@property(readonly) int         PenStatus;
@property(readonly) int         StationPosition;
@property(readonly) int         Temperature;
@property(readonly) BOOL		bConnected;
@property(readonly) BOOL        isBLEConnect;
#if TARGET_OS_IPHONE
#else
@property(readonly) BOOL		bConnectedHID;
@property(readonly) BOOL		bConnectedHIDDongle;
@property(readonly) BOOL		bConnectedHIDDonglePaired;
@property(readonly) NSString*	macAddress;
#endif
@property(readonly) BOOL        bStopped;
@property(readonly) BOOL        bExistCalibrationInfo;
@property(readonly) int         pressure;
@property(readonly) int         modelCode;
@property(readonly) int         MCU1Version;
@property(readonly) int         MCU2Version;
@property(readonly) int         HWVersion;
@property(readonly) int         BTVersion;
@property(readonly) int         penAliveSec;
@property(readonly) BOOL        AudioMode;
@property(readonly) int         Volume;
@property(readonly) int         battery_station;
@property(readonly) int         battery_pen;
@property(readonly) int         RSSI;
@property(readonly) CGPoint     deviceCalibrationData_0;
@property(readonly) CGPoint     deviceCalibrationData_1;
@property(readonly) CGPoint     deviceCalibrationData_2;
@property(readonly) CGPoint     deviceCalibrationData_3;
@property(readonly) enum DEVICE_DIRECTION devicePosition;
@property(readonly) enum DEVICE_LANGUAGE_CODE deviceLanguage;

// For BLE Start
-(id)initWithExtension;
-(void) BLEInit;
-(void) BLEScan;
-(void) BLEScanStop;
-(CBPeripheral*) getBLEPeripheral:(NSUUID*)nsUUID deviceName:(NSString*)name;
-(void) BLEConnect:(CBPeripheral *)peripheral;
-(void) BLEDisconnect;
-(void) BLEConnectForce:(CBPeripheral *)peripheral;
-(void) BLEDisconnectForce;
-(NSString*) BLECurrentName;

-(void) startCalibrationMode;
-(void) endCalibrationMode;
-(void) setStationPositionForCalibration:(enum DEVICE_DIRECTION)dir;
-(void) changeDeviceName:(NSString*)name;
-(void) getCalibrationInfo;
-(void) sendCalibrationDataToDevice:(enum DEVICE_DIRECTION)position CalibPoint:(CGPoint[]) ptCal;
-(void) resetCalibrationToDevice;
-(void) setDeviceLanguage:(enum DEVICE_LANGUAGE_CODE)lang;
// For BLE End

-(void) stopPen;
-(void) restartPen;
-(void) disConnectPen;

-(void) setRetObj:(NSObject *) obj;
-(NSObject*) getRetObj;
-(void) setRetObjForEnv:(NSObject *) obj;
-(NSObject*) getRetObjForEnv;

-(CGSize) getCalibrationSize;
-(void) setCalibration:(CGRect) rtDraw GuideMargin:(float) margin;
-(void) setCalibrationData:(CGRect) rtDraw GuideMargin:(float) margin CalibPoint:(CGPoint[]) ptCal;

-(void) setProjectiveLevel:(int) nProjectiveLevel;
-(int)  getProjectiveLevel;

-(void) changeAudioMode:(BOOL)audio;
-(void) changeVolume:(int)vol;

-(NSDictionary*) ReadQ;
-(void) RemoveQ;
-(void) ClearQ;
-(void) StartReadQ;
-(void) EndReadQ;

-(void) initPenUp;
-(float) calcSmartMarkerEraseThick:(BOOL)isBig;

-(void) GetTransData:(CGFloat) xxx RawY:(CGFloat) yyy TransX:(CGFloat *) xx TransY:(CGFloat *)yy flag:(int)flag;

#if TARGET_OS_IPHONE
#else
-(void) changeScreenSize:(CGRect)rtDraw;
-(void) InitBTConnection:(int)mCode;
-(NSArray*) savePenInfoCount;
-(void) PlayHIDSound:(BOOL)connect;
#endif
@end
