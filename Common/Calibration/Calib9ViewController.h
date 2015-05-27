//
//  Calib9ViewController.h
//  GiniNote_iPad
//
//  Created by choi on 13. 2. 20..
//  Copyright (c) 2013년 PenAndFree. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol Calib9ViewControllerDelegate
-(void) closeCalib9ViewController;
@end

@class PNFPenController;

@interface Calib9ViewController : UIViewController <UIAlertViewDelegate>
{
    id<Calib9ViewControllerDelegate> delegate;
    int count;
	PNFPenController*	m_PenController;
    CGPoint m_CalResultPoint[9];
    CGPoint m_CalResultPointTemp[9];
}
@property (nonatomic, assign) id delegate;

-(void) PenHandler:(id) sender;
-(void) SetPenController:(PNFPenController *) pController;
-(void) InitData;

@end
