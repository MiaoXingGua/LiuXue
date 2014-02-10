//
//  RegisterViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface RegisterViewController : SuperViewController <UITextFieldDelegate>
{
    UITextField *_textfield_name,*_textfield_password,*_textfield_email,*_textfield_passwordRepeat;
}
@end
