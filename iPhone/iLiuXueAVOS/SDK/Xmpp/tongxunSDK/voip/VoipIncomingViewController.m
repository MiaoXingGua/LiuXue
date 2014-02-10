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

#import "VoipIncomingViewController.h"
#import "AppDelegate.h"



extern BOOL globalisVoipView;

@interface VoipIncomingViewController ()
{
    BOOL isShowKeyboard;
}

@property (nonatomic,retain) UIView *keyboardView;

- (void)accept;
- (void)refreshView;
- (void)exitView;
- (void)dismissView;
- (void)showKeyboardView;
@end

@implementation VoipIncomingViewController

#define portraitLeft  100
#define portraitTop   120
#define portraitWidth 150
#define portraitHeight 150

@synthesize lblIncoming;
@synthesize lblName;
@synthesize lblPhoneNO;
@synthesize functionAreaView;
@synthesize contactName;
@synthesize contactPhoneNO;
@synthesize contactVoip;
@synthesize callID;
@synthesize hangUpButton;
@synthesize rejectButton;
@synthesize answerButton;
@synthesize handfreeButton;
@synthesize KeyboardButton;
@synthesize contactPortrait;
@synthesize muteButton;
@synthesize status;
@synthesize keyboardView;
@synthesize statusLabel;
@synthesize p2pStatusLabel;
#pragma mark - init初始化
- (id)initWithName:(NSString *)name andPhoneNO:(NSString *)phoneNO andCallID:(NSString*)callid andParent:(id)viewController
{
    self = [super init];
    if (self)
    {
        self.contactName     = name;
        self.callID          = callid;
        self.contactPhoneNO  = phoneNO;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        self.status = IncomingCallStatus_incoming;
        parentView = viewController;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - viewDidLoad界面初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:24.0/255 green:24.0/255 blue:24.0/255 alpha:1.0];
    UIImage *backImage = [UIImage imageNamed:kCallBg02pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backgroundImg = backGroupImageView;
    backGroupImageView.center = CGPointMake(160.0, self.view.frame.size.height*0.5);
    [self.view addSubview:backGroupImageView];
    [backGroupImageView release];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    self.lblName = nameLabel;
    [nameLabel release];
    self.lblName.frame = CGRectMake(0, 30, 320, 20);
    self.lblName.textAlignment = UITextAlignmentCenter;
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblName.text = self.contactName.length>0?self.contactName:@"";
    [self.view addSubview:lblName];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    self.lblPhoneNO = phoneLabel;
    [phoneLabel release];
    self.lblPhoneNO.frame = CGRectMake(0, 53, 320, 22);
    self.lblPhoneNO.textAlignment = UITextAlignmentCenter;
    self.lblPhoneNO.backgroundColor = [UIColor clearColor];
    self.lblPhoneNO.textColor = [UIColor whiteColor];
    self.lblPhoneNO.text = self.contactPhoneNO.length>0?self.contactPhoneNO:self.contactVoip;
    [self.view addSubview:lblPhoneNO];
    
    UILabel* incomingLabel = [[UILabel alloc] init];
    self.lblIncoming = incomingLabel;
    [incomingLabel release];
    self.lblIncoming.frame = CGRectMake(0, 80, 320, 20);
    self.lblIncoming.textAlignment = UITextAlignmentCenter;
    self.lblIncoming.backgroundColor = [UIColor clearColor];
    self.lblIncoming.textColor = [UIColor whiteColor];
    self.lblIncoming.text = @"";
    [self.view addSubview:lblIncoming];
    
    
    UILabel *tempStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 106.0f, 300.0f, 16.0f)];
    tempStatusLabel.text = @"";
    tempStatusLabel.textColor = [UIColor whiteColor];
    tempStatusLabel.backgroundColor = [UIColor clearColor];
    tempStatusLabel.textAlignment = UITextAlignmentCenter;
    self.statusLabel = tempStatusLabel;
    [self.view addSubview:self.statusLabel];
    [tempStatusLabel release];
    
    UILabel *tempp2pstatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 132.0f, 300.0f, 16.0f)];
    tempp2pstatusLabel.text = @"";
    tempp2pstatusLabel.textColor = [UIColor whiteColor];
    tempp2pstatusLabel.backgroundColor = [UIColor clearColor];
    tempp2pstatusLabel.textAlignment = UITextAlignmentCenter;
    self.p2pStatusLabel = tempp2pstatusLabel;
    [self.view addSubview:self.p2pStatusLabel];
    [tempp2pstatusLabel release];
    
    
    isShowKeyboard = NO;
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-43.0f-5.0f, 320.0f, 43.0f)];
    [self.view addSubview:tempfunctionAreaView];
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    self.functionAreaView = tempfunctionAreaView;
    self.functionAreaView.hidden = YES;
    [tempfunctionAreaView release];
    
    //键盘显示按钮
    UIButton *tempKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.KeyboardButton = tempKeyboardButton;
    tempKeyboardButton.frame = CGRectMake(23.5f, 0.0f, 91.0f, 43.0f);
    [tempKeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
    [tempKeyboardButton addTarget:self action:@selector(showKeyboardView) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempKeyboardButton];
    
    //免提按钮
    UIButton *tempHandFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHandFreeButton.frame = CGRectMake(23.5f+91.0f*2, 0.0f, 91.0f, 43.0f);
    [tempHandFreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
    self.handfreeButton = tempHandFreeButton;
    tempHandFreeButton.enabled = NO;
    [tempHandFreeButton addTarget:self action:@selector(handfree) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempHandFreeButton];
    
    //静音按钮
    UIButton *tempMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempMuteButton.frame = CGRectMake(23.5f+91.0f, 0.0f, 91.0f, 43.0f);
    [tempMuteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
    [tempMuteButton addTarget:self action:@selector(mute) forControlEvents:UIControlEventTouchUpInside];
    self.muteButton = tempMuteButton;
    tempMuteButton.enabled = NO;
    [self.functionAreaView addSubview:tempMuteButton];
    
    
    //拒接
    UIButton *tempRejectButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tempRejectButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 127, 42);
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button.png"] forState:UIControlStateNormal];
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateHighlighted];
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateSelected];
    [tempRejectButton  addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.rejectButton = tempRejectButton;
    [self.view addSubview:self.rejectButton];
    
    //挂机
    UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHangupButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 320.0f-24.0f-24.0f, 42.0f);
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button.png"] forState:UIControlStateNormal];
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateHighlighted];
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateSelected];
    [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    tempHangupButton.hidden = YES;
    self.hangUpButton = tempHangupButton;
    [self.view addSubview:self.hangUpButton];
    
    //接听
    UIButton *tempAnswerButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tempAnswerButton.frame = CGRectMake(24.0f+127+14, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 127, 42.0f);
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button.png"] forState:UIControlStateNormal];
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateHighlighted];
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateSelected];
    [tempAnswerButton  addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    self.answerButton = tempAnswerButton;
    [self.view addSubview:self.answerButton];
    
    [self refreshView];
}

