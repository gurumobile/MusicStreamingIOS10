//
//  FYMainPlayController.h
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYMainPlayController : UIViewController

@property (nonatomic,strong) NSString *musicTitle;
@property (nonatomic,strong) NSString *musicName;
@property (nonatomic,strong) NSString *singer;

@property (nonatomic,strong) NSURL *coverLarge;

@end
