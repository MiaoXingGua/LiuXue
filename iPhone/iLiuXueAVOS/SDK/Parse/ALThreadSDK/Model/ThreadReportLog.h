//
//  ThreadReportLog.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class Thread;
@class Post;
@class User;
@class Comment;

@interface ThreadReportLog : AVObject <AVSubclassing>

@property (nonatomic, retain) Thread *thread;

@property (nonatomic, retain) Post *post;

@property (nonatomic, retain) Comment *comment;

@property (nonatomic, retain) User *fromUser;

@property (nonatomic, retain) NSString *reason;

@property (nonatomic, assign) int state;//状态 1:已读 0:未读  

@end
