//
//  MarkerCalibrationViewController.h
//  PenTestExtension
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MarkerCalibrationViewControllerDelegate
-(void) closeMarkerCalibrationViewController;
-(void) successMarkerCalibrationViewController;
@end

@class PNFPenLibExtension;

@interface MarkerCalibrationViewController : UIViewController
{
    id<MarkerCalibrationViewControllerDelegate> delegate;
    
    PNFPenLibExtension*	m_PenController;
}
@property (nonatomic, assign) id delegate;

-(void) SetPenController:(PNFPenLibExtension *) pController;
@end
