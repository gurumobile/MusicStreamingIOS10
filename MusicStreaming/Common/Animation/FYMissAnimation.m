//
//  FYMissAnimation.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYMissAnimation.h"

@implementation FYMissAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect initFrame = [transitionContext initialFrameForViewController:fromVC];
    
    CGRect finalFrame = CGRectOffset(initFrame, 0, screenBounds.size.height);

    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    [containerView sendSubviewToBack:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.alpha = 0.8;
        fromView.frame = finalFrame;
    } completion:^(BOOL finished) {
        
        BOOL complate = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:(!complate)];
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
