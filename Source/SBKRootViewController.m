#import "SBKRootViewController.h"


bool rebuildApplicationDatabases() {

    LSApplicationWorkspace* applicationWorkspace = [NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace];
    if ([applicationWorkspace _LSPrivateRebuildApplicationDatabasesForSystemApps:YES internal:YES user:NO]) {
        return true;
    } else {
        return false;
    }
}

@implementation SBKRootViewController {
	NSMutableArray *snapshotArray;
}

- (BOOL)shouldAutorotate{

    return NO;

}

-(void)viewDidLoad{
    [super viewDidLoad];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"displayedWarning"]){
       [self varAlert];
       [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"displayedWarning"];
    } 
}

- (void)loadView {
	[super loadView];
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/MobileSoftwareUpdate/mnt1"
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    
    if (error != nil) {
    NSLog(@"error creating directory: %@", error);
    //..
    }
    //self.alertView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //self.alertView.backgroundColor = [UIColor greenColor];
    //[self.view addSubview:self.alertView];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self; 
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
                             UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];

	snapshotArray = [[NSMutableArray alloc] init];
    if (@available(iOS 11, tvOS 11, *)) {
	    self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    self.navigationItem.title = @"SnapShots";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd actionHandler:^{
        //[self runUnmount];
        [MCCommands createSnapshotPrompt:@"/" WithCompletion:^(void){
            [self refreshSnapshots];
        }];
    }];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"info"] style:UIBarButtonItemStylePlain actionHandler:^{
        [self varAlert];
    }];
    self.navigationItem.rightBarButtonItems = @[addButton, infoButton];

    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView.refreshControl addTarget:self action:@selector(refreshSnapshots) forControlEvents:UIControlEventValueChanged];
    [self.tableView setRefreshControl:self.tableView.refreshControl];
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshSnapshots];
}

-(void)varAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!"
                           message:@"While SnapBack has been tested thoroughly, the developer of this software is not responsible for anything that may happen to your device.\nBy clicking OK you understand this and will not harass the developer for any issues that may arise."
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {}];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"displayedWarning"];
                                exit(0);
                            }];

    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil]; 
}

-(void)refreshSnapshots{
    [snapshotArray removeAllObjects];
    [Authorized authorizeAsRoot];
    [self checkForSnapshots];
    [Authorized restore];
    if([snapshotArray count] == 1){
        self.navigationItem.title = @"1 Root Snapshot";
    }else{
        self.navigationItem.title = [NSString stringWithFormat:@"%lu Root Snapshots", (unsigned long)[snapshotArray count]];
    }
    [self.tableView reloadData];
    [self.tableView.refreshControl endRefreshing];
}
-(void)checkForSnapshots{
    int rootfd         = open("/", O_RDONLY);
    if (rootfd) {
        const char **snapshots      = snapshot_list(rootfd);
        if (snapshots != NULL) {
            for (const char **snapshot = snapshots; *snapshot; snapshot++) {
                NSString *snapName = [[NSString alloc] initWithCString:*snapshot encoding:NSUTF8StringEncoding];
                //if(![snapName isEqualToString:@"orig-fs"]){
                [snapshotArray addObject:snapName];
                //}
            }
        }
        free(snapshots);
        close(rootfd);
    }
}



-(void)prepSnapshotRysnc:(NSString *)snapName{
    if([MCCommands batteryOK]){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            self.HUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] init];
            [self.HUD setProgress:0.0f animated:YES];
            self.HUD.textLabel.text = @"Please Wait.\nDo Not Close The App.\nDo Not Lock Your Device.\nYour Device Will Reboot When Done.";
            //[self.view addSubview:self.alertView];
            self.HUD.frame = [UIScreen mainScreen].bounds;
            [self.HUD showInView:self.view];
        });
        [self jumpToSnapshotRsync:snapName];
    }else{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Battery Warning"
                           message:@"SnapBack requires your phone to be at or above 50% batter, or plugged into power.\nPlease plug your device in to continue."
                           preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                    
                               }];

    
        [alert addAction:OKAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)jumpToSnapshotRsync:(NSString *)snapName{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [Authorized authorizeAsRoot];
    [self.HUD.textLabel setText:@"Mounting Snapshot"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/MobileSoftwareUpdate/mnt1/sbin/launchd"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD.textLabel setText:@"Please delete the update from preferences and reboot"];
            self.HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
            //[self.HUD showInView:self.view];
            [self.HUD dismissAfterDelay:10.0 animated:YES];
        });
    }else{
        NSString * command = [NSString stringWithFormat:@"/sbin/mount_apfs -s %@ / /var/MobileSoftwareUpdate/mnt1", snapName];
        NSString * output = runCommandGivingResults(command);
        NSLog(@"SNAPBACK OUTPUT %@", output);
        //sleep(10);
        [self runRsync:snapName];
        [Authorized restore];
        //[self.HUD dismissAnimated:YES];
    }
    
}
-(void)runRsync:(NSString *)snapName{
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/MobileSoftwareUpdate/mnt1/sbin/launchd"]){
        //@"--dry-run",
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self setTabBarVisible:NO animated:YES completion:nil];
        NSMutableArray *rsyncArgs = [NSMutableArray arrayWithObjects:@"-vaxcH", @"--delete", @"--progress", @"--exclude=/Developer", @"--exclude=/usr/libexec/xpcproxy", @"/var/MobileSoftwareUpdate/mnt1/.", @"/", nil];
        NSTask *rsyncTask = [[NSTask alloc] init];
        [rsyncTask setLaunchPath:@"/usr/bin/rsync"];
        [rsyncTask setArguments:rsyncArgs];
        NSPipe *outputPipe = [NSPipe pipe];
        [rsyncTask setStandardOutput:outputPipe];
        NSFileHandle *stdoutHandle = [outputPipe fileHandleForReading];
        [stdoutHandle waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
                                                                        object:stdoutHandle queue:nil
                                                                    usingBlock:^(NSNotification *note){
                                                                        NSData *dataRead = [stdoutHandle availableData];
                                                                        NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
                                                                        NSLog(@"SnapBack RSYNC %@", stringRead);
                                                                        [self.HUD.detailTextLabel setText:stringRead];
                                                                        if ([stringRead containsString:@"00 files..."]) {
                                                                            if(self.HUD.progress != 0.05f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.05f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"Applications/"]) {
                                                                            if(self.HUD.progress != 0.15f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.15f animated:YES];
                                                                                });
                                                                            }
                                                                            
                                                                        }
                                                                        if ([stringRead hasPrefix:@"Library/"]) {
                                                                            if(self.HUD.progress != 0.33f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.33f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"System/"]) {
                                                                            if(self.HUD.progress != 0.67f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.67f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"usr/"]) {
                                                                            if(self.HUD.progress != 0.85f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.85f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"private/"]) {
                                                                            if(self.HUD.progress != 0.95f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.95f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if([stringRead containsString:@"speedup is"]){
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [self.HUD setProgress:1.0f animated:YES];
                                                                            });
                                                                            [self endRsync];
                                                                        }
                                                                        [stdoutHandle waitForDataInBackgroundAndNotify];
                                                                        
                                                                    }];
        [rsyncTask launch];
    }else{
        [self.HUD.textLabel setText:@"Invalid/Corrupt Snapshot"];
    }
}
-(void)endRsync{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self setTabBarVisible:YES animated:YES completion:nil];
        self.HUD.textLabel.text = @"Rebuilding Icon Cache";
        self.HUD.detailTextLabel.text = @"";
        self.HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    });
    [self runUICachewithCompletion:^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.HUD.textLabel.text = @"Success!\nPlease Reboot Your Device.";
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [Authorized authorizeAsRoot];
                reboot(0x400);
                sleep(2);
                kill(1, SIGTERM);
                [Authorized restore];
            });
        });
    }];
}

