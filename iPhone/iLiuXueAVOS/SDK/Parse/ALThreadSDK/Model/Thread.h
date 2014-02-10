//
//  Thread.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class Forum;
@class User;
@class ThreadType;
@class ThreadFlag;
@class ThreadContent;

@interface Thread : AVObject <AVSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString *title;//主题名

@property (nonatomic, retain) ThreadContent *content;//主题描述

@property (nonatomic, retain) Forum *forum;//所属板块板块

@property (nonatomic, retain) User *postUser;//作者

@property (nonatomic, retain) User *lastPoster;//最后回帖人

@property (nonatomic, retain) NSDate *lastPostAt;//最后回复时间

@property (nonatomic, retain) ThreadType *type;//主题类型（目前只有悬赏）

@property (nonatomic, retain) ThreadFlag *flag;//主题 头

@property (nonatomic, retain) NSString *tags;//标签 [tag]xxx[/tag]

@property (nonatomic, assign) int price;//积分

@property (nonatomic, assign) int views;//阅览次数

@property (nonatomic, assign) int viewsOfToday;//今天阅览次数

@property (nonatomic, assign) int viewsOfYesterday;//昨天阅览次数

@property (nonatomic, retain) AVGeoPoint *location;//发帖地点

@property (nonatomic, retain) NSString *place;//发帖地点

@property (nonatomic, assign) int state;//状态 -1:关闭 0:一般 1:完成

@property (nonatomic, assign) int numberOfPosts;

@property (nonatomic, retain) AVRelation *posts;//回复主题的帖子 //Post

@property (nonatomic, assign) int numberOfFavicon;//收藏数

//@property (nonatomic, retain) AVRelation *faviconUser;//收藏人 //user

@end
