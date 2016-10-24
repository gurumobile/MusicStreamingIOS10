//
//  FYPlayManager.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYPlayManager.h"
#import "TracksViewModel.h"
#import <MediaPlayer/MediaPlayer.h>

#import "FYfavoriteItem.h"
#import "FYhistoryItem.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@interface FYPlayManager ()

@property (nonatomic) FYPlayerCycle  cycle;

@property (nonatomic, strong) AVPlayerItem   *currentPlayerItem;
@property (nonatomic, strong) NSMutableArray *favoriteMusic;
@property (nonatomic, strong) NSMutableArray *historyMusic;

@property (nonatomic) BOOL isLocalVideo;
@property (nonatomic) BOOL isFinishLoad;

@property (nonatomic, strong) NSMutableDictionary *soundIDs;

@property (nonatomic,strong) TracksViewModel *tracksVM;
@property (nonatomic,assign) NSInteger indexPathRow;
@property (nonatomic,assign) NSInteger rowNumber;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

static FYPlayManager *_instance = nil;

NSString *itemArchivePath() {
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [pathList[0] stringByAppendingPathComponent:@"guluMusic.sqlite"];//
}

@implementation FYPlayManager {
    id _timeObserve;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _soundIDs = [NSMutableDictionary dictionary];
        
        NSDictionary* defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        
        if (defaults[@"cycle"])
            NSInteger cycleDefaults = [defaults[@"cycle"] integerValue];
            _cycle = cycleDefaults;
        else
            _cycle = theSong;
        
        [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        
        NSURL *storeURL = [NSURL fileURLWithPath:itemArchivePath()];
        NSError *error = nil;
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:nil
                                                               error:&error]){
            
            @throw [NSException exceptionWithName:@"OpenFailure"
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
        
        [self loadAllItems];
    }
    return self;
}

#pragma mark -
#pragma mark - core Data

