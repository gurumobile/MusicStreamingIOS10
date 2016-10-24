//
//  FYNetManager.h
//  music
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYNetManager : NSObject

+ (id)GET:(NSString *)path parameters:(NSDictionary *)params complationHandle:(void(^)(id responseObject, NSError *error))completed;
+ (id)POST:(NSString *)path parameters:(NSDictionary *)params complationHandle:(void(^)(id responseObject, NSError *error))completed;

/**
 *  For coresponding to some chinese characters...
 *
 *  @param path   Request Path
 *  @param params Request Params
 *
 *  @return Return Path + Params
 */
+ (NSString *)percentURLByPath:(NSString *)path params:(NSDictionary *)params;

@end
