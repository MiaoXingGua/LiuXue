//
//  Forum.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "Forum.h"
#import <AVOSCloud/AVSubclassing.h>


@implementation Forum

@dynamic name,upFroum,threadType,threadFlag;

+ (NSString *)parseClassName
{
    return @"Forum";
}
@end
