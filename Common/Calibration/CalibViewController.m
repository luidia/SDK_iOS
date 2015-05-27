#import "CalibViewController.h"
#import "PNFPenLib.h"
#import "Toast+UIView.h"

#define UIALERTVIEW_CALI_SET    1000

@implementation CalibViewController
@synthesize alwayasShowCalibration, delegate, ignoreAlwayasShowCalibration, alwayasPenConnectShowCalibration;

- (void)viewDidUnload {
    [devicePositionBg release];
    devicePositionBg = nil;
    [countBg release];
    countBg = nil;
    [pointBg release];
    pointBg = nil;
    [devicePositionLabel release];
    devicePositionLabel = nil;
    [deviceChangeBg release];
    deviceChangeBg = nil;
    [cancelBtn release];
    cancelBtn = nil;
    [retryBtn release];
    retryBtn = nil;
    [leftDeviceBtn release];
    leftDeviceBtn = nil;
    [rightDeviceBtn release];
    rightDeviceBtn = nil;
    [lollolDeviceBtnBg release];
    lollolDeviceBtnBg = nil;
    [btLeftDeviceBtn release];
    btLeftDeviceBtn = nil;
    [btTopDeviceBtn release];
    btTopDeviceBtn = nil;
    [btRightDeviceBtn release];
    btRightDeviceBtn = nil;
	[super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseCaliViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    
    if (textView)
        [textView removeFromSuperview];
    [devicePositionBg release];
    [countBg release];
    [pointBg release];
    [devicePositionLabel release];
    [deviceChangeBg release];
    [cancelBtn release];
    [retryBtn release];
    [leftDeviceBtn release];
    [rightDeviceBtn release];
    [lollolDeviceBtnBg release];
    [btLeftDeviceBtn release];
    [btTopDeviceBtn release];
    [btRightDeviceBtn release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        delegate = nil;
        self.ignoreAlwayasShowCalibration = NO;
    }
    return self;
}

-(void) LogWrite:(NSString*) logStr
{
//	[txtDebug setText:logStr];
}

-(void) SetPenController:(PNFPenController *) pController
{
	m_PenController = pController;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    if (m_PenController) {
        [m_PenController EndReadQ];
    }
    
    penErrorCnt = 0;
    temperatureCnt = 0;
    
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    [Title1Label setText:@"Select the page size"];
    
    float offsetY = 365;
    if (IS_IPHONE_5) {
        offsetY = self.view.bounds.size.height-115;
    }
    
    textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, p(offsetY, 820), p(320, 768), p(65, 110))] autorelease];
    [textView setTextAlignment:NSTextAlignmentCenter];
    textView.textColor = [UIColor whiteColor];
    textView.backgroundColor = [UIColor clearColor];
    [textView setEditable:NO];
    [textView setFont:[UIFont fontWithName:@"Helvetica-Light" size:p(15, 30)]];
    [self.view addSubview:textView];
    
    [textView setText:@"Tap the points with lollol pen on your paper in numerical order as shown in the picture on the screen."];
    if (m_PenController.modelCode == Equil) {
        [textView setText:@"Tap the points with Equil Smartpen on your paper in the numerical order as the screen shot shows"];
    }
#if 0
    int versionMajor = 0;
    int versionMinor = 0;
//    int versionElse = 0;
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    NSArray* vArray = [systemVersion componentsSeparatedByString:@"."];
    for (int i=0; i<[vArray count]; i++) {
        if (i == 0)
            versionMajor = [[vArray objectAtIndex:i] intValue];
        else if (i == 1)
            versionMinor = [[vArray objectAtIndex:i] intValue];
//        else if (i == 2)
//            versionElse = [[vArray objectAtIndex:i] intValue];
    }
