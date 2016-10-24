//
//  FYPlayManager.h
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TracksViewModel.h"

@protocol FYPlayManagerDelegate <NSObject>

@required
- (void)changeMusic;

@end

@interface FYPlayManager : NSObject

typedef NS_ENUM(NSInteger, FYPlayerCycle) {
    theSong = 1,
    nextSong = 2,
    isRandom = 3
};

typedef NS_ENUM(NSInteger, itemModel) {
    historyItem = 0,
    favoritelItem = 1
};

@property (nonatomic, weak) id<FYPlayManagerDelegate> delegate;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) BOOL isPlay;

+ (instancetype)sharedInstance;

- (void)releasePlayer;

- (void)playWithModel:(TracksViewModel *)tracks indexPathRow:(NSInteger ) indexPathRow;

- (void)pauseMusic;
- (void)previousMusic;
- (void)nextMusic;
- (void)nextCycle;

- (void)setFavoriteMusic;
- (void)setHistoryMusic;

- (void)delFavoriteMusic;
- (void)delMyFavoriteMusic:(NSInteger )indexPathRow;
- (void)delMyFavoriteMusicDictionary:(NSDictionary *)track;
- (void)delMyHistoryMusic:(NSDictionary *)track;
- (void)delAllHistoryMusic;
- (void)delAllFavoriteMusic;
- (void)stopMusic;

- (NSInteger )playerStatus;
- (NSInteger )FYPlayerCycle;

- (NSString *)playMusicName;
- (NSString *)playSinger;
- (NSString *)playMusicTitle;
- (NSURL *)playCoverLarge;
- (UIImage *)playCoverImage;

- (BOOL)hasBeenFavoriteMusic;
- (BOOL)havePlay;

- (NSArray *)favoriteMusicItems;
- (NSArray *)historyMusicItems;

- (BOOL)saveChanges;

- (void)playSound:(NSString *)filename;
- (void)disposeSound:(NSString *)filename;

@end
