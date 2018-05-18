//
//  PenCalibrationViewController.h
//  PenTestExtension
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PenCalibrationViewControllerDelegate
-(void) closePenCalibrationViewController;
-(void) successPenCalibrationViewController;
@end

@class PNFPenLibExtension;

@interface PenCalibrationViewController : UIViewController
{
    id<PenCalibrationViewControllerDelegate> delegate;
    
    PNFPenLibExtension*	m_PenController;
}
@property (nonatomic, assign) id delegate;

-(void) SetPenController:(PNFPenLibExtension *) pController;
@end
