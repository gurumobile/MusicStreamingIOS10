//
//  FYMoreNetManager.h
//  music
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "FYNetManager.h"

@interface FYMoreNetManager : FYNetManager

//Define format...
typedef NS_ENUM(NSUInteger, ContentType) {
    ContentTypeNews,
    ContentTypeNovels,
    ContentTypeTalkShow,
    ContentTypeCrossTalk,
    
    ContentTypeMusic,
    
    ContentTypeEmotion,
    ContentTypeHistory,
    ContentTypeLectures,
    ContentTypeBroadcasr,
    ContentTypeChildrenStory,
    ContentTypeForeignLanguage,
    ContentTypeGame,
};


// http://mobile.ximalaya.com/mobile/discovery/v2/category/recommends?categoryId=1&contentType=album&device=android&scale=2&version=4.3.32.2
+ (id)getContentsForForCategoryId:(NSInteger)categoryID contentType:(NSString*)type completionHandle:(void(^)(id responseObject, NSError *error))completed;

// http://mobile.ximalaya.com/mobile/discovery/v1/category/album?calcDimension=hot&categoryId=1&device=android&pageId=1&pageSize=20&status=0&tagName=%E6%AD%A3%E8%83%BD%E9%87%8F%E5%8A%A0%E6%B2%B9%E7%AB%99
+ (id)getCategoryForCategoryId:(NSInteger)categoryId tagName:(NSString *)name pageSize:(NSInteger)size completionHandle:(void(^)(id responseObject, NSError *error))completed;

// http://mobile.ximalaya.com/mobile/discovery/v1/recommend/editor?device=android&pageId=1&pageSize=20&title=%E6%9B%B4%E5%A4%9A
+ (id)getEditorMoreForPageSize:(NSInteger)size completionHandle:(void(^)(id responseObject, NSError *error))completed;

// http://mobile.ximalaya.com/m/subject_list?device=android&page=1&per_page=10&title=%E6%9B%B4%E5%A4%9A
+ (id)getSpecialForPage:(NSInteger)page completionHandle:(void(^)(id responseObject, NSError *error))completed;

//http://mobile.ximalaya.com/mobile/others/ca/album/track/2758446/true/1/20?position=1&albumId=2758446&isAsc=true&device=android&title=%E5%B0%8F%E7%BC%96%E6%8E%A8%E8%8D%90&pageSize=20
+ (id)getTracksForAlbumId:(NSInteger)albumId mainTitle:(NSString *)title idAsc:(BOOL)isAsc completionHandle:(void(^)(id responseObject, NSError *error))completed;

+ (id)getTracksForMusic:(NSInteger)modelId completionHandle:(void(^)(id responseObject, NSError *error))completed;

@end
