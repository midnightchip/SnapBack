#import <UIKit/UIKit.h>

@interface UIImage (Emoji)

+ (UIImage *) imageFromView:(UIView *)view;
+ (UIImage *) imageFromString:(NSString *)str;
+ (UIImage *) cachedImageFromString:(NSString *)str;

@end