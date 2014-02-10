//
//  MessageRemindViewController.m
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "MessageRemindViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

#import "ViewData.h"
#import "UnReadNotificationViewController.h"
#import "ReadNotificationViewController.h"
#import "AtViewController.h"

@interface MessageRemindViewController ()

@end

@implementation MessageRemindViewController

- (void)dealloc
{
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [ViewData defaultManager].showVc = 2;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIView *stateView = [[UIView alloc] init];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    stateView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [self.view addSubview:stateView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"消息提醒";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    
    UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
    [showLeftViewBtn setImage:[UIImage imageNamed:@"_0025_menu@2x.png"] forState:UIControlStateNormal];
    [showLeftViewBtn addTarget:self action:@selector(showLeftView) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showLeftViewBtn];
    
    UIButton *showrRightViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showrRightViewBtn.frame = CGRectMake(280, 10, 30, 30);
    [showrRightViewBtn setImage:[UIImage imageNamed:@"_0027_friends@2x.png"] forState:UIControlStateNormal];
    [showrRightViewBtn addTarget:self action:@selector(showRightView) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showrRightViewBtn];
    
    
    unReadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unReadBtn.frame = CGRectMake(8, 45, 202/2, 54/2);
    [unReadBtn setBackgroundImage:[UIImage imageNamed:@"_0000_图层-1.png"] forState:UIControlStateNormal];
    [unReadBtn setTitle:@"未读" forState:UIControlStateNormal];
    unReadBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [unReadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [unReadBtn addTarget:self action:@selector(showUnRead) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:unReadBtn];
    
    readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    readBtn.frame = CGRectMake(101+8, 45, 202/2, 54/2);
    [readBtn setTitle:@"已读" forState:UIControlStateNormal];
    readBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [readBtn setBackgroundImage:[UIImage imageNamed:@"_0004_图层-4.png"] forState:UIControlStateNormal];
    [readBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [readBtn addTarget:self action:@selector(showRead) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:readBtn];

    
    atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    atBtn.frame = CGRectMake(101+8+101, 45, 202/2, 54/2);
    [atBtn setTitle:@"@我" forState:UIControlStateNormal];
    atBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [atBtn setBackgroundImage:[UIImage imageNamed:@"_0005__-副本-19.png"] forState:UIControlStateNormal];
    [atBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [atBtn addTarget:self action:@selector(showAt) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:atBtn];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, 320, SCREEN_HEIGHT-80)];
    scrollView.contentSize = CGSizeMake(320*3, SCREEN_HEIGHT-80);
    scrollView.scrollEnabled=NO;
    [backgroundView addSubview:scrollView];
    [scrollView release];
    
    
    UnReadNotificationViewController *unreadView = [[UnReadNotificationViewController alloc] init];
    unreadView.view.frame = CGRectMake(0, -80, 320, SCREEN_HEIGHT);
    [scrollView addSubview:unreadView.view];
    [self addChildViewController:unreadView]; //将vc加入到root页面vc中
    [unreadView release];
    
    ReadNotificationViewController *readView = [[ReadNotificationViewController alloc] init];
    readView.view.frame = CGRectMake(320, -80, 320, SCREEN_HEIGHT);
    [scrollView addSubview:readView.view];
    [self addChildViewController:readView];
    [readView release];
    
    AtViewController *atView = [[AtViewController alloc] init];
    atView.view.frame = CGRectMake(640, -80, 320, SCREEN_HEIGHT);
    [scrollView addSubview:atView.view];
    [self addChildViewController:atView];
    [atView release];
}

//显示未读
- (void)showUnRead
{
    [unReadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [unReadBtn setBackgroundImage:[UIImage imageNamed:@"_0000_图层-1.png"] forState:UIControlStateNormal];
    
    [readBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [readBtn setBackgroundImage:[UIImage imageNamed:@"_0004_图层-4.png"] forState:UIControlStateNormal];

    [atBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [atBtn setBackgroundImage:[UIImage imageNamed:@"_0005__-副本-19.png"] forState:UIControlStateNormal];

    
    [UIView animateWithDuration:0.2 animations:^{
        scrollView.contentOffset = CGPointMake(0, 0);

    } completion:^(BOOL finished) {
        
    }];
}

//显示已读
- (void)showRead
{
    [unReadBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [unReadBtn setBackgroundImage:[UIImage imageNamed:@"_0003_图层-2.png"] forState:UIControlStateNormal];
    
    [readBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [readBtn setBackgroundImage:[UIImage imageNamed:@"_0001_图层-3.png"] forState:UIControlStateNormal];
    
    [atBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [atBtn setBackgroundImage:[UIImage imageNamed:@"_0005__-副本-19.png"] forState:UIControlStateNormal];

    
   
    [UIView animateWithDuration:0.2 animations:^{
        scrollView.contentOffset = CGPointMake(320, 0);
        
    } completion:^(BOOL finished) {
        
    }];
}

//显示@我
- (void)showAt
{
    [unReadBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [unReadBtn setBackgroundImage:[UIImage imageNamed:@"_0003_图层-2.png"] forState:UIControlStateNormal];

    [readBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [readBtn setBackgroundImage:[UIImage imageNamed:@"_0004_图层-4.png"] forState:UIControlStateNormal];

    [atBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [atBtn setBackgroundImage:[UIImage imageNamed:@"_0002_形状-6-副本-3.png"] forState:UIControlStateNormal];

    [UIView animateWithDuration:0.2 animations:^{
        scrollView.contentOffset = CGPointMake(640, 0);
        
    } completion:^(BOOL finished) {
        
    }];
}







#pragma mark ShowLeftView/RightView

- (void)showLeftView
{
    [self.sidePanelController showLeftPanelAnimated:YES];
}

- (void)showRightView
{
    [self.sidePanelController showRightPanelAnimated:YES];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
