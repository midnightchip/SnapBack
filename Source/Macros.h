#include <sys/stat.h>
#import <mach/error.h>
#include <sys/stat.h>
#include <sys/snapshot.h>
#import "../Snappy/snappy.h"

@interface LSApplicationWorkspace : NSObject
+ (id) defaultWorkspace;
- (BOOL) registerApplication:(id)application;
- (BOOL) unregisterApplication:(id)application;
- (BOOL) invalidateIconCache:(id)bundle;
- (BOOL) registerApplicationDictionary:(id)application;
- (BOOL) installApplication:(id)application withOptions:(id)options;
- (BOOL) _LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)system internal:(BOOL)internal user:(BOOL)user;
@end

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
extern const char *find_stock_snapshot();
