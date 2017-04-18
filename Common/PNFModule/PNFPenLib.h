//
//  PNFPenLib.h
//  PNFPenLib
//
//  Created by PNF on 5/30/12.
//  Copyright (c) 2012 Choi. All rights reserved.
//

#import <Foundation/Foundation.h>
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
#if TARGET_OS_IPHONE
#else
@property(readonly) BOOL		bConnectedHID;
@property(readonly) BOOL		bConnectedHIDDongle;
@property(readonly) NSString*	macAddress;
#endif
@property(readonly) BOOL        bStopped;
@property(readonly) BOOL        bExistCalibrationInfo;
@property(readonly) int         pressure;
@property(readonly) int         modelCode;
@property(readonly) int         MCU1Version;
@property(readonly) int         MCU2Version;
@property(readonly) int         HWVersion;
@property(readonly) int         penAliveSec;
@property(readonly) BOOL        AudioMode;
@property(readonly) int         Volume;
@property(readonly) int         battery_station;
@property(readonly) int         battery_pen;

#if TARGET_OS_IPHONE
-(int) startPen;
#else
-(int) startPen:(int)mCode;
#endif
-(void) stopPen;
-(void) restartPen;
-(void) disConnectPen;

-(void) setRetObj:(NSObject *) obj;
-(NSObject*) getRetObj;
-(void) setRetObjForEnv:(NSObject *) obj;

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

#if TARGET_OS_IPHONE
#else
-(void) changeScreenSize:(CGRect)rtDraw;
-(void) InitBTConnection:(int)mCode;
-(NSArray*) savePenInfoCount;
#endif

// Data Import Start =============================//
@property(readonly) int         SMPenState;
@property(readonly) int         SMPenFlag;
@property(readonly) int di_paper_size;
@property(readonly) int di_figure_count;
@property(readonly) NSMutableArray* di_debug_str;
@property(readonly) int di_freespace;
@property(readonly) BOOL di_bRun;
@property(readonly) BOOL di_bTemporary_file;
@property(readonly) NSData *di_file_data;
@property(readonly) NSMutableArray *di_file_data_temp;
@property(readonly) NSMutableArray *di_file_data_mg;
@property(readonly) NSMutableArray *di_file_data_mg_paper;
@property(readonly) NSMutableArray *di_savefilename;
@property(readonly) int di_tempfile_size;
#if TARGET_OS_IPHONE
@property(readonly) int di_disk_state;
#else
#endif

#if TARGET_OS_IPHONE
#else
-(void) checkDICalFromUSB:(NSMutableData*)data;
// for USB Import
-(NSMutableDictionary*) USBManager_Dic;
-(NSMutableArray*) USBManager_FolderList;
-(NSMutableArray*) USBManager_FileList;
-(NSString*) USBManager_RootPath;
-(void) USBManager_setBookmarkData:(NSData*)bookmarkData;
-(NSString*) USBManager_BookmarkPath;
-(void) checkDiData;
-(BOOL) isCheckDiData;
#endif
-(int) getFolderCount;
-(int) getDIAllFileCount;
-(int) getFileCount:(int)index;
-(void) setFolderIndex:(int) index;
-(void) setFileIndex:(int) index;
-(NSMutableArray*) getDIFolderName;
-(NSMutableArray*) getDIFileName:(int)folder;
-(NSMutableArray*) getDISavefileName;
-(NSMutableArray*) getDISaveAllfileName;
-(void) setChoiceFolder:(int)index setState:(int)state;
-(void) setChoiceFile:(int)index fileDel:(BOOL)bkey;
-(int) getDIState;
-(int) getDIDownFileSize;
-(void) setDIState:(int)state;
-(NSData *) getDIShowData;
-(NSMutableArray*) getDIAllfileData;

-(NSMutableData*) getDIDebugData:(BOOL)bList;

-(void) convertData:(NSData*)data c:(BOOL)b;
-(int) getDIFileSize;
-(void)releaseTempData;
-(void)checkDIPaperSize:(NSData *)data;

#if TARGET_OS_IPHONE
-(int) DIDownFilePercent;
-(float) DIDownFileTime;
#else
-(void) setNonSandbox;
#endif
// Data Import End =============================//

@end
