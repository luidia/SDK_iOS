//
//  ProgressViewController.h
//  PenTestExtension
//
//  Created by Choi on 5/20/15.
//  Copyright (c) 2015 choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProgressViewControllerDelegate
-(void) downloadCancel;
@end

@interface ProgressViewController : UIViewController
{
    id<ProgressViewControllerDelegate> delegate;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIProgressView *progress;
}
@property (nonatomic, assign) id delegate;

-(void) setTitleString:(NSString *)title;
-(void) setProgressValue:(float)value;

- (IBAction)cancelClicked:(id)sender;
@end
