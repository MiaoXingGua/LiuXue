//
//  userCount.h
//  AVOS_DEMO
//
//  Created by Albert on 13-9-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//


#import <AVOSCloud/AVOSCloud.h>


@interface UserCount : AVObject <AVSubclassing> 

+ (NSString *)parseClassName;

//用户关系
@property (nonatomic, assign) NSInteger numberOfFollows;//粉丝数
@property (nonatomic, assign) NSInteger numberOfFriends;//关注数
@property (nonatomic, assign) NSInteger numberOfBilaterals;//互粉数
@property (nonatomic, assign) NSInteger numberOfBanList;//黑名单数

@property (nonatomic, assign) NSInteger numberOfThreads;//发主题数
@property (nonatomic, assign) NSInteger numberOfPosts;//回答数
@property (nonatomic, assign) NSInteger numberOfComments;//评论数
@property (nonatomic, assign) NSInteger numberOfSupports;//赞数
@property (nonatomic, assign) NSInteger numberOfAbums;
@property (nonatomic, assign) NSInteger numberOfBestPosts;//最佳回答数
@property (nonatomic, assign) NSInteger numberOfFavicon;//收藏主题数

@end
