#import "SettingsVC.h"

@interface PSSpecifier (Private)
- (void)setButtonAction:(SEL)arg1;
@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    self.view.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    [[self navigationItem] setTitle:@"Settings"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Reload Apple ID stuff
    //[self updateSpecifiersForAppleID:[RPVResources getUsername]];
}

/*- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}*/

-(NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [@[[PSSpecifier preferenceSpecifierNamed:@"Some Title" target:self set:NULL get:NULL detail:Nil cell: PSTitleValueCell edit:Nil]]mutableCopy];
    }
    return _specifiers;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 4 && indexPath.row < 2) {
        static NSString *cellIdentifier = @"credits.cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = indexPath.row == 0 ? @"MidnightChips" : @"Aesign";
        cell.detailTextLabel.text = indexPath.row == 0 ? @"Developer" : @"Designer";

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://twitter.com/MidnightChip/profile_image?size=original"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithURL:url completionHandler :^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) return;

            UIImage *image = [UIImage imageWithData:data];

            if (!image) return;

            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = image;
            });
            }] resume];
        });
            cell.imageView.layer.cornerRadius = 29;
            cell.imageView.clipsToBounds = YES;

        //cell.imageView.image = [UIImage imageNamed:indexPath.row == 0 ? @"author" : @"designer"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    //} 
    /*else {
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
        // Find the type of cell this is.
        int section = (int)indexPath.section;
        int row = (int)indexPath.row;
        
        PSSpecifier *represented;
        NSArray *specifiers = [self specifiers];
        int currentSection = -1;
        int currentRow = 0;
        for (int i = 0; i < specifiers.count; i++) {
            PSSpecifier *spec = [specifiers objectAtIndex:i];
            
            // Update current sections
            if (spec.cellType == PSGroupCell) {
                currentSection++;
                currentRow = 0;
                continue;
            }
            
            // Check if this is the right specifier.
            if (currentRow == row && currentSection == section) {
                represented = spec;
                break;
            } else {
                currentRow++;
            }
        }
        
        // Tint the cell if needed!
        if (represented.cellType == PSButtonCell)
            cell.textLabel.textColor = [UIApplication sharedApplication].delegate.window.tintColor;
        
        return cell;
    }*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 4 && indexPath.row < 2 ? 60.0 : UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4 && indexPath.row < 2) {
        // handle credits tap.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self _openTwitterForUser:indexPath.row == 0 ? @"_Matchstic" : @"aesign_"];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)_openTwitterForUser:(NSString*)username {
    UIApplication *app = [UIApplication sharedApplication];
    
    NSURL *twitterapp = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:///user?screen_name=%@", username]];
    NSURL *tweetbot = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", username]];
    NSURL *twitterweb = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", username]];
    
    
    if ([app canOpenURL:twitterapp])
        [app openURL:twitterapp];
    else if ([app canOpenURL:tweetbot])
        [app openURL:tweetbot];
    else
        [app openURL:twitterweb];
}

@end
