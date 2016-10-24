//
//  FYNAKPlaybackIndicatorView.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYNAKPlaybackIndicatorView.h"

@implementation FYNAKPlaybackIndicatorView

+ (instancetype)sharedInstance {
    
    static FYNAKPlaybackIndicatorView *_sharedMusicIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMusicIndicator = [[FYNAKPlaybackIndicatorView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width - 50, 0, 50, 44)];
    });
    
    return _sharedMusicIndicator;
}

@end
