//
//  RegisterViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "RegisterViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "ALXMPPEngine.h"
#import "ALUserEngine.h"
#import "FinishPersonalDataViewController.h"
#import "ALGPSHelper.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
{
    BOOL _signUpDiscuzSuccess;
    BOOL _signUpXMppSuccess;
    BOOL _isSignUp;
    NSTimer *timer;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"_0029_Background.png"];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:img];
    backgroundImage.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    [self.view addSubview:backgroundImage];
    [backgroundImage release];
    
    
    [self creatRegisterView];
    
    /*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    label.text = @"第三方账号登录";
    [label setTextAlignment:NSTextAlignmentCenter];
    label.center = CGPointMake(128, SCREEN_HEIGHT-140);
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.7 alpha:1];
    [self.view addSubview:label];
    [label release];
    
    UIButton *sinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sinaBtn.frame = CGRectMake(0, 0, 66/2, 65/2);
    [sinaBtn setImage:[UIImage imageNamed:@"_0017_xinlang.png"] forState:UIControlStateNormal];
   // [sinaBtn addTarget:self action:@selector(sinaLogin) forControlEvents:UIControlEventTouchUpInside];
    sinaBtn.center = CGPointMake(52, SCREEN_HEIGHT-90);
    [self.view addSubview:sinaBtn];
    
    UIButton *qqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qqBtn.frame = CGRectMake(0, 0, 66/2, 65/2);
    [qqBtn setImage:[UIImage imageNamed:@"_0015_QQ.png"] forState:UIControlStateNormal];
   // [qqBtn addTarget:self action:@selector(qqLogin) forControlEvents:UIControlEventTouchUpInside];
    qqBtn.center = CGPointMake(125, SCREEN_HEIGHT-90);
    [self.view addSubview:qqBtn];
    
    UIButton *tengxunBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tengxunBtn.frame = CGRectMake(0, 0, 66/2, 65/2);
    [tengxunBtn setImage:[UIImage imageNamed:@"_0016_腾讯微博.png"] forState:UIControlStateNormal];
   // [tengxunBtn addTarget:self action:@selector(tengxunLogin) forControlEvents:UIControlEventTouchUpInside];
    tengxunBtn.center = CGPointMake(200, SCREEN_HEIGHT-90);
    [self.view addSubview:tengxunBtn];
     */
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(0,SCREEN_HEIGHT-87/2, 320, 87/2);
    [registerBtn setImage:[UIImage imageNamed:@"_0028_还没有账号？BG.png"] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(showLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT-35, 200, 30)];
    label2.text = @"返回登录页面";
    [label2 setTextAlignment:NSTextAlignmentLeft];
    label2.font = [UIFont systemFontOfSize:14];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.7 alpha:1];
    [self.view addSubview:label2];
    [label2 release];
    
    UIImageView *arrowsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0027_箭头.png"]];
    arrowsImage.frame = CGRectMake(223, 14, 35/2, 35/2);
    [registerBtn addSubview:arrowsImage];
    arrowsImage.userInteractionEnabled = YES;
    [arrowsImage release];

}

