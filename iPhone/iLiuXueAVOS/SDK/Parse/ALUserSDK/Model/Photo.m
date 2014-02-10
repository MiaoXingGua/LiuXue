//
//  Photo.m
//  PARSE_DEMO
//
//  Created by Albert on 13-10-19.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic image,description;

+ (NSString *)parseClassName
{
    return @"Photo";
}

@end
