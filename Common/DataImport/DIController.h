//
//  DIController.h
//  PenTestExtension
//
//  Created by jhpark on 2014. 5. 22..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressViewController.h"

@protocol DIControllerDelegate
-(void) closeDIController;
@end


@class PNFPenController;

@interface DIController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, ProgressViewControllerDelegate>
{
    id<DIControllerDelegate> delegate;
    
    PNFPenController *penController;
    UIActivityIndicatorView* indicator;
    
    IBOutlet UITableView *listTableView;
    IBOutlet UITableView *infoTableView;
    
    NSMutableArray*	folderItems;
    NSMutableArray*	fileItems;
    
    NSMutableDictionary* infoDic;
    
    IBOutlet UITextView *debugTextView;
    
    NSThread* convertDataThread;
    NSMutableDictionary* convertDic;
    
    ProgressViewController* progressController;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic ,retain) NSMutableArray*	folderItems;
@property (nonatomic ,retain) NSMutableArray*	fileItems;
@property (retain) UIActivityIndicatorView* indicator;
@property (retain) NSMutableDictionary* infoDic;
@property (retain) NSThread* convertDataThread;
@property (retain) NSMutableDictionary* convertDic;
@property (retain) ProgressViewController* progressController;

-(void) SetPenController:(PNFPenController *) pController;
-(void) updateFileList;
@end
