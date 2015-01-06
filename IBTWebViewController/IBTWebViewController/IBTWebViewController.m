//
//  IBTWebViewController.m
//  IBTWebViewController
//
//  Created by Xummer on 14/12/29.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#define IBT_BGCOLOR             [UIColor colorWithRed:.18 green:.19  blue:.2   alpha:1]
#define IBT_ADDRESS_TEXT_COLOR  [UIColor colorWithRed:.44 green:.45  blue:.46  alpha:1]
#define IBT_PROGRESS_COLOR      [UIColor colorWithRed:0   green:.071 blue:.75  alpha:1]

#import "IBTWebViewController.h"
#import "IBTWebViewDelegate.h"
#import "IBTWebProgressBar.h"

@interface IBTWebViewController ()
<
    UIWebViewDelegate
>
{
    // address bar
    UIImageView *m_addressBarView;
    UILabel *m_addressLabel;
    
    // progress view
    IBTWebProgressBar *m_progressView;
    
    // load fail view
    UIButton *m_loadFailView;
    
    // URL
    NSURL *m_currentUrl;
    
    BOOL m_bAutoSetTitle;
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
- (id)initWithURL:(id)url presentModal:(BOOL)modal extraInfo:(NSDictionary *)info {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([url isKindOfClass:[NSString class]]) {
        self.m_initUrl = url;
    }
    else if ([url isKindOfClass:[NSURL class]]) {
        self.m_initUrl = [NSString stringWithFormat:@"%@", url];
    }
    
    m_bAutoSetTitle = YES;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = IBT_BGCOLOR;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initNavigationBarItem];
    [self initAddressBarView];
    [self initWebView];
    [self initProgressView];
    
    [self goToURL:[NSURL URLWithString:self.m_initUrl]];
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
    
    m_loadFailView = nil;
    m_currentUrl = nil;
}

#pragma mark - Setter
- (void)setAutoSetTitle:(BOOL)bAutoSet {
    m_bAutoSetTitle = bAutoSet;
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

- (void)updateDisplayTitle:(NSString *)nsTitle {
    self.title = nsTitle;
}

#pragma mark - Address Bar
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

#pragma mark - Load Fail View
- (void)showLoadFailView:(NSString *)errorDesc {
    if (!m_loadFailView) {
        m_loadFailView = [UIButton buttonWithType:UIButtonTypeCustom];
        m_loadFailView.frame = _m_webView.frame;
        [m_loadFailView setImage:[UIImage imageNamed:@"WebView_LoadFail_Refresh_Icon"]
                        forState:UIControlStateNormal];
        [m_loadFailView setTitleColor:[UIColor lightGrayColor]
                             forState:UIControlStateNormal];
        m_loadFailView.titleLabel.font = [UIFont systemFontOfSize:12];
        [m_loadFailView addTarget:self
                           action:@selector(onClickFailView:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:m_loadFailView];
    }
    
    [m_loadFailView setTitle:errorDesc forState:UIControlStateNormal];
    
    // layout button subviews
    CGFloat fTotalH = CGRectGetHeight(m_loadFailView.imageView.frame) + CGRectGetHeight(m_loadFailView.titleLabel.frame);
    
    CGFloat fTopDelta = (CGRectGetHeight(m_loadFailView.bounds) - fTotalH) * .4;
    
    m_loadFailView.imageEdgeInsets =
    UIEdgeInsetsMake(- (fTotalH - CGRectGetHeight(m_loadFailView.imageView.frame)) - fTopDelta, 0, 0, - CGRectGetWidth(m_loadFailView.titleLabel.frame));
    
    m_loadFailView.titleEdgeInsets =
    UIEdgeInsetsMake(- fTopDelta, - CGRectGetWidth(m_loadFailView.imageView.frame), -(fTotalH - CGRectGetHeight(m_loadFailView.titleLabel.frame)), 0);
    
    [self.view bringSubviewToFront:m_loadFailView];
    m_loadFailView.hidden = NO;
}

- (void)hideLoadFailView {
    m_loadFailView.hidden = YES;
}

- (void)onClickFailView:(__unused id)sender {
    [self hideLoadFailView];
    [self goToURL:m_currentUrl];
}

#pragma mark - Progess Bar
- (void)initProgressView {
    if (!m_progressView) {
        m_progressView = [[IBTWebProgressBar alloc] initWithFrame:(CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width = CGRectGetWidth(self.view.bounds),
            .size.height = 3
        }];
//        m_progressView.backgroundColor = IBT_PROGRESS_COLOR;
        
        [self hideProgressView];
        [self.view addSubview:m_progressView];
    }
}

- (void)hideProgressView {
    m_progressView.hidden = YES;
}

- (void)setProgress100Percent {
    [m_progressView end];
}

- (void)updateProgressView {
    
}

- (void)startProgressAnimation {
    if (m_progressView.bIsFinish) {
        [m_progressView start];
    }
}

- (void)resetProgress {
    [m_progressView reset];
}

#pragma mark - Navigation Bar
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

- (void)updateToolbarHistoryButtons {
    NSUInteger uiLeftItemCount = [self.navigationItem.leftBarButtonItems count];
    
    switch (uiLeftItemCount) {
        case 0:
        {
            UIBarButtonItem *backItem =
            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(onBackAction:)];
            UIBarButtonItem *closeItem =
            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(onColseAction:)];
            
            self.navigationItem.leftBarButtonItems = @[ backItem, closeItem ];
        }
            break;
        case 1:
        {
            UIBarButtonItem *closeItem =
            [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(onColseAction:)];
            NSArray *arrTmp = @[ self.navigationItem.leftBarButtonItem, closeItem ];
            
            self.navigationItem.leftBarButtonItems = arrTmp;
        }
            break;
            
        default:
            break;
    }
}

- (void)onColseAction:(__unused id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

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
- (BOOL)isTopLevelNavigation:(NSURLRequest *)req {
    return [req.URL isEqual:req.mainDocumentURL];
}

- (void)goToURL:(NSURL *)url {
    if (url) {
        [self.m_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else {
        // ERROR
    }
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
    m_currentUrl = request.mainDocumentURL;
    m_addressLabel.text = [self getAddressBarHostText:m_currentUrl];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([_m_delegate respondsToSelector:@selector(onWebViewDidStartLoad:)]) {
        [_m_delegate onWebViewDidStartLoad:webView];
    }
    
    if ([self isTopLevelNavigation:webView.request]) {
        [self startProgressAnimation];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([_m_delegate respondsToSelector:@selector(onWebViewDidFinishLoad:)]) {
        [_m_delegate onWebViewDidFinishLoad:webView];
    }
    
    if ([self isTopLevelNavigation:webView.request]) {
        m_currentUrl = webView.request.mainDocumentURL;
        m_addressLabel.text = [self getAddressBarHostText:m_currentUrl];
        
        [self setProgress100Percent];
        
        if ([_m_webView canGoBack]) {
            [self updateToolbarHistoryButtons];
        }
        
        // get title
        if (m_bAutoSetTitle) {
            NSString *nsTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            [self updateDisplayTitle:nsTitle];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([_m_delegate respondsToSelector:@selector(webViewFailToLoad:)]) {
        [_m_delegate webViewFailToLoad:error];
    }
    
    if ([error code] != NSURLErrorCancelled &&
        [self isTopLevelNavigation:webView.request])
    {
        [self hideLoadFailView];
        [self resetProgress];
        [self showLoadFailView:[error localizedDescription]];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
