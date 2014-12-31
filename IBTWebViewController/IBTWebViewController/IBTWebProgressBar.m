//
//  IBTWebProgressBar.m
//  IBTWebViewController
//
//  Created by Xummer on 14/12/31.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#define PROGRESS_PHASE_1        (.1f)
#define PROGRESS_PHASE_2        (.6f)
#define PROGRESS_PHASE_3        (.8f)
#define PROGRESS_PHASE_4        (.9f)

#define ANIM_DURATION_UNIT      (.2f)
#define PROGRESS_FADEOUT_DELAY  (.1f)
#define PROGRESS_FADE_DURATION  (0.27f)

#import "IBTWebProgressBar.h"

@import QuartzCore;
@interface IBTWebProgressBar ()

@end

@implementation IBTWebProgressBar

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = frame;
    rect.size.width = 0;
    self = [super initWithFrame:rect];
    if (!self) {
        return nil;
    }
    
    self.bIsFinish = YES;
    self.oriFrame = frame;
    
    UIColor *tintColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0]; // iOS7 Safari bar color
    if ([UIApplication.sharedApplication.delegate.window respondsToSelector:@selector(setTintColor:)] && UIApplication.sharedApplication.delegate.window.tintColor) {
        tintColor = UIApplication.sharedApplication.delegate.window.tintColor;
    }
    self.backgroundColor = tintColor;
    
    return self;
}

// 0 - 10% 3
- (CGFloat)durationOfPhase1 {
    return ANIM_DURATION_UNIT * 3;
}


// 10 - 60% 2
- (CGFloat)durationOfPhase2 {
    return ANIM_DURATION_UNIT * 2 * 5;
}

// 60% - 80% 3
- (CGFloat)durationOfPhase3 {
    return ANIM_DURATION_UNIT * 2 * 3;
}

// 80% - 90% 5
- (CGFloat)durationOfPhase4 {
    return ANIM_DURATION_UNIT * 5;
}

// 90% - 100%
- (void)progressing {
    // Waiting
}

- (void)updateProgress:(CGFloat)fProgress {
    
    fProgress = MIN(MAX(fProgress, 0), 1);
    
    CGRect rect = self.frame;
    rect.size.width = fProgress * CGRectGetWidth(self.oriFrame);
    self.frame = rect;
}

#pragma mark - Actions
- (void)start {
    self.alpha = 1;
    self.hidden = NO;
    self.bIsFinish = NO;
    
    __weak typeof(self)weakSelf = self;
    
    void (^animOfPhaseProcess)(BOOL) = ^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.bIsFinish = YES;
        [strongSelf progressing];
    };
    
    void (^animOfPhase4)(BOOL) = ^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:[self durationOfPhase4] delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             __strong __typeof(weakSelf)strongSelf = weakSelf;
                             [strongSelf updateProgress:PROGRESS_PHASE_4];
                         }
                         completion:animOfPhaseProcess];
    };
    
    void (^animOfPhase3)(BOOL) = ^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:[self durationOfPhase3] delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             __strong __typeof(weakSelf)strongSelf = weakSelf;
                             [strongSelf updateProgress:PROGRESS_PHASE_3];
                         }
                         completion:animOfPhase4];
    };
    
    void (^animOfPhase2)(BOOL) = ^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:[self durationOfPhase2] delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             __strong __typeof(weakSelf)strongSelf = weakSelf;
                             [strongSelf updateProgress:PROGRESS_PHASE_2];
                         }
                         completion:animOfPhase3];
    };
    
    [UIView animateWithDuration:[self durationOfPhase1] delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         __strong __typeof(weakSelf)strongSelf = weakSelf;
                         [strongSelf updateProgress:PROGRESS_PHASE_1];
                     }
                     completion:animOfPhase2];
}

- (void)end {
    if (!_bIsFinish) {
        [self.layer removeAllAnimations];
    }
    
    __weak typeof(self)weakSelf = self;
    void (^animOfDismiss)(BOOL) = ^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:PROGRESS_FADE_DURATION
                              delay:PROGRESS_FADEOUT_DELAY
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             __strong __typeof(weakSelf)strongSelf = weakSelf;
                             strongSelf.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (!finished) {
                                 return;
                             }
                             
                             __strong __typeof(weakSelf)strongSelf = weakSelf;
                             strongSelf.hidden = YES;
                             [strongSelf updateProgress:0];
                             strongSelf.bIsFinish = YES;
                         }];
    };
    
    [UIView animateWithDuration:ANIM_DURATION_UNIT delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         __strong __typeof(weakSelf)strongSelf = weakSelf;
                         [strongSelf updateProgress:1];
                     }
                     completion:animOfDismiss];
}

- (void)reset {
    if (!_bIsFinish) {
        [self.layer removeAllAnimations];
        self.bIsFinish = YES;
    }
    
    [self updateProgress:0];
}


@end
