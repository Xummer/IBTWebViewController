//
//  IBTWebViewController.h
//  IBTWebViewController
//
//  Created by Xummer on 14/12/29.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IBTWebViewDelegate;
@interface IBTWebViewController : UIViewController

@property (weak, nonatomic) id<IBTWebViewDelegate> m_delegate;

- (id)initWithURL:(id)url presentModal:(BOOL)modal extraInfo:(NSDictionary *)info;

- (void)setAutoSetTitle:(BOOL)bAutoSet;

@end