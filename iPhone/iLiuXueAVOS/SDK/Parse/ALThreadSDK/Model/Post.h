//
//  Post.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class User;
@class Thread;
@class ThreadContent;

@interface Post : AVObject <AVSubclassing>

//@property (nonatomic, retain) NSString *title;//主题名

@property (nonatomic, retain) Thread *thread;

@property (nonatomic, retain) ThreadContent *content;//内容描述

@property (nonatomic, retain) User *postUser;//作者

@property (nonatomic, retain) AVGeoPoint *location;//发帖地点

@property (nonatomic, retain) NSString *place;//发帖地点

@property (nonatomic, assign) int numberOfSupports;//赞数

//@property (nonatomic, retain) AVRelation *supportUser;//赞 //User

@property (nonatomic, assign) int numberOfComments;//评论数

@property (nonatomic, retain) AVRelation *comments;//评论 //Comment

@property (nonatomic, assign) int state;//状态 0:一般 1:最佳答案

@end
