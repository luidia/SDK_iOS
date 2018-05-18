//
//  PenCalibrationViewController.m
//  PenTestExtension
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import "PenCalibrationViewController.h"
#import "UIImage+ImageNamed.h"
#import "PNFPenLibExtension.h"
#import "PNFDefine.h"

@interface PenCalibrationViewController () <UIAlertViewDelegate>
{
    IBOutlet UIButton *canceBtn;
    IBOutlet UIButton *retryBtn;
    
    IBOutlet UIImageView *eBeam_Paper;
    
    IBOutlet UIImageView *eBeam_Point1;
    IBOutlet UIImageView *eBeam_Point1_Done;
    IBOutlet UIImageView *eBeam_Point2;
    
    int calPointCnt;
    int count;
    CGPoint m_CalResultPoint[4];
    CGPoint m_CalResultPointTemp[4];
}
@end

@implementation PenCalibrationViewController
@synthesize delegate;

- (void)dealloc
{
    [m_PenController StartReadQ];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_PEN_READ_DATA" object:nil];
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
    
    if (eBeam_Paper){
        [eBeam_Paper release];
        eBeam_Paper = nil;
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
    
    if(m_PenController){
        m_PenController = nil;
    }
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        delegate = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenHandlerWithMsg:) name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenCallBackFunc:) name:@"PNF_MSG" object:nil];

    [m_PenController setRetObjForEnv:self];
    if (m_PenController) {
        [m_PenController EndReadQ];
    }
    [m_PenController startCalibrationMode];
    
    [self InitData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) SetPenController:(PNFPenLibExtension *) pController {
    m_PenController = pController;
}
- (void) InitData {
    count = 0;
    calPointCnt = 2;
    
    eBeam_Point2.alpha = 1.0f;
    
    NSString* countStr = [NSString stringWithFormat:@"paper_set_%02d_on.png", count+1];
    [eBeam_Point1 setImage:[UIImage MyImageNamed:countStr]];
    
    float PaperImgSize = self.view.frame.size.width<self.view.frame.size.height?self.view.frame.size.width*0.6:self.view.frame.size.height*0.6;
    eBeam_Paper.frame = CGRectMake((self.view.frame.size.width-PaperImgSize)/2,
                                   (self.view.frame.size.height-PaperImgSize*1.3)/2,
                                   PaperImgSize,
                                   PaperImgSize*1.3);
    
    eBeam_Point1.frame = CGRectMake(eBeam_Paper.frame.origin.x+5,
                                    eBeam_Paper.frame.origin.y+5+(eBeam_Paper.frame.size.height)/10,
                                    eBeam_Point1.frame.size.width,
                                    eBeam_Point1.frame.size.height);
    
    eBeam_Point1_Done.frame = CGRectMake(eBeam_Paper.frame.origin.x+5,
                                         eBeam_Paper.frame.origin.y+5+(eBeam_Paper.frame.size.height)/10,
                                         eBeam_Point1_Done.frame.size.width,
                                         eBeam_Point1_Done.frame.size.height);
    
    eBeam_Point2.frame = CGRectMake(eBeam_Paper.frame.origin.x+eBeam_Paper.frame.size.width-eBeam_Point2.frame.size.width-5,
                                    eBeam_Paper.frame.origin.y+eBeam_Paper.frame.size.height-eBeam_Point2.frame.size.height-5,
                                    eBeam_Point2.frame.size.width,
                                    eBeam_Point2.frame.size.height);
}

- (IBAction)cancelClicked:(id)sender {
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closePenCalibrationViewController)])
            [delegate closePenCalibrationViewController];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)retryClicked:(id)sender {
    [self InitData];
}

- (void) FreeLogMsg:(NSNotification *) note {
    NSString * szS = (NSString *) [note object];
    NSLog(@"FreeLogMsg szS==>%@", szS);
    if ([szS compare:@"FAIL_LISTENING"] == 0 ) {
        
    }
    else if ([szS isEqualToString:@"CONNECTED"]) {
        
    }
    else if ([szS isEqualToString:@"INVALID_PROTOCOL"]) {

    }
    else if ([szS isEqualToString:@"SESSION_CLOSED"]) {
        [self cancelClicked:nil];
    }
    else if ([szS isEqualToString:@"PEN_RMD_ERROR"]) {

    }
    else if ([szS isEqualToString:@"FIRST_DATA_RECV"]) {
    }
}

-(void) PenCallBackFunc:(NSNotification *)call {
    NSString * szS = (NSString *) [call object];
    NSLog(@"PenCallBackFunc szS==>[%@]", szS);
    if ([szS isEqualToString:@"CALIBRATION_SAVE_OK"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"change calbration complete"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if ([self.delegate respondsToSelector:@selector(successPenCalibrationViewController)]) {
                [delegate successPenCalibrationViewController];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([szS isEqualToString:@"CALIBRATION_SAVE_FAIL"] || [szS isEqualToString:@"DI_SEND_ERR"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"change calbration fail"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self retryClicked:nil];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) PenHandlerWithMsg:(NSNotification*) note
{
    NSDictionary* dic = [note object];
    if ([m_PenController getRetObjForEnv] != self)
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

-(void) PenHandlerWithArgs:(CGPoint) Arg_ptRaw ptConv:(CGPoint) Arg_ptConv PenStatus:(int) Arg_PenStatus
               Temperature:(int) Arg_Temperature ModelCode:(int) Arg_modelCode
                SMPenFlag :(int) Arg_SMPenFlag SMPenState:(int) Arg_SMPenState
                  Pressure:(int) Arg_pressure
{
    if (count == calPointCnt) {
        return;
    }

    switch (Arg_PenStatus) {
        case PEN_UP: {
            m_CalResultPointTemp[count].x = Arg_ptRaw.x;
            m_CalResultPointTemp[count].y = Arg_ptRaw.y;
            count++;

            if (count == calPointCnt) {
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

    if (m_CalResultPoint[2].x - m_CalResultPoint[0].x < 500 ||
        m_CalResultPoint[1].y - m_CalResultPoint[0].y < 500) {
        [self retryClicked:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"small area error"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
    m_CalResultPoint[0].y = m_CalResultPointTemp[0].y;
    m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
    m_CalResultPoint[1].y = m_CalResultPointTemp[1].y;
    m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
    m_CalResultPoint[2].y = m_CalResultPointTemp[1].y;
    m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
    m_CalResultPoint[3].y = m_CalResultPointTemp[0].y;
    
    [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:m_CalResultPoint];
}

-(BOOL) shouldAutoRotate {
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
@end
