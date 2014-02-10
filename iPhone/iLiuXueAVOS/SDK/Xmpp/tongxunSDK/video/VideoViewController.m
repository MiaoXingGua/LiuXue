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
#import "VideoViewController.h"
@interface VideoViewController ()
{
    UILabel *statusLabel;
    UILabel *timeLabel;
    UILabel *callStatusLabel;
    UIView *localVideoView;
    UIView *remoteVideoView;
    
    NSInteger curCameraIndex;
}
@property (nonatomic, retain) UIView *makeCallView;
@property (nonatomic, retain) UIView *incomingCallView;
@property (nonatomic, retain) UIView *callingView;
@property (nonatomic, retain) NSArray *cameraInfoArr;
-(void)makeCallViewLayout;
-(void)incomingCallViewLayout;
-(void)callingViewLayout;
-(void)switchCamera;
@end


#define ACTION_CALL_VIEW_FRAME CGRectMake(0.0f, self.view.frame.size.height-54.0f, 320.0f, 54.0f)
#define ACTION_CALL_VIEW_BACKGROUNTCOLOR [UIColor colorWithRed:75.0f/255.0f green:85.0f/255.0f blue:150.0f/255.0f alpha:1.0f]
extern BOOL globalisVoipView;
@implementation VideoViewController

@synthesize callID;
@synthesize callerName;
@synthesize voipNo;
@synthesize hangUpButton;
@synthesize acceptButton;
@synthesize makeCallView;
@synthesize incomingCallView;
@synthesize callingView;
@synthesize p2pStatusLabel;
- (id)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNop andCallstatus:(NSInteger)status
{
    if (self = [super init])
    {
        self.callerName = name;
        self.voipNo = voipNop;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        callStatus = status;
        [self.modelEngineVoip enableLoudsSpeaker:YES];
        
        self.cameraInfoArr = [self.modelEngineVoip getCameraInfo];
        
        //默认使用前置摄像头
        curCameraIndex = self.cameraInfoArr.count-1;
        if (curCameraIndex >= 0)
        {
            CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
            CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
            [self.modelEngineVoip selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_Auto];
        }
        
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_VIDEO;
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UIImageView *videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon.png"]];
    videoIcon.center = CGPointMake(160.0f, 213.0f);
    [self.view addSubview:videoIcon];
    [videoIcon release];
    
    UILabel *statusLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
    statusLabeltmp.backgroundColor = [UIColor clearColor];
    statusLabeltmp.textColor = [UIColor whiteColor];
    statusLabeltmp.font = [UIFont systemFontOfSize:13.0f];
    statusLabel = statusLabeltmp;
    [self.view addSubview:statusLabeltmp];
    [statusLabeltmp release];
    
    UIView *tmpView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 406.0f)];
    remoteVideoView = tmpView1;
    tmpView1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tmpView1];
    [tmpView1 release];
    
    UIView *tmpView2 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 283.0f, 80.0f, 107.0f)];
    tmpView1.backgroundColor = [UIColor clearColor];
    localVideoView = tmpView2;
    [self.view addSubview:tmpView2];
    [tmpView2 release];

    if (callStatus == 0)
    {
        //进来之后先拨号
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* videoBitRates = [userDefaults objectForKey:VIDEOSTREAM_CONTENT_KEY];//获取当前视频码率
        int videoStreamKey = [userDefaults integerForKey:VIDEOSTREAM_KEY];
        int rates= 150;
        if (videoStreamKey == 1)//如果没有取到视频码率或者码率或者关闭状态默认取150
        {
            if (videoBitRates.length > 0)
                rates = videoBitRates.integerValue;
        }
        
        [self.modelEngineVoip setVideoBitRates:rates];
        self.callID = [self.modelEngineVoip makeCall:self.voipNo withPhone:nil withType:EVoipCallType_Video withVoipType:1];
        
        if (self.callID.length <= 0)//获取CallID失败，即拨打失败
        {
            statusLabel.text = @"对方不在线或网络不给力";
        }
        [self makeCallViewLayout];
    }
    else if(callStatus == 1)
    {
        statusLabel.text = [NSString stringWithFormat:@"%@邀请您进行视频通话", self.voipNo];
        [self incomingCallViewLayout];
    }

}

