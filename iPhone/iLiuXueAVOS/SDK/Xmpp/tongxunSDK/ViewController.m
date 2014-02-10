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

#import "ViewController.h"
#import "AppDelegate.h"
#import "VoipCallController.h"
#import "UIselectContactsViewController.h"

#define MAKE_VOIP_FREE_CALL_BUTTON_TAG 200
#define MAKE_VOIP_DIRECT_DIAL_CALL_TAG 201
#define MAKE_VOIP_CALL_BACK_CALL_TAG   202
#define BACKBTN_TAG                    999
@interface ViewController ()

@end

@implementation ViewController
@synthesize voipAccount;
@synthesize tf_Account;
@synthesize scrollView;

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(void)selectVoIPAccount
{
    UIselectContactsViewController* selectView = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_VoipView];
    selectView.backView = self;
    [self.navigationController pushViewController:selectView animated:YES];
    [selectView release];
    return;
}

- (void)popToPreView
{
    [self hideKeyboard];
    [super popToPreView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"VoIP网络语音电话";
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIScrollView* tmpScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tmpScrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    self.scrollView = tmpScrollView;
    [self.view addSubview:tmpScrollView];
    [tmpScrollView release];
    
    UIButton* backgroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tmpScrollView.frame.size.width, tmpScrollView.frame.size.height)];
    [backgroundBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    backgroundBtn.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:backgroundBtn];
    [backgroundBtn release];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.scrollView addSubview:pointImg];
    [pointImg release];
    
    UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbhead.backgroundColor = [UIColor clearColor];
    lbhead.textColor = [UIColor whiteColor];
    lbhead.textAlignment = UITextAlignmentLeft;
    lbhead.font = [UIFont systemFontOfSize:13.0f];
    lbhead.text =  @"您可以呼叫别人也可以让别人呼叫您";
    [self.scrollView addSubview:lbhead];
    [lbhead release];
    
    
    UILabel *lbTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 60.0f, 300.0f, 20.0f)] ;
    lbTitle1.backgroundColor = [UIColor clearColor];
    lbTitle1.textColor = [UIColor blackColor];
    lbTitle1.textAlignment = UITextAlignmentLeft;
    lbTitle1.font = [UIFont systemFontOfSize:20.0f];
    lbTitle1.text =  @"体验接听VoIP电话";
    [self.scrollView addSubview:lbTitle1];
    [lbTitle1 release];
    
    UILabel *lbTips1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 85.0f, 300.0f, 20.0f)] ;
    lbTips1.backgroundColor = [UIColor clearColor];
    lbTips1.textColor = [UIColor grayColor];
    lbTips1.textAlignment = UITextAlignmentLeft;
    lbTips1.font = [UIFont systemFontOfSize:13.0f];
    lbTips1.text =  @"请将您的VoIP账号告诉您的伙伴，如下显示";
    [self.scrollView addSubview:lbTips1];
    [lbTips1 release];
    
    UIImageView *inputImg1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voip_input_box1.png"]];
    inputImg1.frame = CGRectMake(20.0f, 106.0f, 283.5f, 30.0f);
    [self.scrollView addSubview:inputImg1];
    [inputImg1 release];
    
    UILabel *lbVoIPAccount = [[UILabel alloc] initWithFrame:CGRectMake(135.0f, 113.0f, 161.0f, 20.0f)] ;
    lbVoIPAccount.backgroundColor = [UIColor clearColor];
    lbVoIPAccount.textColor = [UIColor grayColor];
    lbVoIPAccount.textAlignment = UITextAlignmentRight;
    lbVoIPAccount.font = [UIFont systemFontOfSize:17.0f];
    lbVoIPAccount.text = self.modelEngineVoip.voipAccount;
    [self.scrollView addSubview:lbVoIPAccount];
    [lbVoIPAccount release];
    
    
    UILabel *lbTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 176.0f, 320.0f, 20.0f)] ;
    lbTitle2.backgroundColor = [UIColor clearColor];
    lbTitle2.textColor = [UIColor blackColor];
    lbTitle2.textAlignment = UITextAlignmentLeft;
    lbTitle2.font = [UIFont systemFontOfSize:20.0f];
    lbTitle2.text =  @"体验拨打VoIP电话";
    [self.scrollView addSubview:lbTitle2];
    [lbTitle2 release];
    
    UILabel *lbTips2 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 200.0f, 300.0f, 20.0f)] ;
    lbTips2.backgroundColor = [UIColor clearColor];
    lbTips2.textColor = [UIColor grayColor];
    lbTips2.textAlignment = UITextAlignmentLeft;
    lbTips2.font = [UIFont systemFontOfSize:13.0f];
    lbTips2.text =  @"请选择您伙伴的VoIP账号跟他通话";
    [self.scrollView addSubview:lbTips2];
    [lbTips2 release];
    
    UIImageView *inputImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_box.png"]];
    inputImg2.frame = CGRectMake(20.0f, 221.0f, 283.5f, 29);
    [self.scrollView addSubview:inputImg2];
    [inputImg2 release];
    
    UIImageView *selectImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voip_select_icon.png"]];
    selectImg.frame = CGRectMake(275.0f, 221.0f, 27.5f, 27.5f);
    [self.scrollView addSubview:selectImg];
    [selectImg release];
    
    UIButton *inputBtn3 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    inputBtn3.frame = CGRectMake(274.f, 221, 30.f, 27.5f);
    [inputBtn3 addTarget:self action:@selector(selectVoIPAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:inputBtn3];
    
    UITextField* tfTmp = [[UITextField alloc] initWithFrame:CGRectMake(24.0f, 221.0f, 250.f, 27.5f)] ;
    tfTmp.textAlignment = UITextAlignmentLeft;
    tfTmp.placeholder =  @"请输入或选择被叫VoIP账号";
    tfTmp.keyboardType = UIKeyboardTypeNumberPad;
    [self.scrollView addSubview:tfTmp];
    [tfTmp release];
    tfTmp.delegate = self;
    self.tf_Account = tfTmp;
    
    UIButton *voipFreeCallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voipFreeCallBtn.frame = CGRectMake(24.0f, 270.0f, 273.0f, 37.0f);
    [voipFreeCallBtn addTarget:self action:@selector(makeVoipCall:) forControlEvents:UIControlEventTouchUpInside];
    [voipFreeCallBtn setTitle:@"VoIP呼叫" forState:UIControlStateNormal];
    [voipFreeCallBtn setBackgroundImage:[UIImage imageNamed:@"voip_button_off.png"] forState:UIControlStateNormal];
    [voipFreeCallBtn setBackgroundImage:[UIImage imageNamed:@"voip_button_on.png"] forState:UIControlStateHighlighted];
    [self.scrollView addSubview:voipFreeCallBtn];
    
    UIImageView *imgTips3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voip_status_icon.png"]];
    imgTips3.frame = CGRectMake(25.0f, 385.0f, 9.5f, 9.5f);
    [self.scrollView addSubview:imgTips3];
    [imgTips3 release];
    
    UILabel *lbTips3 = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 380.0f, 270.0f, 20.0f)] ;
    lbTips3.backgroundColor = [UIColor clearColor];
    lbTips3.textColor = [UIColor grayColor];
    lbTips3.textAlignment = UITextAlignmentLeft;
    lbTips3.font = [UIFont systemFontOfSize:13.0f];
    lbTips3.text =  @"连接已准备就绪，可以呼出或接听电话";
    [self.scrollView addSubview:lbTips3];
    [lbTips3 release];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self.modelEngineVoip setModalEngineDelegate:self];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self hideKeyboard];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    self.tf_Account = nil;
    self.voipAccount = nil;
    self.scrollView = nil;
    [super dealloc];
}

