//
//  Friend.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "Friend.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation Friend

@dynamic User,bkName,state;

+ (NSString *)parseClassName
{
    return @"Friend";
}

@end
