//
//  ALNotificationOfFriend.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "ALNotificationConfig.h"

@interface NotificationOfFriend : AVObject <AVSubclassing>

@property (nonatomic, retain) User *toUser;

@property (nonatomic, retain) User *fromUser;

@property (nonatomic, assign) ALFriendNotificationType type;

@property (nonatomic, assign) BOOL isReaded;

@property (nonatomic, assign) BOOL isDeleted;

@end