#endif
    [devicePositionLabel setText:@"Change the receiver position"];
    
    if (m_PenController.modelCode <= 1) {
        m_calPointCnt = 3;
        btLeftDeviceBtn.hidden = YES;
        btTopDeviceBtn.hidden = YES;
        btRightDeviceBtn.hidden = YES;
        if (left) {
            [devicePositionBg setImage:[UIImage imageNamed:str(@"cali_left.png", @"iPad/cali_left.png")]];
            [deviceChangeBg setImage:[UIImage imageNamed:@"cali_left_bt.png"]];
            
        }
        else {
            [devicePositionBg setImage:[UIImage imageNamed:str(@"cali_right.png", @"iPad/cali_right.png")]];
            [deviceChangeBg setImage:[UIImage imageNamed:@"cali_right_bt.png"]];
        }
    }
    else {
        m_calPointCnt = 2;
        
        btLeftDeviceBtn.hidden = YES;
        btTopDeviceBtn.hidden = YES;
        btRightDeviceBtn.hidden = YES;
        
        leftDeviceBtn.hidden = YES;
        rightDeviceBtn.hidden = YES;
        lollolDeviceBtnBg.hidden = YES;
        devicePositionLabel.hidden = YES;
        //            [devicePositionLabel setFrame:CGRectMake(devicePositionLabel.frame.origin.x, devicePositionLabel.frame.origin.y-20, devicePositionLabel.frame.size.width, devicePositionLabel.frame.size.height)];
        [cancelBtn setImage:[UIImage imageNamed:@"bt_cali_cancel.png"] forState:UIControlStateNormal];
        [cancelBtn setImage:[UIImage imageNamed:@"bt_cali_cancel_on.png"] forState:UIControlStateHighlighted];
        
        [retryBtn setImage:[UIImage imageNamed:@"bt_cali_retry.png"] forState:UIControlStateNormal];
        [retryBtn setImage:[UIImage imageNamed:@"bt_cali_retry_on.png"] forState:UIControlStateHighlighted];
        
        if (IS_IPAD) {
            [cancelBtn setFrame:CGRectMake(180, cancelBtn.frame.origin.y-20, 174, 66)];
            [retryBtn setFrame:CGRectMake(414, retryBtn.frame.origin.y-20, 174, 66)];
        }
        else {
            [cancelBtn setFrame:CGRectMake(40, cancelBtn.frame.origin.y-10, 98, 38)];
            [retryBtn setFrame:CGRectMake(182, retryBtn.frame.origin.y-10, 98, 38)];
            [devicePositionBg setFrame:CGRectMake(devicePositionBg.frame.origin.x, devicePositionBg.frame.origin.y, devicePositionBg.frame.size.width, devicePositionBg.frame.size.height+40)];
        }
        if (btPosition == 0) {
            [devicePositionBg setImage:[UIImage imageNamed:str(@"bt_cali_top.png", @"iPad/bt_cali_top.png")]];
            btTopDeviceBtn.selected = YES;
            btLeftDeviceBtn.selected = NO;
            btRightDeviceBtn.selected = NO;
        }
        else if (btPosition == 1) {
            [devicePositionBg setImage:[UIImage imageNamed:@"bt_cali_left.png"]];
            btTopDeviceBtn.selected = NO;
            btLeftDeviceBtn.selected = YES;
            btRightDeviceBtn.selected = NO;
        }
        else if (btPosition == 2) {
            [devicePositionBg setImage:[UIImage imageNamed:@"bt_cali_right.png"]];
            btTopDeviceBtn.selected = NO;
            btLeftDeviceBtn.selected = NO;
            btRightDeviceBtn.selected = YES;
        }
    }
    
    [self InitData];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenHandlerWithMsg:) name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeSelf)
                                                 name:@"CloseCaliViewController"
                                               object:nil];
}

-(void) closeSelf {
    [self dismissModalViewControllerAnimated:NO];
}

-(void) InitData
{
    count = 0;
    [pointBg setImage:[UIImage imageNamed:@"cali_point_01.png"]];
    if (m_PenController.modelCode <= 1) {
        [pointBg setFrame:CGRectMake(left?self.view.frame.size.width-pointBg.frame.size.width:0,
                                     0,
                                     pointBg.frame.size.width,
                                     pointBg.frame.size.height)];
    }
    else {
        [pointBg setImage:[UIImage imageNamed:@"bt_cali_point_01.png"]];
        float x = 0;
//        float y = self.view.frame.size.height/2-pointBg.frame.size.height/2;
        float y = pointBg.frame.size.height;
        btTopDeviceBtn.selected = YES;
        btLeftDeviceBtn.selected = NO;
        btRightDeviceBtn.selected = NO;
        if (btPosition == 1) {
            x = self.view.frame.size.width/2-pointBg.frame.size.width/2;
            y = 0;
            btTopDeviceBtn.selected = NO;
            btLeftDeviceBtn.selected = YES;
            btRightDeviceBtn.selected = NO;
        }
        else if (btPosition == 2) {
            x = self.view.frame.size.width/2-pointBg.frame.size.width/2;
            y = 0;
            btTopDeviceBtn.selected = NO;
            btLeftDeviceBtn.selected = NO;
            btRightDeviceBtn.selected = YES;
        }
        [pointBg setFrame:CGRectMake(x, y,
                                     pointBg.frame.size.width,
                                     pointBg.frame.size.height)];
    }
}

