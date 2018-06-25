//
//  UIImage+ImageNamed.m
//  PenTestExtension
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import "UIImage+ImageNamed.h"

@implementation UIImage (ImageNamed)

+ (UIImage *)MyImageNamed:(NSString *)imageName
{
	NSString	*path	= nil;
	NSString	*name	= [imageName stringByDeletingPathExtension];
	NSString	*ext	= [imageName pathExtension];
	
	if( [[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
	   [UIImage instancesRespondToSelector:@selector(scale)] )
	{
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