-(void)runUICachewithCompletion:(void (^)(void))handler{
    rebuildApplicationDatabases();
    if(handler) handler();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)returnFirstSnap{
    [Authorized authorizeAsRoot];
    int rootfd = open("/", O_RDONLY);
    if (rootfd <= 0) return NULL;
    const char **snapshots = snapshot_list(rootfd);
    if (snapshots == NULL) return NULL;
    const char* snapshot = *snapshots;
    close (rootfd);
    free(snapshots);
    snapshots = NULL;
	return [NSString stringWithCString:snapshot encoding:NSUTF8StringEncoding];
    [Authorized restore];
}


- (void)addButtonTapped:(id)sender {
	[snapshotArray insertObject:[NSDate date] atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [snapshotArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *simpleTableIdentifier = @"Snapshots";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [snapshotArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = ([MCCommands prefsDict:@"/" containsKey:[snapshotArray objectAtIndex:indexPath.row]]) ? [MCCommands prefsDict:@"/" valueForKey:[snapshotArray objectAtIndex:indexPath.row]] : @"Unknown";
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIAlertController *optionAlert = [UIAlertController alertControllerWithTitle:@"Options for:" message:[NSString stringWithFormat:@"%@",cell.textLabel.text] preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* snapAction = [UIAlertAction actionWithTitle:@"Jump to Snapshot" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self confirmJump:cell.textLabel.text];
                                                             
                                                         }];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete Snapshot" style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * action) {
                                                            [MCCommands confirmDelete:cell.textLabel.text onFS:@"/" WithCompletion:^(void){
                                                                [MCCommands removeKey:cell.textLabel.text inDictKey:@"/"];
                                                                [self refreshSnapshots];
                                                            }];
      
                                                        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self dismissViewControllerAnimated:YES completion:^{
                                                             }];
                                                         }];
    
    [optionAlert addAction:snapAction];
    if(find_stock_snapshot()){
        NSString *origSnap = [NSString stringWithCString:find_stock_snapshot() encoding:NSUTF8StringEncoding];
        if(origSnap){
            if(![cell.textLabel.text isEqualToString:origSnap]){
                [optionAlert addAction:deleteAction];
            }
        }
    }
    [optionAlert addAction:cancelAction];
    [optionAlert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [optionAlert popoverPresentationController];
    popPresenter.sourceView = cell;
    popPresenter.sourceRect = cell.bounds;
    [self presentViewController:optionAlert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)confirmJump:(NSString *)snapName{
    NSString * jumpText = [NSString stringWithFormat:@"Are you sure you want to jump to %@?", snapName];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                           message:jumpText
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* jumpAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                   [self presentBlackWarning:snapName];
                                    //[self prepSnapshotRysnc:snapName];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

                               }];

    
    [alert addAction:cancelAction];
    [alert addAction:jumpAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)presentBlackWarning:(NSString *)snapName{
    NSString * jumpText = [NSString stringWithFormat:@"On completion, SnapBack may appear to have crashed and only be a black screen.\nJust hard restart your device and rejailbreak like normal, SnapBack has operated correctly."];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                           message:jumpText
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                    [self prepSnapshotRysnc:snapName];
                               }];

    
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {

    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;

    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;

    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;

    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

-(void)testAlert{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] init]; 
    HUD.progress = 0.5f;
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:3.0];
}

@end
