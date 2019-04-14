#import "../Frameworks/iAmGRoot.framework/Headers/iAmGRoot.h"
#include <sys/snapshot.h>
#import "../Snappy/snappy.h"
#include <sys/mount.h>
#include <spawn.h>
#import "NSTask.h"
#import "../JGProgressHUD/JGProgressHUD.h"
#import <Foundation/Foundation.h>
#import "Macros.h"
#import <objc/runtime.h>

typedef enum {
	kAdd,
	kRemove,
	kExists
} prefActions;


@interface MCCommands : NSObject
//+ (void)createSnapshotPrompt:(NSString *)fileSystem;
+ (void)createSnapshotPrompt:(NSString *)fileSystem WithCompletion:(void (^)(void))handler;
+ (BOOL)createSnapshotIfNecessary:(NSString *)snapName withFS:(NSString *)fileSystem;
+ (void)confirmDelete:(NSString *)snapName onFS:(NSString*)fileSystem WithCompletion:(void (^)(void))handler;
+ (BOOL) removeSelectedSnapshot:(NSString *)snapName onFS:(NSString *)fileSystem;
+ (NSString *)returnFirstSnapOnFS:(NSString *)fileSystem;
+ (BOOL)batteryOK;
+ (NSMutableArray *)checkForSnapshotsOnFS:(NSString *)fileSystem;

//https://github.com/Tonyk7/MGSpoof/blob/master/mgspoofhelper/MGSpoofHelperPrefs.h
+(BOOL)handleAppPrefsWithAction:(int)action inKey:(NSString *)key withValue:(id)value;
+(id)retrieveObjectFromKey:(NSString *)key;
+(void)addToKey:(NSString *)key withValue:(id)value inDictKey:(NSString *)dictKey;
+(void)removeKey:(NSString *)key inDictKey:(NSString *)dictKey;
+(BOOL)prefsDict:(NSString *)targetDict containsKey:(NSString *)dictKey;
+(NSString *)prefsDict:(NSString *)targetDict valueForKey:(NSString *)key;
@end 