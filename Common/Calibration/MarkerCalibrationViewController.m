//
//  MarkerCalibrationViewController.m
//  Equil Note
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 choi. All rights reserved.
//

#import "MarkerCalibrationViewController.h"
#import "Toast+UIView.h"
#import "UIImage+ImageNamed.h"
#import "PNFPenLibExtension.h"
#import "PNFDefine.h"

enum CaliType {
    CaliType_SmartMarker_Top = 1,
    CaliType_SmartMarker_Left,
    CaliType_SmartMarker_Right,
    CaliType_SmartMarker_Bottom,
    CaliType_SmartMarker_Both,
};

@interface MarkerCalibrationViewController () <UIAlertViewDelegate>
{
    IBOutlet UIButton *canceBtn;
    IBOutlet UIButton *retryBtn;
    
    IBOutlet UIButton *eBeam_Left;
    IBOutlet UIButton *eBeam_Top;
    IBOutlet UIButton *eBeam_Right;
    IBOutlet UIButton *eBeam_Bottom;
    IBOutlet UIButton *eBeam_Both;
    
    IBOutlet UIImageView *eBeam_Point1;
    IBOutlet UIImageView *eBeam_Point1_Done;
    IBOutlet UIImageView *eBeam_Point2;
    
    enum CaliType type;
    int calPointCnt;
    int count;
    int saveStationPosition;
    CGPoint m_CalResultPoint[4];
    CGPoint m_CalResultPointTemp[4];
    
    BOOL runApplyProcessByPass;
}
@end

@implementation MarkerCalibrationViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        delegate = nil;
        type = CaliType_SmartMarker_Top;
        runApplyProcessByPass = NO;
    }
    
    return self;
}
- (void)dealloc {
    [m_PenController StartReadQ];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseCaliViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_MSG" object:nil];
    
    if (canceBtn){
        [canceBtn release];
        canceBtn = nil;
    }
    
    if (retryBtn){
        [retryBtn release];
        retryBtn = nil;
    }
    
    if (eBeam_Left){
        [eBeam_Left release];
        eBeam_Left = nil;
    }
    
    if (eBeam_Top){
        [eBeam_Top release];
        eBeam_Top = nil;
    }
    
    if (eBeam_Right){
        [eBeam_Right release];
        eBeam_Right = nil;
    }
    
    if (eBeam_Bottom){
        [eBeam_Bottom release];
        eBeam_Bottom = nil;
    }
    
    if (eBeam_Both){
        [eBeam_Both release];
        eBeam_Both = nil;
    }
    
    if (eBeam_Point1){
        [eBeam_Point1 release];
        eBeam_Point1 = nil;
    }
    
    if (eBeam_Point1_Done){
        [eBeam_Point1_Done release];
        eBeam_Point1_Done = nil;
    }
    
    if (eBeam_Point2){
        [eBeam_Point2 release];
        eBeam_Point2 = nil;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (m_PenController) {
        [m_PenController EndReadQ];
    }
    [m_PenController startCalibrationMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenHandlerWithMsg:) name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DICallBack:) name:@"PNF_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeSelf)
                                                 name:@"CloseCaliViewController"
                                               object:nil];
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        for (int i=0; i<[subviews count]; i++) {
            if ([[subviews objectAtIndex:i] isKindOfClass:[UIAlertView class]]) {
                UIAlertView* av = (UIAlertView*)[subviews objectAtIndex:i];
                [av dismissWithClickedButtonIndex:0 animated:NO];
            }
        }
    }
    
    saveStationPosition = m_PenController.StationPosition;
    if (m_PenController.StationPosition == DIRECTION_TOP) {
        type = CaliType_SmartMarker_Top;
    }
    else if (m_PenController.StationPosition == DIRECTION_BOTTOM) {
        type = CaliType_SmartMarker_Bottom;
    }
    else if (m_PenController.StationPosition == DIRECTION_RIGHT) {
        type = CaliType_SmartMarker_Right;
    }
    else if (m_PenController.StationPosition == DIRECTION_BOTH) {
        type = CaliType_SmartMarker_Both;
    }
    else {
        type = CaliType_SmartMarker_Left;
    }

    [self InitData];
}
- (void) SetPenController:(PNFPenLibExtension *) pController {
    m_PenController = pController;
}
- (void) closeSelf {
    [m_PenController setStationPositionForCalibration:saveStationPosition];
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}
- (void) InitData {
    count = 0;
    calPointCnt = 2;

    if (type == CaliType_SmartMarker_Top) {
        eBeam_Top.alpha = 1.0f;

        eBeam_Left.alpha = 0.3f;
        eBeam_Right.alpha = 0.3f;
        eBeam_Bottom.alpha = 0.3f;
        eBeam_Both.alpha = 0.3f;
    }
    else if (type == CaliType_SmartMarker_Bottom) {
        eBeam_Bottom.alpha = 1.0f;

        eBeam_Left.alpha = 0.3f;
        eBeam_Right.alpha = 0.3f;
        eBeam_Top.alpha = 0.3f;
        eBeam_Both.alpha = 0.3f;
    }
    else if (type == CaliType_SmartMarker_Right) {
        eBeam_Right.alpha = 1.0f;

        eBeam_Left.alpha = 0.3f;
        eBeam_Bottom.alpha = 0.3f;
        eBeam_Top.alpha = 0.3f;
        eBeam_Both.alpha = 0.3f;
    }
    else if (type == CaliType_SmartMarker_Both) {
        eBeam_Both.alpha = 1.0f;

        eBeam_Left.alpha = 0.3f;
        eBeam_Bottom.alpha = 0.3f;
        eBeam_Top.alpha = 0.3f;
        eBeam_Right.alpha = 0.3f;
    }
    else {
        eBeam_Left.alpha = 1.0f;

        eBeam_Both.alpha = 0.3f;
        eBeam_Bottom.alpha = 0.3f;
        eBeam_Top.alpha = 0.3f;
        eBeam_Right.alpha = 0.3f;
    }

    NSString* countStr = [NSString stringWithFormat:@"paper_set_%02d_on.png", count+1];
    [eBeam_Point1 setImage:[UIImage MyImageNamed:countStr]];
    eBeam_Point1.frame = CGRectMake(5, 5, eBeam_Point1.frame.size.width, eBeam_Point1.frame.size.height);
}

