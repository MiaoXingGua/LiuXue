//
//  SettingViewController.m
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "SettingViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "MLNavigationController.h"
#import "ViewData.h"
#import "ALUserEngine.h"
#import "CollectViewController.h"
#import "FinishPersonalDataViewController.h"
#import "ALXMPPEngine.h"
#import "MessageCenter.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)dealloc
{
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [ViewData defaultManager].showVc = 4;
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
    
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"设置";
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
    
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    versionLabel.text = @"版本：5.6";
    versionLabel.font = [UIFont systemFontOfSize:20];
    versionLabel.textColor = [UIColor blackColor];
    versionLabel.backgroundColor = [UIColor clearColor];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    versionLabel.center = CGPointMake(160, 200);
    [naviView addSubview:versionLabel];
    [versionLabel release];
    
    
//    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    checkBtn.frame = CGRectMake(0, 0, 100, 40);
//    checkBtn.center = CGPointMake(160, 250);
//    [checkBtn setTitle:@"检查更新" forState:UIControlStateNormal];
//    [checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [checkBtn addTarget:self action:@selector(checkVersion) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:checkBtn];
    
    
//    UIButton *logOutBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    logOutBtn.frame = CGRectMake(0, 0, 80, 50);
//    logOutBtn.center = CGPointMake(160, 250);
//    [logOutBtn setTitle:@"登出" forState:UIControlStateNormal];
//    [logOutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:logOutBtn];
    
//    UIButton *dataBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    dataBtn.frame = CGRectMake(0, 0, 80, 50);
//    dataBtn.center = CGPointMake(160, 320);
//    [dataBtn setTitle:@"资料" forState:UIControlStateNormal];
//    [dataBtn addTarget:self action:@selector(dataBtn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:dataBtn];
}

- (void)checkVersion
{
    
}

- (void)dataBtn
{
    FinishPersonalDataViewController *finish = [[FinishPersonalDataViewController alloc] init];
    [self.navigationController pushViewController:finish animated:YES];
    [finish release];
}

- (void)showcollect
{
    CollectViewController *collect = [[CollectViewController alloc] init];
    [self.navigationController pushViewController:collect AnimatedType:MLNavigationAnimationTypeOfScale];
    [collect release];
}

- (void)logOut
{
    [[ALUserEngine defauleEngine] logOut];
    [[ALXMPPEngine defauleEngine] logOut];
    
  //  [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    
    LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
    self.sidePanelController.leftPanel = login;
    
    if([ViewData defaultManager].homeVc!=nil)
    {
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].homeVc] autorelease];
        self.sidePanelController.centerPanel = n;
    }
    else
    {
        HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].homeVc = home;
    }
   
    [[MessageCenter defauleCenter] removeChatView:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logOut" object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(show) userInfo:nil repeats:NO];

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

- (void)show
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];

}

@end
