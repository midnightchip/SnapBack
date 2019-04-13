#import "MCCommands.h"

@implementation MCCommands


+ (void)createSnapshotPrompt:(NSString *)fileSystem WithCompletion:(void (^)(void))handler{

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
        [self createSnapshotIfNecessary:namefield.text withFS:fileSystem];
        [Authorized restore];
        if(handler) handler();    
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (BOOL)createSnapshotIfNecessary:(NSString *)snapName withFS:(NSString *)fileSystem{
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
    int rootfd         = open([fileSystem cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
    
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

+ (void)confirmDelete:(NSString *)snapName onFS:(NSString*)fileSystem WithCompletion:(void (^)(void))handler{
    NSString *deleteText = [NSString stringWithFormat: @"Are you sure you want to delete %@?", snapName];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                            message:deleteText
                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                    [Authorized authorizeAsRoot];
                                    [MCCommands removeSelectedSnapshot:snapName onFS:fileSystem];
                                    [Authorized restore];
                                    if(handler) handler(); 
                                    //[self refreshSnapshots];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                               handler:nil];

    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (BOOL) removeSelectedSnapshot:(NSString *)snapName onFS:(NSString *)fileSystem{
    bool success     = false;
    int rootfd       = open([fileSystem cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
    const char *snapback_snapshot     = [snapName cStringUsingEncoding:NSUTF8StringEncoding];
    success = fs_snapshot_delete(rootfd, snapback_snapshot, 0);
               if (!success){
                   NSLog(@"Failed To Delete Snapshot");
               }
    return success;
}

+ (NSString *)returnFirstSnapOnFS:(NSString *)fileSystem{
    [Authorized authorizeAsRoot];
    int rootfd = open([fileSystem cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
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

+ (BOOL)batteryOK{
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

+ (NSMutableArray *)checkForSnapshotsOnFS:(NSString *)fileSystem{
    NSMutableArray *snapshotArray = [NSMutableArray new];
    [Authorized authorizeAsRoot];
    int rootfd         = open([fileSystem cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
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
    [Authorized restore];
    return snapshotArray;
}

@end 