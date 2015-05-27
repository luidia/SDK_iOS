//
//  PNFStrokePoint.m
//  MINTInteractive
//
//  Created by Jootae Kim on 10. 11. 30..
//  Copyright 2010 PNF/RnD Ceneter. All rights reserved.
//

#import "PNFStrokePoint.h"


@implementation PNFStrokePoint
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)c
{
	self = [super init];
	pt=[c decodeCGPointForKey:@"pt"];
	press=[c decodeFloatForKey:@"press"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)c
{
	[c encodeCGPoint:pt forKey:@"pt"];
	[c encodeFloat:press forKey:@"press"];
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    PNFStrokePoint *copy = [[[self class]allocWithZone:zone] init];
    
    copy.pt = self.pt;
	copy.press = self.press;
    
    return copy;
}

-(id)copyWithZone:(NSZone*)zone{
    PNFStrokePoint *copy = [[[self class]allocWithZone:zone] init];
    
    copy.pt = self.pt;
	copy.press = self.press;
    
    return copy;
}

@synthesize pt;
@synthesize press;
@end
