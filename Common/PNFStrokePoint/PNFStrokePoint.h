//
//  PNFStrokePoint.h
//  MINTInteractive
//
//  Created by Jootae Kim on 10. 11. 30..
//  Copyright 2010 PNF/RnD Ceneter. All rights reserved.
//



@interface PNFStrokePoint:NSObject<NSCoding, NSCopying, NSMutableCopying> {

	CGPoint		pt;
	float		press;
}

@property(readwrite) CGPoint pt;
@property(readwrite) float press;
@end
