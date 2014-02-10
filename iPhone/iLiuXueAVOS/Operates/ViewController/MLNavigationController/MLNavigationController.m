//
//  MLNavigationController.m
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "MLNavigationController.h"
#import <QuartzCore/QuartzCore.h>



//@implementation UIViewController (MLNavigationController)
//
//- (MLNavigationController *)mlNavigationController
//{
//    return (MLNavigationController *)self.navigationController ;
//}
//
//@end

@implementation UINavigationController (MLNavigationController)

- (void)pushViewController:(UIViewController *)viewController AnimatedType:(MLNavigationAnimationType)animatedType
{
    if ([self isKindOfClass:[MLNavigationController class]]) {
        
        [self pushViewController:viewController AnimatedType:animatedType];
    }
}

- (void)popViewControllerAnimated
{
    if ([self isKindOfClass:[MLNavigationController class]]) {
        
        [self popViewControllerAnimated];
    }
}

@end

@interface MLNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    
    UIView *blackMask;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;
@property (nonatomic,assign) BOOL isMoving;

@end

@implementation MLNavigationController


- (void)dealloc
{
    self.screenShotsList = nil;
    self.operationType=nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // draw a shadow for navigation view to differ the layers obviously.
    // using this way to draw shadow will lead to the low performace
    // the best alternative way is making a shadow image.
    //
    //self.view.layer.shadowColor = [[UIColor blackColor]CGColor];
    //self.view.layer.shadowOffset = CGSizeMake(5, 5);
    //self.view.layer.shadowRadius = 5;
    //self.view.layer.shadowOpacity = 1;
    
    [self setNavigationBarHidden:YES];

    self.operationType = [NSMutableArray arrayWithCapacity:0];
    self.screenShotsList = [[[NSMutableArray alloc]initWithCapacity:2]autorelease];
    self.canDragBack = YES;
    
    UIImageView *shadowImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]]autorelease];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    
    UIPanGestureRecognizer *recognizer = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(paningGestureReceive:)]autorelease];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// override the push method
- (void)pushViewController:(UIViewController *)viewController AnimatedType:(MLNavigationAnimationType)animatedType
{
    [self.operationType addObject:[NSNumber numberWithInt:animatedType]];
    [self.screenShotsList addObject:[self capture]];

    switch (animatedType)
    {
        case MLNavigationAnimationTypeOfNone:
           // self.animationType = MLNavigationAnimationTypeOfNone;
            [super pushViewController:viewController animated:YES];
            break;
        
        case MLNavigationAnimationTypeOfScale:
           // self.animationType = MLNavigationAnimationTypeOfScale;
            [self usePushAnimationTypeOfScale:viewController CurrentImage:[self.screenShotsList lastObject]];
            break;
            
        default:
            break;
    }
        
  
}

- (void)usePushAnimationTypeOfScale:(UIViewController *)viewController CurrentImage:(UIImage *)currentimage
{
    CGRect frame = self.view.frame;
    
    UIView *backgroundView1 = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
    backgroundView1.backgroundColor = [UIColor blackColor];
    [self.visibleViewController.view.superview addSubview:backgroundView1];
    
    UIImage *lastScreenShot = [self.screenShotsList lastObject];
    
    UIImageView *lastScreenShotView1 = [[[UIImageView alloc]initWithImage:lastScreenShot]autorelease];
    lastScreenShotView1.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [backgroundView1 addSubview:lastScreenShotView1];
    
    UIView *blackMask1 = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
    blackMask1.backgroundColor = [UIColor blackColor];
    blackMask1.alpha = 0;
    [backgroundView1 addSubview:blackMask1];
    
    
    UIViewController *nextVC = [viewController retain];
    [self.visibleViewController.view.superview addSubview:nextVC.view];
    nextVC.view.frame = CGRectMake(320, 0, 320, self.view.frame.size.height);
    
    if(nextVC)
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            nextVC.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
            lastScreenShotView1.transform = CGAffineTransformMakeScale(0.9, 0.9);
            blackMask1.alpha = 0.7;
            
        } completion:^(BOOL finished) {
            
            [nextVC.view removeFromSuperview];
            [backgroundView1 removeFromSuperview];
            
            [super pushViewController:nextVC animated:NO];
            
            [nextVC.view removeFromSuperview];
            [nextVC release];
        }];
    }

}

// override the pop method
- (void)popViewControllerAnimated
{
    int animationType = [[self.operationType lastObject] intValue];
    
    if(animationType == MLNavigationAnimationTypeOfNone)
    {
        [super popViewControllerAnimated:YES];
    }
    if(animationType == MLNavigationAnimationTypeOfScale)
    {
        [self usePopAnimationTypeOfScale];
    }
    
    [self.screenShotsList removeLastObject];
    [self.operationType removeLastObject];
}

- (void)usePopAnimationTypeOfScale
{
    CGRect frame = self.view.frame;
    
    UIImageView *topView = [[[UIImageView alloc] initWithImage:[self capture]] autorelease];
    topView.frame = CGRectMake(0, 0, 320, frame.size.height);
//
    UIView *backgroundView1 = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
    backgroundView1.backgroundColor = [UIColor blackColor];
    [self.view.superview addSubview:backgroundView1];
    
    UIImage *lastScreenShot = [self.screenShotsList lastObject];
    
    UIImageView *lastScreenShotView1 = [[[UIImageView alloc]initWithImage:lastScreenShot]autorelease];
    lastScreenShotView1.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    lastScreenShotView1.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [backgroundView1 addSubview:lastScreenShotView1];
    
    UIView *blackMask1 = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
    blackMask1.backgroundColor = [UIColor blackColor];
    blackMask1.alpha = 0.7;
    [backgroundView1 addSubview:blackMask1];
    
    

    [self.view.superview addSubview:topView];

    
//    CGRect frame2 = self.view.frame;
//    frame2.origin.x = 320;


    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        //self.view.frame = CGRectMake(320, 0, self.view.frame.size.width, self.view.frame.size.height);
        topView.frame = CGRectMake(320, 0, self.view.frame.size.width, self.view.frame.size.height);
        lastScreenShotView1.transform = CGAffineTransformMakeScale(1, 1);
        blackMask1.alpha = 0;
            
    } completion:^(BOOL finished) {
            
        [topView removeFromSuperview];
        [backgroundView1 removeFromSuperview];
            
        [super popViewControllerAnimated:NO];
            
    }];
    

    
    
}

#pragma mark - Utility Methods -

// get the current view screen shot
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{    
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x/3200)+0.9;
    float alpha = 0.7 - (x/457);
    if(alpha<=0)
    {
        alpha=0;
    }
    
    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    //如果是None类型，则不支持手势滑动返回
    int animationType = [[self.operationType lastObject] intValue];
    
    if(animationType != MLNavigationAnimationTypeOfScale)
    {
        return;
    }
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        
        lastScreenShotView = [[[UIImageView alloc]initWithImage:lastScreenShot]autorelease];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
                
                [self.screenShotsList removeLastObject];
                [self.operationType removeLastObject];
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

@end
