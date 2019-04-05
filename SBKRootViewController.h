#import <iAmGRoot/iAmGRoot.h>
#include <sys/snapshot.h>
#import "Snappy/snappy.h"
#import "UIBarButtonItem+blocks.h"
#import "MCCommands.h"
#include <sys/mount.h>
#include <spawn.h>
#import <mach/error.h>
#include <sys/stat.h>
#import "NSTask.h"
#import "JGProgressHUD/JGProgressHUD.h"

bool is_mountpoint(const char *filename);
bool ensure_directory(const char *directory, int owner, mode_t mode);
@interface SBKRootViewController : UITableViewController
@property JGProgressHUD *HUD;
@end