-(void) setDevicePosition:(BOOL)_left btPosition:(int)positionBT{
    left = _left;
    leftOrg = _left;
    btPosition = positionBT;
    btPositionOrg = positionBT;
}

- (IBAction)backClick:(id)sender
{
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeCalibViewController:btPosition:)])
            [delegate closeCalibViewController:leftOrg btPosition:btPositionOrg];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)retryClicked:(id)sender {
    [self InitData];
}

- (IBAction)topClickedForBT:(id)sender {
    btPosition = 0;
    [self InitData];
    [devicePositionBg setImage:[UIImage imageNamed:@"bt_cali_top.png"]];
}
- (IBAction)leftClickedForBT:(id)sender {
    btPosition = 1;
    [self InitData];
    [devicePositionBg setImage:[UIImage imageNamed:@"bt_cali_left.png"]];
}
- (IBAction)rightClickedForBT:(id)sender {
    btPosition = 2;
    [self InitData];
    [devicePositionBg setImage:[UIImage imageNamed:@"bt_cali_right.png"]];
}
- (IBAction)leftClicked:(id)sender {
    left = YES;
    [self InitData];
    [devicePositionBg setImage:[UIImage imageNamed:str(@"cali_left.png", @"iPad/cali_left.png")]];
    [deviceChangeBg setImage:[UIImage imageNamed:@"cali_left_bt.png"]];
}

