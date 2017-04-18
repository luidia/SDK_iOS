//
//  DIController.m
//  PenTestExtension
//
//  Created by jhpark on 2014. 5. 22..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import "DIController.h"
#import "AppDelegate.h"
#import "DataModel.h"
#import "DIResultViewController.h"

#define FILE_DELETE 1000
#define REMOVE_ALL  FILE_DELETE+1
#define DOWN_ALL    FILE_DELETE+2
#define A_DOWN      FILE_DELETE+3
#define INITIALIZE  FILE_DELETE+4
#define A_REMOVE    FILE_DELETE+5
#define THREAD_DELAY 0.5f

@interface DIController ()
{
    BOOL di_down_cancel;
    int di_down_count;
    int di_all_count;
    int di_cur_convert_idx;
    BOOL allDownMode;
    int totalread;
    double stime;
    double etime;
    
    NSIndexPath* selectedIndexPath;
    
    NSMutableArray* pageData;
    Page* currentPage;
    int saveSMFlag;
    BOOL checkDualSide;
}
@property (readwrite) BOOL di_down_cancel;
@property (readwrite) int di_down_count;
@property (readwrite) int di_all_count;
@property (readwrite) int di_cur_convert_idx;
@property (readwrite) BOOL allDownMode;
@property (readwrite) int totalread;
@property (readwrite) double stime;
@property (readwrite) double etime;
@property (readwrite) int saveSMFlag;;
@property (readwrite) BOOL checkDualSide;
@property (retain) NSIndexPath* selectedIndexPath;
@property (retain) NSMutableArray* pageData;
@property (assign) Page* currentPage;
@end


@implementation DIController
@synthesize folderItems, fileItems;
@synthesize indicator;
@synthesize infoDic;
@synthesize convertDataThread, convertDic;
@synthesize di_down_cancel, di_down_count, di_all_count, allDownMode, totalread, stime, etime;
@synthesize di_cur_convert_idx;
@synthesize progressController;
@synthesize selectedIndexPath;
@synthesize delegate;
@synthesize pageData;
@synthesize currentPage;
@synthesize saveSMFlag;
@synthesize checkDualSide;