- (void)viewDidUnload
{
    self.callID = nil;
    self.callerName = nil;
    self.voipNo = nil;
    self.hangUpButton = nil;
    self.acceptButton = nil;
    self.incomingCallView = nil;
    self.callingView = nil;
    self.makeCallView =nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    globalisVoipView = YES;
    
    [self.modelEngineVoip setModalEngineDelegate:self];
    
    //视频
    [self.modelEngineVoip setVideoView:remoteVideoView andLocalView:localVideoView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    globalisVoipView = NO;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.modelEngineVoip enableLoudsSpeaker:NO];
    [super viewDidDisappear:animated];
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
        callStatusLabel.text = [NSString stringWithFormat:@"丢包率%0.2f%%",lost];
    }
    if (hhInt > 0) {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    }
    else
    {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)updateRealTimeStatusLabel
{
    statusLabel.text = @"正在挂机...";
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
    self.voipNo = nil;
    self.hangUpButton = nil;
    self.acceptButton = nil;
    self.incomingCallView = nil;
    self.callingView = nil;
    self.makeCallView =nil;
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
            statusLabel.text = @"呼叫中...";
        }
            break;
        case ECallStatus_Alerting:
        {
            statusLabel.text = @"等待对方接听";
        }
            break;
            
        case ECallStatus_Answered:
        {
            [self callingViewLayout];
            timeLabel.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            [self.modelEngineVoip enableLoudsSpeaker:YES];
        }
            break;
        case ECallStatus_Failed:
        {
            statusLabel.text = data;
            if( data.intValue == EReasonNoResponse)
            {
                statusLabel.text = @"网络不给力";
            }
            else if( data.intValue == EReasonBadCredentials )
            {
                statusLabel.text = @"鉴权失败";
            }
            else if ( data.intValue == EReasonBusy || data.intValue == EReasonDeclined )
            {
                statusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            }
            else if( data.intValue == EReasonNotFound)
            {
                statusLabel.text = @"对方不在线";
            }
            else if( data.intValue == EReasonCallMissed )
            {
                statusLabel.text = @"呼叫超时";
            }
//            else if( data.intValue == EReasonRegisterFailed )
//            {
//                statusLabel.text = @"连接服务器失败";
//            }
//            else if( data.intValue == EReasonDoesNotSupport)
//            {
//                statusLabel.text = @"该版本不支持此功能";
//            }
            else if( data.intValue == 700 )
            {
                statusLabel.text = @"第三方鉴权地址连接失败";
            }
            else if( data.intValue == EReasonCalleeNoVoip )
            {
                statusLabel.text = @"对方版本不支持视频";
            }
            else if( data.intValue == 701 )
            {
                statusLabel.text = @"主账号余额不足";
            }
            else if( data.intValue == 702 )
            {
                statusLabel.text = @"主账号无效（未找到应用信息）";
            }
            else if( data.intValue == 703 )
            {
                statusLabel.text = @"呼叫受限 ，外呼号码限制呼叫";
            }
            else if( data.intValue == 705 )
            {
                statusLabel.text = @"第三方鉴权失败，子账号余额不足";
            }
            else if( data.intValue == 488 )
            {
                statusLabel.text = @"媒体协商失败";
            }
            else
            {
                statusLabel.text = @"呼叫失败";
            }
        }
            break;
            
        case ECallStatus_Released:
        {
            if ([timer isValid])
            {
                [timer invalidate];
                timer = nil;
            }
            
            statusLabel.text = @"正在挂机...";
            [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
        default:
            break;
    }
}

- (void)hangup
{
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    statusLabel.text = @"正在挂机...";
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
}

