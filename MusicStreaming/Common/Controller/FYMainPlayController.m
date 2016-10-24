//
//  FYMainPlayController.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYMainPlayController.h"
#import "MusicSlider.h"
#import <AVFoundation/AVFoundation.h>

#import "NSString+FYString.h"
#import "UIView+FYAnimations.h"

#import "FYPlayManager.h"

@import AVFoundation;

@interface FYMainPlayController ()<FYPlayManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroudImageView;
@property (weak, nonatomic) IBOutlet UIView *backgroudView;

@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumImageLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumImageRightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;

@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet MusicSlider *musicSlider;

@property (weak, nonatomic) IBOutlet UIButton *musicCycleButton;
@property (weak, nonatomic) IBOutlet UIButton *previousMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *musicToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;

@property (strong, nonatomic) UIVisualEffectView *visualEffectView;

@property (nonatomic) BOOL musicIsPlaying;
@property (nonatomic) BOOL musicIsChange;
@property (nonatomic) BOOL musicIsCan;
@property (nonatomic) BOOL newItem;

@property (nonatomic) FYPlayerCycle  cycle;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSTimeInterval total;

@property (nonatomic,strong) FYPlayManager *playmanager;

@end

@implementation FYMainPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self adapterIphone4];
    [self addPanRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - In/Out Layout...

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    _playmanager = [FYPlayManager sharedInstance];
    _playmanager.delegate = self;
    _cycle = [_playmanager FYPlayerCycle];
    
    switch (_cycle) {
        case theSong:
            
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_single_icon"] forState:UIControlStateNormal];
            break;
        case nextSong:
            
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_all_icon"] forState:UIControlStateNormal];
            break;
        case isRandom:
            
            [_musicCycleButton setImage:[UIImage imageNamed:@"shuffle_icon"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }

    _musicNameLabel.text = [_playmanager playMusicName];
    _musicTitleLabel.text = [_playmanager playMusicTitle];
    _singerLabel.text = [_playmanager playSinger];
    [self setupBackgroudImage:[_playmanager playCoverLarge]];
    
    [self updateProgressLabelCurrentTime:CMTimeGetSeconds([_playmanager.player.currentItem currentTime]) duration:CMTimeGetSeconds([_playmanager.player.currentItem duration])];
    [self addObserverToPlayer:_playmanager.player];
    
    if (_playmanager.player.rate) {
        self.musicIsPlaying = YES;
    } else {
        self.musicIsPlaying = NO;
    }
    
    if ([_playmanager hasBeenFavoriteMusic]) {
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    } else {
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
    }
    
    _newItem = YES;
}

- (void)addPanRecognizer {
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closePlay:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
}

#pragma mark -
#pragma mark - KVO

- (void)addObserverToPlayer:(AVPlayer *)player {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicTimeInterval:) name:@"musicTimeInterval" object:nil];
}

