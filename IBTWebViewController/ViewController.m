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
@property (strong, nonatomic) UITextField *textF;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view.window endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.textF = [[UITextField alloc] initWithFrame:(CGRect){
        .origin.x = 10,
        .origin.y = 20,
        .size.width = CGRectGetWidth(self.view.bounds) - 10 * 2,
        .size.height = 44
    }];
    
    self.textF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textF.text = @"http://xummer26.com/";
    self.textF.backgroundColor = [UIColor colorWithWhite:246.0f/255.0f alpha:1];
    
    [self.view addSubview:self.textF];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor colorWithRed:11.0f/255.0f green:179.0f/255.0f blue:252.0f/255.0f alpha:1];
    [btn setTitle:@"Open WebView" forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(onBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = (CGRect){
        .origin.x = (CGRectGetWidth(self.view.bounds) - 200) * .5f,
        .origin.y = CGRectGetMaxY(self.textF.frame) + 40,
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
    IBTWebViewController *webVC = [[IBTWebViewController alloc] initWithURL:self.textF.text presentModal:NO extraInfo:nil];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:webVC];
    
    [self presentViewController:navCtrl animated:YES completion:NULL];
}

@end