- (void)loadAllItems {
    if (!self.favoriteMusic) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"FYfavoriteItem" inManagedObjectContext:_managedObjectContext];
        request.entity = e;
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        request.sortDescriptors = @[sd];
        
        NSError *error;
        NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
        
        if (!result)
            [NSException raise:@"Fetch failed" format:@"Reason:%@",[error localizedDescription]];
        self.favoriteMusic = [[NSMutableArray alloc] initWithArray:result];
    }
    
    if (!self.historyMusic) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"FYhistoryItem" inManagedObjectContext:_managedObjectContext];
        request.entity = e;
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:NO];
        request.sortDescriptors = @[sd];
        
        NSError *error;
       
        NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
        
        if (!result)
            [NSException raise:@"Fetch failed" format:@"Reason:%@",[error localizedDescription]];
        
        self.historyMusic = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (void)addTrack:(NSDictionary *)track itemModel:(itemModel )itemModel {
    if (itemModel == historyItem) {
        double order;
        if ([self.historyMusic count] == 0) {
            order = 1.0;
        } else {
            FYhistoryItem *item = self.historyMusic[0];
            order = item.orderingValue + 1.0;
        }
        
        FYhistoryItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"FYhistoryItem" inManagedObjectContext:self.managedObjectContext];

        if (s_isPhone4 || s_isPhone5) {
            NSLog(@"Default Save 64bit");
        } else {
            item.albumId = [track[@"albumId"] integerValue];
            item.albumImage = track[@"albumImage"];
            item.albumTitle = [self.tracksVM.albumTitle copy];
            item.comments = [track[@"comments"] integerValue];
            item.coverLarge = track[@"coverLarge"];
            item.coverMiddle = track[@"coverMiddle"];
            item.coverSmall = track[@"coverSmall"];
            item.createdAt = [track[@"createdAt"] integerValue];
            item.downloadAacSize = [track[@"downloadAacSize"] integerValue];
            item.downloadAacUrl = track[@"downloadAacUrl"];
            item.downloadSize = [track[@"downloadSize"] integerValue];
            item.downloadUrl = track[@"downloadUrl"];
            item.duration = [track[@"duration"] floatValue];
            item.isPublic = [track[@"isPublic"] boolValue];
            item.likes = [track[@"likes"] integerValue];
            item.nickname = track[@"nickname"];
            item.opType = [track[@"opType"] integerValue];
            item.orderNum = [track[@"orderNum"] integerValue];
            item.playPathAacv164 = track[@"playPathAacv164"];
            item.playPathAacv224 = track[@"playPathAacv224"];
            item.playUrl32 = track[@"playUrl32"];
            item.playUrl64 = track[@"playUrl64"];
            item.playtimes = [track[@"playtimes"] integerValue];
            item.processState = [track[@"processState"] integerValue];
            item.shares = [track[@"shares"] integerValue];
            item.smallLogo = track[@"smallLogo"];
            item.status = [track[@"status"] integerValue];
            item.title = track[@"title"];
            item.trackId = [track[@"trackId"] integerValue];
            item.uid = [track[@"uid"] integerValue];
            item.userSource = [track[@"userSource"] integerValue];
            item.musicRow = _indexPathRow;
            
            item.orderingValue = order;
        }

        [self.historyMusic addObject:item];
        
        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"trackId == %li",[track[@"trackId"] integerValue]];
        
        NSArray *items = [self.historyMusic filteredArrayUsingPredicate:thePredicate];
        if (items.count > 1) {
            [self.managedObjectContext deleteObject:items[0]];
            [self.historyMusic removeObjectIdenticalTo:items[0]];
        } else {
            NSLog(@"historyMusic one");
        }
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:NO];
        [self.historyMusic sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    }
    if (itemModel == favoritelItem) {
        double order;
        if ([self.favoriteMusic count] == 0) {
            order = 1.0;
        } else {
            FYfavoriteItem *item = [self.favoriteMusic lastObject];
            order = item.orderingValue +1.0;
        }
        FYfavoriteItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"FYfavoriteItem" inManagedObjectContext:self.managedObjectContext];
        
        if (s_isPhone5 || s_isPhone4) {
            NSLog(@"Default Save 64bit");
        } else {
            item.albumId = [track[@"albumId"] integerValue];
            item.albumImage = track[@"albumImage"];
            item.albumTitle = track[@"albumTitle"];
            item.comments = [track[@"comments"] integerValue];
            item.coverLarge = track[@"coverLarge"];
            item.coverMiddle = track[@"coverMiddle"];
            item.coverSmall = track[@"coverSmall"];
            item.createdAt = [track[@"createdAt"] integerValue];
            item.downloadAacSize = [track[@"downloadAacSize"] integerValue];
            item.downloadAacUrl = track[@"downloadAacUrl"];
            item.downloadSize = [track[@"downloadSize"] integerValue];
            item.downloadUrl = track[@"downloadUrl"];
            item.duration = [track[@"duration"] floatValue];
            item.isPublic = [track[@"isPublic"] boolValue];
            item.likes = [track[@"likes"] integerValue];
            item.nickname = track[@"nickname"];
            item.opType = [track[@"opType"] integerValue];
            item.orderNum = [track[@"orderNum"] integerValue];
            item.playPathAacv164 = track[@"playPathAacv164"];
            item.playPathAacv224 = track[@"playPathAacv224"];
            item.playUrl32 = track[@"playUrl32"];
            item.playUrl64 = track[@"playUrl64"];
            item.playtimes = [track[@"playtimes"] integerValue];
            item.processState = [track[@"processState"] integerValue];
            item.shares = [track[@"shares"] integerValue];
            item.smallLogo = track[@"smallLogo"];
            item.status = [track[@"status"] integerValue];
            item.title = track[@"title"];
            item.trackId = [track[@"trackId"] integerValue];
            item.uid = [track[@"uid"] integerValue];
            item.userSource = [track[@"userSource"] integerValue];
            
            item.orderingValue = order;
        }

        [self.favoriteMusic addObject:item];
    }
}

- (void)removeTrack:(NSDictionary *)track itemModel:(itemModel )itemModel {
    if (itemModel == historyItem) {
        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"trackId == %li",[track[@"trackId"] integerValue]];
        
        NSArray *items = [self.historyMusic filteredArrayUsingPredicate:thePredicate];
        if (items.count == 1) {
            [self.managedObjectContext deleteObject:items[0]];
            [self.historyMusic removeObjectIdenticalTo:items[0]];
        } else {
            NSLog(@"historyMusic error");
        }
    }
    if (itemModel == favoritelItem) {
        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"trackId == %li",[track[@"trackId"] integerValue]];
       
        NSArray *items = [self.favoriteMusic filteredArrayUsingPredicate:thePredicate];
        
        if (items.count == 1) {
            [self.managedObjectContext deleteObject:items[0]];
            [self.favoriteMusic removeObjectIdenticalTo:items[0]];
        } else {
            NSLog(@"favoriteMusic error");
        }
    }
}

- (BOOL)saveChanges {
    
    NSError *error;
    BOOL successful = [_managedObjectContext save:&error];
    
    if (!successful)
        NSLog(@"Error saving:%@",[error localizedDescription]);
    
    return successful;
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex
               toIndex:(NSUInteger)toIndex tableID:(NSInteger )tableID {
    
}

#pragma mark -
#pragma mark - play...

- (void)playWithModel:(TracksViewModel *)tracks indexPathRow:(NSInteger ) indexPathRow {
    _tracksVM = tracks;
    _rowNumber = self.tracksVM.rowNumber;
    _indexPathRow = indexPathRow;

    NSURL *musicURL = [self.tracksVM playURLForRow:_indexPathRow];
    _currentPlayerItem = [AVPlayerItem playerItemWithURL:musicURL];
    _player = [[AVPlayer alloc] initWithPlayerItem:_currentPlayerItem];

    [self addMusicTimeMake];
    
    _isPlay = YES;
    [_player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayerItem];
    [self setHistoryMusic];
}

- (void)addMusicTimeMake {
    __weak FYPlayManager *weakSelf = self;
    
    _timeObserve = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        FYPlayManager *innerSelf = weakSelf;
        
        [innerSelf updateLockedScreenMusic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"musicTimeInterval" object:nil userInfo:nil];
    }];
}

