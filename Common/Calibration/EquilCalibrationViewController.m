//
//  EquilCalibrationViewController.m
//  Equil Note
//
//  Created by Choi on 2014. 12. 3..
//
//

#import "EquilCalibrationViewController.h"
//#import "PNFPenLibExtension.h"
//#import "BaseCom.h"
//#import "DefineString.h"
#import "Toast+UIView.h"
#import "Common.h"
//#import "UIImage+ImageNamed.h"
#import "PNFPenLib.h"
#import "PNFDefine.h"

#define UIALERTVIEW_EQUIL_CALI_SET    1000

enum CaliType {
    CaliType_SmartPen_Top = 0,
    CaliType_SmartPen_Bottom,
    CaliType_SmartMarker_Top,
    CaliType_SmartMarker_Left,
    CaliType_SmartMarker_Bottom
};

@interface EquilCalibrationViewController () <UIAlertViewDelegate>
{
    IBOutlet UIImageView *bgImageView;
    IBOutlet UIButton *canceBtn;
    IBOutlet UIButton *retryBtn;
    IBOutlet UIImageView *pointer;
    IBOutlet UIImageView *pointer2;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *descLabel;
    
    enum CaliType type;
    int calPointCnt;
    int count;
    CGPoint m_CalResultPoint[4];
    CGPoint m_CalResultPointTemp[4];
    int penErrorCnt;
    int temperatureCnt;
    CGPoint p;
    CGPoint p2;
}
@end

