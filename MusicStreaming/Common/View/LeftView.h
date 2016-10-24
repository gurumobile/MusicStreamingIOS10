//
//  LeftView.h
//  MusicStreaming
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftDelegate <NSObject>

- (void)jumpWebVC:(NSURL *)url;

@end

@interface LeftView : UIView

@property (nonatomic, weak) id<leftDelegate> delegate;

@end
