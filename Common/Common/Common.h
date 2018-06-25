//
//  Common.h
//  PenTest
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#ifndef PenTest_Common_h
#define PenTest_Common_h

enum CalibrationSize {
    Letter = 0,
    A4,
    A5,
    B5,
    B6,
    Custom,
    FT6X4,
    FT6X5,
    FT8X4,
    FT8X5,
    FT3X5,
    FT3X6,
    FT4X6,
    FT3X5_BOTTOM,
    FT3X6_BOTTOM,
    FT4X6_BOTTOM,
};

#define LETTER()\
NSLog(@"Letter");\
calResultPoint[0] = CGPointMake(1737, 541);\
calResultPoint[1] = CGPointMake(1737, 4818);\
calResultPoint[2] = CGPointMake(5445, 4818);\
calResultPoint[3] = CGPointMake(5445, 541);\

#define A4()\
NSLog(@"A4");\
calResultPoint[0] = CGPointMake(1768, 563);\
calResultPoint[1] = CGPointMake(1768, 5160);\
calResultPoint[2] = CGPointMake(5392, 5160);\
calResultPoint[3] = CGPointMake(5392, 563);\

#define A5()\
NSLog(@"A5");\
calResultPoint[0] = CGPointMake(2341, 542);\
calResultPoint[1] = CGPointMake(2341, 3631);\
calResultPoint[2] = CGPointMake(4865, 3631);\
calResultPoint[3] = CGPointMake(4865, 542);\

#define B5()\
NSLog(@"B5");\
calResultPoint[0] = CGPointMake(2027, 561);\
calResultPoint[1] = CGPointMake(2027, 4462);\
calResultPoint[2] = CGPointMake(5183, 4462);\
calResultPoint[3] = CGPointMake(5183, 561);\

#define B6()\
NSLog(@"B6");\
calResultPoint[0] = CGPointMake(2500, 544);\
calResultPoint[1] = CGPointMake(2500, 3154);\
calResultPoint[2] = CGPointMake(4704, 3154);\
calResultPoint[3] = CGPointMake(4704, 544);\

#define CUSTOM_2_3()\
NSLog(@"Custom 2:3");\
calResultPoint[0] = CGPointMake(2027, 561);\
calResultPoint[1] = CGPointMake(2027, 5295);\
calResultPoint[2] = CGPointMake(5183, 5295);\
calResultPoint[3] = CGPointMake(5183, 561);\

#define CUSTOM_3_4()\
NSLog(@"Custom 3:4");\
calResultPoint[0] = CGPointMake(2027, 561);\
calResultPoint[1] = CGPointMake(2027, 4769);\
calResultPoint[2] = CGPointMake(5183, 4769);\
calResultPoint[3] = CGPointMake(5183, 561);\

#define IPAD_MINI()\
smartPenCalPoint[0] = CGPointMake(2677, 608);\
smartPenCalPoint[1] = CGPointMake(2674, 1860);\
smartPenCalPoint[2] = CGPointMake(2680, 3127);\
smartPenCalPoint[3] = CGPointMake(3605, 3121);\
smartPenCalPoint[4] = CGPointMake(3590, 1857);\
smartPenCalPoint[5] = CGPointMake(3585, 617);\
smartPenCalPoint[6] = CGPointMake(4507, 604);\
smartPenCalPoint[7] = CGPointMake(4525, 1863);\
smartPenCalPoint[8] = CGPointMake(4536, 3114);\

#define IPAD()\
smartPenCalPoint[0] = CGPointMake(2456, 682);\
smartPenCalPoint[1] = CGPointMake(2435, 2222);\
smartPenCalPoint[2] = CGPointMake(2449, 3788);\
smartPenCalPoint[3] = CGPointMake(3599, 3798);\
smartPenCalPoint[4] = CGPointMake(3607, 2212);\
smartPenCalPoint[5] = CGPointMake(3613, 667);\
smartPenCalPoint[6] = CGPointMake(4762, 649);\
smartPenCalPoint[7] = CGPointMake(4756, 2228);\
smartPenCalPoint[8] = CGPointMake(4770, 3771);\

