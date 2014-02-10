//
//  LevelRule.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "LevelRule.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation LevelRule
@dynamic level,experienceLimit,acceptCount,acceptRate;
+ (NSString *)parseClassName
{
    return @"LevelRule";
}

@end

