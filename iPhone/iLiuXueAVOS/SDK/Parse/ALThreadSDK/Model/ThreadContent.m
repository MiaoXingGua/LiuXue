//
//  ThreadContent.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ThreadContent.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation ThreadContent

@dynamic images,text,voice,video,location;

+ (NSString *)parseClassName
{
    return @"ThreadContent";
}

//- (AVRelation *)images
//{
//    return [self relationforKey:@"images"];
//}

@end
