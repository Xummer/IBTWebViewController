//
//  IBTWebViewController.m
//  IBTWebViewController
//
//  Created by Xummer on 14/12/29.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#define IBT_BGCOLOR             [UIColor colorWithRed:.18 green:.19 blue:.2 alpha:1]
#define IBT_ADDRESS_TEXT_COLOR  [UIColor colorWithRed:.44 green:.45 blue:.46 alpha:1]

#import "IBTWebViewController.h"
#import "IBTWebViewDelegate.h"

@interface IBTWebViewController ()
<
    UIWebViewDelegate
>
{
    UIImageView *m_addressBarView;
    UILabel *m_addressLabel;
}
@property (strong, nonatomic) UIWebView *m_webView;
@property (strong, nonatomic) NSString *m_initUrl;
@property (strong, nonatomic) NSMutableDictionary *m_extraInfo;

- (void)initWebView;
- (void)initAddressBarView;
- (void)removeAddressBar;
- (void)initNavigationBarItem;

@end

@implementation IBTWebViewController

#pragma mark - Life Cycle
- (id)initWithURL:(NSString *)urlStr presentModal:(BOOL)modal extraInfo:(NSDictionary *)info; {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.m_initUrl = urlStr;
    
    self.m_extraInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = IBT_BGCOLOR;
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initNavigationBarItem];
    [self initAddressBarView];
    [self initWebView];
    
    [self goToURL:self.m_initUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.m_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.m_webView.delegate = nil;
    
    m_addressBarView = nil;
    m_addressLabel = nil;
}

#pragma mark - Private Method
- (void)initWebView {
    self.m_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.m_webView.backgroundColor = [UIColor clearColor];
    self.m_webView.delegate = self;
    self.m_webView.scalesPageToFit = YES;
    self.m_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.m_webView];
}

- (NSString *)getAddressBarHostText:(NSURL *)url {
    if ([url.host length] > 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Provided by %@", nil), url.host];
    }
    else {
        return @"";
    }
}

- (void)initAddressBarView {
    if (!m_addressBarView) {
        m_addressBarView = [[UIImageView alloc] init];
        m_addressBarView.frame = (CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width = CGRectGetWidth(self.view.bounds),
            .size.height = 40
        };
        
        m_addressLabel = [[UILabel alloc] init];
        m_addressLabel.frame = CGRectInset(m_addressBarView.bounds, 10, 6);
        m_addressLabel.textColor = [UIColor clearColor];
        m_addressLabel.textAlignment = NSTextAlignmentCenter;
        m_addressLabel.textColor = IBT_ADDRESS_TEXT_COLOR;
        m_addressLabel.font = [UIFont systemFontOfSize:12];
        
        [m_addressBarView addSubview:m_addressLabel];
    }
    
    [self.view addSubview:m_addressBarView];
}

- (void)removeAddressBar {
    [m_addressBarView removeFromSuperview];
    m_addressBarView = nil;
    m_addressLabel = nil;
}

- (void)initNavigationBarItem {
    UIBarButtonItem *backItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onBackAction:)];
    
    UIBarButtonItem *moreItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"More", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onMoreAction:)];
    
    self.navigationItem.leftBarButtonItems = @[ backItem ];
    self.navigationItem.rightBarButtonItems = @[ moreItem ];
    
}

#pragma mark - Actions
- (void)onBackAction:(__unused id)sender {
    if ([_m_webView canGoBack]) {
        [self goBack];
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)onMoreAction:(__unused id)sender {
    
}

#pragma mark - WebView Action
- (void)goToURL:(NSString *)url {
    [self.m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)goForward {
    [self.m_webView goForward];
}

- (void)goBack {
    [self.m_webView goBack];
}

- (void)stop {
    [self.m_webView stopLoading];
}

- (void)reload {
    [self.m_webView reload];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    m_addressLabel.text = [self getAddressBarHostText:request.URL];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([_m_delegate respondsToSelector:@selector(onWebViewDidStartLoad:)]) {
        [_m_delegate onWebViewDidStartLoad:webView];
    }
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([_m_delegate respondsToSelector:@selector(onWebViewDidFinishLoad:)]) {
        [_m_delegate onWebViewDidFinishLoad:webView];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([_m_delegate respondsToSelector:@selector(webViewFailToLoad:)]) {
        [_m_delegate webViewFailToLoad:error];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
