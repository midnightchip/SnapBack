//
//  ViewController.m
//  SnapBack
//
//  Created by midnightchips on 4/1/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "ViewController.h"
#import <iAmGRoot/iAmGRoot.h>
#include <sys/snapshot.h>
#import "snappy.h"
#import "UIBarButtonItem+blocks.h"
#import "MCCommands.h"
#include <sys/mount.h>
#include <spawn.h>
#import <mach/error.h>
#include <sys/stat.h>
#import "NSTask.h"
@import JGProgressHUD;

//C functions
bool is_mountpoint(const char *filename) {
    struct stat buf;
    if (lstat(filename, &buf) != ERR_SUCCESS) {
        return false;
    }
    
    if (!S_ISDIR(buf.st_mode))
        return false;
    
    char *cwd = getcwd(NULL, 0);
    int rv = chdir(filename);
    assert(rv == ERR_SUCCESS);
    struct stat p_buf;
    rv = lstat("..", &p_buf);
    assert(rv == ERR_SUCCESS);
    if (cwd) {
        chdir(cwd);
        free(cwd);
    }
    return buf.st_dev != p_buf.st_dev || buf.st_ino == p_buf.st_ino;
}

bool ensure_directory(const char *directory, int owner, mode_t mode) {
    NSString *path = @(directory);
    NSFileManager *fm = [NSFileManager defaultManager];
    id attributes = [fm attributesOfItemAtPath:path error:nil];
    if (attributes &&
        [attributes[NSFileType] isEqual:NSFileTypeDirectory] &&
        [attributes[NSFileOwnerAccountID] isEqual:@(owner)] &&
        [attributes[NSFileGroupOwnerAccountID] isEqual:@(owner)] &&
        [attributes[NSFilePosixPermissions] isEqual:@(mode)]
        ) {
        // Directory exists and matches arguments
        return true;
    }
    if (attributes) {
        if ([attributes[NSFileType] isEqual:NSFileTypeDirectory]) {
            // Item exists and is a directory
            return [fm setAttributes:@{
                                       NSFileOwnerAccountID: @(owner),
                                       NSFileGroupOwnerAccountID: @(owner),
                                       NSFilePosixPermissions: @(mode)
                                       } ofItemAtPath:path error:nil];
        } else if (![fm removeItemAtPath:path error:nil]) {
            // Item exists and is not a directory but could not be removed
            return false;
        }
    }
    // Item does not exist at this point
    return [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:@{
                                                                                       NSFileOwnerAccountID: @(owner),
                                                                                       NSFileGroupOwnerAccountID: @(owner),
                                                                                       NSFilePosixPermissions: @(mode)
                                                                                       } error:nil];
}

const char *find_stock_snapshot() {
    int rootfd = open("/", O_RDONLY);
    if (rootfd <= 0) return NULL;
    const char **snapshots = snapshot_list(rootfd);
    if (snapshots == NULL) return NULL;
    const char *snapshot = *snapshot;
    close (rootfd);
    free(snapshots);
    snapshots = NULL;
    return snapshot;
}

int waitForFile(const char *filename) {
    int rv = 0;
    rv = access(filename, F_OK);
    for (int i = 0; !(i >= 100 || rv == ERR_SUCCESS); i++) {
        usleep(100000);
        rv = access(filename, F_OK);
    }
    return rv;
}


@interface ViewController (){
    NSMutableArray *snapshotArray;
}
@property JGProgressHUD *HUD;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    snapshotArray = [NSMutableArray new];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd actionHandler:^{
        [self createSnapshotPrompt];
    }]];
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView.refreshControl addTarget:self action:@selector(refreshSnapshots) forControlEvents:UIControlEventValueChanged];
    [self.tableView setRefreshControl:self.tableView.refreshControl];
    
    //self.title = @"Sn";
    // Do any additional setup after loading the view, typically from a nib.
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
        self.title = @"1 Snapshot";
    }else{
        self.title = [NSString stringWithFormat:@"%lu Snapshots", (unsigned long)[snapshotArray count]];
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
    snapName = [snapName lowercaseString];
    snapName = [snapName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    if([snapName isEqualToString:[[NSString alloc] initWithCString:find_stock_snapshot() encoding:NSUTF8StringEncoding]]){
        return FALSE;
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



-(void)prepSnapshotRysnc:(NSString *)snapName{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.HUD.textLabel.text = @"Please Wait, Do Not Lock Your Device. \nYour Device Will Reboot When Done.";
        [self.HUD showInView:self.view];
    });
    [self jumpToSnapshotRsync:snapName];
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
                                                                        if([stringRead containsString:@"speedup is"]){
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
    self.HUD.textLabel.text = @"Success, If you see this message you need to force reboot.";
    self.HUD.detailTextLabel.text = @"You will now be rebooted";
    self.HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    //sleep(3);
    [Authorized authorizeAsRoot];
    reboot(0x400)
    sleep(2);
    kill(1, SIGTERM);
    [Authorized restore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Snapshots";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [snapshotArray objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [snapshotArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIAlertController *optionAlert = [UIAlertController alertControllerWithTitle:@"Options for:" message:[NSString stringWithFormat:@"%@",cell.textLabel.text] preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* snapAction = [UIAlertAction actionWithTitle:@"Jump to Snapshot" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self prepSnapshotRysnc:cell.textLabel.text];
                                                             
                                                         }];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete Snapshot" style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * action) {
                                                            [Authorized authorizeAsRoot];
                                                            [self removeSelectedSnapshot:cell.textLabel.text];
                                                            [Authorized restore];
                                                            [self refreshSnapshots];
                                                            [self dismissViewControllerAnimated:YES completion:^{
                                                            }];
                                                        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self dismissViewControllerAnimated:YES completion:^{
                                                             }];
                                                         }];
    
    [optionAlert addAction:snapAction];
    if(![cell.textLabel.text isEqualToString:[[NSString alloc] initWithCString:find_stock_snapshot() encoding:NSUTF8StringEncoding]]]){
        [optionAlert addAction:deleteAction];
    }
    [optionAlert addAction:cancelAction];
    [optionAlert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [optionAlert popoverPresentationController];
    popPresenter.sourceView = cell;
    popPresenter.sourceRect = cell.bounds;
    [self presentViewController:optionAlert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    <#code#>
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    <#code#>
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    <#code#>
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    <#code#>
}

- (void)setNeedsFocusUpdate {
    <#code#>
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    <#code#>
}

- (void)updateFocusIfNeeded {
    <#code#>
}
*/
@end
