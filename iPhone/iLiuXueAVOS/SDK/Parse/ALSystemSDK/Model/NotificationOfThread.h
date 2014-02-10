//
//  ALNotificationOfThread.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "ALNotificationConfig.h"

@class User;
@class Thread;
@class Post;
@class Comment;

@interface NotificationOfThread : AVObject <AVSubclassing>

@property (nonatomic, retain) User *toUser;

@property (nonatomic, retain) User *fromUser;

@property (nonatomic, assign) ALThreadNotificationType type;

@property (nonatomic, retain) Thread *thread;

@property (nonatomic, retain) Post *post;

@property (nonatomic, retain) Comment *comment;

@property (nonatomic, assign) BOOL isReaded;

@property (nonatomic, assign) BOOL isDeleted;

@end
