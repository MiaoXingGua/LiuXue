//
//  ALNotificationSDK.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-18.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALNotificationSDK.h"

@implementation ALNotificationSDK

+ (void)registerLKSDK
{
    [NotificationOfThread registerSubclass];
    [NotificationOfFriend registerSubclass];
    [ALNotificationCenter defauleCenter];
}

@end
