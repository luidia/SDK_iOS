#import <Foundation/Foundation.h>

@interface UIView (Toast)

// each makeToast method creates a view and displays it as toast
-(void)makeToast:(NSString *)message;
-(void)makeToast:(NSString *)message duration:(float)interval position:(id)point;
-(void)makeToast:(NSString *)message duration:(float)interval position:(id)point title:(NSString *)title;
-(void)makeToast:(NSString *)message duration:(float)interval position:(id)point title:(NSString *)title image:(UIImage *)image;
-(void)makeToast:(NSString *)message duration:(float)interval position:(id)point image:(UIImage *)image;

// the showToast method displays an existing view as toast
-(void)showToast:(UIView *)toast;
-(void)showToast:(UIView *)toast duration:(float)interval position:(id)point;

@end