- (void)viewDidUnload
{    
    self.lblIncoming = nil;
    self.functionAreaView = nil;
    self.lblName = nil;
    self.lblPhoneNO = nil;
    self.contactName = nil;
    self.contactPhoneNO = nil;
    self.contactPortrait = nil;
    self.hangUpButton = nil;
    self.handfreeButton = nil;
    self.statusLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    self.contactVoip = nil;
    self.KeyboardButton = nil;
    self.keyboardView = nil;
    self.lblIncoming = nil;
    self.functionAreaView = nil;
    self.lblName = nil;
    self.lblPhoneNO = nil;
    self.contactName = nil;
    self.contactPhoneNO = nil;
    self.contactPortrait = nil;
    self.hangUpButton = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;
    self.statusLabel = nil;
    self.p2pStatusLabel = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Appear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setModalEngineDelegate:self];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView) name:KNOTIFICATION_DISMISSMODALVIEW object:nil];
    
    globalisVoipView = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ModelEngineVoip getInstance].UIDelegate = parentView;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_DISMISSMODALVIEW object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    globalisVoipView = NO;
    [super viewDidDisappear:animated];
}

#pragma mark - 按钮点击
- (void)updateRealtimeLabel
{
    ssInt +=1;
    if (ssInt >= 60) {
        mmInt += 1;
        ssInt -= 60;
        if (mmInt >=  60) {
            hhInt += 1;
            mmInt -= 60;
            if (hhInt >= 24) {
                hhInt = 0;
            }
        }
    }
    
    if(ssInt > 0 && ssInt % 4 == 0 )
    {
        StatisticsInfo * info =[self.modelEngineVoip getCallStatistics];
        double lost = info.rlFractionLost / 255.f;
        self.statusLabel.text = [NSString stringWithFormat:@"延迟时间%d（毫秒）丢包率%0.2f%%",info.rlRttMs,lost];
    }
    
    if (hhInt > 0) {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    }
    else
    {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

#pragma mark - ModelEngineUIDelegate
-(void)responseVoipManagerStatus:(ECallStatusResult)event callID:(NSString*)callid data:(NSString *)data
{
    self.callID = callid;
    switch (event)
    {
        case ECallStatus_Answered:
        {
            self.lblIncoming.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            self.rejectButton.enabled = NO;
            self.rejectButton.hidden = YES;
            
            self.answerButton.enabled = NO;
            self.answerButton.hidden = YES;
            
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            
            self.functionAreaView.hidden = NO;
            backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];

        }
            break;
        case ECallStatus_Released:
        {
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitView) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallStatus_Transfered:
        {
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitView) userInfo:nil repeats:NO];
        }
            break;
        case ECallStatus_Pasused:
        {
            self.lblIncoming.text = @"呼叫保持...";
        }
            break;
        case ECallStatus_PasusedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方保持...";
        }
            break;
        case ECallStatus_Resumed:
        {
            self.lblIncoming.text = @"呼叫恢复...";
        }
            break;
        case ECallStatus_ResumedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方恢复...";
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

#pragma mark - private

