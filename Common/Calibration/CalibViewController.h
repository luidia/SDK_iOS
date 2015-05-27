#import <UIKit/UIKit.h>

@protocol CalibViewControllerDelegate
-(void) closeCalibViewController:(BOOL)left btPosition:(int)positionBT;
@end

@class PNFPenController;

@interface CalibViewController : UIViewController <UIAlertViewDelegate> {
    id<CalibViewControllerDelegate> delegate;
    int count;
	PNFPenController*	m_PenController;
    IBOutlet UIImageView *devicePositionBg;
    BOOL left;
    BOOL leftOrg;
    IBOutlet UIImageView *countBg;
    IBOutlet UIImageView *pointBg;
    IBOutlet UILabel* Title1Label;
    UITextView *textView;
	CGPoint m_CalResultPoint[4];
    CGPoint m_CalResultPointTemp[4];

    IBOutlet UILabel *devicePositionLabel;
    IBOutlet UIImageView *deviceChangeBg;
    
    int penErrorCnt;
    int temperatureCnt;
    int btPosition;
    int btPositionOrg;
    
    int m_calPointCnt;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *retryBtn;
    IBOutlet UIButton *leftDeviceBtn;
    IBOutlet UIButton *rightDeviceBtn;
    IBOutlet UIImageView *lollolDeviceBtnBg;
    IBOutlet UIButton *btLeftDeviceBtn;
    IBOutlet UIButton *btTopDeviceBtn;
    IBOutlet UIButton *btRightDeviceBtn;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, readwrite) BOOL alwayasShowCalibration;
@property (nonatomic, readwrite) BOOL alwayasPenConnectShowCalibration;
@property (nonatomic, readwrite) BOOL ignoreAlwayasShowCalibration;
-(void) setDevicePosition:(BOOL)left btPosition:(int)positionBT;
-(void) LogWrite:(NSString*) logStr;
-(void) PenHandler:(id) sender;
-(BOOL) NextCalibrationProjective4;
-(void) SetPenController:(PNFPenController *) pController;
-(void) InitData;
-(IBAction)backClick:(id)sender;
- (IBAction)retryClicked:(id)sender;
- (IBAction)leftClicked:(id)sender;
- (IBAction)rightClicked:(id)sender;
- (IBAction)topClickedForBT:(id)sender;
- (IBAction)leftClickedForBT:(id)sender;
- (IBAction)rightClickedForBT:(id)sender;

@end
