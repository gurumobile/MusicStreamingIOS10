//
//  FYPlayView.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYPlayView.h"

@implementation FYPlayView

- (instancetype)init {
    if (self = [super init]) {
        UIView *backView = [[UIView alloc]init];

        [self addSubview:backView];
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(s_WindowW/3);
            make.height.mas_equalTo(49);
            
            make.right.equalTo(self).with.offset(0);
        }];

        UIImageView *backgoundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_np_normal"]];
        [self addSubview:backgoundIV];
        
        [backgoundIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(85);
            make.height.mas_equalTo(70);
            
            make.right.equalTo(self).with.offset(0);
        }];
        
        _circleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_np_loop"]];
        [backgoundIV addSubview:_circleIV];
        [_circleIV mas_makeConstraints:^(MASConstraintMaker *make){

            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(65);
            make.height.mas_equalTo(70);
            
            make.right.equalTo(self).with.offset(0);
        }];
        
        [self.playButton setImage:[UIImage imageNamed:@"tabbar_np_play"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(touchPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBackView:)];
        _circleIV.tag = 100;
        [_circleIV addGestureRecognizer:tap];
        
        backgoundIV.userInteractionEnabled = YES;
        _circleIV.userInteractionEnabled = YES;
    }
    return self;
}

- (UIImageView *)contentIV {
    if (!_contentIV) {
        _contentIV = [[UIImageView alloc] init];

        [_circleIV addSubview:_contentIV];
        [_contentIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(8, 8, 8, 8));
        }];

        [_contentIV bk_addObserverForKeyPath:@"image" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        }];

        _contentIV.layer.cornerRadius = 22;
        _contentIV.clipsToBounds = YES;
    }
    return _contentIV;
}

- (UIButton *)playButton {
    
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setHighlighted:NO];
        _playButton.tag = 101;
        [self  addSubview:_playButton];
        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.width.mas_equalTo(65);
            make.height.mas_equalTo(70);
        }];
    }
    return _playButton;
}

- (void)setPlayButtonView {
    [self.playButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.playButton setImage:nil forState:UIControlStateNormal];
}

- (void)setPauseButtonView {
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"avatar_bg"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"toolbar_play_h_p"] forState:UIControlStateNormal];
}

- (void)touchPlayButton:(UIButton *)sender {
    int tag = (int)sender.tag-100;
    [self.delegate playButtonDidClick:tag];
}

- (void)OnTapBackView:(UITapGestureRecognizer *)sender {
    UIView *backView = (UIView *)sender.view;
    int tag = (int)backView.tag-100;
    [self.delegate playButtonDidClick:tag];
}

@end
