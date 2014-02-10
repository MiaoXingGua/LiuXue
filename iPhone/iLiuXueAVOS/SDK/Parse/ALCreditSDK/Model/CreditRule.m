//
//  creditRule.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "CreditRule.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation CreditRule
@dynamic name,type,credits,experience,maxCredits,maxExperience;

+ (NSString *)parseClassName
{
    return @"CreditRule";
}

@end
