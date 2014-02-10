//
//  MessageCenter.m
//  iLiuXue
//
//  Created by Albert on 13-9-5.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "MessageCenter.h"
#import "VCConfig.h"
#import "ALXMPPEngine.h"
#import "ViewPointManager.h"
#import "AsyncImageView.h"
#import "CHDraggableView.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "ViewData.h"
#import "MLNavigationController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

@implementation MessageCenter
{
    AppDelegate *_appDelegate;
    NSDictionary *_userInfo;
}

static MessageCenter *_myCenter=nil;

@synthesize isShowChatView;
@synthesize userInfos = _userInfos;
@synthesize sendUser = _sendUser;
@synthesize lastUser = _lastUser;

- (void)dealloc
{
    [_sendUser release];
    [_userInfos release];
    [_userInfo release];
    [_myCenter release];
    
    [super dealloc];
}

+ (MessageCenter *)defauleCenter
{
    if(_myCenter==nil)
    {
        _myCenter = [[MessageCenter alloc] init];
    }
    
    return _myCenter;
}


- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage:) name:NOTIFICATION_NEW_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatView) name:@"ShowChatViewFromNotifition" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDeleteView:) name:@"showDeleteView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidenDeleteView:) name:@"hidenDeleteView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginDeleteAnimation:) name:@"beginDeleteAnimation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDeleteAnimation:) name:@"stopDeleteAnimation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeChatView:) name:@"removeChatView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatView) name:OPENCHATVIEWFROMNOTIFICATION object:nil];

    _timer=nil;
    deleteView=nil;
}