@implementation EquilCalibrationViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        delegate = nil;
        type = CaliType_SmartPen_Top;
    }
    return self;
}
- (void)dealloc {
    NSLog(@"dealloc EquilCalibrationViewController");
    if (m_PenController && m_PenController.modelCode == 4) {
        [m_PenController StartReadQ];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseCaliViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    
    [bgImageView release];
    [canceBtn release];
    [retryBtn release];
    [pointer release];
    [titleLabel release];
    [descLabel release];
    [pointer2 release];
    [super dealloc];
}
- (void)viewDidUnload {
    [bgImageView release];
    bgImageView = nil;
    [canceBtn release];
    canceBtn = nil;
    [retryBtn release];
    retryBtn = nil;
    [pointer release];
    pointer = nil;
    [titleLabel release];
    titleLabel = nil;
    [descLabel release];
    descLabel = nil;
    [pointer2 release];
    pointer2 = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (m_PenController) {
        [m_PenController EndReadQ];
    }
    
    [titleLabel setText:@"Select your Page size"];
    [descLabel setText:@""];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenHandlerWithMsg:) name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
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
    [self InitData];
}
- (void) SetPenController:(PNFPenController *) pController {
    m_PenController = pController;
}
- (void) closeSelf {
    [self dismissViewControllerAnimated:NO completion:^{}];
}
- (void) InitData {
    count = 0;
    calPointCnt = 2;
    if (m_PenController.modelCode == EquilSmartMarker) {
        NSString* desc = [NSString stringWithFormat:@"%@", @"On your writing surface, use the [MODEL] to tap the points in order, as shown in the picture."];
        desc = [desc stringByReplacingOccurrencesOfString:@"[MODEL]" withString:@"Equil Smartmarker"];
        [descLabel setText:desc];

        if (m_PenController.StationPosition == UIDeviceOrientationPortrait) {
            type = CaliType_SmartMarker_Top;
        }
        else if (m_PenController.StationPosition == UIDeviceOrientationPortraitUpsideDown) {
            type = CaliType_SmartMarker_Bottom;
        }
        else {
            type = CaliType_SmartMarker_Left;
        }
    }
    else {
        NSString* desc = [NSString stringWithFormat:@"%@", @"On your writing surface, use the [MODEL] to tap the points in order, as shown in the picture."];
        desc = [desc stringByReplacingOccurrencesOfString:@"[MODEL]" withString:@"Equil Smartpen"];
        [descLabel setText:desc];
        BOOL top = YES;//[[[NSUserDefaults standardUserDefaults] objectForKey:kSmartpenPositionTop] boolValue];
        if (top)
            type = CaliType_SmartPen_Top;
        else
            type = CaliType_SmartPen_Bottom;
    }
    switch (type) {
        case CaliType_SmartMarker_Top:
        case CaliType_SmartMarker_Bottom: {
            if (IS_IPAD) {
                p = CGPointMake(87, 359);
                p2 = CGPointMake(654, 851);
                [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_01.png", @"eq_iPad/cali_sm_01.png")]];
                if (type == CaliType_SmartMarker_Bottom)
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_03.png", @"eq_iPad/cali_sm_03.png")]];
            }
            else {
                if (IS_IPHONE_5) {
                    p = CGPointMake(20, 232);
                    p2 = CGPointMake(272, 450);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_01.png", @"eq_iPad/cali_sm_01.png")]];
                    if (type == CaliType_SmartMarker_Bottom)
                        [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_03.png", @"eq_iPad/cali_sm_03.png")]];
                }
                else {
                    p = CGPointMake(20, 210);
                    p2 = CGPointMake(272, 420);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_01_iphone4.png", @"eq_iPad/cali_sm_01_iphone4.png")]];
                    if (type == CaliType_SmartMarker_Bottom)
                        [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_03_iphone4.png", @"eq_iPad/cali_sm_03_iphone4.png")]];
                }
            }
            break;
        }
        case CaliType_SmartMarker_Left: {
            if (IS_IPAD) {
                p = CGPointMake(85, 356);
                p2 = CGPointMake(654, 677);
                [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_02.png", @"eq_iPad/cali_sm_02.png")]];
            }
            else {
                if (IS_IPHONE_5) {
                    p = CGPointMake(33, 254);
                    p2 = CGPointMake(274, 386);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_02.png", @"eq_iPad/cali_sm_02.png")]];
                }
                else {
                    p = CGPointMake(33, 224);
                    p2 = CGPointMake(272, 420);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_sm_02_iphone4.png", @"eq_iPad/cali_sm_02_iphone4.png")]];
                }
            }
            break;
        }
        case CaliType_SmartPen_Top: {
            if (IS_IPAD) {
                p = CGPointMake(183, 405);
                p2 = CGPointMake(558, 868);
                [bgImageView setImage:[UIImage imageNamed:str(@"cali_s.png", @"eq_iPad/cali_s.png")]];
            }
            else {
                if (IS_IPHONE_5) {
                    p = CGPointMake(47, 230);
                    p2 = CGPointMake(247, 482);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_s.png", @"eq_iPad/cali_s.png")]];
                }
                else {
                    p = CGPointMake(66, 225);
                    p2 = CGPointMake(226, 423);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_s_iphone4.png", @"eq_iPad/cali_s_iphone4.png")]];
                }
            }
            break;
        }
        case CaliType_SmartPen_Bottom: {
            if (IS_IPAD) {
                p = CGPointMake(183, 350);
                p2 = CGPointMake(555, 863);
                [bgImageView setImage:[UIImage imageNamed:str(@"cali_s_bot.png", @"eq_iPad/cali_s_bot.png")]];
            }
            else {
                if (IS_IPHONE_5) {
                    p = CGPointMake(47, 205);
                    p2 = CGPointMake(247, 482);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_s_bot.png", @"eq_iPad/cali_s_bot.png")]];
                }
                else {
                    p = CGPointMake(66, 200);
                    p2 = CGPointMake(226, 424);
                    [bgImageView setImage:[UIImage imageNamed:str(@"cali_s_iphone4_bot.png", @"eq_iPad/cali_s_iphone4_bot.png")]];
                }
            }
            break;
        }
        default:
            break;
    }
    [pointer setFrame:CGRectMake(p.x, p.y, pointer.frame.size.width, pointer.frame.size.height)];
    NSString* countStr = [NSString stringWithFormat:str(@"eq_pointer_%02d.png", @"eq_iPad/eq_pointer_%02d.png"), count+1];
    [pointer setImage:[UIImage imageNamed:countStr]];
    pointer.alpha = 1;
    
    [pointer2 setFrame:CGRectMake(p2.x, p2.y, pointer2.frame.size.width, pointer2.frame.size.height)];
    pointer2.alpha = 1;
}
- (IBAction)cancelClicked:(id)sender {
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromEquilCalibrationViewController)])
            [delegate closeCalibViewController_FromEquilCalibrationViewController];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)retryClicked:(id)sender {
    [self InitData];
}
- (void) FreeLogMsg:(NSNotification *) note {
    NSString * szS = (NSString *) [note object];
    NSLog(@"%@", szS);
    if ([szS compare:@"FAIL_LISTENING"] == 0 ) {
//        message:@"abnormal connect. please reconnect device"
//        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@""
//                                                     message:[BaseCom GetString:TxtVIEWCONTROLLER_PENCONNECT_FAIL_MSG]
//                                                    delegate:nil
//                                           cancelButtonTitle:[BaseCom GetString:TxtCOMMON_OK]
//                                           otherButtonTitles:nil];
//        [av show];
//        [av release];
        return;
    }
    else if ([szS isEqualToString:@"CONNECTED"]) {
        penErrorCnt = 0;
    }
    else if ([szS isEqualToString:@"INVALID_PROTOCOL"]) {
        return;
    }
    else if ([szS isEqualToString:@"SESSION_CLOSED"]) {
        
    }
    else if ([szS isEqualToString:@"PEN_RMD_ERROR"]) {
        if (m_PenController && (m_PenController.PenStatus == PEN_DOWN || m_PenController.PenStatus == PEN_MOVE)) {
            penErrorCnt++;
            if (penErrorCnt > 5) {
                [self.view makeToast:@"RMD_ERROR"
                            duration:TOAST_DURATION
                            position:@"bottom"];
                penErrorCnt = 0;
            }
        }
        return;
    }
    else if ([szS isEqualToString:@"FIRST_DATA_RECV"]) {
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
    if (m_PenController.modelCode == 4) {
        int smFlag = (Arg_SMPenFlag & 0x01);
        if (smFlag == 0)
            return;
    }
    if (count == calPointCnt) {	// already finish
        return;
    }
    
    if (Arg_Temperature <= 10) {
        temperatureCnt++;
        if (temperatureCnt >= 1000) {
            temperatureCnt = 0;
            [self.view makeToast:@"Low temperature may cause problems during writing."
                        duration:TOAST_DURATION
                        position:@"bottom"];
        }
    }
    else {
        temperatureCnt = 0;
    }
    
    switch (m_PenController.PenStatus) {
        case PEN_UP: {
            m_CalResultPointTemp[count].x = Arg_ptRaw.x;
            m_CalResultPointTemp[count].y = Arg_ptRaw.y;
            count++;
            
            if (count == calPointCnt) {
                UIAlertView* av = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"Do you want to save your calibration changes?"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Apply",
                                   @"Retry", nil];
                av.tag = UIALERTVIEW_EQUIL_CALI_SET;
                [av show];
                [av release];
                return;
            }
            
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 NSString* countStr = [NSString stringWithFormat:str(@"eq_pointer_%02d.png", @"eq_iPad/eq_pointer_%02d.png"), count+1];
                                 [pointer setImage:[UIImage imageNamed:countStr]];
                                 [pointer setFrame:CGRectMake(p2.x, p2.y, pointer.frame.size.width, pointer.frame.size.height)];
                                 pointer2.alpha = 0;
                             }
                             completion:^(BOOL finished){
                             }
            ];
        }
    }
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex = %d", (int)buttonIndex);
    if (alertView.tag == UIALERTVIEW_EQUIL_CALI_SET) {
        if (buttonIndex == 0) { // 취소
            if (delegate)
            {
                if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromEquilCalibrationViewController)])
                    [delegate closeCalibViewController_FromEquilCalibrationViewController];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        else if (buttonIndex == 1) { // 적용
            m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
            m_CalResultPoint[0].y = m_CalResultPointTemp[0].y;
            m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
            m_CalResultPoint[1].y = m_CalResultPointTemp[1].y;
            m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
            m_CalResultPoint[2].y = m_CalResultPointTemp[1].y;
            m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
            m_CalResultPoint[3].y = m_CalResultPointTemp[0].y;
            if (type == CaliType_SmartPen_Bottom) {
                m_CalResultPoint[0].x = m_CalResultPointTemp[1].x;
                m_CalResultPoint[0].y = m_CalResultPointTemp[1].y;
                m_CalResultPoint[1].x = m_CalResultPointTemp[1].x;
                m_CalResultPoint[1].y = m_CalResultPointTemp[0].y;
                m_CalResultPoint[2].x = m_CalResultPointTemp[0].x;
                m_CalResultPoint[2].y = m_CalResultPointTemp[0].y;
                m_CalResultPoint[3].x = m_CalResultPointTemp[0].x;
                m_CalResultPoint[3].y = m_CalResultPointTemp[1].y;
            }
            float w = m_CalResultPoint[2].x-m_CalResultPoint[0].x;
            float h = m_CalResultPoint[1].y-m_CalResultPoint[0].y;
            CGRect rect = CGRectMake(0, 0, (int)self.view.bounds.size.width, (h*self.view.bounds.size.width)/w);
            [self NextCalibrationProjective4:rect];
            [m_PenController setRetObj:nil];
            [m_PenController setRetObjForEnv:nil];
            if (delegate)
            {
                if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromEquilCalibrationViewController:caliRect:)]) {
                    CGRect caliRect = CGRectMake(m_CalResultPoint[0].x, m_CalResultPoint[0].y, w, h);
                    [delegate closeCalibViewController_FromEquilCalibrationViewController:rect caliRect:caliRect];
                }
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        else if (buttonIndex == 2) { // 다시
            [self retryClicked:nil];
            return;
        }
    }
}

-(BOOL) NextCalibrationProjective4:(CGRect) rect
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [m_PenController setProjectiveLevel:4];
        [m_PenController setCalibrationData:scaleRect(rect)
                                GuideMargin:0
                                 CalibPoint:m_CalResultPoint];
    }
    else {
        [m_PenController setProjectiveLevel:4];
        [m_PenController setCalibrationData:scaleRect(rect)
                                GuideMargin:0
                                 CalibPoint:m_CalResultPoint];
    }
    return YES;
}
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}
-(BOOL) shouldAutoRotate {
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
//EquilOrientationRegisterPortrait()
@end