- (IBAction)rightClicked:(id)sender {
    left = NO;
    [self InitData];
    [devicePositionBg setImage:[UIImage imageNamed:str(@"cali_right.png", @"iPad/cali_right.png")]];
    [deviceChangeBg setImage:[UIImage imageNamed:@"cali_right_bt.png"]];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void) FreeLogMsg:(NSNotification *) note
{
    NSLog(@"calib : %@", note);
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
                [self.view makeToast:@"RMD_ERROR" duration:TOAST_DURATION position:@"bottom"];
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
	if (m_PenController == nil) {
        [Title1Label setText:@"PenController is not set"];
        [textView setText:@""];
		return;
	}
    
	if (count == m_calPointCnt) {	// already finish
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
    
    switch (Arg_PenStatus) {
        case PEN_UP: {
            m_CalResultPointTemp[count].x = Arg_ptRaw.x;
            m_CalResultPointTemp[count].y = Arg_ptRaw.y;
            count++;
            
            NSString* countStr = nil;
            countStr = [NSString stringWithFormat:@"cali_check_%02d.png", count];
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
            
            if (count == m_calPointCnt) {
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
            pointStr = [NSString stringWithFormat:@"cali_point_%02d.png", count+1];
            if (Arg_modelCode == 2)
                pointStr = [NSString stringWithFormat:@"bt_cali_point_%02d.png", count+1];
            CGRect rect = CGRectZero;
            switch (count) {
                case 1: {
                    if (Arg_modelCode <= 1) {
                        rect = CGRectMake(left?self.view.frame.size.width-pointBg.frame.size.width:0,
                                          self.view.frame.size.height-pointBg.frame.size.height,
                                          pointBg.frame.size.width,
                                          pointBg.frame.size.height);
                    }
                    else {
                        if (btPosition == 0) {
                            rect = CGRectMake(self.view.frame.size.width-pointBg.frame.size.width,
//                                              self.view.frame.size.height/2-pointBg.frame.size.height/2,
                                              self.view.frame.size.height-pointBg.frame.size.height,
                                              pointBg.frame.size.width,
                                              pointBg.frame.size.height);
                        }
                        else if (btPosition == 1 || btPosition == 2) {
                            rect = CGRectMake(self.view.frame.size.width/2-pointBg.frame.size.width/2,
                                              self.view.frame.size.height-pointBg.frame.size.height,
                                              pointBg.frame.size.width,
                                              pointBg.frame.size.height);
                        }
                    }
                    break;
                }
                case 2: {
                    if (Arg_modelCode <= 1) {
                        rect = CGRectMake(left?0:self.view.frame.size.width-pointBg.frame.size.width,
                                          self.view.frame.size.height-pointBg.frame.size.height,
                                          pointBg.frame.size.width,
                                          pointBg.frame.size.height);
                    }
                    else {
                        
                    }
                    break;
                }
                default: {
                    return;
                    break;
                }
            }
            [pointBg setImage:[UIImage imageNamed:pointStr]];
            [pointBg setNeedsDisplay];
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [pointBg setFrame:rect];
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
                if ([self.delegate respondsToSelector:@selector(closeCalibViewController:btPosition:)])
                    [delegate closeCalibViewController:leftOrg btPosition:btPositionOrg];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        else if (buttonIndex == 1) { // 적용
            if (m_PenController.modelCode <= 1) {
                float distanceW = m_CalResultPointTemp[0].x-m_CalResultPointTemp[1].x;
                float distanceH = m_CalResultPointTemp[1].y-m_CalResultPointTemp[2].y;
                m_CalResultPointTemp[3].x = m_CalResultPointTemp[2].x+distanceW;
                m_CalResultPointTemp[3].y = m_CalResultPointTemp[0].y-distanceH;
                if (left) {
                    for (int i=0; i<4; i++) {
                        m_CalResultPoint[i].x = m_CalResultPointTemp[3-i].x;
                        m_CalResultPoint[i].y = m_CalResultPointTemp[3-i].y;
                    }
                }
                else {
                    for (int i=0; i<4; i++) {
                        m_CalResultPoint[i].x = m_CalResultPointTemp[i].x;
                        m_CalResultPoint[i].y = m_CalResultPointTemp[i].y;
                    }
                }
            }
            else {
                m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
                m_CalResultPoint[0].y = m_CalResultPointTemp[0].y;
                
                m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
                m_CalResultPoint[1].y = m_CalResultPointTemp[1].y;
                
                m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
                m_CalResultPoint[2].y = m_CalResultPointTemp[1].y;
                
                m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
                m_CalResultPoint[3].y = m_CalResultPointTemp[0].y;
#if 0
                float y = 340;
                if (btPosition == 1) {
                    float w = m_CalResultPointTemp[0].x-m_CalResultPointTemp[1].x;
                    float h = w*1.5f+y;
                    if (IS_IPAD)
                        h = w*1.33f+y;
                    m_CalResultPoint[0].x = m_CalResultPointTemp[1].x;
                    m_CalResultPoint[0].y = y;
                    m_CalResultPoint[1].x = m_CalResultPointTemp[1].x;
                    m_CalResultPoint[1].y = h;
                    m_CalResultPoint[2].x = m_CalResultPointTemp[0].x;
                    m_CalResultPoint[2].y = h;
                    m_CalResultPoint[3].x = m_CalResultPointTemp[0].x;
                    m_CalResultPoint[3].y = y;
                }
                else {
                    float w = m_CalResultPointTemp[1].x-m_CalResultPointTemp[0].x;
                    float h = w*1.5f+y;
                    if (IS_IPAD)
                        h = w*1.33f+y;
                    m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
                    m_CalResultPoint[0].y = y;
                    m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
                    m_CalResultPoint[1].y = h;
                    m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
                    m_CalResultPoint[2].y = h;
                    m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
                    m_CalResultPoint[3].y = y;
                }
#endif
            }
//            NSString* msg = [NSString stringWithFormat:@"modeCode [%d]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]\n[%f] [%f]",m_PenController.modelCode,
//                             m_CalResultPoint[0].x, m_CalResultPoint[0].y,
//                             m_CalResultPoint[1].x, m_CalResultPoint[1].y,
//                             m_CalResultPoint[2].x, m_CalResultPoint[2].y,
//                             m_CalResultPoint[3].x, m_CalResultPoint[3].y];
//            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [av show];
//            [av release];
            [self NextCalibrationProjective4];
            [m_PenController setRetObj:nil];
            if (delegate)
            {
                
                if ([self.delegate respondsToSelector:@selector(closeCalibViewController:btPosition:)])
                    [delegate closeCalibViewController:left btPosition:btPositionOrg];
                
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        else if (buttonIndex == 2) { // 다시
            [self retryClicked:nil];
            return;
        }
    }
}

-(BOOL) NextCalibrationProjective4
{
//    CGFloat scale = 1.0f;
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//        scale = [[UIScreen mainScreen] scale];
//    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [m_PenController setCalibrationData:scaleRect(CGRectMake(0, 0, 768, 1024))
                                GuideMargin:0
                                 CalibPoint:m_CalResultPoint];
    }
    else {
        [m_PenController setCalibrationData:scaleRect(CGRectMake(0, 0, 320, 480))
                                GuideMargin:0
                                 CalibPoint:m_CalResultPoint];
    }
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