- (void)removeMusicTimeMake {
    if (_timeObserve) {
        [_player removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
}

#pragma mark-
#pragma mark - KVO

-(void)addNotification {

}

- (void)releasePlayer {
    if (!self.currentPlayerItem)
        return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player removeObserver:self forKeyPath:@"status"];
    
    self.currentPlayerItem = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayer *player = (AVPlayer *)object;
    
    if ([keyPath isEqualToString:@"status"])
        NSLog(@"Current Status——%ld",(long)[player status]);
}

#pragma mark -
#pragma mark - Receive Action...

- (void)pauseMusic {
    if (!self.currentPlayerItem)
        return;
    
    if (_player.rate) {
        _isPlay = NO;
        [_player pause];
        
    } else {
        _isPlay = YES;
        [_player play];
    }
}

- (void)previousMusic {
    if (_cycle == theSong) {
        [self playPreviousMusic];
    } else if (_cycle == nextSong) {
        [self playPreviousMusic];
    } else if (_cycle == isRandom) {
        [self randomMusic];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"coverURL"] = [self.tracksVM coverURLForRow:_indexPathRow];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCoverURL" object:nil userInfo:userInfo];
}

- (void)nextMusic {
    if (_cycle == theSong) {
        [self playNextMusic];
    } else if (_cycle == nextSong) {
        [self playNextMusic];
    }else if (_cycle == isRandom) {
        [self randomMusic];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"coverURL"] = [self.tracksVM coverURLForRow:_indexPathRow];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCoverURL" object:nil userInfo:userInfo];
}

- (void)nextCycle {
    NSDictionary* defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    if (defaults[@"cycle"]) {
        NSInteger cycleDefaults = [defaults[@"cycle"] integerValue];
        _cycle = cycleDefaults;
        
    } else
        _cycle = theSong;
}

- (void)setFavoriteMusic {
    NSDictionary *track = [self.tracksVM trackForRow:_indexPathRow];
    [self addTrack:track itemModel:favoritelItem];
}

- (void)delFavoriteMusic {
    NSDictionary *track = [self.tracksVM trackForRow:_indexPathRow];
    [self removeTrack:track itemModel:favoritelItem];
}

- (void)delMyFavoriteMusicDictionary:(NSDictionary *)track {
    [self removeTrack:track itemModel:favoritelItem];
}

- (void)delMyFavoriteMusic:(NSInteger )indexPathRow {
    NSDictionary *track = [self.tracksVM trackForRow:indexPathRow];
    [self removeTrack:track itemModel:favoritelItem];
}

- (void)setHistoryMusic {
    NSDictionary *track = [self.tracksVM trackForRow:_indexPathRow];
    [self addTrack:track itemModel:historyItem];
}

- (void)delMyHistoryMusic:(NSDictionary *)track {
    [self removeTrack:track itemModel:historyItem];
}

- (void)delAllHistoryMusic {
    for (FYhistoryItem *user in self.historyMusic) {
        [self.managedObjectContext deleteObject:user];
    }
    [self.historyMusic removeAllObjects];
}

- (void)delAllFavoriteMusic {
    for (FYfavoriteItem *user in self.favoriteMusic) {
        [self.managedObjectContext deleteObject:user];
    }
    [self.favoriteMusic removeAllObjects];
}

#pragma mark -
#pragma mark - Playback Action...

-(void)playbackFinished:(NSNotification *)notification {
    if (_cycle == theSong) {
        [self playAgain];
    } else if (_cycle == nextSong) {
        [self playNextMusic];
    } else if (_cycle == isRandom) {
        [self randomMusic];
    }
    NSLog(@"Next");
    
    [self.delegate changeMusic];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"coverURL"] = [self.tracksVM coverURLForRow:_indexPathRow];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCoverURL" object:nil userInfo:userInfo];
}

- (void)playPreviousMusic {
    if (_currentPlayerItem){
        if (_indexPathRow > 0)
            _indexPathRow--;
        else
            _indexPathRow = _rowNumber-1;

        NSURL *musicURL = [self.tracksVM playURLForRow:_indexPathRow];
        _currentPlayerItem = [AVPlayerItem playerItemWithURL:musicURL];
        
        _player = [[AVPlayer alloc] initWithPlayerItem:_currentPlayerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self addMusicTimeMake];
        _isPlay = YES;
        [_player play];
        
        [self.delegate changeMusic];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    }
}