- (void)receiveNewMessage:(NSNotification *)info
{
    if ([ALUserEngine defauleEngine].isLoggedIn==NO || [ALXMPPEngine defauleEngine].isLoggedIn==NO)
    {
        return;
    }
    
    
    self.userInfos = [NSMutableDictionary dictionaryWithDictionary:info.userInfo];
    User *_temp = (User *)[self.userInfos objectForKey:@"sender"];
    
    NSString *_tpye = [self.userInfos objectForKey:@"type"];
    
    
    if ([_tpye isEqualToString:@"group"])
    {
        self.userInfos=nil;
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addUnReadNum" object:_temp];

    
    if([ViewData defaultManager].isShowChatView==YES || [ViewData defaultManager].isShowGroupView==YES || [ViewData defaultManager].isShowUnReadView==YES)
    {
        self.userInfos=nil;

        return;
    }
    
    
    if (self.userInfos)
    {
        
        if (unReadNum==0)
        {
            self.lastUser = (User *)[self.userInfos objectForKey:@"sender"];
            unReadNum+=1;
        }
        else
        {
            self.sendUser = (User *)[self.userInfos objectForKey:@"sender"];
            
            if ([self.sendUser.objectId isEqualToString:self.lastUser.objectId])
            {
                unReadNum +=1;
            }
            else
            {
                unReadNum=0;
                unReadNum +=1;
            }
            
            self.lastUser = self.sendUser;
        }
        
        
        [self performSelectorInBackground:@selector(downLoadUser) withObject:nil];
    }

}

- (void)downLoadUser
{
    self.sendUser = (User *)[[self.userInfos objectForKey:@"sender"] fetchIfNeeded];

    [self performSelectorOnMainThread:@selector(promptView) withObject:nil waitUntilDone:YES];
}

- (void)promptView
{
    CGPoint ViewPoint;
    
    if ([ViewPointManager defultManager].viewPointAry.count==0)
    {
        ViewPoint = CGPointMake(290, 60);
    }
    else
    {
        ViewPoint = [[[ViewPointManager defultManager].viewPointAry lastObject] CGPointValue];
    }
    
    int counts = [ViewPointManager defultManager].viewAry.count;
    
    for (int i=0; i<counts; i++)
    {
        CHDraggableView *temp = [[ViewPointManager defultManager].viewAry objectAtIndex:i];
        [temp removeFromSuperview];
        temp=nil;
    }
    
    [[ViewPointManager defultManager].viewPointAry removeAllObjects];
    [[ViewPointManager defultManager].viewAry removeAllObjects];
    
    [[ViewPointManager defultManager].viewPointAry addObject:[NSValue valueWithCGPoint:ViewPoint]];
    
    UIWindow *_window = [UIApplication sharedApplication].keyWindow;
    
    BOOL gender = self.sendUser.gender;
    
    CHDraggableView *draggableView = [[CHDraggableView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    draggableView.tag = [ViewPointManager defultManager].viewAry.count+1000;
    draggableView.center = ViewPoint;

    
    UIImageView *senderImage = [[UIImageView alloc] init];
    senderImage.frame = CGRectMake(0, 0, 60, 60);
    
    if (gender==0)
    {
        senderImage.image = [UIImage imageNamed:@"nv.png"];
    }
    else
    {
        senderImage.image = [UIImage imageNamed:@"nan.png"];
    }
    [draggableView addSubview:senderImage];


    AsyncImageView *_headAsyView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 54) ImageState:0];
    _headAsyView.urlString = self.sendUser.headView.url;
    _headAsyView.userInteractionEnabled = NO;
    _headAsyView.center = CGPointMake(CGRectGetMidX(draggableView.bounds), CGRectGetMidY(draggableView.bounds));
    [draggableView addSubview:_headAsyView];
    
    [_window addSubview:draggableView];
    
    NSString *unReadStr = [NSString stringWithFormat:@"%d",unReadNum];

    UILabel *Label_num = [[UILabel alloc] init];
    Label_num.text = unReadStr;

    if (unReadStr.length==1)
    {
        Label_num.frame = CGRectMake(40, 2, 12+unReadStr.length*7, 17);
    }
    if (unReadStr.length==2)
    {
        Label_num.frame = CGRectMake(35, 2, 12+unReadStr.length*7, 17);
    }
    if (unReadStr.length>2)
    {
        Label_num.frame = CGRectMake(30, 2, 12+3*7, 17);
        Label_num.text = @"99+";
    }
    
    [Label_num setTextAlignment:NSTextAlignmentCenter];
    Label_num.font = [UIFont systemFontOfSize:13];
    Label_num.layer.cornerRadius = 8;
    Label_num.layer.borderWidth = 1.5;
    Label_num.layer.borderColor = [UIColor whiteColor].CGColor;
    Label_num.font = [UIFont boldSystemFontOfSize:13];
    Label_num.backgroundColor = [UIColor redColor];
    Label_num.textColor = [UIColor whiteColor];
    [draggableView addSubview:Label_num];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        draggableView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            draggableView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
        }];
    }];
    
    [[ViewPointManager defultManager].viewAry addObject:draggableView];
    
    [senderImage release];
    [Label_num release];
    [_headAsyView release];
    [draggableView release];
}


