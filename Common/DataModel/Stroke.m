//
//  Stroke.m
//  PenTest
//
//  Created by Choi on 2017. 4. 13..
//  Copyright © 2017년 choi. All rights reserved.
//

#import "Stroke.h"


@implementation Stroke
@synthesize strokeType;
@synthesize point;
@synthesize colorForSM;
@synthesize eraseSize;

-(id) init {
    self = [super init];
    if (self) {
    }
    return self;
}
@end
