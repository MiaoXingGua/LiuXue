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

NSString * const kCallBg01pngVoip           = @"call_bg01.png";
NSString * const kCallHangUpButtonpng       = @"call_hang_up_button.png";
NSString * const kCallHangUpButtonOnpng     = @"call_hang_up_button_on.png";

#import "VoipCallController.h"
#import "ModelEngineVoip.h"
#import "AppDelegate.h"
extern BOOL globalisVoipView;

@interface VoipCallController ()
{
    BOOL isShowKeyboard;
}
@property (nonatomic,retain) UIView *keyboardView;

- (void)handfree;
- (void)mute;
- (void)hangup;
- (void)backFront;
- (void)releaseCall;
- (void)showKeyboardView;
@end

@implementation VoipCallController
@synthesize callID;
@synthesize callDirection;
@synthesize callerName;
@synthesize callerNo;
@synthesize voipNo;
@synthesize topLabel;
@synthesize callerNameLabel;
@synthesize callerNoLabel;
@synthesize realTimeStatusLabel;
@synthesize statusLabel;
@synthesize hangUpButton;
@synthesize handfreeButton;
@synthesize KeyboardButton;
@synthesize muteButton;
@synthesize functionAreaView;
@synthesize keyboardView;
@synthesize p2pStatusLabel;

