//
//  ViewData.h
//  liuxue
//
//  Created by superhomeliu on 13-7-31.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeViewController.h"
#import "MessageRemindViewController.h"
#import "PublishRequirementsViewController.h"
#import "SettingViewController.h"
#import "NewsListViewController.h"

@interface ViewData : NSObject
{
    HomeViewController *_homeVc;
    MessageRemindViewController *_messageVc;
    PublishRequirementsViewController *_pulishVc;
    SettingViewController *_setVc;
    NewsListViewController *_newsVc;
    
    
    NSTimer *_timer;
}

@property(nonatomic,assign)float leftVisibleWidth;
@property(nonatomic,assign)float rightVisibleWidth;
@property(nonatomic,retain)HomeViewController *homeVc;
@property(nonatomic,retain)MessageRemindViewController *messageVc;
@property(nonatomic,retain)PublishRequirementsViewController *pulishVc;
@property(nonatomic,retain)SettingViewController *setVc;
@property(nonatomic,retain)NewsListViewController *newsVc;
@property(nonatomic,assign)int version;
@property(nonatomic,assign)int versionHeight;
@property(nonatomic,assign)BOOL logOut;
@property(nonatomic,assign)int unReadNumber;
@property(nonatomic,assign)BOOL isShowGroupView;
@property(nonatomic,assign)BOOL isShowChatView;
@property(nonatomic,assign)BOOL isShowUnReadView;
@property(nonatomic,assign)int showVc;
@property(nonatomic,retain)NSString *groupId;
@property(nonatomic,assign)BOOL autoLogin;

+ (ViewData *)defaultManager;
- (void)setNSTimer;
- (void)stopNSTimer;

@end

