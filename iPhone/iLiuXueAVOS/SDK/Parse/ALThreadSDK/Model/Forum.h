//
//  Forum.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface Forum : AVObject <AVSubclassing>

@property (nonatomic, retain) NSString *name;//板块名

@property (nonatomic, retain) Forum *upFroum;//上一级板块

@property (nonatomic, assign) int state;//状态 0：隐藏 1：一般

@property (nonatomic, retain) AVRelation *threadType;//悬赏，投票

@property (nonatomic, retain) AVRelation *threadFlag;//住房，考试，工作...

@property (nonatomic, assign) int numberOfTreads;//主题数

@property (nonatomic, assign) int numberOfPosts;//发帖数

@property (nonatomic, assign) int numberOfTodayPosts;//发帖数

@property (nonatomic, assign) int numberOfYesterdayPosts;//发帖数

@end
