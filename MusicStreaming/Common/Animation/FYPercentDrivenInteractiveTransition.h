//
//  FYPercentDrivenInteractiveTransition.h
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, assign) BOOL isInteracting;
@property (nonatomic, assign) BOOL shouldComplete;

- (instancetype)init:(UIViewController *)vc;

@end
