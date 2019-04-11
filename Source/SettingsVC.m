#import "SettingsVC.h"
#import "UIImage+TextRendering.h"
#import "UIImage+Scale.h"

@interface PSSpecifier (Private)
- (void)setButtonAction:(SEL)arg1;
@end

@interface NSArray (SO) 
+ (NSArray*)arrayByRepeatingObject:(id)obj times:(NSUInteger)t;
@end

@implementation NSArray (SO)
+ (NSArray*)arrayByRepeatingObject:(id)obj times:(NSUInteger)t {
    id arr[t];
    for(NSUInteger i=0; i<t; ++i) 
        arr[i] = obj;
    return [NSArray arrayWithObjects:arr count:t];    
}
@end


@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    //}
    
    self.view.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    [[self navigationItem] setTitle:@"Info"];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    PSSpecifier *group1 = [PSSpecifier groupSpecifierWithName:@"Developer"];
    [array addObject:group1];
    
    self.twitter = [PSSpecifier preferenceSpecifierNamed:@"MidnightTwitter" target:self set:nil get:nil detail:nil cell:PSLinkCell edit:nil];
    
    [array addObject:self.twitter];
    
    PSSpecifier *Email = [PSSpecifier preferenceSpecifierNamed:@"Email" target:self set:nil get:nil detail:nil cell:PSSwitchCell edit:nil];
    [array addObject:Email];

    PSSpecifier *Paypal = [PSSpecifier preferenceSpecifierNamed:@"Donate" target:self set:nil get:nil detail:NSClassFromString(@"SettingsWebVC") cell:PSLinkCell edit:nil];
    [Paypal setProperty:@"https://www.paypal.me/midnighttweaks" forKey:@"source"];
    UIImage *paypalImg = [UIImage imageFromString:@"💲"];
    [Paypal setProperty:paypalImg forKey:@"iconImage"];
    [array addObject:Paypal];

    PSSpecifier *group2 = [PSSpecifier groupSpecifierWithName:@"Support"];
    [array addObject:group2];
    
    PSSpecifier *Support = [PSSpecifier preferenceSpecifierNamed:@"Discord" target:self set:nil get:nil detail:nil cell:PSSwitchCell edit:nil];
    [array addObjectsFromArray:[NSArray arrayByRepeatingObject:Support times:3]];

    PSSpecifier *group3 = [PSSpecifier groupSpecifierWithName:@"Special Thanks"];
    [array addObject:group3];

    PSSpecifier *Thanks = [PSSpecifier preferenceSpecifierNamed:@"User" target:self set:nil get:nil detail:nil cell:PSSwitchCell edit:nil];
    [array addObjectsFromArray:[NSArray arrayByRepeatingObject:Thanks times:5]];

    PSSpecifier *group4 = [PSSpecifier groupSpecifierWithName:@"Source and License"];
    [array addObject:group4];

    PSSpecifier *Source = [PSSpecifier preferenceSpecifierNamed:@"Source" target:self set:nil get:nil detail:NSClassFromString(@"SettingsWebVC") cell:PSLinkCell edit:nil];
    [Source setProperty:@"https://github.com/midnightchip/SnapBack" forKey:@"source"];
    UIImage *sourceImg = [UIImage imageFromString:@"👨‍💻"];
    [Source setProperty:sourceImg forKey:@"iconImage"];
    [array addObject:Source];

    /*PSSpecifier *License = [PSSpecifier preferenceSpecifierNamed:@"License" target:self set:nil get:nil detail:NSClassFromString(@"SettingsWebVC") cell:PSLinkCell edit:nil];
    [License setProperty:@"License" forKey:@"key"];
    [array addObject:License];*/

    PSSpecifier *thirdPartyLicense = [PSSpecifier preferenceSpecifierNamed:@"Licenses" target:self set:nil get:nil detail:NSClassFromString(@"SettingsWebVC") cell:PSLinkCell edit:nil];
    [thirdPartyLicense setProperty:@"openSourceLicenses" forKey:@"key"];
    UIImage *licenseImg = [UIImage imageFromString:@"⚖️"];
    [thirdPartyLicense setProperty:licenseImg forKey:@"iconImage"];
    [array addObject:thirdPartyLicense];

    return array;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < 2) {
        if(indexPath.row == 0){
            static NSString *cellIdentifier = @"credits.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            //PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];

            cell.textLabel.text = @"MidnightChips";
            cell.detailTextLabel.text = @"Developer";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;
            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/MidnightChip/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
           //cell.imageView.image = self.midnightIcon;
        
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
            UIImage *emailImg = [UIImage imageFromString:@"📧"];
            cell.imageView.image = emailImg;
        
            //cell.imageView.layer.cornerRadius = 14.5;
            //cell.imageView.clipsToBounds = YES;

            //cell.imageView.image = self.midnightIcon;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
    }
    if (indexPath.section == 1 && indexPath.row < 3) { 
        if(indexPath.row == 0){
            static NSString *cellIdentifier = @"jbDiscord.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Join r/JB Discord";
            cell.detailTextLabel.text = @"Go to the #genius-bar for Support";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            cell.imageView.image = [UIImage imageNamed:@"Discord.png"];//[[UIImage imageNamed:@"Discord.png"] scaleToSize:CGSizeMake(40.0f, 40.0f)];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            //cell.imageView.image = self.midnightIcon;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 1){
            static NSString *cellIdentifier = @"idhDiscord.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Join iDH Discord";
            cell.detailTextLabel.text = @"Feel free to ping me.";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = [UIImage imageNamed:@"Discord.png"];//[[UIImage imageNamed:@"Discord.png"] scaleToSize:CGSizeMake(40.0f, 40.0f)];
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 2){
            static NSString *cellIdentifier = @"reddit.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Visit /r/Jailbreak";
            cell.detailTextLabel.text = @"Ask questions here as well";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = [UIImage imageNamed:@"Reddit.png"];//[[UIImage imageNamed:@"Discord.png"] scaleToSize:CGSizeMake(40.0f, 40.0f)];
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
    }
    if (indexPath.section == 2 && indexPath.row < 5) {
        if(indexPath.row == 0){
            static NSString *cellIdentifier = @"creater.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"CreatureSurvive";
            cell.detailTextLabel.text = @"Root Framework, pointed out my oversights.";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = self.creature;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 1){
            static NSString *cellIdentifier = @"bingner.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Sbingner";
            cell.detailTextLabel.text = @"Created libSnappy";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = self.bingner;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 2){
            static NSString *cellIdentifier = @"pwn.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Pwn20wnd";
            cell.detailTextLabel.text = @"Guidance";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = self.pwn;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 3){
            static NSString *cellIdentifier = @"samg.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Samg_is_a_Ninja";
            cell.detailTextLabel.text = @"Apfs and helped me work through problems";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = self.sam;
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 4){
            static NSString *cellIdentifier = @"chila.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Chilaxan";
            cell.detailTextLabel.text = @"Tester";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            cell.imageView.image = self.chil;
        
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
    if (indexPath.section == 1 && indexPath.row < 3) {
        if(indexPath.row == 0){
            // handle credits tap.
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/jb"]];
        }
        if(indexPath.row == 1){
            // handle credits tap.
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/ffYejET"]];
        }
        if(indexPath.row == 2){
            // handle credits tap.
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIApplication *app = [UIApplication sharedApplication];
    
            NSURL *apollo = [NSURL URLWithString:@"apollo://reddit.com/r/jailbreak"];
    
    
            if ([app canOpenURL:apollo])
                [app openURL:apollo];
            else
                [app openURL:[NSURL URLWithString:@"https://www.reddit.com/r/jailbreak/"]];
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/r/jailbreak/"]];
        }

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

-(void)getImageFromURL:(NSString *)link withCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)index{
    //https://twitter.com/MidnightChip/profile_image?size=original
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:link];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithURL:url completionHandler :^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) return;

            UIImage *image = [UIImage imageWithData:data];
            image = [image scaleToSize:CGSizeMake(40.0f, 40.0f)];

            if (!image) return;

            dispatch_async(dispatch_get_main_queue(), ^{
                //self.midnightIcon = image;
                [[cell imageView] setImage:image];
                //[cell setNeedsLayout];
                //NSArray *index = @[[self.tableView indexPathForCell:cell]];
                NSLog(@"%@", index);
                //[self.tableView reloadRowsAtIndexPaths:index withRowAnimation:UITableViewRowAnimationNone];
                //[self reloadSpecifier:self.twitter];
                [self reloadSpecifierAtIndex:index.row animated:YES];
                
                
            });
            }] resume];
        });
}

@end
