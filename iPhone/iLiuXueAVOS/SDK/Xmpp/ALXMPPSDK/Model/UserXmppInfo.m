//
//  UserXmppInfo.m
//  PARSE_DEMO
//
//  Created by Albert on 13-10-4.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "UserXmppInfo.h"
#import <AVOSCloud/AVObject+Subclass.h>

@implementation UserXmppInfo
@dynamic subAccountSid,subToken,voipAccount,voipPwd,user;
+ (NSString *)parseClassName
{
    return @"UserXmppInfo";
}

@end
