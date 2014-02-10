//
//  NSString+MyRegex.h
//  ParseTest
//
//  Created by Jack on 13-5-30.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyRegex)
//邮箱
- (BOOL)isValidateEmail;

//用户名
-(BOOL)isValidateUserName;

//密码
-(BOOL)isValidatePassword;

//手机号
- (BOOL)isValidateMobile;

//车牌号
- (BOOL)validateCarNo;

@end
