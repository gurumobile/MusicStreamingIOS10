//
//  FYPickerView.h
//  Test
//
//  Created by Bogdan on 10/24/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FYPickerViewDelegate <NSObject>

@optional
-(void)didSelectedFYPickerView:(NSInteger)index time:(NSInteger)time;

@end

@interface FYPickerView : UIView

@property (nonatomic, assign) id<FYPickerViewDelegate> delegate;

@end
