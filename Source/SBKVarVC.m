#import "SBKVarVC.h"


@implementation SBKVarVC {
	NSMutableArray *snapshotArray;
}


/*-(void)runUnmount{
    [Authorized authorizeAsRoot];
    int success = unmount("/var/MobileSoftwareUpdate/mnt1", MNT_FORCE);
    NSLog(@"UNMOUNT STATUS: %d", success);
    [Authorized authorizeAsRoot];
}*/
-(void)viewDidLoad{
    [super viewDidLoad];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"displayedVarWarning"]){
       [self varAlert];
       [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"displayedVarWarning"];
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
    self.navigationItem.title = @" Var SnapShots";
	/*[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd actionHandler:^{
        //[self runUnmount];
        [MCCommands createSnapshotPrompt:@"/var" WithCompletion:^(void){
            [self refreshSnapshots];
        }];
    }]];*/
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd actionHandler:^{
        //[self runUnmount];
        [self showiCloudWarningCreation];
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

-(void)showiCloudWarningCreation{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!"
                           message:@"You MUST disable iCloud before creating a Snapshot of Var"
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"I have disabled iCloud" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [MCCommands createSnapshotPrompt:@"/var" WithCompletion:^(void){
                                    [self refreshSnapshots];
                                }];
                            }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                            }];

    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil]; 
}

/*-(void)unmountSnap{
    [Authorized authorizeAsRoot];
    umount2("/var/MobileSoftwareUpdate/mnt1", MNT_FORCE);
    [Authorized restore];
}*/

-(void)varAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!"
                           message:@"Before using Var Snapshots, please log out of iCloud. This goes for creating and restoring to Var Snapshots.\nKeep in mind that Var Snapshots are known to take up a large amount of storage as well. It is not recommended to store more than 2 Var Snapshots at a time."
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil]; 
}

-(void)refreshSnapshots{
    [snapshotArray removeAllObjects];
    snapshotArray = [MCCommands checkForSnapshotsOnFS:@"/var"];
    if([snapshotArray count] == 1){
        self.navigationItem.title = @"1 Var Snapshot";
    }else{
        self.navigationItem.title = [NSString stringWithFormat:@"%lu Var Snapshots", (unsigned long)[snapshotArray count]];
    }
    [self.tableView reloadData];
    [self.tableView.refreshControl endRefreshing];
}




-(void)showiCloudWarning:(NSString *)snapName{
    NSString * jumpText = [NSString stringWithFormat:@"Final warning: You need to disable iCloud before continuing"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                           message:jumpText
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* jumpAction = [UIAlertAction actionWithTitle:@"I have Disabled iCloud" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //[self showiCloudWarning:snapName];
                                   [self prepSnapshotRysnc:snapName];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Let me go do that" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

                               }];

    [alert addAction:jumpAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    [self.HUD.textLabel setText:@"Mounting Snapshot"];
    [Authorized authorizeAsRoot];
    NSString * command = [NSString stringWithFormat:@"/sbin/mount_apfs -s %@ /var /var/MobileSoftwareUpdate/mnt1", snapName];
    NSString * output = runCommandGivingResults(command);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/MobileSoftwareUpdate/mnt1/sbin/launchd"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD.textLabel setText:@"Please delete the update from preferences and reboot"];
            self.HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
            //[self.HUD showInView:self.view];
            [self.HUD dismissAfterDelay:10.0 animated:YES];
        });
        [Authorized restore];
    }else{
        NSLog(@"SNAPBACK OUTPUT %@", output);
        //sleep(10);
        [self runRsync:snapName];
        [Authorized restore];
        //[self.HUD dismissAnimated:YES];
    }
    
}
-(void)runRsync:(NSString *)snapName{
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/MobileSoftwareUpdate/mnt1/Keychains"]){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self setTabBarVisible:NO animated:YES completion:nil];
        //@"--dry-run",
        NSMutableArray *rsyncArgs = [NSMutableArray arrayWithObjects:@"-vaxcsH", @"--delete", @"--progress", 
        @"--exclude=/MobileSoftwareUpdate", @"--exclude=/Keychains",
        @"/var/MobileSoftwareUpdate/mnt1/.", @"/var", nil];
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
                                                                        if ([stringRead hasPrefix:@"MobileDevice/"]) {
                                                                            if(self.HUD.progress != 0.15f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.15f animated:YES];
                                                                                });
                                                                            }
                                                                            
                                                                        }
                                                                        if ([stringRead hasPrefix:@"cache/"]) {
                                                                            if(self.HUD.progress != 0.33f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.33f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"containers/"]) {
                                                                            if(self.HUD.progress != 0.50f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.67f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"mobile/"]) {
                                                                            if(self.HUD.progress != 0.85f){
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [self.HUD setProgress:0.85f animated:YES];
                                                                                });
                                                                            }
                                                                        }
                                                                        if ([stringRead hasPrefix:@"preferences/"]) {
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
        self.HUD.textLabel.text = @"Success,\n You will now be rebooted.";
        self.HUD.detailTextLabel.text = @"";
        self.HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    });
    double delayInSeconds = 6.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [Authorized authorizeAsRoot];
        reboot(0x400);
        sleep(2);
        kill(1, SIGTERM);
        [Authorized restore];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.detailTextLabel.text = ([MCCommands prefsDict:@"/var" containsKey:[snapshotArray objectAtIndex:indexPath.row]]) ? [MCCommands prefsDict:@"/var" valueForKey:[snapshotArray objectAtIndex:indexPath.row]] : @"Unknown";
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
                                                            [MCCommands confirmDelete:cell.textLabel.text onFS:@"/var" WithCompletion:^(void){
                                                                [MCCommands removeKey:cell.textLabel.text inDictKey:@"/var"];
                                                                [self refreshSnapshots];
                                                            }];
                                                            /*[self dismissViewControllerAnimated:YES completion:^{
                                                            
                                                            }];*/
                                                        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self dismissViewControllerAnimated:YES completion:nil];
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

    UIAlertAction* jumpAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self showiCloudWarning:snapName];
                                    //[self prepSnapshotRysnc:snapName];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

                               }];

    [alert addAction:jumpAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)testAlert{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] init]; //Or JGProgressHUDRingIndicatorView
    HUD.progress = 0.5f;
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:15.0];
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

@end
