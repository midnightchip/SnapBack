#import "Frameworks/iAmGRoot.framework/Headers/iAmGRoot.h"
#include <sys/snapshot.h>
#import "Snappy/snappy.h"
#import "UIBarButtonItem+blocks.h"
#include <sys/mount.h>
#include <spawn.h>
#import <mach/error.h>
#include <sys/stat.h>
#import "NSTask.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import <Foundation/Foundation.h>

NS_INLINE NSString *runCommandGivingResults(NSString *command) {
    FILE *proc = popen(command.UTF8String, "r");
    
    if (!proc) { return [NSString stringWithFormat:@"ERROR PROCESSING COMMAND: %@", command]; }
    
    int size = 1024;
    char data[size];
    
    NSMutableString *results = [NSMutableString string];
    
    while (fgets(data, size, proc) != NULL) {
        [results appendString:[NSString stringWithUTF8String:data]];
    }
    
    pclose(proc);
    
    return [NSString stringWithString:results];
}

#define resultsForCommand(...) runCommandGivingResults(__VA_ARGS__)

bool is_mountpoint(const char *filename);
bool ensure_directory(const char *directory, int owner, mode_t mode);
@interface SBKRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;
@property JGProgressHUD *HUD;
@property UIView *alertView;
@end
