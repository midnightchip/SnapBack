#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>


@interface SettingsVC : PSListController {
    
}
- (void)_openTwitterForUser:(NSString*)username;
@property NSMutableArray *iconUrls;
@end