- (IBAction)cancelClicked:(id)sender {
    [m_PenController setStationPositionForCalibration:saveStationPosition];
    
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromMarkerCalibrationViewController)])
            [delegate closeCalibViewController_FromMarkerCalibrationViewController];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)retryClicked:(id)sender {
    [self InitData];
}

- (IBAction)eBeam_Left_Clicked:(id)sender {
    if (type == CaliType_SmartMarker_Left)
        return;

    type = CaliType_SmartMarker_Left;

    eBeam_Left.alpha = 1.0f;

    eBeam_Both.alpha = 0.3f;
    eBeam_Bottom.alpha = 0.3f;
    eBeam_Top.alpha = 0.3f;
    eBeam_Right.alpha = 0.3f;

    [m_PenController setStationPositionForCalibration:(enum DEVICE_DIRECTION)type];

    [self retryClicked:nil];
}
- (IBAction)eBeam_Top_Clicked:(id)sender {
    if (type == CaliType_SmartMarker_Top)
        return;

    type = CaliType_SmartMarker_Top;

    eBeam_Top.alpha = 1.0f;

    eBeam_Both.alpha = 0.3f;
    eBeam_Bottom.alpha = 0.3f;
    eBeam_Left.alpha = 0.3f;
    eBeam_Right.alpha = 0.3f;

    [m_PenController setStationPositionForCalibration:(enum DEVICE_DIRECTION)type];

    [self retryClicked:nil];
}
- (IBAction)eBeam_right_Clicked:(id)sender {
    if (type == CaliType_SmartMarker_Right)
        return;

    type = CaliType_SmartMarker_Right;

    eBeam_Right.alpha = 1.0f;

    eBeam_Both.alpha = 0.3f;
    eBeam_Bottom.alpha = 0.3f;
    eBeam_Left.alpha = 0.3f;
    eBeam_Top.alpha = 0.3f;

    [m_PenController setStationPositionForCalibration:(enum DEVICE_DIRECTION)type];

    [self retryClicked:nil];
}
- (IBAction)eBeam_Bottom_Clicked:(id)sender {
    if (type == CaliType_SmartMarker_Bottom)
        return;

    type = CaliType_SmartMarker_Bottom;

    eBeam_Bottom.alpha = 1.0f;

    eBeam_Both.alpha = 0.3f;
    eBeam_Right.alpha = 0.3f;
    eBeam_Left.alpha = 0.3f;
    eBeam_Top.alpha = 0.3f;

    [m_PenController setStationPositionForCalibration:(enum DEVICE_DIRECTION)type];

    [self retryClicked:nil];
}

