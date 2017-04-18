//
//  DIResultViewController.m
//  PenTest
//
//  Created by Choi on 2017. 4. 13..
//  Copyright © 2017년 choi. All rights reserved.
//

#import "DIResultViewController.h"

@interface DIResultViewController ()
{
    IBOutlet DIDrawView *drawView;
    IBOutlet UILabel *pageLabel;
    IBOutlet UIButton *prevBtn;
    IBOutlet UIButton *nextBtn;
    int curPage;
    IBOutlet UIActivityIndicatorView *indicator;
}
@end

@implementation DIResultViewController
@synthesize pages;

-(void) dealloc {
    [drawView release];
    [pageLabel release];
    [prevBtn release];
    [nextBtn release];
    
    [self.pages removeAllObjects];
    self.pages = nil;
    
    [indicator release];
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    drawView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleWidth|
    UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleBottomMargin;
    
    curPage = 0;
    [self updateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) updateView {
    [indicator setHidden:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(updateViewImpl)
                                   userInfo:nil
                                    repeats:NO];
}
-(void) SetPenController:(PNFPenController *) pController {
    penController = pController;
}
-(void) updateViewImpl {
    [drawView clear];
    Page* page = [self.pages objectAtIndex:curPage];
    
    [pageLabel setText:[NSString stringWithFormat:@"%d / %d", curPage+1, (int)self.pages.count]];
    
    if (self.pages.count == 1) {
        [prevBtn setHidden:YES];
        [nextBtn setHidden:YES];
        [pageLabel setHidden:YES];
    }
    else {
        if (curPage == 0) {
            [prevBtn setEnabled:NO];
            [nextBtn setEnabled:YES];
        }
        else if (curPage == self.pages.count-1) {
            [prevBtn setEnabled:YES];
            [nextBtn setEnabled:NO];
        }
        else {
            [prevBtn setEnabled:YES];
            [nextBtn setEnabled:YES];
        }
    }
    
    CGPoint whiteSpaceOffset = CGPointZero;
    BOOL LandscapeMode = NO;
    float calcW = 0.;
    float calcH = 0.;
    if (page.calibrationSize == Custom) {
        whiteSpaceOffset = CGPointZero;
        float w = page.calibrationRect.size.width;
        float h = page.calibrationRect.size.height;
        calcW = self.view.frame.size.width;
        calcH = (int)((h*self.view.frame.size.width)/w);
        if (calcH > self.view.frame.size.height) {
            calcH = self.view.frame.size.height;
            calcW = (int)((w*self.view.frame.size.height)/h);
        }
    }
    else {
        CGSize defaultSize = CGSizeZero;
        defaultSize = [self GetDefaultSizeByPaper:page.calibrationSize];
        
        switch (page.calibrationSize) {
            case FT6X4:
            case FT6X5:
            case FT8X4:
            case FT8X5:
                LandscapeMode = YES;
                break;
            default:
                LandscapeMode = NO;
                break;
        }
        
        float w = defaultSize.width;
        float h = defaultSize.height;
        calcW = self.view.frame.size.width;
        calcH = (int)((h*self.view.frame.size.width)/w);
        if (calcH > self.view.frame.size.height) {
            calcH = self.view.frame.size.height;
            calcW = (int)((w*self.view.frame.size.height)/h);
        }
        float ratio = page.calibrationRect.size.height/page.calibrationRect.size.width;
        whiteSpaceOffset = CGPointMake(0, calcH-(int)(calcW*ratio));
        calcH = calcH-whiteSpaceOffset.y;
        
        if (LandscapeMode) {
            w = defaultSize.width;
            h = defaultSize.height;
            calcW = (int)((w*self.view.bounds.size.height)/h);
            calcH = self.view.bounds.size.height;
            
            if (calcW > self.view.frame.size.width) {
                calcW = self.view.frame.size.width;
                calcH = (int)((h*self.view.frame.size.width)/w);
            }
            float ratio = page.calibrationRect.size.width/page.calibrationRect.size.height;
            whiteSpaceOffset = CGPointMake(calcW-(int)(calcH*ratio), 0);
            calcW = calcW-whiteSpaceOffset.x;
        }
    }
    if (LandscapeMode) {
        [drawView setFrame:CGRectMake(0, 0, calcW+whiteSpaceOffset.x, calcH)];
    }
    else {
        [drawView setFrame:CGRectMake(0, 0, calcW, calcH+whiteSpaceOffset.y)];
    }
    drawView.center = self.view.center;
    [drawView changeDrawingSize];
    
    for (Stroke* s in page.strokeData) {
        UIColor* color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        CGPoint p = CGPointMake(s.point.x, s.point.y);
        if (penController.modelCode == 4) {
            BOOL erase = NO;
            BOOL big = NO;
            switch (s.colorForSM) {
                case 0x51: // red marker
                    color = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1];
                    break;
                case 0x52: // green marker
                    color = [UIColor colorWithRed:60.0/255.0 green:184.0/255.0 blue:120.0/255.0 alpha:1];
                    break;
                case 0x53:
                    color = [UIColor colorWithRed:1.0 green:1.0 blue:0 alpha:1];
                    break;
                case 0x54:
                    color = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:1];
                    break;
                case 0x56:
                    color = [UIColor colorWithRed:128.0/255.0 green:0 blue:128.0/255.0 alpha:1];
                    break;
                case 0x58:
                    color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
                    break;
                case 0x59:  // eraser cap
                    erase = YES;
                    color = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1];
                    break;
                case 0x50:
                case 0x5C:  // big eraser
                    erase = YES;
                    big = YES;
                    color = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1];
                    break;
                default:
                    break;
            }
            [drawView DoPenProcess:s.strokeType pressure:100 X:p.x Y:p.y color:color erase:erase eraseSize:s.eraseSize];
        }
        else {
            [drawView DoPenProcess:s.strokeType pressure:100 X:p.x Y:p.y color:color erase:NO eraseSize:s.eraseSize];
        }
    }
    
    [indicator setHidden:YES];
}
- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)prevClicked:(id)sender {
    curPage+=-1;
    [self updateView];
}
- (IBAction)nextClicked:(id)sender {
    curPage+=1;
    [self updateView];
}
-(CGSize) GetDefaultSizeByPaper:(int) nPaper
{
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
@end
