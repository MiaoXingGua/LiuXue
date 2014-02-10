//
//  Comment.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "Comment.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation Comment

@dynamic post,content,postUser;

+ (NSString *)parseClassName
{
    return @"Comment";
}

@end
