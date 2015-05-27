//
//  Calib9ViewController.m
//  GiniNote_iPad
//
//  Created by choi on 13. 2. 20..
//  Copyright (c) 2013년 PenAndFree. All rights reserved.
//

#import "Calib9ViewController.h"
#import "PNFPenLib.h"
#import "Toast+UIView.h"

#define UIALERTVIEW_CALI_SET    1000

@interface Calib9ViewController ()
{
    IBOutlet UILabel *titleText;
    IBOutlet UIImageView *pointImgView;
    IBOutlet UIImageView *countBg;
    
    int penErrorCnt;
    int temperatureCnt;
}
- (IBAction)cancelClicked:(id)sender;
- (IBAction)retryClicked:(id)sender;

@end

@implementation Calib9ViewController
@synthesize delegate;

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
    if (m_PenController) {
        [m_PenController EndReadQ];
    }
    penErrorCnt = 0;
    temperatureCnt = 0;
    
    [self InitData];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenHandlerWithMsg:) name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeSelf)
                                                 name:@"CloseCaliViewController"
                                               object:nil];
}

-(void) FreeLogMsg:(NSNotification *) note
{
    NSLog(@"calib9 : %@", note);
	NSString * szS = (NSString *) [note object];
    if ([szS compare:@"FAIL_LISTENING"] == 0 ) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@""
                                                     message:@"abnormal connect. please reconnect device"
                                                    delegate:nil
                                           cancelButtonTitle:@"확인"
                                           otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    else if ([szS isEqualToString:@"CONNECTED"]) {
        penErrorCnt = 0;
    }
    else if ([szS isEqualToString:@"INVALID_PROTOCOL"]) {
        return;
    }
    else if ([szS isEqualToString:@"SESSION_CLOSED"]) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else if ([szS isEqualToString:@"PEN_RMD_ERROR"]) {
        if (m_PenController && (m_PenController.PenStatus == PEN_DOWN || m_PenController.PenStatus == PEN_MOVE)) {
            penErrorCnt++;
            if (penErrorCnt > 5) {
                [self.view makeToast:@"RMD_ERROR" duration:TOAST_DURATION position:@"bottom"];
                penErrorCnt = 0;
            }
        }
        return;
    }
    else if ([szS isEqualToString:@"FIRST_DATA_RECV"]) {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseCaliViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    
    [pointImgView release];
    [titleText release];
    [countBg release];
    [super dealloc];
}

- (void)viewDidUnload {
    [pointImgView release];
    pointImgView = nil;
    [titleText release];
    titleText = nil;
    [countBg release];
    countBg = nil;
    [super viewDidUnload];
}

-(void) SetPenController:(PNFPenController *) pController
{
	m_PenController = pController;
}

-(void) closeSelf {
    [self dismissModalViewControllerAnimated:NO];
}

-(void) InitData
{
    count = 0;
    [pointImgView setImage:[UIImage imageNamed:@"iPad/cali_c.png"]];
    [pointImgView setFrame:CGRectMake(10, 10,
                                 pointImgView.frame.size.width,
                                 pointImgView.frame.size.height)];
}

- (IBAction)cancelClicked:(id)sender {
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeCalib9ViewController)])
            [delegate closeCalib9ViewController];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)retryClicked:(id)sender {
    [self InitData];
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
	if (m_PenController == nil) {
        [titleText setText:@"PenController is not set"];
		return;
	}
    
	if (count == CAL_POINT_COUNT_NINE) {	// already finish
		return;
	}
    
    if (Arg_Temperature <= 10) {
        temperatureCnt++;
        if (temperatureCnt >= 1000) {
            temperatureCnt = 0;
            [self.view makeToast:@"Temperature Error"
                        duration:TOAST_DURATION
                        position:@"bottom"];
        }
    }
    else {
        temperatureCnt = 0;
    }
    
    switch (Arg_PenStatus) {
        case PEN_UP: {
            m_CalResultPointTemp[count].x = Arg_ptRaw.x;
            m_CalResultPointTemp[count].y = Arg_ptRaw.y;
            count++;
            
            NSString* countStr = nil;
            countStr = [NSString stringWithFormat:@"iPad/cali_%02d.png", count];
            [countBg setImage:[UIImage imageNamed:countStr]];
            countBg.alpha = 1;
            
            [UIView animateWithDuration:1.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 countBg.alpha = 0;
                             }
                             completion:^(BOOL finished){
                             }
             ];
            
            if (count == CAL_POINT_COUNT_NINE) {
                UIAlertView* av = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"Apply changes to setting?"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Apply", @"Retry", nil];
                av.tag = UIALERTVIEW_CALI_SET;
                [av show];
                [av release];
                return;
            }
            
            NSString* pointStr = nil;
            pointStr = @"iPad/cali_c.png";//[NSString stringWithFormat:@"cali_c%02d.png", count+1];
            CGRect rect = CGRectZero;
            int x[3] = { 10, 354, 698 };
            int y[9] = { 10, 482, 954, 954, 482, 10, 10, 482, 954 };
            rect = CGRectMake(x[count/3], y[count], pointImgView.frame.size.width, pointImgView.frame.size.height);
            [pointImgView setImage:[UIImage imageNamed:pointStr]];
            [pointImgView setNeedsDisplay];
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [pointImgView setFrame:rect];
                             }
                             completion:^(BOOL finished){
                             }
             ];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == UIALERTVIEW_CALI_SET) {
        if (buttonIndex == 0) { // 취소
            if (delegate)
            {
                if ([self.delegate respondsToSelector:@selector(closeCalib9ViewController)])
                    [delegate closeCalib9ViewController];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        else if (buttonIndex == 1) { // 적용
            m_CalResultPoint[0].x = (m_CalResultPointTemp[0].x+m_CalResultPointTemp[1].x+m_CalResultPointTemp[2].x)/3;
            m_CalResultPoint[0].y = (m_CalResultPointTemp[0].y+m_CalResultPointTemp[5].y+m_CalResultPointTemp[6].y)/3;
            m_CalResultPoint[1].x = m_CalResultPoint[0].x;
            m_CalResultPoint[1].y = (m_CalResultPointTemp[1].y+m_CalResultPointTemp[4].y+m_CalResultPointTemp[7].y)/3;
            m_CalResultPoint[2].x = m_CalResultPoint[0].x;
            m_CalResultPoint[2].y = (m_CalResultPointTemp[2].y+m_CalResultPointTemp[3].y+m_CalResultPointTemp[8].y)/3;
            m_CalResultPoint[3].x = (m_CalResultPointTemp[3].x+m_CalResultPointTemp[4].x+m_CalResultPointTemp[5].x)/3;
            m_CalResultPoint[3].y = m_CalResultPoint[2].y;
            m_CalResultPoint[4].x = m_CalResultPoint[3].x;
            m_CalResultPoint[4].y = m_CalResultPoint[1].y;
            m_CalResultPoint[5].x = m_CalResultPoint[3].x;
            m_CalResultPoint[5].y = m_CalResultPoint[0].y;
            m_CalResultPoint[6].x = (m_CalResultPointTemp[6].x+m_CalResultPointTemp[7].x+m_CalResultPointTemp[8].x)/3;
            m_CalResultPoint[6].y = m_CalResultPoint[0].y;
            m_CalResultPoint[7].x = m_CalResultPoint[6].x;
            m_CalResultPoint[7].y = m_CalResultPoint[1].y;
            m_CalResultPoint[8].x = m_CalResultPoint[6].x;
            m_CalResultPoint[8].y = m_CalResultPoint[2].y;

//            for (int i=0; i<CAL_POINT_COUNT_NINE; i++) {
//                m_CalResultPoint[i].x = m_CalResultPointTemp[i].x;
//                m_CalResultPoint[i].y = m_CalResultPointTemp[i].y;
//            }

//            NSString* msg = [NSString stringWithFormat:@"[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]",
//                                                        m_CalResultPointTemp[0].x, m_CalResultPointTemp[0].y,
//                                                        m_CalResultPointTemp[1].x, m_CalResultPointTemp[1].y,
//                                                        m_CalResultPointTemp[2].x, m_CalResultPointTemp[2].y,
//                                                        m_CalResultPointTemp[3].x, m_CalResultPointTemp[3].y,
//                                                        m_CalResultPointTemp[4].x, m_CalResultPointTemp[4].y,
//                                                        m_CalResultPointTemp[5].x, m_CalResultPointTemp[5].y,
//                                                        m_CalResultPointTemp[6].x, m_CalResultPointTemp[6].y,
//                                                        m_CalResultPointTemp[7].x, m_CalResultPointTemp[7].y,
//                                                        m_CalResultPointTemp[8].x, m_CalResultPointTemp[8].y];
//            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [av show];
//            [av release];
            
            [self NextCalibrationProjective9];
            [m_PenController setRetObj:nil];
            if (delegate)
            {
                if ([self.delegate respondsToSelector:@selector(closeCalib9ViewController)])
                    [delegate closeCalib9ViewController];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        else if (buttonIndex == 2) { // 다시
            [self retryClicked:nil];
            return;
        }
    }
}

-(BOOL) NextCalibrationProjective9
{
    CGFloat scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    [m_PenController setProjectiveLevel:9];
    [m_PenController setCalibrationData:scaleRect(CGRectMake(0, 0, 768, 1024))
                            GuideMargin:40*scale
                             CalibPoint:m_CalResultPoint];
	return YES;
	
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL) shouldAutoRotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
@end
