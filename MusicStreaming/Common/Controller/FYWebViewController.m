//
//  FYWebViewController.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h> 
#import <WebKit/WebKit.h>


@interface FYWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (strong, nonatomic) WKWebView *webView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation FYWebViewController

- (void)loadView {
    self.webView = [[WKWebView alloc] init];

    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.view = self.webView;

    self.webView.allowsBackForwardNavigationGestures = YES;
}

- (void)initViews {
    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-15, [UIScreen mainScreen].bounds.size.height/2-85, 30, 30)];
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    _activityView.hidesWhenStopped = YES;
    [self.view addSubview:_activityView];
    [self.view bringSubviewToFront:_activityView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupnav];

    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    self.progressView = [[UIProgressView alloc] initWithFrame: windowFrame];
    [self.view addSubview:self.progressView];
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(UIWebView *)self.view loadRequest:req];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_webView removeObserver:self forKeyPath:@"loading" context:nil];
    [_webView removeObserver:self forKeyPath:@"title" context:nil];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}

#pragma mark -
#pragma mark - Initialize Navigation...

- (void)setupnav {
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]){
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    if (!self.webView.loading) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0.0;
        }];
    }
}

#pragma mark -
#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *schemeName = navigationAction.request.URL.scheme.lowercaseString;
    NSLog(@"Hello %@",schemeName);
    
    if ([schemeName containsString:@"bainuo"])
        decisionHandler(WKNavigationActionPolicyCancel);
    else {
        self.progressView.alpha = 1.0;
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark -
#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(void (^)())completionHandler;{
    
}

#pragma mark -
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

}

- (void)backButtonPush:(UIButton *)button {
    if (self.webView.canGoBack)
        [self.webView goBack];
}

- (void)forwardButtonPush:(UIButton *)button {
    if (self.webView.canGoForward)
        [self.webView goForward];
}

- (void)reloadButtonPush:(UIButton *)button {
    [self.webView reload];
}

- (void)stopButtonPush:(UIButton *)button {
    if (self.webView.loading)
        [self.webView stopLoading];    
}

@end
