//From reprovision
//https://github.com/Matchstic/ReProvision/blob/7b595c699335940f68702bb204c5aa55b8b1896f/iOS/HTML/RPVWebViewController.m


#import "SettingsWebVC.h"

@interface SettingsWebVC ()

@property (nonatomic, strong) WKWebView *webView;
@property UIProgressView *progress;
@end

@implementation SettingsWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.webView.frame = self.view.bounds;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithDocument:(NSString*)document {
    self = [super init];
    
    if (self) {
        [self _configureForDocument:document];
    }
    
    return self;
}

- (void)_configureForDocument:(NSString*)document {
    NSURL *url = [NSURL fileURLWithPath:document];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.navigationDelegate = self;
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
    
    [self.view addSubview:self.webView];
}

- (void)_loadURL:(NSString*)link {
    NSURL *url = [NSURL URLWithString:link];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.navigationDelegate = self;
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:nsrequest];
    
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
    [self.view addSubview:self.webView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progress setProgress:self.webView.estimatedProgress];
        // estimatedProgress is a value from 0.0 to 1.0
        // Update your UI here accordingly
        /*if(self.webView.estimatedProgress == 1.0){
            [self.progress ]
        }*/
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// XXX: As we are going to be presented by Preferences.framework, we have to implement a couple of shims.
- (void)setRootController:(id)controller {}
- (void)setParentController:(id)controller {}
- (void)setSpecifier:(id)specifier {
    if ([specifier propertyForKey:@"key"]) {
        // Load openSourceLicenses.html

        NSString *htmlFile = [specifier propertyForKey:@"key"];
        NSString *qualifiedHTMLFile = [[NSBundle mainBundle] pathForResource:htmlFile ofType:@"html"];
        
        NSLog(@"loading for %@", qualifiedHTMLFile);
        
        [self _configureForDocument:qualifiedHTMLFile];
    }
    if ([specifier propertyForKey:@"source"]) {
        NSString *source = [specifier propertyForKey:@"source"];
        [self _loadURL:source];
    }
}

// WKWebView navigation delegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[self navigationItem] setTitle:self.webView.title];
}

@end
