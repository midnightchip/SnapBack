#import "MCCommands.h"
#import "UIBarButtonItem+blocks.h"

@interface SBKVarVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;
@property JGProgressHUD *HUD;
@end
