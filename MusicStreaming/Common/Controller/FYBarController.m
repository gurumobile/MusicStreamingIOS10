//
//  FYBarController.m
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYBarController.h"

#import "FYMainViewController.h"
#import "FYTuiViewController.h"
#import "FYMyViewController.h"
#import "FYMainPlayController.h"

#import "FYNavigationController.h"
#import "TracksViewModel.h"
#import "FYPlayView.h"      //Playback Icon
#import "FYPlayManager.h"   //Player

#import "FYPercentDrivenInteractiveTransition.h"
#import "FYMissAnimation.h"

@interface FYBarController ()<PlayViewDelegate,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic,strong) FYPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic,strong) TracksViewModel *tracksVM;

@property (nonatomic,assign) NSInteger indexPathRow;
@property (nonatomic,assign) NSInteger rowNumber;

@property (nonatomic,strong) FYPlayView *playView;
@property (nonatomic,strong) NSString *imageName;

@property (nonatomic) BOOL isCan;

@end

@implementation FYBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTabBarController];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTabBarController {
    FYMainViewController *item0 = [[FYMainViewController alloc]init];
    [self controller:item0 title:@"主页" image:@"tab_icon_selection_normal" selectedimage:@"tab_icon_selection_highlight"];
    
    FYTuiViewController *item1 = [[FYTuiViewController alloc]init];
    [self controller:item1 title:@"推荐" image:@"icon_tab_shouye_normal" selectedimage:@"icon_tab_shouye_highlight"];
    
    FYTuiViewController *item2 = [[FYTuiViewController alloc]init];
    [self controller:item2 title:@"" image:@"" selectedimage:@""];
    
    self.tabBar.backgroundColor = [UIColor whiteColor];
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor colorWithRed:252/255.0 green:74/255.0 blue:132/255.0 alpha:0.9];
    [self setSelectedIndex:0];
    
    self.playView = [[FYPlayView alloc] init];
    [self addNotification];
    
    self.playView.delegate = self;
    [self.view addSubview:_playView];
    
    [_playView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo([[UIScreen mainScreen] bounds].size.width/3);
        make.height.mas_equalTo(70);
        
        make.right.equalTo(self.view).with.offset(0);
    }];
}

#pragma mark -
#pragma mark - Initialize...

- (void)controller:(UIViewController *)TS title:(NSString *)title image:(NSString *)image selectedimage:(NSString *)selectedimage {
    TS.tabBarItem.title = title;
    if ([image  isEqual: @""]) {
        
    } else {
        TS.tabBarItem.image = [UIImage imageNamed:image];
        TS.tabBarItem.selectedImage = [[UIImage imageNamed:selectedimage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }

    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:TS];
    nav.delegate = self;
    [self addChildViewController:nav];
}

#pragma mark -
#pragma mark - PlayView proxy method...

- (void)playButtonDidClick:(NSInteger)index {
    
    NSLog(@"Event Click%li",(long)index);
    
    if ([[FYPlayManager sharedInstance] playerStatus]) {
        FYMainPlayController *mainPlay = [[FYMainPlayController alloc]initWithNibName:@"FYMainPlayController" bundle:nil];

        [self presentViewController: mainPlay animated:YES completion:nil];
    } else {
        if ([[FYPlayManager sharedInstance] havePlay]) {
            [self showMiddleHint:@"Loading Song"];
        } else
            [self showMiddleHint:@"Song is not loaded"];
    }

}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[FYMissAnimation alloc]init];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return (_interactiveTransition.isInteracting ? _interactiveTransition : nil);
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    if (viewController.hidesBottomBarWhenPushed) {
        if(self.tabBar.frame.origin.y == [[UIScreen mainScreen] bounds].size.height - 49){
            [UIView animateWithDuration:0.2
                             animations:^{
                                 CGRect tabFrame = self.tabBar.frame;
                                 tabFrame.origin.y = [[UIScreen mainScreen] bounds].size.height;
                                 self.tabBar.frame = tabFrame;
                             }];
            self.tabBar.hidden = YES;
        }
    } else {

    }

}
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    if (viewController.hidesBottomBarWhenPushed) {

    } else {
        if(self.tabBar.frame.origin.y == [[UIScreen mainScreen] bounds].size.height ){
            [UIView animateWithDuration:0.2
                             animations:^{
                                 CGRect tabFrame = self.tabBar.frame;
                                 tabFrame.origin.y += -49;
                                 self.tabBar.frame = tabFrame;
                             }];
            self.tabBar.hidden = NO;
        }
    }
    [super.view bringSubviewToFront:self.playView];
}

