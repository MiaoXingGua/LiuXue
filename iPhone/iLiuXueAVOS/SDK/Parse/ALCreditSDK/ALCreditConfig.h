//
//  CreditConfig.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#ifndef PARSE_DEMO_CreditConfig_h
#define PARSE_DEMO_CreditConfig_h

#import "ALParseConfig.h"

#define NOTIFICATION_CREDITS_CHANGE  @"BIUSLGFEI47R3O48QR3KUTFI7632VOY8FQO346RQ3BP97TVSER7F80Q"

#define POST_NOTIFICATION_CREDITS_CHANGE(type,user,price)  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREDITS_CHANGE object:self userInfo:@{@"ALCreditRuleType":[NSNumber numberWithInteger:type],@"toUser":user,@"price":[NSNumber numberWithInteger:price]}]
/*
 通知userInfo格式:
 @{@"ALCreditRuleType":xxx,@"toUser":xxx,@"price":xxx}
 */


typedef NS_ENUM(NSUInteger, ALCreditRuleType) {
    
    //异常
    ALCreditRuleTypeOfUndefined = 0,
    
    //登录
    ALCreditRuleTypeOfSignUp = 1,//注册
    ALCreditRuleTypeOfLogin = 2,//每日首次登录
    
    
    //发帖
    ALCreditRuleTypeOfSendThread = 11,//提交问题
    ALCreditRuleTypeOfSendThreadWithAnonymity = 12,//匿名+提交问题
    ALCreditRuleTypeOfAppointBestAnswern = 13,//处理问题
    
    //回答
    ALCreditRuleTypeOfPost = 21,//提交回答
    ALCreditRuleTypeOfComment = 22,//提交评论
    ALCreditRuleTypeOfBecomeBestAnswern = 23,//回答被采纳
    ALCreditRuleTypeOfBecomeExcellentAnswern = 24,//回答被采纳(高效额外回答奖励)
    ALCreditRuleTypeOfSupport = 25,//被赞
    
};


#endif
