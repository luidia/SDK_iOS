/*
 *  Define.h
 *  MINTSketch
 *
 *  Created by PNF on 7/12/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
//#define	_DEBUG_MODE
#ifndef __PNF_DEFINE_H___
#define __PNF_DEFINE_H___ 
enum PEN_STATUS {
	PEN_DOWN=1,
	PEN_MOVE,
	PEN_UP,
	PEN_HOVER,
    PEN_HOVER_DOWN,
    PEN_HOVER_MOVE
};

enum DEVICE_LANGUAGE_CODE {
    Language_None = -1,
    Language_English = 0,
    Language_Korean = 1,
    Language_Spanish = 2,
    Language_German = 3,
    Language_French = 4,
    Language_Italian = 5,
    Language_Japan = 6,
    Language_Portuguese = 7,
    Language_Russian = 8,
    Language_Chinese = 9,
    Language_Arabic = 11,
};

enum PNF_ERROR{
    PNF_E_NOT_CONNECTED=-1001,
    PNF_E_INVALID_PROTOCOL=-1002,
    PNF_E_FAIL_LISTENING= -1003
};

enum DEVICE_DIRECTION {
    DIRECTION_TOP=1,
    DIRECTION_LEFT,
    DIRECTION_RIGHT,
    DIRECTION_BOTTOM,
    DIRECTION_BOTH
};

enum ModelCode {
    SmartPen = 0,
    LolLolPen,
    Equil,
    EquilPro,
    EquilSmartMarker,
    eBeamSmartMarker,
    eBeamSmartPen
};

#define CAL_POINT_COUNT 3
#define CAL_POINT_MARGIN_X  0
#define CAL_POINT_MARGIN_Y  0

enum DEVICE_DIRECTION_NINE {
    DIRECTION_TOP_LEFT=1,
    DIRECTION_CENTER_LEFT,
    DIRECTION_BOTTOM_LEFT,
    
    DIRECTION_BOTTOM_CENTER=1,
    DIRECTION_CENTER_CENTER,
    DIRECTION_TOP_CENTER,
    
    DIRECTION_TOP_RIGHT=1,
    DIRECTION_CENTER_RIGHT,
    DIRECTION_BOTTOM_RIGHT
};
#define CAL_POINT_COUNT_NINE 9
#define CAL_POINT_NINE_MARGIN_X  10
#define CAL_POINT_NINE_MARGIN_Y  10

//Filter용 Parameter struct.
typedef struct StFilterParam {
    int rangeDelta;
    CGFloat zeroLevel;
} FilterParam;

enum DataImportCommand {
    DI_Fail = -1,
    DI_None = 0,
    DI_ShowList,
    DI_FileOpen,
    DI_FolderOpen,
    DI_FileRemove,
    DI_FolderRemove,    // 5
    DI_RemoveAll,
    DI_SetDate,
    DI_ShowDate,
    DI_ShowFreeSpace,
    DI_DeviceID,        // 10
    DI_InitializeDisk,
    DI_StopDownload,
    DI_ShowTempory,
    DI_RemoveT2File,
    DI_RealMode,        // 15
    DI_T1Mode,
    DI_ShowTempFile,
    DI_DeviceReset,
    DI_PacketSize18,
    DI_PacketSize36,    // 20
    DI_PacketSize48,
    DI_PacketSize72,
    DI_PacketSize90,
    DI_PacketSize108,
    DI_PacketSize126,   // 25
    DI_PacketSize144,
    DI_SetLabel,
    DI_SetDevicePosition,
    DI_SetDeviceCalibration1,
    DI_SetDeviceCalibration2,
    DI_GetDevicePositionCalibration,
    DI_StartCalibrationMode,
    DI_EndCalibrationMode,
    DI_ChangeDeviceName,
    DI_ResetCalibration,
    DI_SetDeviceLanguage,
};
#endif
