//
//  ViewData.m
//  liuxue
//
//  Created by superhomeliu on 13-7-31.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "ViewData.h"
#import "ALXMPPEngine.h"

static ViewData *viewdata=nil;

@implementation ViewData
@synthesize leftVisibleWidth,rightVisibleWidth;
@synthesize homeVc = _homeVc,messageVc = _messageVc,pulishVc = _pulishVc,setVc = _setVc;

+ (ViewData *)defaultManager
{
    if(viewdata==nil)
    {
        viewdata = [[ViewData alloc] init];
    }
    
    return viewdata;
}

- (void)stopNSTimer
{
    if (_timer!=nil)
    {
        [_timer invalidate];
        _timer=nil;
    }
}

- (void)setNSTimer
{
    if (_timer==nil)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(beginLogin) userInfo:nil repeats:YES];
    }
}

- (void)beginLogin
{
    if (self.autoLogin==YES)
    {
        [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                NSLog(@"自动登录成功");
            }
        }];
    }
}

@end
