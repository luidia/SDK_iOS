//
//  Stroke.h
//  PenTest
//
//  Created by Choi on 2017. 4. 13..
//  Copyright © 2017년 choi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNFPenLib.h"

@interface Stroke : NSObject
{
    enum PEN_STATUS strokeType;
    int colorForSM;
    float eraseSize;
    CGPoint point;
}
@property (readwrite) enum PEN_STATUS strokeType;
@property (readwrite) CGPoint point;
@property (readwrite) int colorForSM;
@property (readwrite) float eraseSize;
@end
