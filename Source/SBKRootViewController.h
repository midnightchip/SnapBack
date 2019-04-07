#import "../Frameworks/iAmGRoot.framework/Headers/iAmGRoot.h"
#import "UIBarButtonItem+blocks.h"
#include <sys/mount.h>
#include <spawn.h>
#import <mach/error.h>
#import "NSTask.h"
#import "../JGProgressHUD/JGProgressHUD.h"
#import <Foundation/Foundation.h>
#import "Macros.h"



@interface SBKRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;
@property JGProgressHUD *HUD;
@property UIView *alertView;
@end
