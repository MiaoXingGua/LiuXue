//
//  ALiveUserSDK.m
//  LiveRoom
//
//  Created by Jack on 13-6-14.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALUserSDK.h"

@implementation ALUserSDK

+ (void)registerLKSDK
{
    [User registerSubclass];
    [UserInfo registerSubclass];
    [UserCount registerSubclass];
    [UserRelation registerSubclass];
    [UserFavicon registerSubclass];
    [Friend registerSubclass];
    [Follow registerSubclass];
    [BanList registerSubclass];
    [Photo registerSubclass];
}

@end
