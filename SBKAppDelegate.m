#import "SBKAppDelegate.h"
#import "SBKRootViewController.h"
#import "SBKVarVC.h"

@implementation SBKAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UITabBarController *tabBars = [[UITabBarController alloc] init];
    NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:1];
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[SBKRootViewController alloc] init]];
	_rootViewController.tabBarItem.image=[UIImage imageNamed:@"save.png"];

	_VarVC = [[UINavigationController alloc] initWithRootViewController:[[SBKVarVC alloc] init]];
	_VarVC.tabBarItem.image=[UIImage imageNamed:@"save.png"];
	_VarVC.tabBarItem.title = @"Var Snapshots";
	[localViewControllersArray addObject:_rootViewController];
	[localViewControllersArray addObject:_VarVC];
	tabBars.viewControllers = localViewControllersArray;
	tabBars.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);    
	_window.rootViewController = tabBars;
	//_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	

}

- (void)dealloc {
}

@end
