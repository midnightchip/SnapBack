//
//  ViewController.h
//  SnapBack
//
//  Created by midnightchips on 4/1/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <UIKit/UIKit.h>
bool is_mountpoint(const char *filename);
bool ensure_directory(const char *directory, int owner, mode_t mode);

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

