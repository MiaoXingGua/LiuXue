//
//  ALCreditSDK.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-18.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALCreditSDK.h"

@implementation ALCreditSDK

+ (void)registerLKSDK
{
    [CreditRule registerSubclass];
    [CreditRuleLog registerSubclass];
    [LevelRule registerSubclass];
    [TitleRule registerSubclass];
    [ALCreditsCenter defaultCenter];
}

@end