-(void) dealloc {
    [self.pageData removeAllObjects];
    self.pageData = nil;
    
    [self.folderItems removeAllObjects];
    self.folderItems = nil;
    
    [self.fileItems removeAllObjects];
    self.fileItems = nil;
    
    [self.infoDic removeAllObjects];
    self.infoDic = nil;

    [self.convertDic removeAllObjects];
    self.convertDic = nil;

    self.progressController = nil;
    
    self.selectedIndexPath = nil;
    
    [self stopConvertDataThread];
    
    [listTableView release];
    [infoTableView release];

    [debugTextView release];
    [super dealloc];
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.folderItems = [[[NSMutableArray alloc] init] autorelease];
        self.fileItems = [[[NSMutableArray alloc] init] autorelease];
        self.infoDic = [[[NSMutableDictionary alloc] init] autorelease];
        self.convertDic = [[[NSMutableDictionary alloc] init] autorelease];
        self.pageData = [[[NSMutableArray alloc] init] autorelease];
        self.convertDataThread = nil;
        self.progressController = nil;
        self.selectedIndexPath = nil;
        delegate = nil;
        [self initVar];
    }
    return self;
}
-(void) viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    [self initVar];
    
    self.indicator = [[[UIActivityIndicatorView alloc] init] autorelease];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
    
    listTableView.delegate = self;
    listTableView.dataSource = self;
    
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    
    NSNumber* key = [NSNumber numberWithInt:0];
    NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
    [items addObject:@"Refresh"];
    [items addObject:@"Down All"];
    [items addObject:@"Remove All"];
    [items addObject:@"Free Space"];
    [items addObject:@"Show Data Time"];
    [items addObject:@"Initialize"];
    [items addObject:@"Clear Log"];
    [self.infoDic setObject:items forKey:key];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DICallback:) name:@"PNF_MSG" object:nil];
    
    [self refresh];
}
-(void) viewDidUnload {
    [debugTextView release];
    debugTextView = nil;
    [super viewDidUnload];
}
-(IBAction) backBtnClicked:(id)sender {
    if (delegate) {
        if ([self.delegate respondsToSelector:@selector(closeDIController)])
            [self.delegate closeDIController];
    }
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}
-(void) initVar {
    di_cur_convert_idx = 0;
    di_down_cancel = NO;
    di_down_count = 0;
    di_all_count = 0;
    allDownMode = NO;
    totalread = 0;
    stime = 0;
    etime = 0;
}
-(void) showIndicator {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.indicator startAnimating];
}
-(void) hideIndicator {
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    [self.indicator stopAnimating];
}
-(void) refresh {
    [self showIndicator];
    [self.folderItems removeAllObjects];
    [self.fileItems removeAllObjects];
    [penController setDIState:DI_ShowList];
}
-(void) updateFileList {
    self.folderItems = [penController getDIFolderName];
    for (int i=0; i<self.folderItems.count; i++) {
        [penController setChoiceFolder:i setState:0];
        [self.fileItems addObject:[penController getDIFileName:i]];
    }
    di_all_count = [penController getDIAllFileCount];
    [listTableView reloadData];
    [self hideIndicator];
}
-(void) DIAllFileDown {
    int count = [penController getDIAllFileCount];
    if(!self.di_down_cancel) {
        int ncnt = count - self.di_down_count;
        if(ncnt > 0) {
            int nfolder =0;
            int nfile = 0;
            int t_folder = [penController getFolderCount];
            int t_file = 0;
            for(int i=0;i<t_folder;i++) {
                t_file += [penController getFileCount:i];
                if(self.di_down_count < t_file) {
                    nfolder = i;
                    if(i > 0) {
                        for(int j=0;j<nfolder;j++) {
                            nfile += [penController getFileCount:j];
                        }
                    }
                    [penController setChoiceFolder:nfolder setState:0];
                    [penController setChoiceFile:(di_down_count-nfile) fileDel:false];
                    break;
                }
            }
        }
        else
        {
            [self.progressController.view removeFromSuperview];
            self.progressController = nil;
            
            NSLog(@"\n\nall down files : %d, %d\n\n", di_down_count, count);
            double endtime = CACurrentMediaTime() - stime;
            float speed = ((float)totalread/endtime)/1000.;
            
            NSString* tile = @"[ALL File Download] OK!!";
            NSString* msg = [NSString stringWithFormat:@"count : %d\ndownloading time : %f\ntotal size : %d\nspeed : %.02f kbyte/sec",
                             di_down_count, endtime, totalread, speed];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:tile
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            self.allDownMode = NO;
            [self hideIndicator];
            return;
        }
    }
    else
    {
        NSString* tile = @"[ALL File Download] CANCEL!!";
        NSString* msg = [NSString stringWithFormat:@"count : %d", di_down_count];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:tile
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        self.allDownMode = NO;
        [self hideIndicator];
    }
}
-(void) downloadCancel {
    [self showIndicator];
    self.di_down_cancel = YES;
    [self.progressController.view removeFromSuperview];
    self.progressController = nil;
}

