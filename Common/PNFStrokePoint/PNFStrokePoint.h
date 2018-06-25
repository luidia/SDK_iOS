//
//  PNFStrokePoint.h
//  PenTestExtension
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//



@interface PNFStrokePoint:NSObject<NSCoding, NSCopying, NSMutableCopying> {
    
    CGPoint        pt;
    float        press;
}

@property(readwrite) CGPoint pt;
@property(readwrite) float press;
@end