- (IBAction)eBeam_Both_Clicked:(id)sender {
    if (type == CaliType_SmartMarker_Both)
        return;

    type = CaliType_SmartMarker_Both;

    eBeam_Both.alpha = 1.0f;

    eBeam_Bottom.alpha = 0.3f;
    eBeam_Right.alpha = 0.3f;
    eBeam_Left.alpha = 0.3f;
    eBeam_Top.alpha = 0.3f;

    [m_PenController setStationPositionForCalibration:(enum DEVICE_DIRECTION)type];

    [self retryClicked:nil];
}

- (void) FreeLogMsg:(NSNotification *) note {
    NSString * szS = (NSString *) [note object];
    NSLog(@"%@", szS);
    if ([szS compare:@"FAIL_LISTENING"] == 0 ) {
        
    }
    else if ([szS isEqualToString:@"CONNECTED"]) {
        
    }
    else if ([szS isEqualToString:@"INVALID_PROTOCOL"]) {

    }
    else if ([szS isEqualToString:@"SESSION_CLOSED"]) {
        
    }
    else if ([szS isEqualToString:@"PEN_RMD_ERROR"]) {

    }
    else if ([szS isEqualToString:@"FIRST_DATA_RECV"]) {
    }
}

-(void) DICallBack:(NSNotification *)call {
    NSString * szS = (NSString *) [call object];
    NSLog(@"szS = [%@]", szS);
    if ([szS isEqualToString:@"CHANGE_DEVECE_POSITION"]) {
        [self retryClicked:nil];
    }
    else if ([szS isEqualToString:@"CALIBRATION_SAVE_OK"]) {
        type = CaliType_SmartMarker_Left;
        if (m_PenController.StationPosition == DIRECTION_TOP) {
            type = CaliType_SmartMarker_Top;
        }
        else if (m_PenController.StationPosition == DIRECTION_BOTTOM) {
            type = CaliType_SmartMarker_Bottom;
        }
        else if (m_PenController.StationPosition == DIRECTION_LEFT) {
            type = CaliType_SmartMarker_Left;
        }
        else if (m_PenController.StationPosition == DIRECTION_RIGHT) {
            type = CaliType_SmartMarker_Right;
        }
        else if (m_PenController.StationPosition == DIRECTION_BOTH) {
            type = CaliType_SmartMarker_Both;
        }

        float w = m_CalResultPoint[2].x-m_CalResultPoint[0].x;
        float h = m_CalResultPoint[1].y-m_CalResultPoint[0].y;
        CGRect rect = CGRectMake(0, 0, (int)self.view.bounds.size.width, (h*self.view.bounds.size.width)/w);
        if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromMarkerCalibrationViewController:caliRect:)]) {
            CGRect caliRect = CGRectMake(m_CalResultPoint[0].x, m_CalResultPoint[0].y, w, h);
            [delegate closeCalibViewController_FromMarkerCalibrationViewController:rect caliRect:caliRect];
        }
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else if ([szS isEqualToString:@"CALIBRATION_SAVE_FAIL"]) {
        //fail
    }
}

-(void) PenHandlerWithMsg:(NSNotification*) note
{
    NSDictionary* dic = [note object];
    if ([m_PenController getRetObj] != self)
        return;
    [self PenHandlerWithDictionary:dic];
}
-(void) PenHandlerWithDictionary:(NSDictionary*) dic
{
    CGPoint ptRaw = [[dic objectForKey:@"ptRaw"] CGPointValue];
    CGPoint ptConv = [[dic objectForKey:@"ptConv"] CGPointValue];
    int PenStatus  =[[dic objectForKey:@"PenStatus"] intValue];
    int Temperature = [[dic objectForKey:@"Temperature"] intValue];
    int modelCode = [[dic objectForKey:@"modelCode"] intValue];
    int SMPenFlag = [[dic objectForKey:@"SMPenFlag"] intValue];
    int SMPenState = [[dic objectForKey:@"SMPenState"] intValue];
    int pressure = [[dic objectForKey:@"pressure"] intValue];
    
    [self PenHandlerWithArgs:ptRaw
                      ptConv:ptConv
                   PenStatus:PenStatus
                 Temperature:Temperature
                   ModelCode:modelCode
                   SMPenFlag:SMPenFlag
                  SMPenState:SMPenState
                    Pressure:pressure];
    
}

-(void) PenHandler:(id) sender
{
}

