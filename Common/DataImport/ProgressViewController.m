//
//  ProgressViewController.m
//  PenTestExtension
//
//  Created by Choi on 5/20/15.
//  Copyright (c) 2015 choi. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) setTitleString:(NSString *)title {
    [titleLabel setText:title];
}
-(void) setProgressValue:(float)value {
    [progress setProgress:value animated:YES];
}
- (void)dealloc {
    [titleLabel release];
    [cancelBtn release];
    [progress release];
    [super dealloc];
}
- (void)viewDidUnload {
    [titleLabel release];
    titleLabel = nil;
    [cancelBtn release];
    cancelBtn = nil;
    [progress release];
    progress = nil;
    [super viewDidUnload];
}
- (IBAction)cancelClicked:(id)sender {
    if (delegate) {
        if ([self.delegate respondsToSelector:@selector(downloadCancel)])
            [self.delegate downloadCancel];
    }
}
@end
