//
//  TimeTestViewController.m
//  PenTest
//
//  Created by choi on 9/29/13.
//  Copyright (c) 2013 choi. All rights reserved.
//

#import "TimeTestViewController.h"

@interface TimeTestViewController ()
{
    IBOutlet UITextField *startTimeField;
    IBOutlet UITextField *endTimeField;
    IBOutlet UITextField *durTimeField;
}
@end

@implementation TimeTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) PenHandlerEnv:(NSArray*)info {
//    NSLog(@"-(void) PenHandlerEnv:(NSArray*)info");
//    [self calcTime];
}
-(void) PenHandler:(id) sender {
//    NSLog(@"-(void) PenHandler:(id) sender");
    [self calcTime];
}
-(void) calcTime {
    if ([startTimeField.text isEqualToString:@""]) {
        endTimeField.text = @"";
        durTimeField.text = @"";
        return;
    }
    NSDateFormatter* today = [[[NSDateFormatter alloc] init] autorelease];
    [today setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [endTimeField setText:[today stringFromDate:[NSDate date]]];

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSDate *date1 = [dateFormatter dateFromString:startTimeField.text];
    NSDate *date2 = [dateFormatter dateFromString:[today stringFromDate:[NSDate date]]];
    
    NSTimeInterval diff = [date2 timeIntervalSinceDate:date1];
    NSInteger ti = (NSInteger)diff;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    [durTimeField setText:[NSString stringWithFormat:@"%02i:%02i:%02i", (int)hours, (int)minutes, (int)seconds]];
}
-(void) SetPenController:(PNFPenController *) pController
{
    penController = pController;
}

- (void)dealloc {
    [startTimeField release];
    [endTimeField release];
    [durTimeField release];
    [super dealloc];
}
- (void)viewDidUnload {
    [startTimeField release];
    startTimeField = nil;
    [endTimeField release];
    endTimeField = nil;
    [durTimeField release];
    durTimeField = nil;
    [super viewDidUnload];
}
- (IBAction)startClicked:(id)sender {
    [startTimeField setText:@""];
    [endTimeField setText:@""];
    [durTimeField setText:@""];
    
    NSDateFormatter* startTime = [[[NSDateFormatter alloc] init] autorelease];
    [startTime setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [startTimeField setText:[startTime stringFromDate:[NSDate date]]];
}
- (IBAction)closeClicked:(id)sender {
    [self dismissModalViewControllerAnimated:NO];
}
@end
