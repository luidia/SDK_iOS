//
//  MarkerCalibrationViewController.h
//  Equil Note
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MarkerCalibrationViewControllerDelegate
-(void) closeCalibViewController_FromMarkerCalibrationViewController;
-(void) closeCalibViewController_FromMarkerCalibrationViewController:(CGRect)rect caliRect:(CGRect)caliRect;
@end

@class PNFPenLibExtension;

@interface MarkerCalibrationViewController : UIViewController
{
    id<MarkerCalibrationViewControllerDelegate> delegate;
    
    PNFPenLibExtension*	m_PenController;
}
@property (nonatomic, assign) id delegate;

-(void) PenHandler:(id) sender;
-(void) SetPenController:(PNFPenLibExtension *) pController;
@end
