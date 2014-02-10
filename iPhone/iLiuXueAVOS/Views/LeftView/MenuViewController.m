//
//  MenuViewController.m
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCustomCell.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MLNavigationController.h"
#import "PublishRequirementsViewController.h"
#import "MessageRemindViewController.h"
#import "SettingViewController.h"
#import "HomeViewController.h"
#import "PersonalDataViewController.h"
#import "AppDelegate.h"
#import "ALUserEngine.h"
#import "ViewData.h"
#import "ALNotificationCenter.h"
#import "QuartzCore/QuartzCore.h"
#import "LoginViewController.h"
#import "ALXMPPEngine.h"
#import "MessageCenter.h"
//#import <ShareSDK/ShareSDK.h>

@interface MenuViewController ()

@end

@implementation MenuViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_JASIDE_LOAD_LEFT_PANEL object:nil];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refreashThreadCounts];
    
}

- (void)refreashThreadCounts
{
    if (![[ALUserEngine defauleEngine] isLoggedIn])
    {
        LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
        MLNavigationController *navigation = [[[MLNavigationController alloc] initWithRootViewController:login] autorelease];
        self.sidePanelController.leftPanel = navigation;
    }
    else
    {
        __block typeof(self) bself = self;

        __block UITableView *__tableview = _tableView;
        
        [[ALNotificationCenter defauleCenter] getNotificationsOfThreadCountWithType:ALThreadNotificationTypeOfThreadNewPost isUnread:YES block:^(NSInteger count, NSError *error) {
            
            bself.notReadPostCounts = count;
            
            [ViewData defaultManager].unReadNumber = count;
            
            [__tableview reloadData];
            
        }];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.notReadPostCounts = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreashThreadCounts) name:NOTIFICATION_JASIDE_LOAD_LEFT_PANEL object:nil];
    
    UIView *stateView = [[UIView alloc] init];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    stateView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:stateView];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0032_Background-副本.png"]];
    backgroundImage.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    [self.view addSubview:backgroundImage];
    [backgroundImage release];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
}


