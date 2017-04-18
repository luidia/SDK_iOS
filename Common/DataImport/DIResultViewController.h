//
//  DIResultViewController.h
//  PenTest
//
//  Created by Choi on 2017. 4. 13..
//  Copyright © 2017년 choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIDrawView.h"
#import "DataModel.h"

@interface DIResultViewController : UIViewController
{
    NSMutableArray* pages;
    PNFPenController *penController;
}
@property (retain) NSMutableArray* pages;
-(void) SetPenController:(PNFPenController *) pController;
@end