- (void)playNextMusic {
    if (_currentPlayerItem) {
        if (_indexPathRow < _rowNumber-1)
            _indexPathRow++;
        else
            _indexPathRow = 0;
        
        NSURL *musicURL = [self.tracksVM playURLForRow:_indexPathRow];
        _currentPlayerItem = [AVPlayerItem playerItemWithURL:musicURL];
        
        _player = [[AVPlayer alloc] initWithPlayerItem:_currentPlayerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self addMusicTimeMake];
        _isPlay = YES;
        [_player play];
        
        [self.delegate changeMusic];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    }
}

- (void)randomMusic {
    if (_currentPlayerItem) {
        _indexPathRow = random()%_rowNumber;
        
        NSURL *musicURL = [self.tracksVM playURLForRow:_indexPathRow];
        _currentPlayerItem = [AVPlayerItem playerItemWithURL:musicURL];
        
        _player = [[AVPlayer alloc] initWithPlayerItem:_currentPlayerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self addMusicTimeMake];
        _isPlay = YES;
        [_player play];
 
        [self.delegate changeMusic];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    }
}

- (void)playAgain {
    [_player seekToTime:CMTimeMake(0, 1)];
    _isPlay = YES;
    [_player play];
}

- (void)stopMusic {
    
}

#pragma mark -
#pragma mark - Return...

- (NSInteger )playerStatus {
    if (_currentPlayerItem.status == AVPlayerItemStatusReadyToPlay)
        return 1;
    else
        return 0;
}

- (NSInteger )FYPlayerCycle {
    return _cycle;
}

- (NSString *)playMusicName {
    return [[self.tracksVM titleForRow: _indexPathRow] copy];
}

- (NSString *)playSinger {
    return [[self.tracksVM nickNameForRow: _indexPathRow] copy];
}

- (NSString *)playMusicTitle {
    return [[self.tracksVM albumTitle] copy];
}

- (NSURL *)playCoverLarge {
    return [[self.tracksVM coverLargeURLForRow: _indexPathRow] copy];
}

- (UIImage *)playCoverImage {
    UIImageView *imageCoverView = [[UIImageView alloc] init];
    [imageCoverView sd_setImageWithURL:[self playCoverLarge] placeholderImage:[UIImage imageNamed:@"music_placeholder"]];

    return [imageCoverView.image copy];
}

- (BOOL)hasBeenFavoriteMusic {
    for (FYfavoriteItem *item in self.favoriteMusic) {
        if (item.trackId == [self.tracksVM trackIdForRow:_indexPathRow]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)favoriteMusicItems {
    NSArray *items = [NSArray arrayWithArray:self.favoriteMusic];
    return [items copy];
}

- (NSArray *)historyMusicItems {
    NSArray *items = [NSArray arrayWithArray:self.historyMusic];
    return [items copy];
}

- (BOOL)havePlay {
    return _isPlay;
}

#pragma mark -
#pragma mark - Update lock screen music...

- (void)updateLockedScreenMusic {
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];

    info[MPMediaItemPropertyAlbumTitle] = [self playMusicName];
    info[MPMediaItemPropertyArtist] = [self playSinger];
    info[MPMediaItemPropertyTitle] = [self playMusicTitle];
    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[self playCoverImage]];
    
    [info setObject:[NSNumber numberWithFloat:CMTimeGetSeconds([self.player.currentItem duration])] forKey:MPMediaItemPropertyPlaybackDuration];
    [info setObject:[NSNumber numberWithFloat:CMTimeGetSeconds([self.player.currentItem currentTime])] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    center.nowPlayingInfo = info;
}

#pragma mark -
#pragma mark - Play Sound...

- (void)playSound:(NSString *)filename {
    if (!filename)
        return;

    SystemSoundID soundID = (int)[self.soundIDs[filename] unsignedLongValue];
    
    if (!soundID) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (!url)
            return;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);

        self.soundIDs[filename] = @(soundID);
    }
    AudioServicesPlaySystemSound(soundID);
}

- (void)disposeSound:(NSString *)filename {
    if (!filename){
        return;
    }
    SystemSoundID soundID = (int)[self.soundIDs[filename] unsignedLongValue];
    
    if (soundID) {
        AudioServicesDisposeSystemSoundID(soundID);
        [self.soundIDs removeObjectForKey:filename];
    }
}

- (void)iPhoneSysctlbyname {
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    NSLog(@"iPhone Device%@",[self platformType:platform]);
    
    free(machine);
}

- (NSString *)platformType:(NSString *)platform {
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

@end
