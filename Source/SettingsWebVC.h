
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface SettingsWebVC : UIViewController <WKNavigationDelegate>

- (instancetype)initWithDocument:(NSString*)document;

@end
