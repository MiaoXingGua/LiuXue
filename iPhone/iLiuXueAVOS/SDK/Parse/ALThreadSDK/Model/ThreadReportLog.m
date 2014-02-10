//
//  ThreadReportLog.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ThreadReportLog.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation ThreadReportLog

@dynamic thread,post,comment,fromUser,reason;

+ (NSString *)parseClassName
{
    return @"ThreadReportLog";
}


@end
