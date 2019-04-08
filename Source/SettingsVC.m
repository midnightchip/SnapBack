#import "SettingsVC.h"

@interface PSSpecifier (Private)
- (void)setButtonAction:(SEL)arg1;
@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    //}
    
    self.view.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    [[self navigationItem] setTitle:@"Info"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://twitter.com/MidnightChip/profile_image?size=original"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithURL:url completionHandler :^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) return;

            UIImage *image = [UIImage imageWithData:data];

            if (!image) return;

            dispatch_async(dispatch_get_main_queue(), ^{
                self.midnightIcon = image;
                //[self reloadSpecifier:self.twitter];
                [self reloadSpecifierAtIndex:0 animated:YES];
            });
            }] resume];
        });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Reload Apple ID stuff
    //[self updateSpecifiersForAppleID:[RPVResources getUsername]];
}

-(NSMutableArray *)specifiers {
    if (!_specifiers) {
        //_specifiers = [@[[PSSpecifier preferenceSpecifierNamed:@"MindnightCell" target:self set:NULL get:NULL detail:Nil cell: PSTitleValueCell edit:Nil]]mutableCopy];
        NSMutableArray *newSpecs = [NSMutableArray array];
        [newSpecs addObjectsFromArray:[self _makeSpecifiers]];
        _specifiers = newSpecs;
    }
    return _specifiers;
}

- (NSArray*)_makeSpecifiers{
    NSMutableArray *array = [NSMutableArray array];
    PSSpecifier *group1 = [PSSpecifier groupSpecifierWithName:@"Support"];
    [array addObject:group1];
    
    self.twitter = [PSSpecifier preferenceSpecifierNamed:@"MidnightTwitter" target:self set:nil get:nil detail:nil cell:PSSwitchCell edit:nil];
    
    [array addObject:self.twitter];
    
    PSSpecifier *Email = [PSSpecifier preferenceSpecifierNamed:@"Email" target:self set:nil get:nil detail:nil cell:PSSwitchCell edit:nil];
    
    [array addObject:Email];

    PSSpecifier *group2 = [PSSpecifier groupSpecifierWithName:@"Source and License"];
    [array addObject:group2];

    PSSpecifier *Source = [PSSpecifier preferenceSpecifierNamed:@"Source" target:self set:nil get:nil detail:nil cell:PSSwitchCell edit:nil];
    [array addObject:Source];

    /*PSSpecifier *License = [PSSpecifier preferenceSpecifierNamed:@"License" target:self set:nil get:nil detail:NSClassFromString(@"SettingsWebVC") cell:PSLinkCell edit:nil];
    [License setProperty:@"License" forKey:@"key"];
    [array addObject:License];*/

    PSSpecifier *thirdPartyLicense = [PSSpecifier preferenceSpecifierNamed:@"Licenses" target:self set:nil get:nil detail:NSClassFromString(@"SettingsWebVC") cell:PSLinkCell edit:nil];
    [thirdPartyLicense setProperty:@"openSourceLicenses" forKey:@"key"];
    [array addObject:thirdPartyLicense];

    return array;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            static NSString *cellIdentifier = @"credits.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"MidnightChips";
            cell.detailTextLabel.text = @"Developer";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 14.5;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = self.midnightIcon;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 1){
            static NSString *cellIdentifier = @"email.cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Email Me";
            cell.detailTextLabel.text = @"midnightchips@gmail.com";
            //cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            //cell.imageView.layer.cornerRadius = 14.5;
            //cell.imageView.clipsToBounds = YES;

            //cell.imageView.image = self.midnightIcon;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        
    } 
    else {
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 && indexPath.row == 0 ? 60.0 : UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        // handle credits tap.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self _openTwitterForUser:@"MidnightChip"];
    } 
    if (indexPath.section == 0 && indexPath.row == 1) {
        // handle credits tap.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString *recipients = @"mailto:midnightchips@gmail.com?subject=SnapBack";
        NSString *body = @"&body=Enter Your Info :)";

        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    } 
    else {
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
