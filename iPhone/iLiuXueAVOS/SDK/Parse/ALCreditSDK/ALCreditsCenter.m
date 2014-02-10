//
//  ALCreditsCenter.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALCreditsCenter.h"
#import "User.h"

static ALCreditsCenter *creditsCenter = nil;

@implementation ALCreditsCenter

+ (ALCreditsCenter *)defaultCenter
{
    if (!creditsCenter)
    {
        creditsCenter = [[ALCreditsCenter alloc] init];
        [creditsCenter addNotification];
    }
    return creditsCenter;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creditsHandle:) name:NOTIFICATION_CREDITS_CHANGE object:nil];
}

//是否是当天
- (BOOL)isOnTheSameDay:(NSDate *)theDate andDate:(NSDate *)anotherDate
{
    //从已有日期获取日期
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    NSString *theDateStr = [dateFormatter stringFromDate:theDate];
    NSString *anotherDateStr = [dateFormatter stringFromDate:anotherDate];
    
    return [theDateStr isEqualToString:anotherDateStr] ? YES: NO;
}

//+积分
- (void)addCreditsWithUser:(User *)theUser creditRule:(CreditRule *)theCreditRule price:(int)thePrice
{
    [theUser incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:theCreditRule.credits+thePrice]];
    
    [theUser incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:theCreditRule.experience]];
    
    [theUser saveEventually];
}

//+积分记录
- (void)addCreditsLogWithUser:(User *)theUser creditRule:(CreditRule *)theCreditRule price:(int)thePrice
{
    
    CreditRuleLog *creditLog = [CreditRuleLog object];
    creditLog.user = theUser;
    creditLog.type = theCreditRule;
    creditLog.accumulativeCredit = theCreditRule.credits+thePrice;
    creditLog.accumulativeExperience = theCreditRule.experience;
    
    [creditLog saveEventually];
}

//接收积分变更通知
- (void)creditsHandle:(NSNotification *)notification

{
    NSDictionary *userInfo = notification.userInfo;
    
    ALCreditRuleType type = [userInfo[@"ALCreditRuleType"] integerValue];
        
    User *user = userInfo[@"toUser"];
    
    NSInteger price = [userInfo[@"price"] integerValue];
    
    __block typeof (self) bself = self;
    
    //获取积分规则
    AVQuery *creditRule = [CreditRule query];
    [creditRule whereKey:@"type" equalTo:[NSNumber numberWithInteger:type]];
    [creditRule getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        //积分规则
        CreditRule *creditRule = (CreditRule *)object;
        
        //+积分
        [bself addCreditsWithUser:user creditRule:creditRule price:price];
        
        //+积分记录
        [bself addCreditsLogWithUser:user creditRule:creditRule price:price];
        
        //操作类型
        /*
        switch (type)
        {
            //每日登录积分
            case ALCreditRuleTypeOfLogin:
            {
                //+积分
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                
                [user saveEventually];
            }
                break;
                
            //注册积分
            case ALCreditRuleTypeOfSignUp:
            {
                //+积分
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                
                break;
                
            //发帖积分
            //bug:没有用到每日上限
            case ALCreditRuleTypeOfSendThread:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                
                break;
                
            //匿名发帖
            //bug:没有用到每日上限
            case ALCreditRuleTypeOfSendThreadWithAnonymity:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
                
            //选择最佳答案
            //bug:没有用到每日上限
            case ALCreditRuleTypeOfAppointBestAnswern:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
            case ALCreditRuleTypeOfPost:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
            case ALCreditRuleTypeOfComment:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
            case ALCreditRuleTypeOfBecomeBestAnswern:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
            case ALCreditRuleTypeOfBecomeExcellentAnswern:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
            case ALCreditRuleTypeOfSupport:
            {
                [user incrementKey:@"credits" byAmount:[NSNumber numberWithInteger:creditRule.credits+price]];
                [user incrementKey:@"experience" byAmount:[NSNumber numberWithInteger:creditRule.experience]];
                [user saveEventually:nil];
            }
                break;
            default:
                break;
        }
        */
    }];
  
}

@end
