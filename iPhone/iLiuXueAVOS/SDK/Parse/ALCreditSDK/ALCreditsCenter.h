//
//  ALCreditsCenter.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

/* 
 通知userInfo格式:
 @{ 
    @"ALCreditRuleType":xxx
    @"toUser":xxx
    
 }
 */

#import <Foundation/Foundation.h>

#import "ALCreditConfig.h"
#import "CreditRule.h"
#import "CreditRuleLog.h"

@interface ALCreditsCenter : NSObject

+ (ALCreditsCenter *)defaultCenter;

@end
