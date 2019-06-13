#import "UIImage+TextRendering.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage(Emoji)

+ (UIImage *) imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *) imageFromString:(NSString *)str
{
    UILabel *label = [[UILabel alloc] init];
    label.text = str;
    label.opaque = NO;
    label.backgroundColor = UIColor.clearColor;
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:18]];
    label.frame = CGRectMake(0, 0, 40, 40);
    return [UIImage imageFromView:label];
}

+ (UIImage *) cachedImageFromString:(NSString *)str
{
    static NSMutableDictionary *cache = nil;
    if (cache == nil)
        cache = [NSMutableDictionary dictionary];
    UIImage *image = [cache objectForKey:str];
    if (image != nil)
        return image;
    image = [UIImage imageFromString:str];
    [cache setObject:image forKey:str];
    return image;
}

@end