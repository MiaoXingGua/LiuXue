//
//  Post.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "Post.h"
#import <AVOSCloud/AVSubclassing.h>


@implementation Post

@dynamic thread,content,postUser,location,place,comments,numberOfSupports,numberOfComments,state;

+ (NSString *)parseClassName
{
    return @"Post";
}

@end
