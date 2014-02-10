//
//  CHDraggableView.m
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "CHDraggableView.h"
#import <QuartzCore/QuartzCore.h>

#import "SKBounceAnimation.h"
#import "ViewPointManager.h"
#import "CHAvatarView.h"

#define CGPointIntegral(point) CGPointMake((int)point.x, (int)point.y)

@interface CHDraggableView ()

@property (nonatomic, assign) BOOL moved;
@property (nonatomic, assign) BOOL scaledDown;
@property (nonatomic, assign) CGPoint startTouchPoint;

@end

@implementation CHDraggableView
@synthesize pointAry = _pointAry;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
        [tap release];
        
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan)];
//        [self addGestureRecognizer:pan];
//        [pan release];
//        
        _timer=nil;
        
        self.pointAry = [NSMutableArray arrayWithCapacity:0];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPoint:) name:@"getStartPoint" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginMove:) name:@"beginFollowView" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMove:) name:@"stopFollowView" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeViewState:) name:@"changeViewState" object:nil];
        
        
        isMoing = NO;
    }
    return self;
}



- (void)tap
{
    NSLog(@"tap!!!!");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowChatViewFromNotifition" object:nil];
//    NSString *viewstate = [ViewPointManager defultManager].viewState;
//    
//    if([ViewPointManager defultManager].showViewTag == self.tag)
//    {
//        if([viewstate isEqualToString:@"unfold"])
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeViewState" object:[NSArray arrayWithObjects:[NSNumber numberWithInt:self.tag],[ViewPointManager defultManager].lastViewPoint,@"fold", nil]];
//        }
//        else
//        {
//            [ViewPointManager defultManager].lastViewPoint = [NSValue valueWithCGPoint:self.center];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeViewState" object:[NSArray arrayWithObjects:[NSNumber numberWithInt:self.tag],[NSValue valueWithCGPoint:self.center],@"unfold", nil]];
//        }
//    }
//    else
//    {
//        [ViewPointManager defultManager].showViewTag = self.tag;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeChatView" object:[NSNumber numberWithInt:self.tag]];
//    }
    
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"showChatView" object:[NSNumber numberWithInt:self.tag]];
}

- (void)changeViewState:(NSNotification *)info
{
    NSArray *array = [info object];
    viewState = [array objectAtIndex:2];
    [ViewPointManager defultManager].viewState = viewState;
    float pointX,pointY;
    
    pointX = [[array objectAtIndex:1] CGPointValue].x;
    pointY = [[array objectAtIndex:1] CGPointValue].y;

    if([viewState isEqualToString:@"fold"])
    {
        //执行合并动画
        if(self.tag==1000)
        {
            [self foldAnimation:CGPointMake(pointX, pointY) delayTime:0 AnimationType:@"fold"];
        }
        else
        {
            if(pointX>=160)
            {
                [self foldAnimation:CGPointMake(pointX-5, pointY) delayTime:(self.tag-1000)*0.03 AnimationType:@"fold"];
            }
            else
            {
                [self foldAnimation:CGPointMake(pointX+5, pointY) delayTime:(self.tag-1000)*0.03 AnimationType:@"fold"];
            }
            
        }
        [ViewPointManager defultManager].showViewTag = 1000;
    }
    else
    {
        self.pointAry = [ViewPointManager defultManager].viewPointAry;
        //执行展开动画
        [self foldAnimation:[[self.pointAry objectAtIndex:self.tag-1000] CGPointValue] delayTime:(self.tag-1000)*0.03 AnimationType:@"unfold"];

    }
    
    
  //  NSLog(@"X=%f,Y=%f",self.center.x,self.center.y);

    
}

- (void)stopMove:(NSNotification *)info
{
    float pointX,pointY;
    
    NSArray *array = [info object];
    
    int _tag = (int)[[array objectAtIndex:2] intValue];
    NSString *viewState = [array objectAtIndex:3];
    
    if(_tag==self.tag)
    {
        return;
    }
    
    pointX = [[array objectAtIndex:0] intValue];
    pointY = [[array objectAtIndex:1] intValue];
    
    //靠近左边
    if([viewState isEqualToString:@"left"])
    {
        [self moveTo:CGPointMake(pointX+5, pointY) delayTime:0];

    }
    else
    {
        [self moveTo:CGPointMake(pointX-5, pointY) delayTime:0];

    }
    
}