- (void)showKeyboardView
{
    isShowKeyboard = !isShowKeyboard;
    
    if (self.keyboardView == nil)
    {
        CGFloat viewWidth = 86.0f*3;
        CGFloat viewHeight = 46.0*4;
        UIView *tmpKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(160.0f-viewWidth*0.5f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-80.0f-viewHeight, viewWidth, viewHeight)];
        tmpKeyboardView.backgroundColor = [UIColor clearColor];
        self.keyboardView = tmpKeyboardView;
        [self.view addSubview:tmpKeyboardView];
        [tmpKeyboardView release];
        for (NSInteger i = 0; i<4; i++)
        {
            for (NSInteger j = 0; j<3; j++)
            {
                //Button alloc
                UIButton* numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                numberButton.frame = CGRectMake(86.0f*j, 46.0f*i, 86.0f, 46.0f);
                [numberButton addTarget:self action:@selector(dtmfNumber:) forControlEvents:UIControlEventTouchUpInside];
                
                //设置数字图片
                NSInteger numberNum = i*3+j+1;
                if (numberNum == 11)
                {
                    numberNum = 0;
                }
                else if (numberNum == 12)
                {
                    numberNum = 11;
                }
                NSString * numberImgName = [NSString stringWithFormat:@"keyboard_%0.2d.png",numberNum];
                NSString * numberImgOnName = [NSString stringWithFormat:@"keyboard_%0.2d_on.png",numberNum];
                numberButton.tag = 1000 + numberNum;
                
                [numberButton setImage:[UIImage imageNamed:numberImgName] forState:UIControlStateNormal];
                [numberButton setImage:[UIImage imageNamed:numberImgOnName] forState:UIControlStateHighlighted];
                
                [self.keyboardView addSubview:numberButton];
            }
        }
    }
    
    if (isShowKeyboard)
    {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.keyboardView];
    }
    else
    {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        [self.view sendSubviewToBack:self.keyboardView];
    }
}

- (void)dtmfNumber:(id)sender
{
    NSString *numberString = nil;
    UIButton *button = (UIButton *)sender;
    switch (button.tag)
    {
        case 1000:
            numberString = @"0";
            break;
        case 1001:
            numberString = @"1";
            break;
        case 1002:
            numberString = @"2";
            break;
        case 1003:
            numberString = @"3";
            break;
        case 1004:
            numberString = @"4";
            break;
        case 1005:
            numberString = @"5";
            break;
        case 1006:
            numberString = @"6";
            break;
        case 1007:
            numberString = @"7";
            break;
        case 1008:
            numberString = @"8";
            break;
        case 1009:
            numberString = @"9";
            break;
        case 1010:
            numberString = @"*";
            break;
        case 1011:
            numberString = @"#";
            break;
        default:
            numberString = @"#";
            break;
    }
    [self.modelEngineVoip sendDTMF:callID dtmf:numberString];
}

- (void)answer
{
    NSInteger ret = [self.modelEngineVoip acceptCall:self.callID];
    if (ret == 0)
    {
        self.status = IncomingCallStatus_accepted;
        [self refreshView];
    }
    else
    {
        [self exitView];
    }
}

- (void)handfree
{
    //成功时返回0，失败时返回-1
    int returnValue = [self.modelEngineVoip enableLoudsSpeaker:!isLouder];
    if (0 == returnValue)
    {
        isLouder = !isLouder;
    }
    if (isLouder) 
    {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnOnpng] forState:UIControlStateNormal];
    }
    else
    {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
    }
}

- (void)mute
{
    int muteFlag = [self.modelEngineVoip getMuteStatus];
    if (muteFlag == MuteFlagNotMute1) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagIsMute1];
    }
    else
    {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagNotMute1];
    }
}

- (void)releaseCall
{
    [self.modelEngineVoip releaseCall:self.callID];
}

- (void)hangup
{
    [self.modelEngineVoip releaseCall:self.callID];
    [self exitView];
}

- (void)refreshView
{
    if (self.status == IncomingCallStatus_accepting)
    {
        self.lblIncoming.text = @"正在接听...";
        self.rejectButton.enabled = NO;
        self.rejectButton.hidden = YES;
        
        self.answerButton.enabled = NO;
        self.answerButton.hidden = YES;
        
        self.handfreeButton.enabled = YES;
        self.handfreeButton.hidden = NO;
        
        self.muteButton.enabled = YES;
        self.muteButton.hidden = NO;
        
        self.hangUpButton.enabled = YES;
        self.hangUpButton.hidden = NO;
        
        self.functionAreaView.hidden = NO;
        backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];

        [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
    }
    else if (self.status == IncomingCallStatus_incoming)
    {
        
    }
    else if(self.status == IncomingCallStatus_accepted)
    {
    }
    else
    {
        
    }
}
- (void)accept
{
    self.status = IncomingCallStatus_accepting;
    [self refreshView];
}

-(void) exitView
{
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)process
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
	[pool release];
}

- (void)dismissView
{
    [NSThread detachNewThreadSelector:@selector(process) toTarget:self withObject:nil];
}

@end
