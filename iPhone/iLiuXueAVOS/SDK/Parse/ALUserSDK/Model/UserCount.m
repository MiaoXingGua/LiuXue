//
//  userCount.m
//  AVOS_DEMO
//
//  Created by Albert on 13-9-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "UserCount.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation UserCount

@dynamic numberOfFollows,numberOfFriends,numberOfBanList,numberOfThreads,numberOfPosts,numberOfAbums,numberOfBestPosts;

+ (NSString *)parseClassName
{
    return @"UserCount";
}

@end
