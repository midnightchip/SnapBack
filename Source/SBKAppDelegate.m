#import "SBKAppDelegate.h"
#import "SBKRootViewController.h"
#import "SBKVarVC.h"
#import "SettingsVC.h"
#import "MCCommands.h"

@interface UINavigationBar (iOS11)
@property (nonatomic, readwrite) BOOL prefersLargeTitles;
@end


@implementation SBKAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	UITabBarController *tabBars = [[UITabBarController alloc] init];
    NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:1];
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[SBKRootViewController alloc] init]];
	_rootViewController.tabBarItem.image=[UIImage imageNamed:@"save.png"];
	_rootViewController.tabBarItem.title = @"Root Snapshots";

	_VarVC = [[UINavigationController alloc] initWithRootViewController:[[SBKVarVC alloc] init]];
	_VarVC.tabBarItem.image=[UIImage imageNamed:@"mem.png"];
    _VarVC.tabBarItem.title = @"Var Snapshots";
    
	//_VarVC.tabBarItem.title = @"Var Snapshots";
	[localViewControllersArray addObject:_rootViewController];
	[localViewControllersArray addObject:_VarVC];

	_SettingsVC = [[UINavigationController alloc] initWithRootViewController:[[SettingsVC alloc] init]];
	_SettingsVC.tabBarItem.image=[UIImage imageNamed:@"settings.png"];
	_SettingsVC.tabBarItem.title = @"Info";
	if (@available(iOS 11, tvOS 11, *)) {
		_SettingsVC.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
	}
	[localViewControllersArray addObject:_SettingsVC];

	tabBars.viewControllers = localViewControllersArray;
	tabBars.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);    
	_window.rootViewController = tabBars;
	//_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	

}

- (void)dealloc {
}

@end