- (VoipCallController *)initWithCallerName:(NSString *)name andCallerNo:(NSString *)phoneNo andVoipNo:(NSString *)voipNop andCallType:(NSInteger)type
{
    if (self = [super init])
    {
        self.callerName = name;
        self.callerNo = phoneNo;
        self.voipNo = voipNop;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        voipCallType = type;
        [self.modelEngineVoip enableLoudsSpeaker:isLouder];
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *tempView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = tempView;
    self.view.backgroundColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.0];
    [tempView release];
    
    UIImage *backImage = [UIImage imageNamed:kCallBg01pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backGroupImageView.center = CGPointMake(160.0, self.view.frame.size.height*0.5);
    [self.view addSubview:backGroupImageView];
    [backGroupImageView release];
    
    //名字
    UILabel *tempCallerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-100.0f, 28.0f, 200.0f, 22.0f)];
    tempCallerNameLabel.text = self.callerName;
    tempCallerNameLabel.font = [UIFont systemFontOfSize:20.0f];
    tempCallerNameLabel.textColor = [UIColor whiteColor];
    tempCallerNameLabel.backgroundColor = [UIColor clearColor];
    tempCallerNameLabel.textAlignment = UITextAlignmentCenter;
    self.callerNameLabel = tempCallerNameLabel;
    [self.view addSubview:self.callerNameLabel];
    [tempCallerNameLabel release];
    
    //电话
    UILabel *tempCallerNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-100.0f, 54.0f, 200.0f, 20.0f)];
    tempCallerNoLabel.text = self.callerNo;
    tempCallerNoLabel.font = [UIFont systemFontOfSize:18.0f];
    tempCallerNoLabel.textColor = [UIColor whiteColor];
    tempCallerNoLabel.backgroundColor = [UIColor clearColor];
    tempCallerNoLabel.textAlignment = UITextAlignmentCenter;
    self.callerNoLabel = tempCallerNoLabel;
    [self.view addSubview:self.callerNoLabel];
    [tempCallerNoLabel release];
    
    //连接状态提示
    UILabel *tempRealTimeStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 80.0f, 300.0f, 16.0f)];
    tempRealTimeStatusLabel.text = @"网络正在连接请稍后...";
    tempRealTimeStatusLabel.textColor = [UIColor whiteColor];
    tempRealTimeStatusLabel.backgroundColor = [UIColor clearColor];
    tempRealTimeStatusLabel.textAlignment = UITextAlignmentCenter;
    self.realTimeStatusLabel = tempRealTimeStatusLabel;
    [self.view addSubview:self.realTimeStatusLabel];
    [tempRealTimeStatusLabel release];
    
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
    
    
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-43.0f-5.0f, 320.0f, 43.0f)];
    self.functionAreaView = tempfunctionAreaView;
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tempfunctionAreaView];
    [tempfunctionAreaView release];
    
    isShowKeyboard = NO;
    //键盘显示按钮
    UIButton *tempKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.KeyboardButton = tempKeyboardButton;
    tempKeyboardButton.frame = CGRectMake(23.5f, 0.0f, 91.0f, 43.0f);
    [tempKeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
    [tempKeyboardButton addTarget:self action:@selector(showKeyboardView) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempKeyboardButton];
    
    //免提按钮
    UIButton *tempHandFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHandFreeButton.frame = CGRectMake(23.5f+91.0*2, 0.0f, 91.0f, 43.0f);
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
    
    //挂机
    UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHangupButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 320.0f-24.0f-24.0f, 42.0f);
    
    [tempHangupButton setImage:[UIImage imageNamed:kCallHangUpButtonpng] forState:UIControlStateNormal];
    [tempHangupButton setImage:[UIImage imageNamed:kCallHangUpButtonOnpng] forState:UIControlStateHighlighted];
    
    [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.hangUpButton = tempHangupButton;
    [self.view addSubview:self.hangUpButton];
    
    //进来之后先拨号
    if (voipCallType==0)
    {
        self.callID = [self.modelEngineVoip makeCall:self.voipNo withPhone:self.callerNo withType:EVoipCallType_Voice withVoipType:1];
    }
    else if(voipCallType==1)
    {
        //等待调用SDK中网络直拨接口
        self.callID = [self.modelEngineVoip makeCall:self.voipNo withPhone:self.callerNo withType:EVoipCallType_Voice withVoipType:0];
    }
    else
    {
        [[ModelEngineVoip getInstance] callback:[ModelEngineVoip getInstance].voipPhone withTOCall:self.callerNo];
    }
    
    if (voipCallType==2)
    {
        self.realTimeStatusLabel.text = @"正在回拨...";
        self.handfreeButton.hidden = YES;
        self.handfreeButton.enabled = NO;
        self.muteButton.hidden = YES;
        self.muteButton.enabled = NO;
        self.hangUpButton.hidden = NO;
        self.hangUpButton.enabled = YES;
        self.functionAreaView.hidden = YES;
        isShowKeyboard = YES;
        [self showKeyboardView];
    }
    else if (self.callID.length <= 0)//获取CallID失败，即拨打失败
    {
        self.realTimeStatusLabel.text = @"对方不在线或网络不给力";
        self.handfreeButton.hidden = YES;
        self.handfreeButton.enabled = NO;
        self.muteButton.hidden = YES;
        self.muteButton.enabled = NO;
        self.hangUpButton.hidden = NO;
        self.hangUpButton.enabled = YES;
        self.functionAreaView.hidden = YES;
        isShowKeyboard = YES;
        [self showKeyboardView];
    }
}

- (void)viewDidUnload
{
    self.callID = nil;
    self.callerName = nil;
    self.callerNo = nil;
    self.voipNo = nil;
    self.topLabel = nil;
    self.callerNameLabel = nil;
    self.callerNoLabel = nil;
    self.realTimeStatusLabel = nil;
    self.statusLabel = nil;
    self.hangUpButton = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;
    self.keyboardView = nil;
    self.functionAreaView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    globalisVoipView = YES;
    
    [self.modelEngineVoip setModalEngineDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    globalisVoipView = NO;
    [super viewDidDisappear:animated];
}


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
        [self.view bringSubviewToFront:self.keyboardView];
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
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
        self.realTimeStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    }
    else
    {
        self.realTimeStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)updateRealTimeStatusLabel
{
    self.realTimeStatusLabel.text = @"正在挂机...";
}

- (void)backFront
{
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    self.callID = nil;
    self.callerName = nil;
    self.callerNo = nil;
    self.voipNo = nil;
    self.topLabel = nil;
    self.callerNameLabel = nil;
    self.callerNoLabel = nil;
    self.realTimeStatusLabel = nil;
    self.statusLabel = nil;
    self.hangUpButton = nil;
    self.KeyboardButton = nil;
    self.keyboardView = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;
    self.functionAreaView = nil;
    self.p2pStatusLabel = nil;
    [super dealloc];
}

