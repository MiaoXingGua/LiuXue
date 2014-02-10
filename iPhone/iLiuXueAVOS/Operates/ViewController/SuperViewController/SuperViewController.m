//
//  SuperViewController.m
//  NightTalk
//
//  Created by superhomeliu on 13-6-9.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import "SuperViewController.h"
#import "AppDelegate.h"

@interface SuperViewController ()

@end

@implementation SuperViewController
@synthesize F3HUD;

- (void)dealloc
{
    [_F3HUD release]; _F3HUD=nil;
    
    if (self.F3HUD!=nil)
    {
        [self.F3HUD removeFromSuperview];
        [self.F3HUD release];
        self.F3HUD=nil;
    }
    
    [super dealloc];
}

- (void)showF3HUDLoad:(NSString *)text
{
    [self.view bringSubviewToFront:self.F3HUD];
    
    [self addAnimationView];
    
    [self.F3HUD addThreshold:5
              withColor:[UIColor colorWithRed:0.12 green:0.61 blue:0.81 alpha:1]
                    rpm:50
                  label:text
               segments:3];
    
    self.F3HUD.value = 5;
}

- (void)hideF3HUDSucceed:(NSString *)text
{
    [self.F3HUD addThreshold:10
                   withColor:[UIColor colorWithRed:0.55 green:0.78 blue:0.2 alpha:1]
                         rpm:50
                       label:text
                    segments:1];
    
    self.F3HUD.value = 10;
    
    [self removeAnimationView];
}

- (void)hideF3HUDError:(NSString *)text
{
    [self.F3HUD addThreshold:15
                   withColor:[UIColor colorWithRed:0.83 green:0.36 blue:0.43 alpha:1]
                         rpm:50
                       label:text
                    segments:4];
    
    self.F3HUD.value = 15;
    
    [self removeAnimationView];
}

- (void)hideF3UHDTimeOut:(NSString *)text
{
    [self.F3HUD addThreshold:20
                   withColor:[UIColor colorWithRed:0.97 green:0.7 blue:0.31 alpha:1]
                         rpm:50
                       label:text
                    segments:2];
    
    self.F3HUD.value = 20;
    
    [self removeAnimationView];
}

- (void)removeAnimationView
{
    [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.F3HUD.alpha=0;

    } completion:^(BOOL finished) {
        
        [self.F3HUD removeFromSuperview];
        [self.F3HUD release];
        self.F3HUD=nil;
        
    }];
}


- (void)addAnimationView
{
    if (self.F3HUD)
    {
        [self.F3HUD removeFromSuperview];
        [self.F3HUD release];
        self.F3HUD=nil;
    }
    
    self.F3HUD = [[[F3Swirly alloc]initWithFrame:CGRectMake(0, 0, 120, 120)] autorelease];
    self.F3HUD.font = [UIFont fontWithName:@"Futura-Medium" size:12.0];
    self.F3HUD.center = CGPointMake(160, SCREEN_HEIGHT/2);
    self.F3HUD.thickness = 10.0f;
    self.F3HUD.backgroundColor = [UIColor clearColor];
    self.F3HUD.textColor = [UIColor orangeColor];
    [self.view addSubview:F3HUD];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addAnimationView];

}


#pragma mark 计算发帖时间
- (NSString *)calculateDate:(NSDate *)date
{
    int now = (int)[[NSDate date] timeIntervalSince1970];
    int send = (int)[date timeIntervalSince1970];
    
    int i = now-send;
    
    if(i<=0)
    {
        return [NSString stringWithFormat:@"%d分前",1];
    }

    if(i<60)
    {
        return [NSString stringWithFormat:@"%d秒前",i];
    }
    else if(i>=60 && i<3600)
    {
        return [NSString stringWithFormat:@"%d分前",i/60];
    }
    else if(i>=3600 && i<86400)
    {
        return [NSString stringWithFormat:@"%d小时前",i/60/60];
    }
    else if(i>=86400 && i<2592000)
    {
        return [NSString stringWithFormat:@"%d天前",i/60/60/24];
    }
    else if(i>=2592000 && i<2592000*12)
    {
        return [NSString stringWithFormat:@"%d月前",i/60/60/24/30];
    }
    else
    {
        return [NSString stringWithFormat:@"%d年前",i/60/60/24/30/12];
    }
}


@end
