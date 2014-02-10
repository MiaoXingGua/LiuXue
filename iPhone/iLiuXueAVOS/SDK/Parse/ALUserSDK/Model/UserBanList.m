//
//  UserBanList.m
//  AVOS_DEMO
//
//  Created by Albert on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "UserBanList.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation UserBanList

@dynamic fromUser,toUser,description;

+ (NSString *)parseClassName
{
    return @"UserBanList";
}

@end
