#import "SBKRootViewController.h"


// End C
@implementation SBKRootViewController {
	NSMutableArray *snapshotArray;
}

- (BOOL)shouldAutorotate{

    return NO;

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
    //if (@available(iOS 11, tvOS 11, *)) {
	    self.navigationController.navigationBar.prefersLargeTitles = YES;
    //}
    self.title = @"SnapShots";
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd actionHandler:^{
        [self createSnapshotPrompt];
    }]];
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView.refreshControl addTarget:self action:@selector(refreshSnapshots) forControlEvents:UIControlEventValueChanged];
    [self.tableView setRefreshControl:self.tableView.refreshControl];
}
-(void)viewDidAppear:(BOOL)animated{
    [self refreshSnapshots];
}

-(void)refreshSnapshots{
    [snapshotArray removeAllObjects];
    [Authorized authorizeAsRoot];
    [self checkForSnapshots];
    [Authorized restore];
    if([snapshotArray count] == 1){
        self.title = @"1 Root Snapshot";
    }else{
        self.title = [NSString stringWithFormat:@"%lu Root Snapshots", (unsigned long)[snapshotArray count]];
    }
    [self.tableView reloadData];
    [self.tableView.refreshControl endRefreshing];
}
-(void)createSnapshotPrompt{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Name"
                                                                              message: @"Enter Snapshot Name"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Snapshot Name";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        [Authorized authorizeAsRoot];
        [self createSnapshotIfNecessary:namefield.text];
        [Authorized restore];
        [self refreshSnapshots];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
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

- (BOOL)createSnapshotIfNecessary:(NSString *)snapName {
    //snapName = [snapName lowercaseString];
    snapName = [snapName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    if(find_stock_snapshot()){
        NSString *origSnap = [NSString stringWithCString:find_stock_snapshot() encoding:NSUTF8StringEncoding];
        if(origSnap){
            if([snapName isEqualToString:origSnap]){
                return FALSE;
            }
        }
    }
    bool success     = false;
    int rootfd         = open("/", O_RDONLY);
    
    if (rootfd) {
        bool has_snapback_snapshot     = false;
        const char **snapshots             = snapshot_list(rootfd);
        const char *snapback_snapshot     = [snapName cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (snapshots != NULL) {
            for (const char **snapshot = snapshots; *snapshot; snapshot++) {
                if (strcmp(snapback_snapshot, *snapshot) == 0) {
                    has_snapback_snapshot = true;
                    break;
                }
            }
        }
        
        if (!has_snapback_snapshot) {
            success = fs_snapshot_create(rootfd, snapback_snapshot, 0);
            
            if (!success) {
                NSLog(@"*** Failed to create snapshot ***");
            }
            
            else{
                success = snapshot_check(rootfd, snapback_snapshot);
                
                if (!success) {
                    NSLog(@"*** Snapback Snapshot corrupt ***");
                }
            }
        }
        
        else {
            success = has_snapback_snapshot;
            NSLog(@"*** Snapback Snapshot already exists ***");
        }
    }
    
    close(rootfd);
    
    return success;
}

-(BOOL) removeSelectedSnapshot:(NSString *)snapName{
    bool success     = false;
    int rootfd       = open("/", O_RDONLY);
    const char *snapback_snapshot     = [snapName cStringUsingEncoding:NSUTF8StringEncoding];
    success = fs_snapshot_delete(rootfd, snapback_snapshot, 0);
               if (!success){
                   NSLog(@"Failed To Delete Snapshot");
               }
    return success;
}

-(BOOL)batteryOK{
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];

    int state = [myDevice batteryState];

    double batLeft = (float)[myDevice batteryLevel] * 100;
    if(state >= 2 || batLeft >= 50){
        return TRUE;
    }else{
        return FALSE;
    }
}

-(void)prepSnapshotRysnc:(NSString *)snapName{
    if([self batteryOK]){
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD.textLabel setText:@"Make sure your device is plugged in and/or charged to at least 50%"];
            self.HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
            //[self.HUD showInView:self.view];
            [self.HUD dismissAfterDelay:10.0 animated:YES];
        });
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
        NSMutableArray *rsyncArgs = [NSMutableArray arrayWithObjects:@"-vaxcH", @"--delete-after", @"--progress", @"--exclude=/Developer", @"/var/MobileSoftwareUpdate/mnt1/.", @"/", nil];
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
        self.HUD.textLabel.text = @"Success,\n You will now be rebooted.";
        self.HUD.detailTextLabel.text = @"";
        self.HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    });
    //sleep(3);
    double delayInSeconds = 5.0;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [snapshotArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[snapshotArray removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                                                            [self confirmDelete:cell.textLabel.text];
                                                            /*[self dismissViewControllerAnimated:YES completion:^{
                                                            
                                                            }];*/
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

-(void)confirmDelete:(NSString *)snapName{
    NSString *deleteText = [NSString stringWithFormat: @"Are you sure you want to delete %@?", snapName];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                            message:deleteText
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                    [Authorized authorizeAsRoot];
                                    [self removeSelectedSnapshot:snapName];
                                    [Authorized restore];
                                    [self refreshSnapshots];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

                               }];

    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)confirmJump:(NSString *)snapName{
    NSString * jumpText = [NSString stringWithFormat:@"Are you sure you want to jump to %@?", snapName];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                           message:jumpText
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* jumpAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                    [self prepSnapshotRysnc:snapName];
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
    [HUD dismissAfterDelay:3.0];
}

@end
