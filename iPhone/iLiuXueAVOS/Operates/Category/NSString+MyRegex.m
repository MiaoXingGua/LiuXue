//
//  NSString+MyRegex.m
//  ParseTest
//
//  Created by Jack on 13-5-30.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "NSString+MyRegex.h"

@implementation NSString (MyRegex)

- (BOOL)isValidateEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

-(BOOL)isValidateUserName
{
//    NSString *Regex = @"^//w{2,16}$";
//    
//    NSPredicate *userTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
//    
//    return [userTest evaluateWithObject:self];
    
//    NSString *patternStr = [NSString stringWithFormat:@"^.{0,4}$|.{21,}|^[^A-Za-z0-9u4E00-u9FA5]|[^\wu4E00-u9FA5.-]|([_.-])1"];
//    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
//                                              initWithPattern:patternStr
//                                              options:NSRegularExpressionCaseInsensitive
//                                              error:nil];
//    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:self
//                                                                  options:NSMatchingReportProgress
//                                                                    range:NSMakeRange(0, self.length)];
//    
//    [regularexpression release];
//    
//    if(numberofMatch > 0)
//    {
//        return YES;
//    }
//    return NO;
    
    return YES;
}

-(BOOL)isValidatePassword
{
//    NSString *Regex = @"//w{6,16}";
//    
//    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
//    
//    return [passwordTest evaluateWithObject:self];
    return YES;
}

- (BOOL)isValidateMobile
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:self] == YES)
        || ([regextestcm evaluateWithObject:self] == YES)
        || ([regextestct evaluateWithObject:self] == YES)
        || ([regextestcu evaluateWithObject:self] == YES))
    {
        if([regextestcm evaluateWithObject:self] == YES) {
            NSLog(@"China Mobile");
        } else if([regextestct evaluateWithObject:self] == YES) {
            NSLog(@"China Telecom");
        } else if ([regextestcu evaluateWithObject:self] == YES) {
            NSLog(@"China Unicom");
        } else {
            NSLog(@"Unknow");
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)validateCarNo
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];

    return [carTest evaluateWithObject:self];
}

@end
