//
//  LoginViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "LoginViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "RegisterViewController.h"
#import "MenuViewController.h"
#import "ALUserEngine.h"
#import "RegisterViewController.h"
#import "ALXMPPEngine.h"
#import "ALGPSHelper.h"
#import "FinishPersonalDataViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    BOOL _loginDiscuzSuccess;
    BOOL _loginXMppSuccess;
    BOOL _isLogin;
    NSTimer *timer;
}

@synthesize uid = _uid;
@synthesize nickName = _nickName;
@synthesize gender = _gender;
@synthesize birthdayDate = _birthdayDate;
@synthesize headUrl = _headUrl;

- (void)dealloc
{
    [_birthdayDate release]; _birthdayDate=nil;
    [_headUrl release]; _headUrl=nil;
    [_uid release]; _uid=nil;
    [_nickName release]; _nickName=nil;
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"_0029_Background.png"];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:img];
    backgroundImage.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    [self.view addSubview:backgroundImage];
    [backgroundImage release];
    
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0023_logo.png"]];
    logoImage.frame = CGRectMake(0, 0, 204/2, 133/2);
    logoImage.center = CGPointMake(128, 75);
    [self.view addSubview:logoImage];
    [logoImage release];
    
    [self creatLoginView];

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
    [sinaBtn addTarget:self action:@selector(sinaLogin) forControlEvents:UIControlEventTouchUpInside];
    sinaBtn.center = CGPointMake(52, SCREEN_HEIGHT-90);
    [self.view addSubview:sinaBtn];
    
    UIButton *qqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qqBtn.frame = CGRectMake(0, 0, 66/2, 65/2);
    [qqBtn setImage:[UIImage imageNamed:@"_0015_QQ.png"] forState:UIControlStateNormal];
    [qqBtn addTarget:self action:@selector(qqLogin) forControlEvents:UIControlEventTouchUpInside];
    qqBtn.center = CGPointMake(125, SCREEN_HEIGHT-90);
    [self.view addSubview:qqBtn];
    
    UIButton *tengxunBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tengxunBtn.frame = CGRectMake(0, 0, 66/2, 65/2);
    [tengxunBtn setImage:[UIImage imageNamed:@"_0016_腾讯微博.png"] forState:UIControlStateNormal];
    [tengxunBtn addTarget:self action:@selector(tengxunLogin) forControlEvents:UIControlEventTouchUpInside];
    tengxunBtn.center = CGPointMake(200, SCREEN_HEIGHT-90);
    [self.view addSubview:tengxunBtn];
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(0,SCREEN_HEIGHT-87/2, 320, 87/2);
    [registerBtn setImage:[UIImage imageNamed:@"_0028_还没有账号？BG.png"] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(showRegisterView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
   
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT-35, 200, 30)];
    label2.text = @"还没有账号？请点击这里注册";
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
    
   // sharetype = ShareTypeSinaWeibo;

}

#pragma mark - 第三方登录
- (void)sinaLogin
{
//    if (isRequest==YES)
//    {
//        return;
//    }
//    
//    isRequest=YES;
    
    //sharetype = ShareTypeSinaWeibo;

   // [self showF3HUDLoad:nil];
    
//    [self author];
}

- (void)qqLogin
{
    //sharetype = ShareTypeQQSpace;

}

- (void)tengxunLogin
{
   // sharetype = ShareTypeTencentWeibo;

}

- (void)regisertAuthor
{
    __block typeof(self) bself = self;

    [[ALUserEngine defauleEngine] signUpWithUserName:self.uid andPassword:@"qweqwe123" andEmail:[NSString stringWithFormat:@"%@@qq.com",self.uid] block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            FinishPersonalDataViewController *finish = [[[FinishPersonalDataViewController alloc] init] autorelease];
            finish.nickName = bself.nickName;
            finish.headUrl = bself.headUrl;
            finish.bridayDate = bself.birthdayDate;
            finish.gender = bself.gender;
            
            [bself.sidePanelController showCenterPanelAnimated:YES];
            bself.sidePanelController.centerPanel = finish;
            bself.sidePanelController.recognizesPanGesture = NO;
            
            [bself hideF3HUDSucceed:nil];
            
            bself.isRequest=NO;
        }
        else
        {
            int errorcode = [[[error userInfo] objectForKey:@"code"] intValue];
            
            NSLog(@"%d",error.code);
            
            if (errorcode==202 || errorcode==203)
            {
                [bself authorLogin:self.uid Password:@"qweqwe123"];
                
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"连接超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                
                [bself hideF3HUDError:nil];
                bself.isRequest=NO;
            }
            
        }
        
        
    }];
}

