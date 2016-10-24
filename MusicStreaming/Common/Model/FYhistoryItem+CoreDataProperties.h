//
//  FYhistoryItem+CoreDataProperties.h
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYhistoryItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FYhistoryItem (CoreDataProperties)

@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSString *albumImage;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, strong) NSString *coverLarge;
@property (nonatomic, strong) NSString *coverMiddle;
@property (nonatomic, strong) NSString *coverSmall;
@property (nonatomic, assign) NSInteger createdAt;
@property (nonatomic, assign) NSInteger downloadAacSize;
@property (nonatomic, strong) NSString *downloadAacUrl;
@property (nonatomic, assign) NSInteger downloadSize;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, assign) NSInteger opType;
@property (nonatomic, assign) NSInteger orderNum;
@property (nonatomic, strong) NSString *playPathAacv164;
@property (nonatomic, strong) NSString *playPathAacv224;
@property (nonatomic, assign) NSInteger playtimes;
@property (nonatomic, strong) NSString *playUrl32;
@property (nonatomic, strong) NSString *playUrl64;
@property (nonatomic, assign) NSInteger processState;
@property (nonatomic, assign) NSInteger shares;
@property (nonatomic, strong) NSString *smallLogo;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger trackId;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger userSource;
@property (nonatomic, assign) double orderingValue;
@property (nonatomic, assign) NSInteger musicRow;

@end

NS_ASSUME_NONNULL_END
