//
//  UserFollow.m
//  AVOS_DEMO
//
//  Created by Albert on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "UserRelation.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation UserRelation

@dynamic friends,follows,banList,user;

+ (NSString *)parseClassName
{
    return @"UserRelation";
}

@end