//拨打电话
- (void)makeVoipCall:(id)sender
{
    [self hideKeyboard];
    if (tf_Account.text.length > 0 && [self.voipAccount isEqualToString:tf_Account.text])
    {
        VoipCallController *myVoipCallController = [[VoipCallController alloc]
                                                    initWithCallerName:@""
                                                    andCallerNo:tf_Account.text
                                                    andVoipNo:tf_Account.text
                                                    andCallType:0];
        [self presentViewController:myVoipCallController animated:YES completion:nil];
        [myVoipCallController release];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择被叫VoIP账号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    return; 
}

#pragma mark - text Delegate
 - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    int height = 480 - 64 - 216;
    int y = 120;
    if (IPHONE5)
    {
        height = 568 - 64 - 216;
        y = 50;
    }
    self.scrollView.frame =  CGRectMake(0,0,self.view.frame.size.width, height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [self.scrollView setContentOffset:CGPointMake(0, y)];
    [UIView commitAnimations];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.voipAccount = self.tf_Account.text;
}

- (void) hideKeyboard
{
    [self.tf_Account resignFirstResponder];
    int height = 480 - 64;
    if (IPHONE5)
    {
        height = 568 - 64;
    }
    self.scrollView.frame = CGRectMake(0,0,self.view.frame.size.width, height);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
}

@end
