//
//  VoiceAnimationView.h
//  iLiuXue
//
//  Created by superhomeliu on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceAnimationView : UIView
{
    UIImageView *animationView;
    UILabel *timeLabel;
    
    NSTimer *_timer;
    int _totaltimers;
}

- (void)startAnimation;
- (void)stopAnimation;
@end
