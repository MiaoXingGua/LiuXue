//
//  ALNotificationOfFriend.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "NotificationOfFriend.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation NotificationOfFriend
@dynamic toUser,fromUser,type,isReaded,isDeleted;

+ (NSString *)parseClassName
{
    return @"NotificationOfFriend";
}

@end
