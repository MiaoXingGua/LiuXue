//
//  CreditRuleLog.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "CreditRuleLog.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation CreditRuleLog
@dynamic user,type,accumulativeCredit,accumulativeExperience;
+ (NSString *)parseClassName
{
    return @"CreditRuleLog";
}

@end