#pragma mark - ModelEngineUIDelegate
-(void)responseVoipManagerStatus:(ECallStatusResult)event callID:(NSString*)callid data:(NSString *)data
{
    self.callID = callid;
    switch (event)
    {
        case ECallStatus_Proceeding:
        {
            self.realTimeStatusLabel.text = @"呼叫中...";
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
        }
            break;
        case ECallStatus_Alerting:
        {
            self.realTimeStatusLabel.text = @"等待对方接听";
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
        }
            break;
            
        case ECallStatus_Answered:
        {
            self.realTimeStatusLabel.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            
        }
            break;
        case ECallStatus_Failed:
        {
            self.realTimeStatusLabel.text = data;
            if( data.intValue == EReasonNoResponse)
            {
                self.realTimeStatusLabel.text = @"网络不给力";
            }
            else if( data.intValue == EReasonBadCredentials )
            {
                self.realTimeStatusLabel.text = @"鉴权失败";
            }
            else if ( data.intValue == EReasonBusy || data.intValue == EReasonDeclined )
            {
                self.realTimeStatusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            }
            else if( data.intValue == EReasonNotFound)
            {
                self.realTimeStatusLabel.text = @"对方不在线";
            }
            else if( data.intValue == EReasonCallMissed )
            {
                self.realTimeStatusLabel.text = @"呼叫超时";
            }
//            else if( data.intValue == EReasonRegisterFailed )
//            {
//                self.realTimeStatusLabel.text = @"连接服务器失败";
//            }
//            else if( data.intValue == EReasonDoesNotSupport)
//            {
//                self.realTimeStatusLabel.text = @"该版本不支持此功能";
//            }
            else if( data.intValue == EReasonCalleeNoVoip )
            {
                self.realTimeStatusLabel.text = @"对方版本不支持音频";
            }
            else if( data.intValue == 700 )
            {
                self.realTimeStatusLabel.text = @"第三方鉴权地址连接失败";
            }            
            else if( data.intValue == 701 )
            {
                self.realTimeStatusLabel.text = @"主账号余额不足";
            }
            else if( data.intValue == 702 )
            {
                self.realTimeStatusLabel.text = @"主账号无效（未找到应用信息）";
            }
            else if( data.intValue == 703 )
            {
                self.realTimeStatusLabel.text = @"呼叫受限 ，外呼号码限制呼叫";
            }
            else if( data.intValue == 705 )
            {
                self.realTimeStatusLabel.text = @"第三方鉴权失败，子账号余额不足";
            }
            else if( data.intValue == 488 )
            {
                self.realTimeStatusLabel.text = @"媒体协商失败";
            }
            else
            {
                self.realTimeStatusLabel.text = @"呼叫失败";
            }
            
            self.functionAreaView.hidden = YES;
            isShowKeyboard = YES;
            [self showKeyboardView];
            
            self.handfreeButton.enabled = NO;
            [self.handfreeButton setHidden:YES];
            self.muteButton.enabled = NO;
            [self.muteButton setHidden:YES];
        }
            break;
    
        case ECallStatus_Released:
        {
            if ([timer isValid]) 
            {
                [timer invalidate];
                timer = nil;
            }
            
            self.realTimeStatusLabel.text = @"正在挂机...";
            [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
        case ECallStatus_CallBack:
        {
            self.realTimeStatusLabel.text = @"回拨呼叫成功,请注意接听系统来电";
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
        case ECallStatus_CallBackFailed:
        {
            self.realTimeStatusLabel.text = @"回拨呼叫失败,请稍后再试";
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
        default:
            break;
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
    if (muteFlag == MuteFlagNotMute) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagIsMute];
    }
    else
    {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagNotMute];
    }
}

- (void)hangup
{
    if (voipCallType == 2)
    {
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
    }
    else
    {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
        self.realTimeStatusLabel.text = @"正在挂机...";
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
    }
}

- (void)releaseCall
{
    [self.modelEngineVoip releaseCall:self.callID];
}

@end