- (void)accept
{
    [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
}
- (void)answer
{
    NSInteger ret = [self.modelEngineVoip acceptCall:self.callID withType:EVoipCallType_Video];
    if (ret == 0)
    {
        [self callingViewLayout];
    }
    else
    {
        [self backFront];
    }
}

- (void)releaseCall
{
    [self.modelEngineVoip releaseCall:self.callID];
}

-(void)makeCallViewLayout
{
    statusLabel.text = @"正在等待对方接受邀请......";
    if (self.makeCallView == nil)
    {
        self.makeCallView = [[[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME] autorelease];
        [self.view addSubview:self.makeCallView];
        self.makeCallView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.makeCallView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f, 6.0f, 291.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button2_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button2_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束视频通话" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.view bringSubviewToFront:self.makeCallView];
    }
}

-(void)incomingCallViewLayout
{
    if (self.incomingCallView == nil)
    {
        self.incomingCallView = [[[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME] autorelease];
        [self.view addSubview:self.incomingCallView];
        self.incomingCallView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        UIButton* answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.incomingCallView addSubview:answerBtn];
        answerBtn.frame = CGRectMake(15.0f, 6.0f, 201.0f, 42.0f);
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"video_button_on.png"] forState:UIControlStateHighlighted];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"video_button_off.png"] forState:UIControlStateNormal];
        [answerBtn setTitle:@"开始视频通话" forState:UIControlStateNormal];
        answerBtn.titleLabel.textColor = [UIColor whiteColor];
        [answerBtn addTarget:self action:@selector(answer) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.incomingCallView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f+210.0f+13.0f, 6.0f, 76.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        [self.view bringSubviewToFront:self.incomingCallView];
    }
}

-(void)callingViewLayout
{
    callStatus = 1;
    statusLabel.hidden = YES;
    if (self.callingView == nil)
    {
        self.callingView = [[[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME] autorelease];
        [self.view addSubview:self.callingView];
        self.callingView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;

        UILabel *labeltmp = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 6.0f, 140.0f, 42.0f)];
        labeltmp.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        [self.callingView addSubview:labeltmp];
        labeltmp.textColor = [UIColor whiteColor];
        labeltmp.text = [NSString stringWithFormat:@"与%@视频通话中", (self.voipNo.length>3?[self.voipNo substringFromIndex:(self.voipNo.length-3)]:@"")];
        [labeltmp release];
        
        UILabel *timeLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(155.0f, 6.0f, 60.0f, 42.0f)];
        timeLabel = timeLabeltmp;
        timeLabeltmp.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        [self.callingView addSubview:timeLabeltmp];
        timeLabeltmp.textColor = [UIColor whiteColor];
        timeLabeltmp.textAlignment = NSTextAlignmentRight;
        [timeLabeltmp release];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 2.0f, 200.0f, 13.0f)];
        label.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        callStatusLabel = label;
        [self.callingView addSubview:callStatusLabel];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        [label release];
        
        UILabel *tmplabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 30.0f, 155.0f, 12.0f)];
        tmplabel.backgroundColor = [UIColor clearColor];
        self.p2pStatusLabel = tmplabel;
        [self.callingView addSubview:tmplabel];
        tmplabel.textColor = [UIColor whiteColor];
        tmplabel.font = [UIFont systemFontOfSize:11];
        [tmplabel release];
        
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.callingView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f+210.0f+13.0f, 6.0f, 76.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.cameraInfoArr.count>1)
        {
            UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [switchBtn setImage:[UIImage imageNamed:@"camera_switch.png"] forState:UIControlStateNormal];
            switchBtn.frame = CGRectMake(230.0f, 35.0f, 70.0f, 35.0f);
            [self.view addSubview:switchBtn];
            [switchBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        [self.view bringSubviewToFront:self.callingView];
    }
    
}

-(void)switchCamera
{
    curCameraIndex ++;
    if (curCameraIndex >= self.cameraInfoArr.count)
    {
        curCameraIndex = 0;
    }
    CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
    [self.modelEngineVoip selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_Auto];
}




@end
