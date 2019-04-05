//
//  MCCommands.m
//  SnapBack
//
//  Created by midnightchips on 4/1/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "MCCommands.h"
#import <iAmGroot/iAmGroot.h>
#import "NSTask.h"


@implementation MCCommands
+ (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    if(errors) [task setStandardError:out];
    [task launch];
    [task waitUntilExit];
    return [[NSMutableString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}
@end
