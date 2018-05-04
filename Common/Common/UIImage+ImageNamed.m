//
//  UIImage+ImageNamed.m
//  Equil Note HD
//
//  Created by choi on 14. 5. 20..
//  Copyright (c) 2014년 PenAndFree. All rights reserved.
//

#import "UIImage+ImageNamed.h"

@implementation UIImage (ImageNamed)

+ (UIImage *)MyImageNamed:(NSString *)imageName
{
	NSString	*path	= nil;
	NSString	*name	= [imageName stringByDeletingPathExtension];
	NSString	*ext	= [imageName pathExtension];
	BOOL		isiPhone	= YES;
	
	if( [[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
	   [UIImage instancesRespondToSelector:@selector(scale)] )
	{
#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
		if( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone )
		{
            isiPhone    = NO;
		}
#endif
		
		if( [[UIScreen mainScreen] scale] == 2.0)
		{
			// 레티나 디스플레이 지원용 이미지 확인 작업.
			path	= [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"]
												   ofType:ext];
			
			
		}
	}
	
	if( nil == path )
	{
		path	= [[NSBundle mainBundle] pathForResource:name ofType:ext];
	}
	
	if( nil == path )
	{
		path	= [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
	}
	
	UIImage	*image	= nil;
	
	if( path )
	{
		image	= [UIImage imageWithContentsOfFile:path];
	}
	
	return image;
}
@end