#pragma mark PenController Notification
-(void) SetPenController:(PNFPenController *) pController {
    penController = pController;
}
-(void) DICallback:(NSNotification *) note {
    NSString * szS = (NSString *) [note object];
    NSLog(@"DI CALLBACK - %@", szS);
    if([szS isEqualToString:@"DI_ShowList"]) {
        NSLog(@"ALL FILE CNT : %d", [penController getDIAllFileCount]);
        int len = [penController getFolderCount];
        szS = [szS stringByAppendingString:@"\n=========================="];
        for(int i=0;i<len;i++) {
            NSString* slog = [NSString stringWithFormat:@"\nDI - folder(%d), file(%d)", i+1, [penController getFileCount:i]];
            szS = [szS stringByAppendingString:slog];
        }
        [self updateFileList];
    }
    else if([szS isEqualToString:@"DI_FileOpen"]) {
        if (self.allDownMode) {
            totalread += [penController getDIFileSize];
           
            NSString* stmp = [[penController getDISavefileName] objectAtIndex:0];
            NSLog(@"SAVEFILENAME : %@, length:%d", stmp, (int)stmp.length);
            int cnt = (int)penController.di_file_data_mg.count;
            NSLog(@"penController.di_file_data_mg.count = %d", (int)penController.di_file_data_mg.count);
            if (cnt > 0) {
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
                [dic setObject:penController.di_file_data_mg forKey:@"data"];
                [dic setObject:penController.di_file_data_mg_paper forKey:@"size"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            else {
                // invalid file
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"valid"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            
            if (di_down_count == 0)
                [self startConvertDataThread];
            
            di_down_count++;
            
            [self.progressController setProgressValue:(float)di_down_count/(float)di_all_count];
            
            [self DIAllFileDown];
        }
        else {
            totalread += [penController getDIFileSize];
            NSString* stmp = [[penController getDISavefileName] objectAtIndex:0];
            NSLog(@"SAVEFILENAME : %@, length:%d", stmp, (int)stmp.length);
            int cnt = (int)penController.di_file_data_mg.count;
            NSLog(@"penController.di_file_data_mg.count = %d", (int)penController.di_file_data_mg.count);
            [self.pageData removeAllObjects];
            
            if (cnt > 0) {
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
                [dic setObject:penController.di_file_data_mg forKey:@"data"];
                [dic setObject:penController.di_file_data_mg_paper forKey:@"size"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            else {
                // invalid file
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"valid"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            
            [self startConvertDataThread];
            
            [self hideIndicator];

            double endtime = CACurrentMediaTime() - stime;
            float speed = ((float)totalread/endtime)/1000.;
            NSString* title = @"[File Download] complete!!";
            NSString* msg = [NSString stringWithFormat:@"%@\nFigure count : %d\ndownloading time : %f\ntotal size : %d\nspeed : %.02f kbyte/sec",
                             cnt==0?@"Invalid":@"Valid", [penController di_figure_count], endtime, totalread, speed];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else if([szS isEqualToString:@"FILE_DELETE_SUCCESS"] || [szS isEqualToString:@"FILE_DELETE_FAIL"]) {
        [self hideIndicator];
        
        NSString* title = @"[Remove File] complete!!";
        if ([szS isEqualToString:@"FILE_DELETE_FAIL"])
            title = @"[Remove File] failed!!";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        alert.tag = FILE_DELETE;
        [alert show];
        [alert release];
    }
    else if([szS isEqualToString:@"DI_ShowFreeSpace"]) {
        [self hideIndicator];
        
        NSString* title = @"[Disk free space] complete!!";
        NSString* msg = [NSString stringWithFormat:@"[ %d ] KBytes", penController.di_freespace];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if ([szS isEqualToString:@"DI_ShowDate"]) {
        [self hideIndicator];
        
        NSString* title = @"[Show Date&Time] complete!!";
        NSString* msg = @"";
        uint8_t *res = (uint8_t *)[[penController getDIShowData] bytes];
        char temp[3];
        for(int i=0;i<6;i++)
        {
            temp[0] = temp[1] = temp[2] = 0;
            (void)sprintf(temp, "%02x", res[i]);
            int dec = (int)strtol(temp, NULL, 16);
            
            msg = [msg stringByAppendingString:[NSString stringWithFormat:@"%02d", dec]];
            if(i < 5) msg = [msg stringByAppendingString:@"-"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if([szS isEqualToString:@"OK_ASK_REMOVEALL"] || [szS isEqualToString:@"FAIL_ASK_REMOVEALL"])
    {
        [self hideIndicator];
        
        NSString* title = @"[Remove All(folder&file)] complete!!";
        if ([szS isEqualToString:@"FAIL_ASK_REMOVEALL"])
            title = @"[Remove All(folder&file)] failed!!";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        alert.tag = FILE_DELETE;
        [alert show];
        [alert release];
    }
    else if([szS isEqualToString:@"OK_ASK_INIT_DISK"] || [szS isEqualToString:@"FAIL_ASK_INIT_DISK"])
    {
        [self hideIndicator];
        
        NSString* title = @"Init Disk Done!!";
        if ([szS isEqualToString:@"FAIL_ASK_INIT_DISK"])
            title = @"Init Disk Fail!!";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        alert.tag = FILE_DELETE;
        [alert show];
        [alert release];
    }
    else if([szS isEqualToString:@"FAIL_ACK"])
    {
    }
    else if([szS isEqualToString:@"DI_SEND_ERR"]) {
        [self hideIndicator];
    }
    else if([szS isEqualToString:@"DI_SEND_ERR_RE"])
    {
    }
    else if([szS isEqualToString:@"DI_APP_RESTART"])
    {
    }
    else if([szS isEqualToString:@"DI_CONNECT_CLOSED"])
    {
    }
    else if([szS isEqualToString:@"FOLDER_DELETE_SUCCESS"])
    {
    }
    else
    {
        return;
    }
}

#pragma mark UIAlertView
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == FILE_DELETE) {
        [self refresh];
    }
    else if (alertView.tag == REMOVE_ALL) {
        if (buttonIndex == 0)
            return;
        
        [self showIndicator];
        [penController setDIState:DI_RemoveAll];
    }
    else if (alertView.tag == A_DOWN) {
        if (buttonIndex == 0)
            return;
        
        [self initVar];
        [self showIndicator];
        self.allDownMode = NO;
        self.di_all_count = 1;
        self.di_cur_convert_idx = 0;
        [self.convertDic removeAllObjects];
        stime = CACurrentMediaTime();
        [penController setChoiceFolder:(int)[self.selectedIndexPath section] setState:0];
        [penController setChoiceFile:(int)[self.selectedIndexPath row] fileDel:NO];
    }
    else if (alertView.tag == DOWN_ALL) {
        if (buttonIndex == 0)
            return;
        
        [self initVar];
        self.allDownMode = YES;
        self.di_all_count = [penController getDIAllFileCount];
        if (di_all_count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"import data is empty!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        self.di_cur_convert_idx = 0;
        [self.convertDic removeAllObjects];
        [self.pageData removeAllObjects];
        
        stime = CACurrentMediaTime();
        
        [self DIAllFileDown];
        
        if (self.progressController == nil) {
            self.progressController = [[[ProgressViewController alloc] initWithNibName:@"ProgressViewController"
                                                                                                        bundle:nil] autorelease];
        }
        self.progressController.delegate = self;
        [self.progressController setTitle:@"Downloading"];
        [self.progressController setProgressValue:0];
        self.progressController.view.center = self.view.center;
        [self.view addSubview:self.progressController.view];
    }
    else if (alertView.tag == INITIALIZE) {
        if (buttonIndex == 0)
            return;
        [self showIndicator];
        [penController setDIState:DI_InitializeDisk];
    }
    else if (alertView.tag == A_REMOVE) {
        if (buttonIndex == 0)
            return;
        
        [self showIndicator];
        [penController setChoiceFolder:(int)[self.selectedIndexPath section] setState:0];
        [penController setChoiceFile:(int)[self.selectedIndexPath row] fileDel:YES];
    }
}

#pragma mark UITableView
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == listTableView) {
        return [folderItems count];
    }
    else {
        return [self.infoDic count];
    }
    return 0;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == listTableView) {
        return [[self.fileItems objectAtIndex:section] count];
    }
    else {
        return [[self.infoDic objectForKey:[NSNumber numberWithInt:(int)section]] count];
    }
    return 0;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)]autorelease];
    UILabel* hLabel = [[[UILabel alloc]initWithFrame:CGRectMake(15, 20, tableView.frame.size.width, 22)]autorelease];
    hLabel.backgroundColor = [UIColor clearColor];
    hLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    if(tableView == listTableView) {
        hLabel.text = [self.folderItems objectAtIndex:section];
    }
    else {
        hLabel.text =  @"";
    }
    [headerView addSubview:hLabel];
    return headerView;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:p(10, 14)];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:p(10, 14)];
    
    if (tableView == listTableView) {
        [cell.textLabel setText:[[self.fileItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(listTableView.bounds.size.width-120, 2.0f, 60.0f, 40.0f);
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:p(10, 14)];
        [btn setTitle:@"DOWN" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(downFileRow:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn2.frame = CGRectMake(listTableView.bounds.size.width-60, 2.0f, 60.0f, 40.0f);
        btn2.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:p(10, 14)];
        [btn2 setTitle:@"DEL" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(deleteFileRow:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn2];
    }
    else {
        [cell.textLabel setText:[[self.infoDic objectForKey:[NSNumber numberWithInt:(int)indexPath.section]] objectAtIndex:indexPath.row]];
    }
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == listTableView) {
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) { // Refresh
                [self refresh];
            }
            else if (indexPath.row == 1) { // Down All
                NSString* title = @"Down All?";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes", nil];
                alert.tag = DOWN_ALL;
                [alert show];
                [alert release];
            }
            else if (indexPath.row == 2) { // Remove All
                NSString* title = @"Remove All?";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes", nil];
                alert.tag = REMOVE_ALL;
                [alert show];
                [alert release];
            }
            else if (indexPath.row == 3) { // Free Space
                [self showIndicator];
                [penController setDIState:DI_ShowFreeSpace];
            }
            else if (indexPath.row == 4) { // Show Date/Time
                [self showIndicator];
                [penController setDIState:DI_ShowDate];
            }
            else if (indexPath.row == 5) { // Initialize
                NSString* title = @"Initialize?";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes", nil];
                alert.tag = INITIALIZE;
                [alert show];
                [alert release];
            }
            else if (indexPath.row == 6) { // Clear Log
                [debugTextView setText:@""];
            }
        }
    }
}
-(void) downFileRow:(id)sender {
    self.allDownMode = NO;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:listTableView];
    NSIndexPath *indexPath = [listTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil) {
        self.selectedIndexPath = indexPath;
        NSString* title = @"A Down?";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = A_DOWN;
        [alert show];
        [alert release];
    }
}
-(void) deleteFileRow:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:listTableView];
    NSIndexPath *indexPath = [listTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil) {
        self.selectedIndexPath = indexPath;
        NSString* title = @"A Remove?";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = A_REMOVE;
        [alert show];
        [alert release];
    }
}

#pragma mark Convert Data
-(void) startConvertDataThread {
    NSLog(@"startConvertDataThread");
    [self stopConvertDataThread];
    self.convertDataThread = [[[NSThread alloc] initWithTarget:self selector:@selector(runConverData:) object:self] autorelease];
    [self.convertDataThread start];
}
-(void) stopConvertDataThread {
    NSLog(@"stopConvertDataThread..........1");
    if (self.convertDataThread) {
        NSLog(@"stopConvertDataThread..........2");
        [self.convertDataThread cancel];
        [NSThread sleepForTimeInterval:THREAD_DELAY];
        self.convertDataThread = nil;
    }
}
-(void) runConverData:(id)object {
    @autoreleasepool {
        while ([[NSThread currentThread] isCancelled] == NO) {
            NSMutableDictionary* dic = [self.convertDic objectForKey:[NSNumber numberWithInt:self.di_cur_convert_idx]];
            if (dic == nil) {
                [NSThread sleepForTimeInterval:THREAD_DELAY];
                continue;
            }
            NSString* name = [dic objectForKey:@"name"];
            BOOL valid = [[dic objectForKey:@"valid"] boolValue];
            if (!valid) {
                [self addDebugText:[NSString stringWithFormat:@"\nName = %@",name]];
                [self addDebugText:@"Invalid Data!!!"];
                self.di_cur_convert_idx++;
                if (self.di_cur_convert_idx == self.di_all_count) {
                    NSLog(@"ConvertDataThread Stop");
                    break;
                }
                [NSThread sleepForTimeInterval:THREAD_DELAY];
                continue;
            }
            NSMutableArray* dataArr = [dic objectForKey:@"data"];
            NSMutableArray* sizeArr = [dic objectForKey:@"size"];
            [self addDebugText:[NSString stringWithFormat:@"\nName = %@",name]];
            for (int i=0; i<sizeArr.count; i++) {
                CGPoint calResultPoint[4];
                calResultPoint[0] = CGPointZero;
                calResultPoint[1] = CGPointZero;
                calResultPoint[2] = CGPointZero;
                calResultPoint[3] = CGPointZero;
                
                NSDictionary* tDic = [sizeArr objectAtIndex:i];
                enum CalibrationSize di_calib = (enum CalibrationSize)[[tDic objectForKey:@"cali"] intValue];
                int position = [[tDic objectForKey:@"position"] intValue];
                [self addDebugText:[NSString stringWithFormat:@"Position: [%d]", position]];
                if (di_calib == Letter) { [self addDebugText:@"Calibration = Letter"]; LETTER() }
                else if (di_calib == A4) { [self addDebugText:@"Calibration = A4"]; A4() }
                else if (di_calib == A5) { [self addDebugText:@"Calibration = A5"]; A5() }
                else if (di_calib == B5) { [self addDebugText:@"Calibration = B5"]; B5() }
                else if (di_calib == B6) { [self addDebugText:@"Calibration = B6"]; B6() }
                else if (di_calib == FT6X4) { [self addDebugText:@"Calibration = FT_6X4"]; FT_6X4() }
                else if (di_calib == FT6X5) { [self addDebugText:@"Calibration = FT_6X5"]; FT_6X5() }
                else if (di_calib == FT8X4) { [self addDebugText:@"Calibration = FT_8X4"]; FT_8X4() }
                else if (di_calib == FT8X5) { [self addDebugText:@"Calibration = FT_8X5"]; FT_8X5() }
                else if (di_calib == FT3X5) { [self addDebugText:@"Calibration = FT_3X5"]; FT_3X5() }
                else if (di_calib == FT3X6) { [self addDebugText:@"Calibration = FT_3X6"]; FT_3X6() }
                else if (di_calib == FT4X6) { [self addDebugText:@"Calibration = FT_4X6"]; FT_4X6() }
                else if (di_calib == FT3X5_BOTTOM) { [self addDebugText:@"Calibration = FT_3X5_BOTTOM"]; FT_3X5_BOTTOM() }
                else if (di_calib == FT3X6_BOTTOM) { [self addDebugText:@"Calibration = FT_3X6_BOTTOM"]; FT_3X6_BOTTOM() }
                else if (di_calib == FT4X6_BOTTOM) { [self addDebugText:@"Calibration = FT_4X6_BOTTOM"]; FT_4X6_BOTTOM() }
                
                BOOL landscape = NO;
                switch (di_calib) {
                    case FT6X4:
                    case FT6X5:
                    case FT8X4:
                    case FT8X5:
                        landscape = YES;
                        break;
                    default:
                        landscape = NO;
                        break;
                }
                [penController setProjectiveLevel:4];
                
                float ww = calResultPoint[2].x-calResultPoint[0].x;
                float hh = calResultPoint[1].y-calResultPoint[0].y;
                CGRect calibrationRect = CGRectMake(0, 0, (int)self.view.bounds.size.width, (hh*self.view.bounds.size.width)/ww);
                
                CGPoint whiteSpaceOffset = CGPointZero;
                CGSize defaultSize = CGSizeZero;
                float calcW = 0.;
                float calcH = 0.;
                defaultSize = [self GetDefaultSizeByPaper:di_calib];
                float w = defaultSize.width;
                float h = defaultSize.height;
                calcW = self.view.frame.size.width;
                calcH = (int)((h*self.view.frame.size.width)/w);
                if (calcH > self.view.frame.size.height) {
                    calcH = self.view.frame.size.height;
                    calcW = (int)((w*self.view.frame.size.height)/h);
                }
                float ratio = calibrationRect.size.height/calibrationRect.size.width;
                whiteSpaceOffset = CGPointMake(0, calcH-(int)(calcW*ratio));
                calcH = calcH-whiteSpaceOffset.y;
                
                if (landscape) {
                    w = defaultSize.width;
                    h = defaultSize.height;
                    calcW = (int)((w*self.view.bounds.size.height)/h);
                    calcH = self.view.bounds.size.height;
                    
                    if (calcW > self.view.frame.size.width) {
                        calcW = self.view.frame.size.width;
                        calcH = (int)((h*self.view.frame.size.width)/w);
                    }
                    float ratio = calibrationRect.size.width/calibrationRect.size.height;
                    whiteSpaceOffset = CGPointMake(calcW-(int)(calcH*ratio), 0);
                    calcW = calcW-whiteSpaceOffset.x;
                }
                CGSize drawSize = CGSizeZero;
                if (landscape) {
                    drawSize = CGSizeMake(calcW+whiteSpaceOffset.x, calcH);
                    [penController setCalibrationData:scaleRect(CGRectMake(0, 0, drawSize.width-whiteSpaceOffset.x, drawSize.height))
                                          GuideMargin:0
                                           CalibPoint:calResultPoint];
                }
                else {
                    drawSize = CGSizeMake(calcW, calcH+whiteSpaceOffset.y);
                    [penController setCalibrationData:scaleRect(CGRectMake(0, 0, drawSize.width, drawSize.height-whiteSpaceOffset.y))
                                          GuideMargin:0
                                           CalibPoint:calResultPoint];
                }

                {
                    Page* page = [[[Page alloc] init] autorelease];
                    page.calibrationSize = di_calib;
                    page.drawSize = drawSize;
                    float w = calResultPoint[2].x-calResultPoint[0].x;
                    float h = calResultPoint[1].y-calResultPoint[0].y;
                    page.calibrationRect = CGRectMake(calResultPoint[0].x, calResultPoint[0].y, w, h);
                    
                    self.currentPage = page;
                    self.saveSMFlag = -1;
                    self.checkDualSide = NO;
                    [self.pageData addObject:page];
                }
                
                NSData* data = [dataArr objectAtIndex:i];
                [penController setRetObj:self];
                [penController convertData:data c:FALSE];
            }
            self.di_cur_convert_idx++;
            if (self.di_cur_convert_idx == self.di_all_count) {
                NSLog(@"ConvertDataThread Stop");
                [self performSelectorOnMainThread:@selector(showPage) withObject:nil waitUntilDone:NO];
                break;
            }
            [NSThread sleepForTimeInterval:THREAD_DELAY];
        }
    }
}
-(void) showPage {
    DIResultViewController* diView = [[[DIResultViewController alloc] initWithNibName:@"DIResultViewController" bundle:nil] autorelease];
    diView.pages = self.pageData;
    [diView SetPenController:penController];
    [self presentViewController:diView animated:YES completion:^{
        
    }];
}
-(CGSize) GetDefaultSizeByPaper:(int) nPaper {
    CGSize defaultSize = CGSizeZero;
    switch (nPaper) {
        case  Letter:
        {
            defaultSize = CGSizeMake(216, 279);
        }
            break;
        case A4:
        {
            defaultSize = CGSizeMake(210, 297);
        }
            break;
        case  A5:
        {
            defaultSize = CGSizeMake(148, 210);
        }
            break;
        case B5:
        {
            defaultSize = CGSizeMake(176, 250);
        }
            break;
            
        case B6:
        {
            defaultSize = CGSizeMake(125, 175);
        }
            break;
            
        case FT6X4:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1828, 1219);
        }
            break;
            
        case FT6X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1828, 1524);
        }
            break;
        case FT8X4:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(2438, 1219);
        }
            break;
        case FT8X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(2438, 1524);
        }
            break;
        case FT3X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1524);
        }
            break;
        case FT3X6:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1828);
        }
            break;
        case FT4X6:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1219, 1828);
        }
            break;
        case FT3X5_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1524);
        }
            break;
        case FT3X6_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1828);
        }
            break;
        case FT4X6_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1219, 1828);
        }
            break;
        default:
            NSLog(@"%d is not define size",nPaper);
            break;
    }
    return defaultSize;
    
}
-(void) PenHandlerDI:(id)sender {
    [self DoPenProcessDI:penController.PenStatus SMPenState:penController.SMPenState];
}
-(void) DoPenProcessDI:(int) PenStatus SMPenState:(int) smPenState {
    if (isnan(penController.ptRaw.x) ||
        isnan(penController.ptRaw.y) ||
        isnan(penController.ptConv.x) ||
        isnan(penController.ptConv.y))
        return;
    
    if (self.currentPage) {
        Stroke* stroke = [[[Stroke alloc] init] autorelease];
        stroke.strokeType = PenStatus;
        stroke.point = penController.ptConv;
        if (penController.modelCode == EquilSmartMarker) {
            int smFlag = (penController.SMPenFlag & 0x01);
            if (self.saveSMFlag == -1) {
                self.saveSMFlag = smFlag;
            }
            else {
                if (self.saveSMFlag != smFlag) {
                    self.saveSMFlag = smFlag;
                    if (self.checkDualSide) {
                        if (smFlag) { // right
                            self.currentPage = [self.pageData objectAtIndex:self.pageData.count-1];
                        }
                        else { // left
                            self.currentPage = [self.pageData objectAtIndex:self.pageData.count-2];
                        }
                    }
                    else {
                        self.checkDualSide = YES;
                        Page* page = [[[Page alloc] init] autorelease];
                        page.calibrationSize = self.currentPage.calibrationSize;
                        page.drawSize = self.currentPage.drawSize;
                        page.calibrationRect = self.currentPage.calibrationRect;
                        
                        if (smFlag) { // right
                            [self.pageData addObject:page];
                        }
                        else { // left
                            [self.pageData insertObject:page atIndex:self.pageData.count-1];
                        }
                        self.currentPage = page;
                    }
                }
            }
            stroke.colorForSM = penController.SMPenState;
            BOOL eraseIsBig = NO;
            switch (penController.SMPenState) {
                case 0x59: { eraseIsBig = NO; break; }
                case 0x50: { eraseIsBig = YES; break; }
                case 0x5C: { eraseIsBig = YES; break; }
                default:
                    break;
            }
            stroke.eraseSize = [penController calcSmartMarkerEraseThick:eraseIsBig];
        }
        [self.currentPage.strokeData addObject:stroke];
    }
    
    switch (PenStatus) {
        case PEN_DOWN: {
            if (penController.modelCode == EquilSmartMarker) {
                NSString* color = @"";
                switch (penController.SMPenState) {
                    case 0x51:
                    case 0xf: { color = @"Red"; break; }
                    case 0x52: { color = @"Green"; break; }
                    case 0x53: { color = @"Yellow"; break; }
                    case 0x54: { color = @"Blue"; break; }
                    case 0x56: { color = @"Violet"; break; }
                    case 0x58: { color = @"Black"; break; }
                    case 0x59: { color = @"Erase Cap"; break; }
                    case 0x50: { color = @"Erase Big"; break; }
                    case 0x5C: { color = @"Erase Big"; break; }
                    default:
                        break;
                }
//                [self addDebugText:[NSString stringWithFormat:@"Color = %@", color]];
//                NSLog(@"Color = %@", color);
            }
            else {
                
            }
//            [self addDebugText:[NSString stringWithFormat:@"Down %@", NSStringFromCGPoint(penController.ptConv)]];
//            NSLog(@"%@", [NSString stringWithFormat:@"Down %@", NSStringFromCGPoint(penController.ptConv)]);
            break;
        }
        case PEN_MOVE:
//            [self addDebugText:[NSString stringWithFormat:@"Move %@", NSStringFromCGPoint(penController.ptConv)]];
//            NSLog(@"%@", [NSString stringWithFormat:@"Move %@", NSStringFromCGPoint(penController.ptConv)]);
            break;
        case PEN_UP:
//            [self addDebugText:[NSString stringWithFormat:@"Up %@", NSStringFromCGPoint(penController.ptConv)]];
//            NSLog(@"%@", [NSString stringWithFormat:@"Up %@", NSStringFromCGPoint(penController.ptConv)]);
//            [self addDebugText:@" "];
            break;
        default:
            break;
    }
}

#pragma mark Debug
-(void) addDebugText:(NSString*)text {
    [self performSelectorOnMainThread:@selector(addDebugTextOnMainThread:) withObject:text waitUntilDone:YES];
}
-(void) addDebugTextOnMainThread:(NSString*)text {
    NSString* t = [NSString stringWithFormat:@"%@\n%@", debugTextView.text, text];
    [debugTextView setText:t];
    [debugTextView scrollRangeToVisible:NSMakeRange([debugTextView.text length], 0)];
}
@end
