//
//  IBTWebProgressBar.h
//  IBTWebViewController
//
//  Created by Xummer on 14/12/31.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBTWebProgressBar : UIView
@property (assign) BOOL bIsFinish;
@property (assign) CGRect oriFrame;

- (CGFloat)durationOfPhase1;
- (CGFloat)durationOfPhase2;
- (CGFloat)durationOfPhase3;
- (CGFloat)durationOfPhase4;

- (void)start;
- (void)progressing;
- (void)end;
- (void)reset;

@end
