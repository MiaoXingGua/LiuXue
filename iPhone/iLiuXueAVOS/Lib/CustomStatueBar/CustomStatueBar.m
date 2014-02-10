//
//  CustomStatueBar.m
//  CustomStatueBar
//
//  Created by 贺 坤 on 12-5-21.
//  Copyright (c) 2012年 深圳市瑞盈塞富科技有限公司. All rights reserved.
//

#import "CustomStatueBar.h"

@implementation CustomStatueBar
@synthesize tapdelegate;
@synthesize isfromuserchat;

- (id)initWithFrame:(CGRect)frame UserColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelNormal;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.frame = frame;
        self.backgroundColor = color;
        
        defaultLabel = [[BBCyclingLabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) andTransitionType:BBCyclingLabelTransitionEffectScrollUp];
        defaultLabel.backgroundColor = [UIColor clearColor];
        defaultLabel.textColor = [UIColor whiteColor];
        defaultLabel.font = [UIFont systemFontOfSize:12.0f];
        defaultLabel.textAlignment = NSTextAlignmentRight;
        defaultLabel.transitionDuration = 0.5;
        defaultLabel.clipsToBounds = YES;
        
        [self addSubview:defaultLabel];

        isFull = NO;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, frame.size.width, 20)];
        [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}
- (void)fullStatueBar
{
    if (isFull)
    {
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:1.0f];
        self.frame =CGRectMake(320, 0,40, 20);
        [UIView commitAnimations];
    }else {
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:1.0f];
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        [UIView commitAnimations];
    }
}

- (void)showStatusMessage:(NSString *)message
{
    self.hidden = NO;
    self.alpha = 1.0f;
    
    defaultLabel.text = message;
}

- (void)hide
{
    [self.tapdelegate didSelectMessageRemind];
    
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        defaultLabel.text = @"";
        self.hidden = YES;
    }];;

}
- (void)changeMessge:(NSString *)message
{
    [defaultLabel setText:message animated:YES];
}
- (void)dealloc
{
    [defaultLabel release];
    [super dealloc];
}
@end
