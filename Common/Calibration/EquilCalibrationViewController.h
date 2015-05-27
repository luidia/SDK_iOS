//
//  EquilCalibrationViewController.h
//  Equil Note
//
//  Created by Choi on 2014. 12. 3..
//
//

#import <UIKit/UIKit.h>

@protocol EquilCalibrationViewControllerDelegate
-(void) closeCalibViewController_FromEquilCalibrationViewController;
-(void) closeCalibViewController_FromEquilCalibrationViewController:(CGRect)rect caliRect:(CGRect)caliRect;
@end

@class PNFPenController;

@interface EquilCalibrationViewController : UIViewController
{
    id<EquilCalibrationViewControllerDelegate> delegate;
    
    PNFPenController*	m_PenController;
}
@property (nonatomic, assign) id delegate;

-(void) PenHandler:(id) sender;
-(void) SetPenController:(PNFPenController *) pController;
@end