// TODO:: marker
#define FT_6X4()\
NSLog(@"Ft 6X4");\
calResultPoint[0] = CGPointMake(1728, 45372);\
calResultPoint[1] = CGPointMake(1728, 54824);\
calResultPoint[2] = CGPointMake(15524, 54824);\
calResultPoint[3] = CGPointMake(15524, 45372);\

// TODO:: marker
#define FT_6X5()\
NSLog(@"Ft 6X5");\
calResultPoint[0] = CGPointMake(1830, 44156);\
calResultPoint[1] = CGPointMake(1830, 56034);\
calResultPoint[2] = CGPointMake(15506, 56034);\
calResultPoint[3] = CGPointMake(15506, 44156);\

// TODO:: marker
#define FT_7X4()\
NSLog(@"Ft 7X4");\
calResultPoint[0] = CGPointMake(1883, 45300);\
calResultPoint[1] = CGPointMake(1883, 55219);\
calResultPoint[2] = CGPointMake(18514, 55219);\
calResultPoint[3] = CGPointMake(18514, 45300);\

// TODO:: marker
#define FT_8X4()\
NSLog(@"Ft 8X4");\
calResultPoint[0] = CGPointMake(1868, 45377);\
calResultPoint[1] = CGPointMake(1868, 54735);\
calResultPoint[2] = CGPointMake(20153, 54735);\
calResultPoint[3] = CGPointMake(20153, 45377);\

// TODO:: marker
#define FT_8X5()\
NSLog(@"Ft 8X5");\
calResultPoint[0] = CGPointMake(1810, 44163);\
calResultPoint[1] = CGPointMake(1810, 55938);\
calResultPoint[2] = CGPointMake(20164, 55938);\
calResultPoint[3] = CGPointMake(20164, 44163);\

// TODO:: marker
#define FT_3X5()\
NSLog(@"Ft 3X5");\
calResultPoint[0] = CGPointMake(12790, 1547);\
calResultPoint[1] = CGPointMake(12790, 13248);\
calResultPoint[2] = CGPointMake(19966, 13248);\
calResultPoint[3] = CGPointMake(19966, 1547);\

#define FT_3X5_BOTTOM()\
NSLog(@"Ft 3X5 Bottom");\
calResultPoint[0] = CGPointMake(46612, 53961);\
calResultPoint[1] = CGPointMake(46612, 65662);\
calResultPoint[2] = CGPointMake(53788, 65662);\
calResultPoint[3] = CGPointMake(53788, 53961);\

#define FT_3X6()\
NSLog(@"Ft 3X6");\
calResultPoint[0] = CGPointMake(12790, 1532);\
calResultPoint[1] = CGPointMake(12790, 15298);\
calResultPoint[2] = CGPointMake(19966, 15298);\
calResultPoint[3] = CGPointMake(19966, 1532);\

#define FT_3X6_BOTTOM()\
NSLog(@"Ft 3X6 Bottom");\
calResultPoint[0] = CGPointMake(46612, 51800);\
calResultPoint[1] = CGPointMake(46612, 65566);\
calResultPoint[2] = CGPointMake(53788, 65566);\
calResultPoint[3] = CGPointMake(53788, 51800);\

#define FT_4X6()\
NSLog(@"Ft 4X6");\
calResultPoint[0] = CGPointMake(11551, 1532);\
calResultPoint[1] = CGPointMake(11551, 15298);\
calResultPoint[2] = CGPointMake(21303, 15298);\
calResultPoint[3] = CGPointMake(21303, 1532);\

#define FT_4X6_BOTTOM()\
NSLog(@"Ft 4X6 Bottom");\
calResultPoint[0] = CGPointMake(45338, 51900);\
calResultPoint[1] = CGPointMake(45338, 65666);\
calResultPoint[2] = CGPointMake(55089, 65666);\
calResultPoint[3] = CGPointMake(55089, 51900);\

#endif
