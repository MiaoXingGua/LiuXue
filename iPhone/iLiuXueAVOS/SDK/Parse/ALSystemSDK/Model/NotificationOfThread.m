//
//  ALNotificationOfThread.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "NotificationOfThread.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation NotificationOfThread
@dynamic fromUser,type,thread,post,comment,isReaded,isDeleted;

+ (NSString *)parseClassName
{
    return @"NotificationOfThread";
}

@end
