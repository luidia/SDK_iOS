//
//  Page.m
//  PenTest
//
//  Created by Choi on 2017. 4. 13..
//  Copyright © 2017년 choi. All rights reserved.
//

#import "Page.h"

@implementation Page
@synthesize calibrationSize;
@synthesize strokeData;
@synthesize drawSize;
@synthesize calibrationRect;

-(void) dealloc {
    [self.strokeData removeAllObjects];
    self.strokeData = nil;
    [super dealloc];
}
-(id) init {
    self = [super init];
    if (self) {
        self.strokeData = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

@end
