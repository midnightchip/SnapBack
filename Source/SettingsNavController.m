#import "SettingsNavController.h"
#import "SettingsVC.h"

@interface UINavigationBar (iOS11)
@property (nonatomic, readwrite) BOOL prefersLargeTitles;
@end

@interface SettingsNavController ()

@end

@implementation SettingsNavController

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {

        if (@available(iOS 11.0, *)) {
            self.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
        }
        
        // Create root controller
        SettingsVC *table = [[SettingsVC alloc] init];
        [self setViewControllers:@[table] animated:NO];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self.navigationItem setTitle:@"About"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