- (void)beginMove:(NSNotification *)info
{
    
    NSArray *array = [info object];
    
    int _tag = (int)[[array objectAtIndex:1] intValue];
    if(_tag==self.tag)
    {
        return;
    }
    
    NSValue *value = [array objectAtIndex:0];
    
    self.center = [value CGPointValue];
    


}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"finish");
}

- (void)followAnimationWithX:(float)x WithY:(float)y
{
    //temp = CGPointMake(x, y);
    if(isMoing==YES)
    {
        return;
    }
    else
    {
        isMoing=YES;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.center = CGPointMake(x, y);
        } completion:^(BOOL finished) {
          //  temp = self.center;
            isMoing=NO;
        }];
    }
}

- (void)snapViewCenterToPoint:(CGPoint)point edge:(CGRectEdge)edge
{
    [self _snapViewCenterToPoint:point edge:edge];
}

#pragma mark - Override Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
//    UITouch *touch = [touches anyObject];
//    _startTouchPoint = [touch locationInView:self];
    
//   if([[ViewPointManager defultManager].viewState isEqualToString:@"unfold"])
//   {
//       [ViewPointManager defultManager].removeViewPoint = [NSValue valueWithCGPoint:self.center];
//   }
    

    UIWindow *_window = [UIApplication sharedApplication].keyWindow;
	NSArray * touchesArr=[[event allTouches] allObjects];
    _startTouchPoint =[[touchesArr objectAtIndex:0] locationInView:_window];
    
   // NSLog(@"%f,%f",_startTouchPoint.x,_startTouchPoint.y);
    
    // Simulate a touch with the scale animation
    [self _beginHoldAnimation];
    _scaledDown = YES;
    
    [_delegate draggableViewHold:self];
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if([[ViewPointManager defultManager].viewState isEqualToString:@"unfold"])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideChatView" object:nil];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showDeleteView" object:nil];

    
    UIWindow *_window = [UIApplication sharedApplication].keyWindow;
	NSArray * touchesArr=[[event allTouches] allObjects];
    movedPoint =[[touchesArr objectAtIndex:0] locationInView:_window];
    
    
//    if(![[ViewPointManager defultManager].viewState isEqualToString:@"unfold"])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"beginFollowView" object:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:movedPoint],[NSNumber numberWithInt:self.tag], nil] userInfo:nil];
//       
//    }
   
//    UITouch *touch = [touches anyObject];
//    CGPoint movedPoint = [touch locationInView:self];

   
    
    [self _moveByDeltaX:movedPoint.x deltaY:movedPoint.y];
    
    if(movedPoint.x>=100 && movedPoint.x<=220 && movedPoint.y>=self.superview.frame.size.height-140 && movedPoint.y<=self.superview.frame.size.height-20)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"beginDeleteAnimation" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopDeleteAnimation" object:nil];
    }
    
    if (_scaledDown) {
        [self _beginReleaseAnimation];
    }
    _scaledDown = NO;
    _moved = YES;
    
    //[_delegate draggableView:self didMoveToPoint:movedPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIWindow *_window = [UIApplication sharedApplication].keyWindow;

	NSArray * touchesArr=[[event allTouches] allObjects];
    CGPoint p1=[[touchesArr objectAtIndex:0] locationInView:_window];    

    
    if (_scaledDown)
    {
        [self _beginReleaseAnimation];
    }
    
    float pointX,pointY;
    
    if(p1.x>=100 && p1.x<=220 && p1.y>=self.superview.frame.size.height-140 && p1.y<=self.superview.frame.size.height-20)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeChatView" object:nil];
        
        return;
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidenDeleteView" object:nil];

    }

    
    //展开状态
//    if([[ViewPointManager defultManager].viewState isEqualToString:@"unfold"])
//    {
//        if(p1.x>=100 && p1.x<=200 && p1.y>=400)
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeChatView" object:[NSString stringWithFormat:@"%d",self.tag]];
//            
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"recoverChatView" object:@"0"];
//        }
//        else
//        {
//           // NSLog(@"%f,%f",[[ViewPointManager defultManager].removeViewPoint CGPointValue].x,[[ViewPointManager defultManager].removeViewPoint CGPointValue].y);
//            
//            [UIView animateWithDuration:0.2 animations:^{
//                self.center = [[ViewPointManager defultManager].removeViewPoint CGPointValue];
//            } completion:^(BOOL finished) {
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"recoverChatView" object:nil];
//            }];
//        }
//        return;
//    }
    //合并状态