#pragma mark - 进行用户授权
- (void)author
{
//    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
//                                                         allowCallback:YES
//                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
//                                                          viewDelegate:nil
//                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
//    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
//                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
//                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
//                                    nil]];
    __block typeof(self) bself = self;
    
//    [ShareSDK ssoEnabled:YES];
//
//    [ShareSDK getUserInfoWithType:sharetype
//                      authOptions:nil
//                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
//                               if (result)
//                               {
//                                   NSLog(@"授权成功！");
//                                   NSLog(@"username=%@",[userInfo nickname]);
//                                   NSLog(@"uid=%@",[userInfo uid]);
//                                   NSLog(@"gender=%d",[userInfo gender]);
//                                   NSLog(@"url=%@",[userInfo icon]);
//                                   NSLog(@"birthday=%@",[userInfo birthday]);
//                            
//                                   //登录
//                                   bself.uid = [userInfo uid];
//                                   bself.nickName = [userInfo nickname];
//                                   bself.headUrl = [userInfo icon];
//                                   bself.gender = [userInfo gender];
//                                  // bself.birthdayDate = [userInfo birthday];
//                                   
//                                   [bself regisertAuthor];
//                                }
//                               else
//                               {
//                                   NSLog(@"授权失败！");
//                                   NSLog(@"%d:%@",[error errorCode], [error errorDescription]);
//
//                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                                   [alert show];
//                                   [alert release];
//                                   
//                                   [bself hideF3HUDError:nil];
//                    
//                                   isRequest=NO;
//                               }
//                           }];

}

- (void)cancelAuthor
{
    //取消授权
   // [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
}

#pragma mark - 创建登录页面
- (void)creatLoginView
{
    UIImageView *userNameImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0022_用户名.png"]];
    userNameImage.frame = CGRectMake(0, 0, 457/2, 70/2);
    userNameImage.center = CGPointMake(128, 150);
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
    passwordImage.center = CGPointMake(128, 195);
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
    [_textfield_password setSecureTextEntry:YES];
    _textfield_password.returnKeyType = UIReturnKeyDone;
    [passwordImage addSubview:_textfield_password];
    [_textfield_password release];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(0, 0, 457/2,69/2);
    doneBtn.center = CGPointMake(128, 263);
    [doneBtn setImage:[UIImage imageNamed:@"_0025_登录.png"] forState:UIControlStateNormal];
    [doneBtn setImage:[UIImage imageNamed:@"_0024_登录点击.png"] forState:UIControlStateHighlighted];
    [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
}

#pragma mark 授权账号登录
- (void)authorLogin:(NSString *)username Password:(NSString *)password
{
    __block typeof(self) bself = self;

    ALGPSHelper *gps = [ALGPSHelper OpenGPS];
    
    CGFloat latitude = gps.offLatitude;
    CGFloat longitude = gps.offLongitude;
    
    [[ALXMPPEngine defauleEngine] logOut];

    [[ALUserEngine defauleEngine] logInWithUserName:username andPassword:password isAutoLogin:NO latitude:latitude longitude:longitude place:gps.LocationName block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hideF3HUDSucceed:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logIn" object:nil];
            [bself showLeftView];
            
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        
        bself.isRequest=NO;
    }];

}

#pragma mark - 登录
- (void)done
{
    
    [_textfield_name resignFirstResponder];
    [_textfield_password resignFirstResponder];
    
    if(_textfield_name.text.length==0)
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入用户名！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
        
        return;
    }
    if(_textfield_password.text.length==0)
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
        
        return;
    }
    
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest=YES;
    
    __block typeof(self) bself = self;
    
    [self showF3HUDLoad:nil];
    
    ALGPSHelper *gps = [ALGPSHelper OpenGPS];
    
    CGFloat latitude;
    CGFloat longitude;
    NSString *placename;
    
    if (gps.latitude==0)
    {
        latitude=0;
    }
    else
    {
        latitude = gps.latitude;
    }
    
    if (gps.longitude==0)
    {
        longitude=0;
    }
    else
    {
        longitude = gps.longitude;
    }
    
    if (gps.LocationName.length==0)
    {
        placename=@"";
    }
    else
    {
        placename = gps.LocationName;
    }
    
    [[ALUserEngine defauleEngine] logInWithUserName:_textfield_name.text andPassword:_textfield_password.text isAutoLogin:NO latitude:latitude longitude:longitude place:gps.LocationName block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hideF3HUDSucceed:nil];
            [bself showLeftView];
        }
        else
        {
            int _code = [[[error userInfo] objectForKey:@"code"] intValue];
            
            if (_code==1)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"用户名或密码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
            NSLog(@"error=%@",[error userInfo]);
            
            [bself hideF3HUDError:nil];
        }
        
        bself.isRequest=NO;
    }];
    
}



- (void)showLeftView
{
    MenuViewController *menu = [[MenuViewController alloc] init];
    [self.sidePanelController showCenterPanelAnimated:YES];
    self.sidePanelController.leftPanel = menu;
    [menu release];
    
    [self loginUserChat];
}

- (void)loginUserChat
{
    [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            
        }
    }];
}

#pragma mark - 注册
- (void)showRegisterView
{
    RegisterViewController *registerView = [[[RegisterViewController alloc] init] autorelease];
    [self.sidePanelController showCenterPanelAnimated:YES];
    self.sidePanelController.leftPanel = registerView;
    [self performSelector:@selector(registerView) withObject:nil afterDelay:0.3];

}

- (void)registerView
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