-(void) PenHandlerWithArgs:(CGPoint) Arg_ptRaw ptConv:(CGPoint) Arg_ptConv PenStatus:(int) Arg_PenStatus
               Temperature:(int) Arg_Temperature ModelCode:(int) Arg_modelCode
                SMPenFlag :(int) Arg_SMPenFlag SMPenState:(int) Arg_SMPenState
                  Pressure:(int) Arg_pressure
{
    // already finish
    if (count == calPointCnt) {
        return;
    }

    int rightDataFlag = (Arg_SMPenFlag & 0x01);

    if (type == CaliType_SmartMarker_Right) {
        if (rightDataFlag) {
            return;
        }
    }else{
        if (!rightDataFlag) {
            return;
        }
    }

    switch (Arg_PenStatus) {
        case PEN_UP: {
            m_CalResultPointTemp[count].x = Arg_ptRaw.x;
            m_CalResultPointTemp[count].y = Arg_ptRaw.y;
            count++;

            if (count == calPointCnt) {
                if (type == CaliType_SmartMarker_Right) {
                    CGPoint tCali[2];
                    tCali[0].x = m_CalResultPointTemp[1].x;
                    tCali[0].y = m_CalResultPointTemp[0].y;
                    tCali[1].x = m_CalResultPointTemp[0].x;
                    tCali[1].y = m_CalResultPointTemp[1].y;
                    m_CalResultPointTemp[0] = tCali[0];
                    m_CalResultPointTemp[1] = tCali[1];
                }

                runApplyProcessByPass = NO;

                [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                 target:self
                                               selector:@selector(runApplyProcess)
                                               userInfo:nil
                                                repeats:NO];

                return;
            }

            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 //paper_set_02_on
                                 NSString* countStr = [NSString stringWithFormat:@"paper_set_%02d_on.png", count+1];

                                 [eBeam_Point1 setImage:[UIImage MyImageNamed:countStr]];
                                 eBeam_Point1.frame = eBeam_Point2.frame;
                                 eBeam_Point2.alpha = 0;
                             }
                             completion:^(BOOL finished){
                             }
             ];
        }
    }
}

-(void) runApplyProcess {
    m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
    m_CalResultPoint[0].y = m_CalResultPointTemp[0].y;
    m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
    m_CalResultPoint[1].y = m_CalResultPointTemp[1].y;
    m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
    m_CalResultPoint[2].y = m_CalResultPointTemp[1].y;
    m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
    m_CalResultPoint[3].y = m_CalResultPointTemp[0].y;

    if (m_CalResultPoint[0].x > m_CalResultPoint[2].x ||
        m_CalResultPoint[0].y > m_CalResultPoint[2].y) {
        [self retryClicked:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"pen data error"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    if (m_CalResultPoint[2].x - m_CalResultPoint[0].x < 2400 ||
        m_CalResultPoint[1].y - m_CalResultPoint[0].y < 2400) {
        [self retryClicked:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"small area error"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    if (!runApplyProcessByPass) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"change calbration complete"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
            m_CalResultPoint[0].y = m_CalResultPointTemp[0].y;
            m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
            m_CalResultPoint[1].y = m_CalResultPointTemp[1].y;
            m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
            m_CalResultPoint[2].y = m_CalResultPointTemp[1].y;
            m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
            m_CalResultPoint[3].y = m_CalResultPointTemp[0].y;
            
            float w = m_CalResultPoint[2].x-m_CalResultPoint[0].x;
            float h = m_CalResultPoint[1].y-m_CalResultPoint[0].y;
            CGRect rect = CGRectMake(0, 0, (int)self.view.bounds.size.width, (h*self.view.bounds.size.width)/w);
            [self NextCalibrationProjective4:rect];
            [m_PenController setRetObj:nil];
            [m_PenController setRetObjForEnv:nil];
            if (delegate)
            {
                if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromMarkerCalibrationViewController:caliRect:)]) {
                    CGRect caliRect = CGRectMake(m_CalResultPoint[0].x, m_CalResultPoint[0].y, w, h);
                    [delegate closeCalibViewController_FromMarkerCalibrationViewController:rect caliRect:caliRect];
                }
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [m_PenController setCalibrationDataToDevice:(enum DEVICE_DIRECTION)type CalibPoint:m_CalResultPoint];
    
    [m_PenController setRetObj:nil];
    [m_PenController setRetObjForEnv:nil];

    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(BOOL) NextCalibrationProjective4:(CGRect) rect
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        [m_PenController setCalibrationDataToDevice:(enum DEVICE_DIRECTION)type CalibPoint:m_CalResultPoint];
    }
    else {
        [m_PenController setCalibrationDataToDevice:(enum DEVICE_DIRECTION)type CalibPoint:m_CalResultPoint];
    }
    return YES;
}

-(BOOL) shouldAutoRotate {
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
@end
