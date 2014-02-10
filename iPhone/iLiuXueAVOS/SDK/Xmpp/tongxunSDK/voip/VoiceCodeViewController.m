/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */


#import "VoiceCodeViewController.h"
#import "VoiceCodeStateViewController.h"



@interface VoiceCodeViewController ()
{
    UIButton *btnGetVerifyCode;
    NSTimer *updateBtnTimer;
    NSInteger remainTime;
}
@end

@implementation VoiceCodeViewController

@synthesize tfPhoneNO;
@synthesize tfVerifyCode;
@synthesize myVerifyCode;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    self.title =@"语音验证码";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIButton *btnBG = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnBG.frame = self.view.frame;
    [btnBG addTarget:self action:@selector(hidekeyboard) forControlEvents:(UIControlEventTouchDown)];
    [self.view addSubview:btnBG];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.f, 0.f, 320.f, 29.f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 29.f)] ;
    lbhead.backgroundColor = [UIColor clearColor];
    lbhead.textColor = [UIColor whiteColor];
    lbhead.textAlignment = UITextAlignmentLeft;
    lbhead.font = [UIFont systemFontOfSize:13.f];
    lbhead.text =  @"    请输入要接收语音验证码的号码";
    [self.view addSubview:lbhead];
    [lbhead release];
    
    UILabel *lbPhoneNO = [[UILabel alloc] initWithFrame:CGRectMake(18.f, 44.f, 220.f, 18.f)] ;
    lbPhoneNO.backgroundColor = [UIColor clearColor];
    lbPhoneNO.textColor = [UIColor grayColor];
    lbPhoneNO.textAlignment = UITextAlignmentLeft;
    lbPhoneNO.font = [UIFont systemFontOfSize:17.f];
    lbPhoneNO.text =  @"号码（固号加区号）：";
    [self.view addSubview:lbPhoneNO];
    [lbPhoneNO release];
    
    UIImageView *imgPhone = [[UIImageView alloc] initWithFrame:CGRectMake(16.f, 65, 283.5f, 40.f)];
    imgPhone.image = [UIImage imageNamed:@"input_box1@2x.png"];
    [self.view addSubview:imgPhone];
    [imgPhone release];
    
    UITextField* tf1 = [[UITextField alloc] initWithFrame:CGRectMake(19.f, 65.f, 277.f, 40.f)];
    //tf1.font = [UIFont systemFontOfSize:17];
    tf1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf1.keyboardType = UIKeyboardTypePhonePad;
    tf1.delegate = self;
    tf1.tag = 801;
    [self.view addSubview:tf1];
    self.tfPhoneNO = tf1;
    if ([self.modelEngineVoip.voipPhone length]>0)
    {
        tf1.text = self.modelEngineVoip.voipPhone;
    }
    [tf1 release];
    
    UILabel *lbVerifyCode = [[UILabel alloc] initWithFrame:CGRectMake(18.f, 110.f, 120.f, 19.f)] ;
    lbVerifyCode.backgroundColor = [UIColor clearColor];
    lbVerifyCode.textColor = [UIColor grayColor];
    lbVerifyCode.textAlignment = UITextAlignmentLeft;
    lbVerifyCode.font = [UIFont systemFontOfSize:17.f];
    lbVerifyCode.text =  @"验证码";
    [self.view addSubview:lbVerifyCode];
    [lbVerifyCode release];
    
    UIImageView *imgVerifyCode = [[UIImageView alloc] initWithFrame:CGRectMake(16.f,133.f , 138.5f, 40.f)];
    imgVerifyCode.image = [UIImage imageNamed:@"input_box2@2x.png"];
    [self.view addSubview:imgVerifyCode];
    [imgVerifyCode release];
    
    UITextField* tf2 = [[UITextField alloc] initWithFrame:CGRectMake(18.f, 133.f, 134.f, 40.0)];
    //tf2.font = [UIFont systemFontOfSize:17];
    tf2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tfVerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    tf2.delegate = self;
    tf1.tag = 802;
    [self.view addSubview:tf2];
    self.tfVerifyCode = tf2;
    [tf2 release];
    
    btnGetVerifyCode = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnGetVerifyCode.frame = CGRectMake(163.f, 133.f, 136.f, 36.5f);
    [btnGetVerifyCode setTitle:@"获取语音验证码" forState:UIControlStateNormal];
    btnGetVerifyCode.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [btnGetVerifyCode setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnGetVerifyCode setBackgroundImage:[UIImage imageNamed:@"input_box_button_off@2x.png"] forState:(UIControlStateNormal)];
    [btnGetVerifyCode setBackgroundImage:[UIImage imageNamed:@"input_box_button_on@2x.png"] forState:(UIControlStateSelected)];
    [btnGetVerifyCode addTarget:self action:@selector(getVerifyCode) forControlEvents:(UIControlEventTouchDown)];
    [self.view addSubview:btnGetVerifyCode];
    
    UIButton *btnVerifyCode = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnVerifyCode.frame = CGRectMake(85.f, 215.f, 126.f, 36.5f);
    [btnVerifyCode setBackgroundImage:[UIImage imageNamed:@"botton_off@2x.png"] forState:(UIControlStateNormal)];
    [btnVerifyCode setBackgroundImage:[UIImage imageNamed:@"botton_on@2x.png"] forState:(UIControlStateSelected)];
    [btnVerifyCode setTitle:@"提交" forState:(UIControlStateNormal)];
    [btnVerifyCode setTitle:@"提交" forState:(UIControlStateSelected)];
    [btnVerifyCode addTarget:self action:@selector(verifyCode) forControlEvents:(UIControlEventTouchDown)];
    [self.view addSubview:btnVerifyCode];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)getVerifyCode
{
    [self hidekeyboard];
    NSMutableString* strVerifyCode = [[NSMutableString alloc] init];
    for (int i = 0; i<6; i++)
    {
        int i = arc4random() % 2;
        int j = 0;
        if (i == 0)
        {
            j = arc4random() % 26;
            j += 97;
            [strVerifyCode appendFormat:@"%c",j];
        }
        else
        {
            j = arc4random() % 10;
            [strVerifyCode appendFormat:@"%d",j];
        }
    }
    self.myVerifyCode = strVerifyCode;
    [strVerifyCode release];
    
    if ([self.tfPhoneNO.text length] > 0)
    {
        [self displayProgressingView];
        [self.modelEngineVoip VoiceCodeWithVerifyCode:self.myVerifyCode andTo:[NSString stringWithFormat:@"0086%@",self.tfPhoneNO.text] andPlayTimes:3 andRespUrl:nil];
    }
    else
    {
        [self popPromptViewWithMsg:@"请填写接收语音呼入的号码！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

-(void)verifyCode
{
    if ([self.tfVerifyCode.text length]>0)
    {
        BOOL flag = [self.tfVerifyCode.text isEqualToString:self.myVerifyCode];
        VoiceCodeStateViewController* view = [[VoiceCodeStateViewController alloc] initWithVoiceCodeFlag:flag];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        [self popPromptViewWithMsg:@"请填写听到的验证码" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)hidekeyboard
{
    [tfPhoneNO resignFirstResponder];
    [tfVerifyCode resignFirstResponder];
}

-(void)dealloc
{
    if (updateBtnTimer)
    {
        [updateBtnTimer invalidate];
        updateBtnTimer = nil;
    }
    self.tfPhoneNO = nil;
    self.tfVerifyCode = nil;
    self.myVerifyCode = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
}


//语音验证码返回状态
- (void)onVoiceCode:(NSInteger)reason;
{
    if (reason == ERequestType_NetError)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络错误，获取验证码失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if (reason == ERequestType_XmlError)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取验证码失败,请稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if(reason == 0)
    {
        updateBtnTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateBtnDisplay) userInfo:nil repeats:YES];
        btnGetVerifyCode.enabled = NO;
        remainTime = 30;
        [btnGetVerifyCode setTitle:[NSString stringWithFormat:@"%d秒后重新获取",remainTime] forState:UIControlStateNormal];
    }
    
    [self dismissProgressingView];
}

- (void)updateBtnDisplay
{
    remainTime --;
    if (remainTime == 0)
    {
        if (updateBtnTimer)
        {
            [updateBtnTimer invalidate];
            updateBtnTimer = nil;
        }
        btnGetVerifyCode.enabled = YES;
        [btnGetVerifyCode setTitle:@"获取语音验证码" forState:UIControlStateNormal];
    }
    else
    {
        [btnGetVerifyCode setTitle:[NSString stringWithFormat:@"%d秒后重新获取",remainTime] forState:UIControlStateNormal];
    }
}
@end