- (void)showChatView
{
    if (!self.sendUser)
    {
        return;
    }
    
    unReadNum = 0;
    
    [[ALXMPPEngine defauleEngine] beganToChatWithUser:self.sendUser block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            deleteView.hidden = YES;
            isShowChatView = YES;
            
            if([ViewPointManager defultManager].viewAry.count!=0)
            {
                CHDraggableView *chd = [[ViewPointManager defultManager].viewAry lastObject];
                [chd removeFromSuperview];
                chd=nil;
                [[ViewPointManager defultManager].viewAry removeAllObjects];
                [[ViewPointManager defultManager].viewPointAry removeAllObjects];
            }
            
            UIWindow *_window = [UIApplication sharedApplication].keyWindow;
            
            ChatViewController* _chatView = [[ChatViewController alloc] initWithUser:self.sendUser fromNotifition:self.userInfos IsFromNotifition:YES];
            _chatView.view.frame = CGRectMake(0, 20, 320, _window.frame.size.height);
            

            int _showVcNum = [ViewData defaultManager].showVc;
            
            if (_showVcNum==0)
            {
                [[ViewData defaultManager].homeVc.sidePanelController showCenterPanelAnimated:NO];
                
                [[ViewData defaultManager].homeVc.navigationController pushViewController:_chatView AnimatedType:MLNavigationAnimationTypeOfNone];
            }
            if (_showVcNum==1)
            {
                [[ViewData defaultManager].pulishVc.sidePanelController showCenterPanelAnimated:NO];

                [[ViewData defaultManager].pulishVc.navigationController pushViewController:_chatView AnimatedType:MLNavigationAnimationTypeOfNone];
            }
            if (_showVcNum==2)
            {
                [[ViewData defaultManager].messageVc.sidePanelController showCenterPanelAnimated:NO];

                [[ViewData defaultManager].messageVc.navigationController pushViewController:_chatView AnimatedType:MLNavigationAnimationTypeOfNone];
            }
            if (_showVcNum==3)
            {
                [[ViewData defaultManager].newsVc.sidePanelController showCenterPanelAnimated:NO];

                [[ViewData defaultManager].newsVc.navigationController pushViewController:_chatView AnimatedType:MLNavigationAnimationTypeOfNone];
            }
            if (_showVcNum==4)
            {
                [[ViewData defaultManager].setVc.sidePanelController showCenterPanelAnimated:NO];

                [[ViewData defaultManager].setVc.navigationController pushViewController:_chatView AnimatedType:MLNavigationAnimationTypeOfNone];
            }
            
        
            [_chatView release];
        }
        else
        {
            
        }
    }];
}

#pragma mark 删除动画
- (void)beginDeleteAnimation:(NSNotification *)info
{
    if(_timer==nil)
    {
        deleteView.image = [UIImage imageNamed:@"OR delete.png"];
        [self deleteAnimation];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(deleteAnimation) userInfo:nil repeats:YES];
    }
}

- (void)removeChatView:(NSNotification *)info
{
    unReadNum=0;
    isShowChatView = NO;
    deleteView.hidden = YES;
    deleteView.image = [UIImage imageNamed:@"_0008_delete.png"];
    
    __block CHDraggableView *chyView = [[ViewPointManager defultManager].viewAry lastObject];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        chyView.alpha = 0;
    } completion:^(BOOL finished) {
        [chyView removeFromSuperview];
        chyView = nil;
    }];
    
    int counts = [ViewPointManager defultManager].viewAry.count;

    if (counts>0)
    {
        for (int i=0; i<counts; i++)
        {
            CHDraggableView *temp = [[ViewPointManager defultManager].viewAry objectAtIndex:i];
            [temp removeFromSuperview];
            temp=nil;
        }
    }
    
 
    [[ViewPointManager defultManager].viewPointAry removeAllObjects];
}

- (void)stopDeleteAnimation:(NSNotification *)info
{
    deleteView.image = [UIImage imageNamed:@"_0008_delete.png"];
    [_timer invalidate];
    _timer=nil;
}

- (void)deleteAnimation
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        deleteView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            deleteView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            //[self deleteAnimation];
        }];
    }];
}

- (void)showDeleteView:(NSNotification *)info
{
    if(deleteView==nil)
    {
        UIWindow *_window = [UIApplication sharedApplication].keyWindow;

        deleteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0008_delete.png"]];
        deleteView.frame = CGRectMake(0, 0, 116/2, 116/2);
        deleteView.center = CGPointMake(160, _window.frame.size.height-80);
        [_window addSubview:deleteView];
        [deleteView release];
    }
    
    deleteView.hidden = NO;
}

- (void)hidenDeleteView:(NSNotification *)info
{
    deleteView.hidden = YES;
    deleteView.image = [UIImage imageNamed:@"_0008_delete.png"];
}

@end
