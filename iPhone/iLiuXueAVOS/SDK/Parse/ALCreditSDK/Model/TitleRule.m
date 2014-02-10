//
//  TitleRule.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "TitleRule.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation TitleRule
@dynamic level,name,series;

+ (NSString *)parseClassName
{
    return @"TitleRule";
}

@end
