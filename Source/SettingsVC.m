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

    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    self.view.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    [[self navigationItem] setTitle:@"Info"];
    self.iconUrls = [NSMutableArray new];
    
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
    
    PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"MidnightTwitter" target:self set:nil get:nil detail:nil cell:PSLinkCell edit:nil];
    
    [array addObject:twitter];
    
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
    [array addObjectsFromArray:[NSArray arrayByRepeatingObject:Thanks times:9]];

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
    if (indexPath.section == 2 && indexPath.row < 9) {
        if(indexPath.row == 0){
            static NSString *cellIdentifier = @"creature.cell";
        
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

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/CreatureSurvive/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 1){
            static NSString *cellIdentifier = @"bingner.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Sam Bingner";
            cell.detailTextLabel.text = @"Created libSnappy";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/sbingner/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
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

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/pwn20wnd/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
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
            cell.detailTextLabel.text = @"Worked through problems with me.";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://avatars0.githubusercontent.com/u/25284532?s=400&v=4" withCell:cell indexPath:indexPath];
 
            }
        
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

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/chilaxan1/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 5){
            static NSString *cellIdentifier = @"pin.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"PINPAL";
            cell.detailTextLabel.text = @"Made the Amazing artwork";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/TPinpal/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 6){
            static NSString *cellIdentifier = @"casle.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"the_casle";
            cell.detailTextLabel.text = @"Good Friend";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/the_casle/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 7){
            static NSString *cellIdentifier = @"ez.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Easy_Z";
            cell.detailTextLabel.text = @"Support";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/_Easy_Z_/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
            return cell;
        }
        if(indexPath.row == 8){
            static NSString *cellIdentifier = @"tony.cell";
        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
        
            cell.textLabel.text = @"Tony";
            cell.detailTextLabel.text = @"Ideas";
            cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x , cell.imageView.frame.origin.y,  40, 40);

            //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://twitter.com/MidnightChip/profile_image?size=original"]];
            //cell.imageView.image = [UIImage imageWithData: data];
        
            cell.imageView.layer.cornerRadius = 10.0;
            cell.imageView.clipsToBounds = YES;

            if(!cell.imageView.image){
                [self getImageFromURL:@"https://twitter.com/Tonerk7/profile_image?size=original" withCell:cell indexPath:indexPath];
 
            }
        
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
        if (represented.cellType == PSButtonCell){
            cell.textLabel.textColor = [UIApplication sharedApplication].delegate.window.tintColor;
        }
        return cell;
    }
    return nil;
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
        email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email] options:@{} completionHandler:nil];
    }
    if (indexPath.section == 1 && indexPath.row < 3) {
        if(indexPath.row == 0){
            // handle credits tap.
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/jb"] options:@{} completionHandler:nil];
        }
        if(indexPath.row == 1){
            // handle credits tap.
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/ffYejET"] options:@{} completionHandler:nil];
        }
        if(indexPath.row == 2){
            // handle credits tap.
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIApplication *app = [UIApplication sharedApplication];
    
            NSURL *apollo = [NSURL URLWithString:@"apollo://reddit.com/r/jailbreak"];
    
    
            if ([app canOpenURL:apollo])
                [app openURL:apollo options:@{} completionHandler:nil];
            else
                [app openURL:[NSURL URLWithString:@"https://www.reddit.com/r/jailbreak/"] options:@{} completionHandler:nil];
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/r/jailbreak/"]];
        }

    }
    if (indexPath.section == 2 && indexPath.row < 9) {
        if(indexPath.row == 0){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"CreatureSurvive"];
        }
        if(indexPath.row == 1){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"sbingner"];
        }
        if(indexPath.row == 2){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"Pwn20wnd"];
        }   
        if(indexPath.row == 3){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIApplication *app = [UIApplication sharedApplication];
            [app openURL:[NSURL URLWithString:@"https://github.com/samgisaninja"] options:@{} completionHandler:nil];
        }
        if(indexPath.row == 4){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"chilaxan1"];
        }
        if(indexPath.row == 5){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"TPinpal"];
        }
        if(indexPath.row == 6){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"the_casle"];
        }
        if(indexPath.row == 7){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"_Easy_Z_"];
        }
        if(indexPath.row == 8){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self _openTwitterForUser:@"Tonerk7"];
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
        [app openURL:twitterapp options:@{} completionHandler:nil];
    else if ([app canOpenURL:tweetbot])
        [app openURL:tweetbot options:@{} completionHandler:nil];
    else
        [app openURL:twitterweb options:@{} completionHandler:nil];
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
                if(![self.iconUrls containsObject:link]){
                    [self.iconUrls addObject:link];
                    [cell setNeedsLayout];
                    
                }
                
                
                
            });
            }] resume];
        });
}

@end