- (void)hideTabBar {
    self.playView.hidden = NO;
}

- (void)showTabBar {
    self.playView.hidden = YES;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPausePlayView:) name:@"setPausePlayView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingWithInfoDictionary:) name:@"BeginPlay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingInfoDictionary:) name:@"StartPlay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCoverURL:) name:@"changeCoverURL" object:nil];
}

#pragma mark -
#pragma mark - Information Center...

- (void)setPausePlayView:(NSNotification *)notification {
    if ([[FYPlayManager sharedInstance] isPlay])
        [self.playView setPlayButtonView];
    else
        [self.playView setPauseButtonView];
}

- (void)playingWithInfoDictionary:(NSNotification *)notification {
    if (!_isCan) {
        _isCan = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dejTableInteger" object:nil userInfo:nil];

        NSURL *coverURL = notification.userInfo[@"coverURL"];
        
        _tracksVM = notification.userInfo[@"theSong"];
        _indexPathRow = [notification.userInfo[@"indexPathRow"] integerValue];
        _rowNumber = self.tracksVM.rowNumber;
        
        [self.playView setPlayButtonView];
        
        CGFloat y = [notification.userInfo[@"originy"] floatValue];
        CGRect rect = CGRectMake(10, y+80, 50, 50);
        
        CGFloat moveX = s_WindowW -68;
        CGFloat moveY = s_WindowH - rect.origin.y-60;
        
        NSTimeInterval nowTime = [[NSDate date]timeIntervalSince1970]*1000;
        NSInteger imTag = (long)nowTime%(3600000*24);
        
        UIImageView * sImgView = [[UIImageView alloc]initWithFrame:rect];
        sImgView.tag = imTag;
        [sImgView sd_setImageWithURL:coverURL];
        [self.view addSubview:sImgView];
        sImgView.layer.cornerRadius = 22;
        sImgView.clipsToBounds = YES;
        
        CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        
        alphaBaseAnimation.fillMode = kCAFillModeForwards;
        alphaBaseAnimation.duration = moveX/800;
        alphaBaseAnimation.removedOnCompletion = NO;
        [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        CABasicAnimation * scaleBaseAnimation = [CABasicAnimation animation];
        
        scaleBaseAnimation.removedOnCompletion = NO;
        scaleBaseAnimation.fillMode = kCAFillModeForwards;
        scaleBaseAnimation.duration = moveX/800;
        scaleBaseAnimation.keyPath = @"transform.scale";
        scaleBaseAnimation.toValue = @0.3;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, sImgView.center.x, sImgView.center.y);
        
        CGPathAddQuadCurveToPoint(path, NULL, sImgView.center.x+moveX/12, sImgView.center.y-80, sImgView.center.x+moveX/12*2, sImgView.center.y);
        CGPathAddLineToPoint(path,NULL,sImgView.center.x+moveX/12*4,sImgView.center.y+moveY/8);
        CGPathAddLineToPoint(path,NULL,sImgView.center.x+moveX/12*6,sImgView.center.y+moveY/8*3);
        CGPathAddLineToPoint(path,NULL,sImgView.center.x+moveX,sImgView.center.y+moveY);
        
        
        CAKeyframeAnimation * frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        frameAnimation.duration = 5*moveX/800;
        
        frameAnimation.removedOnCompletion = NO;
        frameAnimation.fillMode = kCAFillModeForwards;
        
        [frameAnimation setPath:path];
        CFRelease(path);
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        
        animGroup.animations = @[alphaBaseAnimation,scaleBaseAnimation,frameAnimation];
        animGroup.duration = moveX/800;
        animGroup.fillMode = kCAFillModeForwards;
        animGroup.removedOnCompletion = NO;
        [sImgView.layer addAnimation:animGroup forKey:[NSString stringWithFormat:@"%ld",(long)imTag]];
        
        NSDictionary * dic = @{
                               @"animationGroup":sImgView,
                               @"coverURL":coverURL,
                               };
        
        
        NSTimer * t = [NSTimer scheduledTimerWithTimeInterval:animGroup.duration target:self selector:@selector(endPlayImgView:) userInfo:dic repeats:NO];
        [[NSRunLoop currentRunLoop]addTimer:t forMode:NSRunLoopCommonModes];
    }
}

