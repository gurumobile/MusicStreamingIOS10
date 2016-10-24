//
//  FYPlayView.h
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PlayViewDelegate <NSObject>

- (void)playButtonDidClick:(NSInteger)index;

@end

@interface FYPlayView : UIView

@property (nonatomic,weak) id<PlayViewDelegate> delegate;

@property (nonatomic,strong) UIImageView *circleIV;
@property (nonatomic,strong) UIImageView *contentIV;

@property (nonatomic,strong) UIButton *playButton;

- (void) setPlayButtonView;
- (void) setPauseButtonView;

@end
