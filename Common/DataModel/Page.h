//
//  Page.h
//  PenTest
//
//  Created by Choi on 2017. 4. 13..
//  Copyright © 2017년 choi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNFPenLib.h"

@interface Page : NSObject
{
    enum CalibrationSize calibrationSize;
    CGRect calibrationRect;
    CGSize drawSize;
    NSMutableArray* strokeData;
}
@property (readwrite) enum CalibrationSize calibrationSize;
@property (readwrite) CGSize drawSize;
@property (readwrite) CGRect calibrationRect;
@property (retain) NSMutableArray* strokeData;
@end
