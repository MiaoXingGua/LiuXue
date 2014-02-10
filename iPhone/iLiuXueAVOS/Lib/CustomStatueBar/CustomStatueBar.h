//
//  CustomStatueBar.h
//  CustomStatueBar
//
//  Created by 贺 坤 on 12-5-21.
//  Copyright (c) 2012年 深圳市瑞盈塞富科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBCyclingLabel.h"

@protocol tapNewMessageDelegate;

@interface CustomStatueBar : UIWindow
{
    BBCyclingLabel *defaultLabel;
    BOOL isFull;
}

@property(nonatomic,assign)id<tapNewMessageDelegate>tapdelegate;
@property(nonatomic,assign)BOOL isfromuserchat;

- (id)initWithFrame:(CGRect)frame UserColor:(UIColor *)color;
- (void)showStatusMessage:(NSString *)message;
- (void)hide;
- (void)changeMessge:(NSString *)message;

- (void)fullStatueBar;

@end

@protocol tapNewMessageDelegate <NSObject>

- (void)didSelectMessageRemind;

@end