#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        if(SCREEN_HEIGHT==460)
        {
            return 160;
        }
        else
        {
            return 200;
        }
        
    }
    else
    {
        return 50;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *Cellidentifier = @"cell1";
        
    MenuCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if(cell==nil)
    {
        cell = [[[MenuCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if(indexPath.row==0)
    {
        
        cell.headView.hidden = NO;
        cell.headView.urlString = [ALUserEngine defauleEngine].user.headView.url;
        [cell.headView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        int _gender = [ALUserEngine defauleEngine].user.gender;
        //女
        if (_gender==0)
        {
            cell.headCoverImage.image = [UIImage imageNamed:@"nv.png"];
        }
        //男
        if (_gender==1)
        {
            cell.headCoverImage.image = [UIImage imageNamed:@"nan.png"];
        }
        //删除
        if (_gender==2)
        {
            cell.headCoverImage.image = [UIImage imageNamed:@"图层-20.png"];
        }
        cell.headCoverImage.hidden = NO;
        
        
        cell.userName.text = [ALUserEngine defauleEngine].user.nickName;
        
        CGSize userNameSize = [cell.userName.text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(256, 1000) lineBreakMode:0];
        cell.userName.frame = CGRectMake(0, 0, userNameSize.width, 30);
        cell.userName.center = CGPointMake(128-25, 140);
    
        if(SCREEN_HEIGHT==460)
        {
            cell.mainText.frame = CGRectMake(cell.userName.frame.origin.x+userNameSize.width+5, 130, 50, 20);
            cell.menuCellLine.center = CGPointMake(140, 160);

        }
        else
        {
            cell.mainText.frame = CGRectMake(cell.userName.frame.origin.x+userNameSize.width+5, 130, 50, 20);
            cell.menuCellLine.center = CGPointMake(140, 230);
        }
        
        
    }
    if(indexPath.row==1)
    {
        cell.titleImage.image = [UIImage imageNamed:@"_0015_home.png"];
        cell.titleImage.frame = CGRectMake(20, 15, 25, 23);
        cell.title.text = @"首页";
        cell.titleEnglish.text = @"Home";
        cell.menuCellLine.center = CGPointMake(160, 50);
    }
    if(indexPath.row==2)
    {
        cell.titleImage.image = [UIImage imageNamed:@"_0013_write.png"];
        cell.titleImage.frame = CGRectMake(20, 15, 22, 20);
        cell.title.text = @"发布需求";
        cell.titleEnglish.text = @"Publishing Requirements";
        cell.menuCellLine.center = CGPointMake(160, 50);
    }
    if(indexPath.row==3)
    {
        cell.titleImage.image = [UIImage imageNamed:@"_0014_feedback.png"];
        cell.titleImage.frame = CGRectMake(20, 15, 22, 21);
        cell.title.text = @"消息提醒";
        cell.titleEnglish.text = @"Message Remind";
        cell.menuCellLine.center = CGPointMake(160, 50);
        
        
        
        if (self.notReadPostCounts>0)
        {
            NSString *unReadStr = [NSString stringWithFormat:@"%d",self.notReadPostCounts];
            
            if (unReadStr.length>2)
            {
                unReadStr = @"99+";
            }
            
            if (Label_num==nil)
            {
                Label_num = [[UILabel alloc] init];
                Label_num.frame = CGRectMake(0, 0, 12+unReadStr.length*7, 17);
                [Label_num setTextAlignment:NSTextAlignmentCenter];
                Label_num.font = [UIFont systemFontOfSize:13];
                Label_num.layer.cornerRadius = 8;
                Label_num.text = unReadStr;
                Label_num.layer.borderWidth = 1.5;
                Label_num.center = CGPointMake(145, 20);
                Label_num.layer.borderColor = [UIColor whiteColor].CGColor;
                Label_num.font = [UIFont boldSystemFontOfSize:13];
                Label_num.backgroundColor = [UIColor redColor];
                Label_num.textColor = [UIColor whiteColor];
                [cell.contentView addSubview:Label_num];
                [Label_num release];
            }
            else
            {
                Label_num.frame = CGRectMake(0, 0, 12+unReadStr.length*7, 17);
                Label_num.center = CGPointMake(145, 20);
                Label_num.text = unReadStr;
            }
        }
        else
        {
            if (Label_num)
            {
                [Label_num removeFromSuperview];
                Label_num=nil;
            }
            
        }
        
    }
    
    if (indexPath.row==4)
    {
        cell.titleImage.image = [UIImage imageNamed:@"美国轶事.png"];
        cell.titleImage.frame = CGRectMake(16, 10, 30, 30);
        cell.title.text = @"美国轶事";
        cell.titleEnglish.text = @"Anecdotes";
        cell.menuCellLine.center = CGPointMake(160, 50);
    }
    
    if(indexPath.row==5)
    {
        cell.titleImage.image = [UIImage imageNamed:@"_0012_setting.png"];
        cell.titleImage.frame = CGRectMake(20, 15, 24, 24);
        cell.title.text = @"设置";
        cell.titleEnglish.text = @"Setting";
        cell.menuCellLine.center = CGPointMake(160, 50);
    }
    
    if(indexPath.row==6)
    {
        cell.titleImage.image = [UIImage imageNamed:@"登出.png"];
        cell.titleImage.frame = CGRectMake(18, 10, 30, 30);
        cell.title.text = @"登出";
        cell.titleEnglish.text = @"Logout";
        cell.menuCellLine.center = CGPointMake(160, 50);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==1)
    {
        if([ViewData defaultManager].homeVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].homeVc] autorelease];
            self.sidePanelController.centerPanel = n;
            
            return;
        }
        
        HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].homeVc = home;
        
    }
    
    if(indexPath.row==2)
    {
        if([ViewData defaultManager].pulishVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].pulishVc] autorelease];
            self.sidePanelController.centerPanel = n;
            
            return;
        }
        
        PublishRequirementsViewController *publish = [[[PublishRequirementsViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:publish] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].pulishVc = publish;

    }
    if(indexPath.row==3)
    {
        if([ViewData defaultManager].messageVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].messageVc] autorelease];
            self.sidePanelController.centerPanel = n;
            
            return;
        }
        
        MessageRemindViewController *message = [[[MessageRemindViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:message] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].messageVc = message;
    }
    if(indexPath.row==4)
    {
        if([ViewData defaultManager].newsVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].newsVc] autorelease];
            self.sidePanelController.centerPanel = n;
            
            return;
        }
        
        NewsListViewController *news = [[[NewsListViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:news] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].newsVc = news;
    }
    
    if(indexPath.row==5)
    {
        if([ViewData defaultManager].setVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].setVc] autorelease];
            self.sidePanelController.centerPanel = n;
            
            return;
        }
        
        SettingViewController *setting = [[[SettingViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:setting] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].setVc = setting;
    }
    
    if (indexPath.row==6)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要退出登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        [alert show];
        [alert release];
        alert=nil;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        if ([ViewData defaultManager].homeVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].homeVc] autorelease];
            self.sidePanelController.centerPanel = n;
        }
        else
        {
            HomeViewController *home = [[HomeViewController alloc] init];
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
            self.sidePanelController.centerPanel = n;
        }

        
        [self.sidePanelController showCenterPanelAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_LOG_OUT object:nil];
        [[MessageCenter defauleCenter] removeChatView:nil];
        
        [ViewData defaultManager].autoLogin=NO;
        [[ViewData defaultManager] stopNSTimer];
        
        LoginViewController *login = [[LoginViewController alloc] init];
        self.sidePanelController.leftPanel = login;
        [login release];
        
        
        [self performSelectorInBackground:@selector(logOutUser) withObject:nil];
    }
}

- (void)logOutUser
{
    [[ALUserEngine defauleEngine] logOut];
    [[ALXMPPEngine defauleEngine] logOut];
}

#pragma mark 个人主页
- (void)showUserInfo:(AsyncImageView *)info
{
    if ([[ALUserEngine defauleEngine] user])
    {
        PersonalDataViewController *personal = [[[PersonalDataViewController alloc] initWithUser:[[ALUserEngine defauleEngine] user] FromSelf:YES SelectFromCenter:NO] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:personal] autorelease];
        self.sidePanelController.centerPanel = n;
    }
}

#pragma mark didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
