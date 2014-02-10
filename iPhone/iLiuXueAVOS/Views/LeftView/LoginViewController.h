//
//  LoginViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
//#import <ShareSDK/ShareSDK.h>

@interface LoginViewController : SuperViewController <UITextFieldDelegate>
{
    UITextField *_textfield_name,*_textfield_password;

  //  ShareType sharetype;
    
    NSString *_uid;
    NSString *_nickName;
    NSString *_headUrl;
    NSDate *_birthdayDate;
    int _gender;
    
}
@property(nonatomic,assign)BOOL isRequest;
@property(nonatomic,assign)int gender;

@property(nonatomic,retain)NSString *headUrl;
@property(nonatomic,retain)NSDate *birthdayDate;
@property(nonatomic,retain)NSString *uid,*nickName;
@end
