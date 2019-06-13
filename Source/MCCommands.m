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
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        NSString *cleanString = [self returnCleanedString:namefield.text];
        [Authorized authorizeAsRoot];
        [self createSnapshotIfNecessary:cleanString withFS:fileSystem];
        [Authorized restore];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mm a, E MMM d, yyyy"];
        NSDate *currentDate = [NSDate date];
        NSString *dateString = [formatter stringFromDate:currentDate];
        [MCCommands addToKey:cleanString withValue:dateString inDictKey:fileSystem];
        if(handler) handler();    
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (NSString *)returnCleanedString:(NSString *)snapName{
    snapName = [snapName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"(" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@")" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"\\" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"$" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"%" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"*" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"[" withString:@"-"];
    snapName = [snapName stringByReplacingOccurrencesOfString:@"]" withString:@"-"];
    return snapName;
}

+ (BOOL)createSnapshotIfNecessary:(NSString *)snapName withFS:(NSString *)fileSystem{
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

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                    [Authorized authorizeAsRoot];
                                    [MCCommands removeSelectedSnapshot:snapName onFS:fileSystem];
                                    [Authorized restore];
                                    if(handler) handler(); 
                                    //[self refreshSnapshots];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                               handler:nil];

    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
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

+(BOOL)handleAppPrefsWithAction:(int)action inKey:(NSString *)key withValue:(id)value {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.midnightchips.SnapBack"];
	NSArray *oldArray = (NSArray *)[userDefaults objectForKey:key];
	// if there is no array make it 
	if (!oldArray) {
		[userDefaults setValue:@[] forKey:key];
		oldArray = @[];
	}
	NSMutableArray *tempArray = oldArray.mutableCopy;
	// add or remove item from remove and update array in userDefaults depending on action
	switch (action) {
		case kAdd:
			if ([value isKindOfClass:[NSString class]]) {
				if (value && ![tempArray containsObject:value])
					[tempArray addObject:value];
			} else if (value && [value isKindOfClass:[NSArray class]]) {
					tempArray = [tempArray arrayByAddingObjectsFromArray:value].mutableCopy;
			}
			break;
		case kRemove:
			if (value && [tempArray containsObject:value])
				[tempArray removeObject:value];
			break;
		case kExists:
			return [tempArray containsObject:value];
	}
	// update the array in userDefaults
	[userDefaults setValue:tempArray forKey:key];
	return 0;
}

+(void)addToKey:(NSString *)key withValue:(id)value inDictKey:(NSString *)dictKey {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.midnightchips.SnapBack"];
	NSMutableDictionary *newDict = ((NSDictionary *)[userDefaults objectForKey:dictKey]).mutableCopy;
	if (!newDict) {
		[userDefaults setValue:@{} forKey:dictKey];
		newDict = @{}.mutableCopy;
	}
	newDict[key] = value;
	[userDefaults setValue:newDict forKey:dictKey];
    [userDefaults synchronize];
}

+(void)removeKey:(NSString *)key inDictKey:(NSString *)dictKey {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.midnightchips.SnapBack"];
	NSMutableDictionary *newDict = ((NSDictionary *)[userDefaults objectForKey:dictKey]).mutableCopy;
	[newDict removeObjectForKey:key];
	[userDefaults setValue:newDict forKey:dictKey];
    [userDefaults synchronize];
}

+(id)retrieveObjectFromKey:(NSString *)key {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.midnightchips.SnapBack"];
	return [userDefaults objectForKey:key];
}

+(NSString *)prefsDict:(NSString *)targetDict valueForKey:(NSString *)key{
    NSMutableDictionary *newDict;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.midnightchips.SnapBack"];
    if([userDefaults objectForKey:targetDict]){
        newDict = ((NSDictionary *)[userDefaults objectForKey:targetDict]).mutableCopy;
        if([newDict objectForKey:key]){
            return [newDict objectForKey:key];
        }else{
            return @"Unknown";
        }
    }else{
        return @"Unknown";
    }
}

+(BOOL)prefsDict:(NSString *)targetDict containsKey:(NSString *)dictKey{
    NSMutableDictionary *newDict;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.midnightchips.SnapBack"];
    if([userDefaults objectForKey:targetDict]){
        newDict = ((NSDictionary *)[userDefaults objectForKey:targetDict]).mutableCopy;
        if([newDict objectForKey:dictKey]){
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}


@end 