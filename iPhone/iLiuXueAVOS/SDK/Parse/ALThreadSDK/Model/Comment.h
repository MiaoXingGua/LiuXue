//
//  Comment.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class User;
@class Post;
@class ThreadContent;

@interface Comment : AVObject <AVSubclassing>

@property (nonatomic, retain) Post *post;

@property (nonatomic, retain) ThreadContent *content;//内容描述

@property (nonatomic, retain) User *postUser;//作者

@property (nonatomic, assign) int state;//状态 0:一般

@end
