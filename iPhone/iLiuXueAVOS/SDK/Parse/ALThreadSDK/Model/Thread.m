//
//  Thread.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "Thread.h"
#import <AVOSCloud/AVSubclassing.h>


@implementation Thread

@dynamic title,content,forum,postUser,lastPoster,lastPostAt,type,flag,tags,location,place,posts;
@dynamic price,views,viewsOfToday,viewsOfYesterday,state,numberOfPosts,numberOfFavicon;
+ (NSString *)parseClassName
{
    return @"Thread";
}   

@end
