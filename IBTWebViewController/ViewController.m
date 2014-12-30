//
//  ViewController.m
//  IBTWebViewController
//
//  Created by Xummer on 14/12/29.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import "ViewController.h"
#import "IBTWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"Open WebView" forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(onBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = (CGRect){
        .origin.x = (CGRectGetWidth(self.view.bounds) - 200) * .5f,
        .origin.y = 100,
        .size.width = 200,
        .size.height = 44
    };
    
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)onBtnTapped:(id)sender {
    IBTWebViewController *webVC = [[IBTWebViewController alloc] initWithURL:@"http://xummer26.com/" presentModal:NO extraInfo:nil];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:webVC];
    
    [self presentViewController:navCtrl animated:YES completion:NULL];
}

@end
