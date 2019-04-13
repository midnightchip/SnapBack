#import "../Frameworks/iAmGRoot.framework/Headers/iAmGRoot.h"
#include <sys/snapshot.h>
#import "../Snappy/snappy.h"
#include <sys/mount.h>
#include <spawn.h>
#import "NSTask.h"
#import "../JGProgressHUD/JGProgressHUD.h"
#import <Foundation/Foundation.h>
#import "Macros.h"


@interface MCCommands : NSObject
//+ (void)createSnapshotPrompt:(NSString *)fileSystem;
+ (void)createSnapshotPrompt:(NSString *)fileSystem WithCompletion:(void (^)(void))handler;
+ (BOOL)createSnapshotIfNecessary:(NSString *)snapName withFS:(NSString *)fileSystem;
+ (void)confirmDelete:(NSString *)snapName onFS:(NSString*)fileSystem WithCompletion:(void (^)(void))handler;
+ (BOOL) removeSelectedSnapshot:(NSString *)snapName onFS:(NSString *)fileSystem;
+ (NSString *)returnFirstSnapOnFS:(NSString *)fileSystem;
+ (BOOL)batteryOK;
+ (NSMutableArray *)checkForSnapshotsOnFS:(NSString *)fileSystem;
@end 