//
//  CreditRuleLog.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "ALCreditConfig.h"

@class User;
@class CreditRule;

@interface CreditRuleLog : AVObject <AVSubclassing>

@property (nonatomic, retain) User *user;

@property (nonatomic, retain) CreditRule *type;

@property (nonatomic, assign) int accumulativeCredit;

@property (nonatomic, assign) int accumulativeExperience;

@end
