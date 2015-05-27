//
//  TimeTestViewController.h
//  PenTest
//
//  Created by choi on 9/29/13.
//  Copyright (c) 2013 choi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PNFPenController;

@interface TimeTestViewController : UIViewController
{
    PNFPenController *penController;
}
-(void) SetPenController:(PNFPenController *) pController;
-(void) PenHandler:(id) sender;
@end
