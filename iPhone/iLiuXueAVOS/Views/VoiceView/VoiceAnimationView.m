//
//  VoiceAnimationView.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "VoiceAnimationView.h"

@implementation VoiceAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[UIImage imageNamed:@"_0005_0.png"]];
        [array addObject:[UIImage imageNamed:@"_0004_1.png"]];
        [array addObject:[UIImage imageNamed:@"_0003_2.png"]];
        [array addObject:[UIImage imageNamed:@"_0002_3.png"]];

        animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 143/2)];
        animationView.center = CGPointMake(160, frame.size.height/2-20);
        animationView.animationDuration = 0.8;
        animationView.animationImages = array;
        [self addSubview:animationView];
        [animationView release];
        [array release];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        timeLabel.center = CGPointMake(160, animationView.center.y+45);
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        timeLabel.font = [UIFont systemFontOfSize:12];
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:timeLabel];
        timeLabel.hidden = YES;
        [timeLabel release];
        
        _totaltimers = 60;
        
    }
    return self;
}

- (void)startAnimation
{
    timeLabel.hidden = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(begincountdown) userInfo:nil repeats:YES];
    [animationView startAnimating];
}

- (void)stopAnimation
{
    timeLabel.hidden = YES;
    _totaltimers=60;
    [_timer invalidate];
    _timer=nil;
    
    [animationView stopAnimating];
}

- (void)begincountdown
{
    if(_totaltimers<=0)
    {
        
        [self stopAnimation];
        
        return;
    }

    _totaltimers -=1;
    timeLabel.text = [NSString stringWithFormat:@"剩余:%d秒",_totaltimers];
}

@end