- (void)endPlayImgView:(NSTimer *)timer {
    UIImageView * imgView = (UIImageView *)[timer.userInfo objectForKey:@"animationGroup"];
    
    if (imgView) {
        [imgView removeFromSuperview];
        imgView = nil;
    }
    
    NSURL *coverURL = timer.userInfo[@"coverURL"];
    
    [self.playView.contentIV sd_setImageWithURL:coverURL];
    self.playView.contentIV.alpha = 0.0;

    CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaBaseAnimation.fillMode = kCAFillModeForwards;
    alphaBaseAnimation.duration = 1.0;
    alphaBaseAnimation.removedOnCompletion = NO;
    [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [self.playView.contentIV.layer addAnimation:alphaBaseAnimation forKey:[NSString stringWithFormat:@"%ld",(long)self.playView.contentIV]];
    
    FYPlayManager *playmanager = [FYPlayManager sharedInstance];
    [playmanager playWithModel:_tracksVM indexPathRow:_indexPathRow];
    _isCan = NO;

    [self becomeFirstResponder];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)playingInfoDictionary:(NSNotification *)notification {
    NSURL *coverURL = notification.userInfo[@"coverURL"];
    
    _tracksVM = notification.userInfo[@"theSong"];
    _indexPathRow = [notification.userInfo[@"indexPathRow"] integerValue];
    _rowNumber = self.tracksVM.rowNumber;
    
    [self.playView setPlayButtonView];
    
    [self.playView.contentIV sd_setImageWithURL:coverURL];
    self.playView.contentIV.alpha = 0.0;
    
    CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaBaseAnimation.fillMode = kCAFillModeForwards;
    alphaBaseAnimation.duration = 1.0;
    alphaBaseAnimation.removedOnCompletion = NO;
    [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.playView.contentIV.layer addAnimation:alphaBaseAnimation forKey:[NSString stringWithFormat:@"%ld",(long)self.playView.contentIV]];
    
    FYPlayManager *playmanager = [FYPlayManager sharedInstance];
    [playmanager playWithModel:_tracksVM indexPathRow:_indexPathRow];
    _isCan = NO;

    [self becomeFirstResponder];
}

- (void)changeCoverURL:(NSNotification *)notification {
    NSURL *coverURL = notification.userInfo[@"coverURL"];
    
    [self.playView.contentIV sd_setImageWithURL:coverURL];
    self.playView.contentIV.alpha = 0.0;
    
    CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaBaseAnimation.fillMode = kCAFillModeForwards;
    alphaBaseAnimation.duration = 1.0;
    alphaBaseAnimation.removedOnCompletion = NO;
    [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.playView.contentIV.layer addAnimation:alphaBaseAnimation forKey:[NSString stringWithFormat:@"%ld",(long)self.playView.contentIV]];
    
}

#pragma mark -
#pragma mark - Remote Control Event Listener

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [[FYPlayManager sharedInstance] pauseMusic];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [[FYPlayManager sharedInstance] nextMusic];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [[FYPlayManager sharedInstance] previousMusic];
            
        default:
            break;
    }
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[FYPlayManager sharedInstance] releasePlayer];
    
    NSLog(@"play dealloc");
}

@end
