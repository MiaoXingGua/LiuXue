//
//  AppDelegate.m
//  iLiuXueAVOS
//
//  Created by Albert on 13-12-22.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

//parse
//#define AVOS_APP_ID @"64a1G4wbJEW5hBelwJc42za9Fjc29fJflic7Ukv7"
//#define AVOS_APP_KEY @"Yxqkguy2J1srjBfn74Pf3fElkatG0NDz45Qy8IDS"

//avos
#define AVOS_APP_ID @"m4w0zqq4se2ppkrsilj1zck1mflep40z4u97wryups3f5l2f"
#define AVOS_APP_KEY @"n9uk90lg83r5z3p4agl0xo59dyxltwj5sb2qb19jmapcsfdb"

#import "AppDelegate.h"

#import <AVOSCloud/AVOSCloud.h>
#import "ALXMPPSDK.h"
#import "ALUserSDK.h"
#import "ALGPSHelper.h"
#import "ALCreditSDK.h"
#import "ALThreadSDK.h"
#import "ALNotificationSDK.h"

#import "HomeViewController.h"
#import "MenuViewController.h"
#import "LinkManViewController.h"
#import "LoginViewController.h"
#import "MLNavigationController.h"

#import "ViewData.h"
#import "ALFMDBHelper.h"
#import "MessageCenter.h"

#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[CustomWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    int iosversion = [[[UIDevice currentDevice] systemVersion] intValue];
    
    if(iosversion>=7)
    {
        [ViewData defaultManager].version=7;
        [ViewData defaultManager].versionHeight=20;
    }
    else
    {
        [ViewData defaultManager].version=6;
        [ViewData defaultManager].versionHeight=0;
    }
    
    [[ALFMDBHelper shareDBHelper] setApplicationDataBaseName:@"userXmppInfo.sqlite"];
    
    [ALXMPPSDK registerLKSDK];
    [ALUserSDK registerLKSDK];
    [ALThreadSDK registerLKSDK];
    [ALNotificationSDK registerLKSDK];
    [ALCreditSDK registerLKSDK];
    
    [AVOSCloud setApplicationId:AVOS_APP_ID clientKey:AVOS_APP_KEY];
    [AVOSCloud useAVCloudCN];
    
    [User currentUser];
    AVACL *defaultACL = [AVACL ACL];
    [defaultACL setPublicWriteAccess:YES];
    [defaultACL setPublicReadAccess:YES];
    [AVACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    //打开新消息监听
    [[MessageCenter defauleCenter] addNotification];
    
    //注册shareSDK
    [ShareSDK registerApp:@"api20"];
    
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
                               appSecret:@"0334252914651e8f76bad63337b3b78f"
                             redirectUri:@"http://appgo.cn"];
    
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"];
    
    //添加QQ空间应用
    [ShareSDK connectQZoneWithAppKey:@"100371282"
                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"];
    
    //添加微信
    [ShareSDK connectWeChatWithAppId:@"wx6dd7a9b94f3dd72a" //此参数为申请的微信AppID
                           wechatCls:[WXApi class]];
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //PUSH进入程序
    if (application.applicationIconBadgeNumber != 0)
    {
        application.applicationIconBadgeNumber = 0;
        //存储在当前安装deviceToken解析并保存它
        [[AVInstallation currentInstallation] saveInBackground];
    }
    
    [self handlePush:launchOptions];
    
    
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.panelViewController = [[[JASidePanelController alloc] init] autorelease];
    self.panelViewController.shouldDelegateAutorotateToVisiblePanel = NO;
    
    if([[ALUserEngine defauleEngine] isLoggedIn]==YES)
    {
        MenuViewController *menu = [[[MenuViewController alloc] init] autorelease];
        MLNavigationController *navigation = [[[MLNavigationController alloc] initWithRootViewController:menu] autorelease];
        self.panelViewController.leftPanel = navigation;
    }
    else
    {
        LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
        MLNavigationController *navigation = [[[MLNavigationController alloc] initWithRootViewController:login] autorelease];
        self.panelViewController.leftPanel = navigation;
    }
    
    
    HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
    MLNavigationController *navigation3 = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
	self.panelViewController.centerPanel = navigation3;
    [ViewData defaultManager].homeVc = home;
    
    LinkManViewController *link = [[[LinkManViewController alloc] init] autorelease];
    MLNavigationController *navigation2 = [[[MLNavigationController alloc] initWithRootViewController:link] autorelease];
	self.panelViewController.rightPanel = navigation2;
    
	self.window.rootViewController = self.panelViewController;
    
    //定位
    [ALGPSHelper OpenGPS];
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

//通知来时应用程序已经打开了
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"receviedPushOfUserInfo = %@", userInfo);
    if (application.applicationState == UIApplicationStateActive)
    {
        if (customBar==nil)
        {
            UIColor *_color;
            
            if ([ViewData defaultManager].version>=7)
            {
                _color = [UIColor blackColor];
            }
            else
            {
                _color = [UIColor blackColor];
            }
            
            
            customBar = [[CustomStatueBar alloc] initWithFrame:CGRectMake(320-120, 0, 120, 20) UserColor:_color];
            customBar.tapdelegate = self;
        }
        
        BOOL _from = [[userInfo valueForKey:@"isFromChatUser"] boolValue];
        
        if (_from==YES)
        {
            if ([ViewData defaultManager].isShowChatView==NO && [ViewData defaultManager].isShowGroupView==NO)
            {
                customBar.isfromuserchat=YES;
                [customBar showStatusMessage:@"您收到一条新消息！"];
            }
        }
        else
        {
            customBar.isfromuserchat=NO;
            [customBar showStatusMessage:@"您收到一条新提醒！"];
        }
     
    }
    else
    {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}


- (void)didSelectMessageRemind
{
    if (customBar.isfromuserchat==YES)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:OPENCHATVIEWFROMNOTIFICATION object:nil];
    }
    else
    {
        if (![ViewData defaultManager].isShowChatView && ![ViewData defaultManager].isShowGroupView)
        {
            MessageRemindViewController *message = [[[MessageRemindViewController alloc] init] autorelease];
            MLNavigationController *navigation3 = [[[MLNavigationController alloc] initWithRootViewController:message] autorelease];
            self.panelViewController.centerPanel = navigation3;
            [ViewData defaultManager].messageVc = message;
            
        }
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([ViewData defaultManager].autoLogin==YES)
    {
        [[ViewData defaultManager] setNSTimer];
    }
    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)printLog:(NSString*)log
{
    NSLog(@"%@",log); //用于xcode日志输出
}

//当一个应用程序打开了从一个通知
- (void)handlePush:(NSDictionary *)launchOptions
{
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Create a pointer to the Photo object
    NSLog(@"notificationPayload = %@",notificationPayload);
    
    
    // 判断：如果应用程序的启动是因为一个推送通知
    if (notificationPayload)
    {
//        UIAlertView *aV = [[UIAlertView alloc] initWithTitle:@"您有一个新的提醒" message:[NSString stringWithFormat:@"%@",launchOptions] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [aV show];
//        [aV release];
//        NSLog(@"应用程序的启动是因为一个推送通知!!!");
        
        if (![ViewData defaultManager].isShowChatView && ![ViewData defaultManager].isShowGroupView)
        {
            MessageRemindViewController *message = [[[MessageRemindViewController alloc] init] autorelease];
            MLNavigationController *navigation3 = [[[MLNavigationController alloc] initWithRootViewController:message] autorelease];
            self.panelViewController.centerPanel = navigation3;
            [ViewData defaultManager].messageVc = message;
            
        }
    }
}


@end
