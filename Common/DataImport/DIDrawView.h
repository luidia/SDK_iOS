//
//  DIDrawView.h
//  PNFPenTest
//
//  Created by PNF on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DIDrawView : UIView
{
    CGContextRef        m_CtxMain;
    CGLayerRef          m_LyrMain;
    CGContextRef        m_CtxLyr;

    CGPoint             m_ptOld;
    CGPoint             m_ptNew;
    
    int                 m_nPointCnt;
    NSMutableArray      *m_Points;
}
-(void) DoPenProcess:(int) penTip pressure:(int)pressure X:(float) x Y:(float) y color:(UIColor*)color erase:(BOOL)erase eraseSize:(float)eraseSize;
-(void) clear;
-(void) changeDrawingSize;
@end
