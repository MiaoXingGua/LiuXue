//
//  UserFavicon.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "UserFavicon.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation UserFavicon

@dynamic threads,supports;

+ (NSString *)parseClassName
{
    return @"UserFavicon";
}
    
    
//- (AVRelation *)supports
//{
//    return [self relationforKey:@"supports"];
//}

@end
