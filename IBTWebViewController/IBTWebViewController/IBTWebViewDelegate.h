//
//  IBTWebViewDelegate.h
//  IBTWebViewController
//
//  Created by Xummer on 14/12/30.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IBTWebViewDelegate <NSObject>
@optional
- (void)onWebViewWillClose:(UIWebView *)webView;
- (void)onWebViewDidFinishLoad:(UIWebView *)webView;
- (void)onWebViewDidStartLoad:(UIWebView *)webView;
- (void)webViewFailToLoad:(NSError *)error;
@end