- (void)removeObserverFromPlayer:(AVPlayer *)player {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (_playmanager.player.status) {
            case AVPlayerStatusUnknown:
                [self showMiddleHint:@"Unknown state, can't play at this time"];
                break;
            case AVPlayerStatusReadyToPlay:
                [self showMiddleHint:@"Ready, you can play"];
                break;
            case AVPlayerStatusFailed:
                [self showMiddleHint:@"Failed to load, network or server problems"];
                break;
            default:
                break;
        }
    }
    if ([keyPath isEqualToString:@"rate"]) {
        if ([[FYPlayManager sharedInstance] isPlay])
            self.musicIsPlaying = YES;
        else
            self.musicIsPlaying = NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPausePlayView" object:nil userInfo:nil];

    }
    if ([keyPath isEqualToString:@"currentItem"]) {
        FYPlayManager *playmanager = [FYPlayManager sharedInstance];

        _musicNameLabel.text = [playmanager playMusicName];
        _musicTitleLabel.text = [playmanager playMusicTitle];
        _singerLabel.text = [playmanager playSinger];
        [self setupBackgroudImage:[playmanager playCoverLarge]];
        [playmanager setHistoryMusic];

        if ([_playmanager hasBeenFavoriteMusic])
            [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
        else
            [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
        
        _newItem = YES;
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem * songItem = object;
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        NSLog(@"Total Buffer %.2f",totalBuffer);
    }
}

#pragma mark -
#pragma mark - Change Music...

- (void)changeMusic {
    FYPlayManager *playmanager = [FYPlayManager sharedInstance];
    
    _musicNameLabel.text = [playmanager playMusicName];
    _musicTitleLabel.text = [playmanager playMusicTitle];
    _singerLabel.text = [playmanager playSinger];
    [self setupBackgroudImage:[playmanager playCoverLarge]];
    [playmanager setHistoryMusic];
    
    if ([_playmanager hasBeenFavoriteMusic])
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    else
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
    
    _newItem = YES;
}

- (void)musicTimeInterval:(NSNotification *)notification {
    NSTimeInterval current=CMTimeGetSeconds([_playmanager.player.currentItem currentTime]);
    
    if (_newItem == YES) {
        AVPlayerItem *newItem = self.playmanager.player.currentItem;
        if (!isnan(CMTimeGetSeconds([newItem duration]) )) {
            self.total = CMTimeGetSeconds([newItem duration]);
            
            _newItem = NO;
        }
    }
    
    [self updateProgressLabelCurrentTime:current duration:self.total];
}

#pragma mark -
#pragma mark - Initialize...

- (void)adapterIphone4 {
    if (s_isPhone4) {
        CGFloat margin = 65;
        _albumImageLeftConstraint.constant = margin;
        _albumImageRightConstraint.constant = margin;
    }
}

- (void)setupBackgroudImage:(NSURL *)imageUrl {
    _albumImageView.layer.cornerRadius = 7;
    _albumImageView.layer.masksToBounds = YES;
    
    [_backgroudImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music_placeholder"]];
    [_albumImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music_placeholder"]];
    
    if(![_visualEffectView isDescendantOfView:_backgroudView]) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = CGRectMake(0, 0, s_WindowW, s_WindowH);
        [_backgroudView addSubview:_visualEffectView];
    }
    
    [_backgroudImageView startTransitionAnimation];
    [_albumImageView startTransitionAnimation];
}

- (void)setMusicIsPlaying:(BOOL)musicIsPlaying {
    _musicIsPlaying = musicIsPlaying;
    
    if (_musicIsPlaying)
        [_musicToggleButton setImage:[UIImage imageNamed:@"big_pause_button"] forState:UIControlStateNormal];
    else
        [_musicToggleButton setImage:[UIImage imageNamed:@"big_play_button"] forState:UIControlStateNormal];
}

- (void)updateProgressLabelCurrentTime:(NSTimeInterval )currentTime duration:(NSTimeInterval )duration {
    _beginTimeLabel.text = [NSString timeIntervalToMMSSFormat:currentTime];
    _endTimeLabel.text = [NSString timeIntervalToMMSSFormat:duration];
    
    if (_musicIsCan == YES) {
        CGFloat currentTimef = currentTime;
        int currentTimei = currentTime;
        if (currentTimef == currentTimei) {
            _musicIsCan = NO;
        }
    }
    
    if (_musicIsChange == NO && _musicIsCan == NO)
        [_musicSlider setValue:currentTime / duration animated:YES];
}

- (void)checkMusicFavoritedIcon {
    if ([_playmanager hasBeenFavoriteMusic])
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    else
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - Event Click...

- (IBAction)didTouchMusicToggleButton:(id)sender {
    if (_playmanager.player.status == 1) {
        [_playmanager pauseMusic];
        
        if ([[FYPlayManager sharedInstance] isPlay])
            self.musicIsPlaying = YES;
        else
            self.musicIsPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPausePlayView" object:nil userInfo:nil];
        
    } else
        [self showMiddleHint:@"Currently, there is no music."];
}

- (IBAction)didTouchCycle:(id)sender {
    if (_cycle < 3)
        _cycle++;
    else
        _cycle = 1;
    
    NSNumber *userCycle = [NSNumber numberWithInt:_cycle];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:userCycle forKey:@"cycle"];

    [_playmanager nextCycle];
    
    switch (_cycle) {
        case theSong:
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_single_icon"] forState:UIControlStateNormal];
            [self showMiddleHint:@"Single Cycle"];
            break;
        case nextSong:
            [_musicCycleButton setImage:[UIImage imageNamed:@"loop_all_icon"] forState:UIControlStateNormal];
            [self showMiddleHint:@"Sequential Cycle"];
            break;
        case isRandom:
            [_musicCycleButton setImage:[UIImage imageNamed:@"shuffle_icon"] forState:UIControlStateNormal];
            [self showMiddleHint:@"Random Cycle"];
            break;
            
        default:
            break;
    }
    
}
- (IBAction)idiTouchFavorite:(id)sender {
    [_favoriteButton startDuangAnimation];
    
    if ([_playmanager hasBeenFavoriteMusic]) {
        [_playmanager delFavoriteMusic];
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
    } else {
        [_playmanager setFavoriteMusic];
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    }
}

- (IBAction)didTouchMoreButton:(id)sender {
    NSArray *aa = [[FYPlayManager sharedInstance] favoriteMusicItems];
    NSLog(@"%@",aa);
}

- (IBAction)playPreviousMusic:(id)sender {
    if (_playmanager.player.status == 1) {
        [_playmanager previousMusic];
        
        if ([[FYPlayManager sharedInstance] isPlay])
            self.musicIsPlaying = YES;
        else
            self.musicIsPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPausePlayView" object:nil userInfo:nil];
    } else
        [self showMiddleHint:@"Please wait for load the music"];
}

- (IBAction)playNextMusic:(id)sender {
    if (_playmanager.player.status == 1) {
        [_playmanager nextMusic];

        if ([[FYPlayManager sharedInstance] isPlay])
            self.musicIsPlaying = YES;
        else
            self.musicIsPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setPausePlayView" object:nil userInfo:nil];
    } else
        [self showMiddleHint:@"Please wait for load the music"];
}

- (IBAction)closePlay:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeMusicTime:(id)sender {
    _musicIsChange = YES;
}

- (IBAction)setMusicTime:(id)sender {
    CGFloat endTime = CMTimeGetSeconds([_playmanager.player.currentItem duration]);
    NSInteger dragedSeconds = floorf(self.musicSlider.value * endTime);

    [_playmanager.player seekToTime:CMTimeMakeWithSeconds(dragedSeconds, 1)];
    
    _musicIsChange = NO;
    _musicIsCan = YES;
}

- (IBAction)noChangeMusic:(id)sender {
    _musicIsChange = NO;
}

#pragma mark -
#pragma mark - HUD

- (void)showMiddleHint:(NSString *)hint {
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.margin = 10.f;
    hud.yOffset = 0;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)dealloc{
    [self removeObserverFromPlayer:_playmanager.player];
    NSLog(@"main dealloc");
}

@end