//    else
//    {
//
//    }
    
   // NSLog(@"%f,%f",p1.x,p1.y);

    
    if(p1.x>=160)
    {
        if(p1.y>=450)
        {
            pointX = 290;
            pointY = 450;
//            [self moveTo:CGPointMake(300, 450)];
        }
        else if(p1.y<=50)
        {
            pointX = 290;
            pointY = 50;
//            [self moveTo:CGPointMake(300, 50)];
        }
        else
        {
            pointX = 290;
            pointY = p1.y;
//            [self moveTo:CGPointMake(300, p1.y)];
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopFollowView" object:[NSArray arrayWithObjects:[NSNumber numberWithFloat:pointX],[NSNumber numberWithFloat:pointY],[NSNumber numberWithInt:self.tag],@"right", nil] userInfo:nil];
    }
    else
    {
        if(p1.y>=450)
        {
            pointX = 30;
            pointY = 450;
//            [self moveTo:CGPointMake(20, 450)];
        }
        else if(p1.y<=30)
        {
            pointX = 30;
            pointY = 50;
//            [self moveTo:CGPointMake(20, 50)];
        }
        else
        {
            pointX = 30;
            pointY = p1.y;
//            [self moveTo:CGPointMake(20, p1.y)];

        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopFollowView" object:[NSArray arrayWithObjects:[NSNumber numberWithFloat:pointX],[NSNumber numberWithFloat:pointY],[NSNumber numberWithInt:self.tag], @"left",nil] userInfo:nil];
    }
//    if (!_moved) {
//        [_delegate draggableViewTouched:self];
//    } else {
//        [_delegate draggableViewReleased:self];
//    }
    
    
    [self moveTo:CGPointMake(pointX, pointY) delayTime:0];
    
    if([ViewPointManager defultManager].viewPointAry.count!=0)
    {
        [[ViewPointManager defultManager].viewPointAry removeAllObjects];
    }
    
    _moved = NO;

    [[ViewPointManager defultManager].viewPointAry addObject:[NSValue valueWithCGPoint:CGPointMake(pointX, pointY)]];
    
}

- (void)foldAnimation:(CGPoint)Point delayTime:(float)time AnimationType:(NSString *)type
{
    float pointX = Point.x;
    float pointY = Point.y;
    
    if([type isEqualToString:@"fold"])
    {
        [UIView animateWithDuration:0.2 delay:time options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            self.center = CGPointMake(pointX, pointY+5);
            
        } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.3 animations:^{
                 
                 self.center = CGPointMake(pointX, pointY);
                 
             }];
         }];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:time options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            self.center = CGPointMake(pointX, pointY-5);
            
        } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.3 animations:^{
                 
                 self.center = CGPointMake(pointX, pointY);
                 
             }];
         }];
    }
    
  
}


- (void)moveTo:(CGPoint)viewPoint delayTime:(float)time
{
    float pointX = viewPoint.x;
    float pointY = viewPoint.y;
    
    [UIView animateWithDuration:0.2 delay:time options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.center = CGPointMake(pointX, pointY);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

#pragma mark - Animations

- (CGFloat)_distanceFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    return hypotf(point1.x - point2.x, point1.y - point2.y);
}

- (CGFloat)_angleFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    CGFloat x = point2.x - point1.x;
    CGFloat y = point2.y - point1.y;
    
    return atan2f(x,y);
}

- (void)_moveByDeltaX:(CGFloat)x deltaY:(CGFloat)y
{
    [UIView animateWithDuration:0.3f animations:^{
//        CGPoint center = self.center;
//        center.x += x;
//        center.y += y;
        self.center = CGPointMake(x, y);
    }];
}

- (void)_beginHoldAnimation
{
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1)];
    animation.duration = 0.2f;
    
    self.layer.transform = [animation.toValue CATransform3DValue];
    [self.layer addAnimation:animation forKey:nil];
}

- (void)_beginReleaseAnimation
{
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"transform"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCATransform3D:self.layer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    animation.duration = 0.2f;
    
    self.layer.transform = [animation.toValue CATransform3DValue];
    [self.layer addAnimation:animation forKey:nil];
}

- (void)_snapViewCenterToPoint:(CGPoint)point edge:(CGRectEdge)edge
{
    CGPoint currentCenter = self.center;
    
    SKBounceAnimation *animation = [SKBounceAnimation animationWithKeyPath:@"position"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:currentCenter];
    animation.toValue = [NSValue valueWithCGPoint:point];
    animation.duration = 1.2f;
    self.layer.position = point;
    [self.layer addAnimation:animation forKey:nil];
}

@end