#pragma mark 创建注册页面
- (void)creatRegisterView
{
    UIImageView *userNameImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0022_用户名.png"]];
    userNameImage.frame = CGRectMake(0, 0, 457/2, 70/2);
    userNameImage.center = CGPointMake(128, 50);
    [self.view addSubview:userNameImage];
    userNameImage.userInteractionEnabled = YES;
    [userNameImage release];
    
    _textfield_name = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    _textfield_name.center = CGPointMake(125, 20);
    _textfield_name.delegate = self;
    _textfield_name.borderStyle = UITextBorderStyleNone;
    _textfield_name.backgroundColor = [UIColor clearColor];
    [userNameImage addSubview:_textfield_name];
    _textfield_name.placeholder = @"用户名";
    _textfield_name.returnKeyType = UIReturnKeyDone;
    _textfield_name.textColor = [UIColor whiteColor];
    [_textfield_name release];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0021_密码.png"]];
    passwordImage.frame = CGRectMake(0, 0, 457/2, 70/2);
    passwordImage.center = CGPointMake(128, 95);
    [self.view addSubview:passwordImage];
    passwordImage.userInteractionEnabled = YES;
    [passwordImage release];
    
    _textfield_password = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    _textfield_password.center = CGPointMake(125, 20);
    _textfield_password.delegate = self;
    _textfield_password.keyboardType = UIKeyboardTypeAlphabet;
    _textfield_password.textColor = [UIColor whiteColor];
    _textfield_password.borderStyle = UITextBorderStyleNone;
    _textfield_password.backgroundColor = [UIColor clearColor];
    _textfield_password.placeholder = @"密码";
    _textfield_password.returnKeyType = UIReturnKeyDone;
    [_textfield_password setSecureTextEntry:YES];
    [passwordImage addSubview:_textfield_password];
    [_textfield_password release];
    
    UIImageView *passwordImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0021_密码.png"]];
    passwordImage2.frame = CGRectMake(0, 0, 457/2, 70/2);
    passwordImage2.center = CGPointMake(128, 140);
    [self.view addSubview:passwordImage2];
    passwordImage2.userInteractionEnabled = YES;
    [passwordImage2 release];
    
    _textfield_passwordRepeat = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    _textfield_passwordRepeat.center = CGPointMake(125, 20);
    _textfield_passwordRepeat.delegate = self;
    _textfield_passwordRepeat.keyboardType = UIKeyboardTypeAlphabet;
    _textfield_passwordRepeat.textColor = [UIColor whiteColor];
    _textfield_passwordRepeat.borderStyle = UITextBorderStyleNone;
    _textfield_passwordRepeat.backgroundColor = [UIColor clearColor];
    _textfield_passwordRepeat.placeholder = @"再次输入密码";
    _textfield_passwordRepeat.returnKeyType = UIReturnKeyDone;
    [_textfield_passwordRepeat setSecureTextEntry:YES];
    [passwordImage2 addSubview:_textfield_passwordRepeat];
    [_textfield_passwordRepeat release];
    
    UIImageView *emailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0014_message.png"]];
    emailImage.frame = CGRectMake(0, 0, 457/2, 70/2);
    emailImage.center = CGPointMake(128, 185);
    [self.view addSubview:emailImage];
    emailImage.userInteractionEnabled = YES;
    [emailImage release];
    
    _textfield_email = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    _textfield_email.center = CGPointMake(125, 20);
    _textfield_email.delegate = self;
    _textfield_email.keyboardType = UIKeyboardTypeEmailAddress;
    _textfield_email.textColor = [UIColor whiteColor];
    _textfield_email.borderStyle = UITextBorderStyleNone;
    _textfield_email.backgroundColor = [UIColor clearColor];
    _textfield_email.placeholder = @"邮箱";
    _textfield_email.returnKeyType = UIReturnKeyDone;
    [emailImage addSubview:_textfield_email];
    [_textfield_email release];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(0, 0, 457/2,69/2);
    doneBtn.center = CGPointMake(128, 263);
    [doneBtn setImage:[UIImage imageNamed:@"_0013_注-册.png"] forState:UIControlStateNormal];
    [doneBtn setImage:[UIImage imageNamed:@"_0012_注-册点击.png"] forState:UIControlStateHighlighted];
    [doneBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
}

#pragma mark 显示登录页面
- (void)showLoginView
{
    LoginViewController *loginView = [[[LoginViewController alloc] init] autorelease];
    [self.sidePanelController showCenterPanelAnimated:YES];
    self.sidePanelController.leftPanel = loginView;

    [self performSelector:@selector(showleftView) withObject:nil afterDelay:0.3];
}

- (void)uploadUserLocation
{
    if ([ALGPSHelper OpenGPS].latitude!=0 && [ALGPSHelper OpenGPS].longitude!=0)
    {
        [[ALUserEngine defauleEngine] uploadPointWithLatitude:[ALGPSHelper OpenGPS].latitude longitude:[ALGPSHelper OpenGPS].longitude place:[ALGPSHelper OpenGPS].LocationName block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                NSLog(@"定位上传成功");
            }
        }];
    }
}

- (void)submit
{
    if(_textfield_name.text.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入用户名！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    if(_textfield_password.text.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    if(_textfield_passwordRepeat.text.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请重复输入密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    if(![_textfield_password.text isEqualToString:_textfield_passwordRepeat.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"输入2次密码必须相同！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    if(_textfield_email.text.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入邮箱！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    __block typeof(self) bself = self;
    
   // [self showHUDWithTitle:@"提示" status:@"注册中"];
    [self showF3HUDLoad:nil];
    
    [[ALUserEngine defauleEngine] signUpWithUserName:_textfield_name.text andPassword:_textfield_password.text andEmail:_textfield_email.text block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself uploadUserLocation];
            
            FinishPersonalDataViewController *finish = [[[FinishPersonalDataViewController alloc] init] autorelease];
            [bself.sidePanelController showCenterPanelAnimated:YES];
            bself.sidePanelController.centerPanel = finish;
            bself.sidePanelController.recognizesPanGesture = NO;
            
            [bself hideF3HUDSucceed:nil];
        }
        else
        {
            [bself hideF3HUDError:nil];
            
            int errorcode = [[[error userInfo] objectForKey:@"code"] intValue];
            
            if (errorcode==125)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
            }
            
            else if (errorcode==202)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名已注册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
            }
            
            else if (errorcode==203)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱已注册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"连接超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
            }

            NSLog(@"%d",error.code);
        }
        
    }];
}



- (void)showCenterView
{
    MenuViewController *menu = [[[MenuViewController alloc] init] autorelease];
    [self.sidePanelController showCenterPanelAnimated:YES];
    self.sidePanelController.leftPanel = menu;
}

- (void)showleftView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
