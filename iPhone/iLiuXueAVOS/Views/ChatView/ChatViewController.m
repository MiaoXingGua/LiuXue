//
//  TakeMessageViewController.m
//  NightTalk
//
//  Created by superhomeliu on 13-6-9.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ALProgressImageView.h"
#import "JSONKit.h"
#import "NSString+Encode.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIImage+imageNamed_Hack.h"
#import "AsyncImageView.h"
#import "AppDelegate.h"
#import "MessageCenter.h"
#import "MIDCreate.h"
#import "ViewData.h"
#import "PersonalDataViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize chatArray = _chatArray;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextView = _messageTextView;
@synthesize messageString = _messageString;
@synthesize lastTime = _lastTime;
@synthesize recorderVC,player,originWav,convertAmr,convertWav;
@synthesize selfheadImg = _selfheadImg,otherheadImg = _otherheadImg;
@synthesize selfImageUrl = _selfImageUrl,otherImageUrl = _otherImageUrl;
@synthesize previewData = _previewData;
@synthesize chatUser = _chatUser;
@synthesize messageIDArray = _messageIDArray;

- (void)dealloc
{
    [_chatUser release]; _chatUser=nil;
    [_previewData release]; _previewData=nil;
    [_selfImageUrl release]; _selfImageUrl=nil;
    [_otherImageUrl release]; _otherImageUrl=nil;
    [_selfheadImg release]; _selfheadImg=nil;
    [_otherheadImg release]; _otherheadImg=nil;
	[_lastTime release]; _lastTime=nil;
	[_messageString release]; _messageString=nil;
    [_messageTextView release]; _messageTextView=nil;
	[_chatArray release]; _chatArray=nil;
	[_chatTableView release]; _chatTableView=nil;
    [recorderVC release]; recorderVC=nil;
    [_faceMap release]; _faceMap=nil;
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
    
    [super dealloc];
}

- (id)initWithUser:(User *)user
{
    if (self = [super init])
    {
        self.chatUser = user;
        if (user.gender==0)
        {
            _takeUsergender = 0;
        }
        else
        {
            _takeUsergender = 1;
        }
        
        if ([ALUserEngine defauleEngine].user.gender==0)
        {
            _sendUsergender=0;
        }
        else
        {
            _sendUsergender=1;
        }
    }
    
    return self;
}

- (id)initWithUser:(User *)user fromNotifition:(NSDictionary *)info IsFromNotifition:(BOOL)isFrom
{
    if (self = [super init])
    {
        
        isFromNotifition = isFrom;
        
        self.chatUser = user;
        
        if (user.gender==0)
        {
            _takeUsergender = 0;
        }
        else
        {
            _takeUsergender = 1;
        }
        
        if ([ALUserEngine defauleEngine].user.gender==0)
        {
            _sendUsergender=0;
        }
        else
        {
            _sendUsergender=1;
        }
    }
    
    return self;
}



-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}


#pragma mark - 接收聊天信息
- (void)receiveNewMessage:(NSNotification *)info
{
    NSDictionary *_tempDic = [NSDictionary dictionaryWithDictionary:[info userInfo]];
    
    NSString *typeStr = [_tempDic objectForKey:@"subType"];
    NSString *msgId = [_tempDic objectForKey:@"msgId"];
    
    //文字类型
    if ([typeStr isEqualToString:@"text"])
    {
        NSString *_content = [_tempDic objectForKey:@"url"];
        
        if (_content.length>0)
        {
            [self.messageIDArray addObject:msgId];
            
            [self sendMassage:_content from:NO isHistroy:NO];
        }
    }
    //图片类型
    if ([typeStr isEqualToString:@"image"])
    {
        NSString *_imageUrl = [_tempDic objectForKey:@"url"];
        CGSize _imageSize = CGSizeFromString([_tempDic objectForKey:@"size"]);
        NSString *_priviewUrl = [_tempDic objectForKey:@"preview"];
        
        if (_imageUrl.length>0)
        {
            [self.messageIDArray addObject:msgId];

            [self creatImagebubbleViewSize:_imageSize ImgURL:_imageUrl priViewUrl:_priviewUrl isHistroy:NO From:NO];
        }
    }
    //视频类型
    if ([typeStr isEqualToString:@"video"])
    {
        __block NSString *_videoUrl = [[_tempDic objectForKey:@"url"] retain];
        __block NSString *_previewUrl = [_tempDic objectForKey:@"preview"];
        
        __block typeof(self) bself = self;

        if (_videoUrl.length>0)
        {
            [self.messageIDArray addObject:msgId];
            
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                __block NSData *previewData = [[NSData dataWithContentsOfURL:[NSURL URLWithString:_previewUrl]] retain];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [bself creatVideobubbliView:previewData Video:_videoUrl isHistroy:NO From:NO];

                    [previewData release]; previewData=nil;
                    [_videoUrl release]; _videoUrl=nil;
                    
                });
            });
        }
    }
    //声音类型
    if ([typeStr isEqualToString:@"voice"])
    {
        __block NSString *_voiceStr = [[_tempDic objectForKey:@"url"] retain];
        
        if (_voiceStr.length>0)
        {
            [self.messageIDArray addObject:msgId];
            
            __block typeof(self) bself = self;
            
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
               __block NSData *_voiceData = [[NSData dataWithContentsOfURL:[NSURL URLWithString:_voiceStr]] retain];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [bself takeVoice:_voiceData fromSelf:NO isHistroy:NO];
                    
                    [_voiceData release]; _voiceData=nil;
                    [_voiceStr release]; _voiceStr=nil;
                    
                });
            });
        }
    }
}

//- (void)downLoadVideo:(NSArray *)array
//{
//    NSData *previewData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[array objectAtIndex:1]]];
//    NSString *_videoUrl = [array objectAtIndex:0];
//    
//    [self creatVideobubbliView:previewData Video:_videoUrl isHistroy:NO From:NO];
//}

//- (void)downLoadVoice:(NSString *)voiceUrl
//{
//    NSData *_voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:voiceUrl]];
//    
//    if (_voiceData)
//    {
//        [self takeVoice:_voiceData fromSelf:NO isHistroy:NO];
//    }
//}

#pragma mark - 被迫下线
- (void)userLogOut
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的账号已下线" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    alert=nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self back:nil];
}

#pragma mark - 用户当前不在线
//- (void)checkUserState:(NSNotification *)info
//{
//    NSLog(@"用户不在线！！！");
//    
//    title.text = [NSString stringWithFormat:@"%@(离线)",self.chatUser.nickName];
//
//}

#pragma mark - ViewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ViewData defaultManager].isShowChatView=YES;
    
    //用户被迫下线
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage:) name:NOTIFICATION_NEW_MESSAGE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalImageView:) name:@"removeImageView" object:nil];
    
    isVoice = NO;
    isSelectSqlite = NO;
    
    self.chatArray = [NSMutableArray arrayWithCapacity:0];
    self.messageIDArray = [NSMutableArray arrayWithCapacity:0];
    
    stateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0011111111_bg.png"]];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    [self.view addSubview:stateView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIImageView *bgImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0029_Background.png"]];
    bgImageview.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    [backgroundView addSubview:bgImageview];
    [bgImageview release];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 15)];
    headView.backgroundColor = [UIColor clearColor];
    
    self.chatTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain] autorelease];
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.tag = 1000;
    self.chatTableView.separatorColor = [UIColor clearColor];
    self.chatTableView.backgroundColor = [UIColor clearColor];
    self.chatTableView.tableHeaderView = headView;
    [backgroundView addSubview:self.chatTableView];
    [headView release];
    
    UIImageView *navigationBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0011111111_bg.png"]];
    navigationBarView.frame = CGRectMake(0, 0, 320, 45);
    [backgroundView addSubview:navigationBarView];
    navigationBarView.userInteractionEnabled = YES;
    [navigationBarView release];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    title.center = CGPointMake(160, 23);
    title.text = self.chatUser.nickName;
    [title setTextAlignment:NSTextAlignmentCenter];
    title.font = [UIFont systemFontOfSize:20];
    title.font = [UIFont boldSystemFontOfSize:20];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    [navigationBarView addSubview:title];
    [title release];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 10, 30, 30);
    [backBtn setImage:[UIImage imageNamed:@"_0010_chat_返回.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:backBtn];

    UIButton *friendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendBtn.frame = CGRectMake(280, 10, 30, 30);
    [friendBtn setImage:[UIImage imageNamed:@"_0001_好友信息.png"] forState:UIControlStateNormal];
    [friendBtn addTarget:self action:@selector(showFriendInfo:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:friendBtn];
    
    
    textBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-49-[ViewData defaultManager].versionHeight, 320, 216+49)];
    textBackView.userInteractionEnabled = YES;
    textBackView.image = [UIImage imageNamed:@"_0029_Background.png"];
    [backgroundView addSubview:textBackView];
    [textBackView release];
    
    [self addFaceView];
    [self addOperationView];

    
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
    bottomView.image = [UIImage imageNamed:@"bg(1).png"];
    [textBackView addSubview:bottomView];
    bottomView.userInteractionEnabled = YES;
    [bottomView release];

    
    inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inputBtn.frame = CGRectMake(12, 10, 33, 72/2);
    [inputBtn setImage:[UIImage imageNamed:@"_0009_语音.png"] forState:UIControlStateNormal];
    [inputBtn setImage:[UIImage imageNamed:@"_0008_语音--点击.png"] forState:UIControlStateHighlighted];
    [inputBtn addTarget:self action:@selector(changeInputState:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:inputBtn];
    
    textImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007_文字输入.png"]];
    textImage.frame = CGRectMake(70, 7, 180, 37);
    [bottomView addSubview:textImage];
    [textImage release];
    
    self.messageTextView = [[[UITextView alloc] initWithFrame:CGRectMake(65,8, 190,35)] autorelease];
    self.messageTextView.delegate = self;
    self.messageTextView.tag = 2000;
    self.messageTextView.font = [UIFont systemFontOfSize:14];
    self.messageTextView.textColor = [UIColor whiteColor];
    self.messageTextView.returnKeyType = UIReturnKeySend;
    self.messageTextView.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:self.messageTextView];
    
    
    voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.frame = CGRectMake(62, 7, 392/2, 40);
    [voiceBtn addTarget:self action:@selector(beginRecord:) forControlEvents:UIControlEventTouchDown];
    [voiceBtn setImage:[UIImage imageNamed:@"_0020_按住说话.png"] forState:UIControlStateNormal];
    [voiceBtn setImage:[UIImage imageNamed:@"_0019_按住说话---点击.png"] forState:UIControlStateHighlighted];
    [bottomView addSubview:voiceBtn];
    voiceBtn.hidden = YES;
    
    //初始化录音vc
    recorderVC = [[ChatVoiceRecorderVC alloc] init];
    recorderVC.vrbDelegate = self;
    
    //初始化播放器
    player = [[AVAudioPlayer alloc] init];
    
    //添加手势
    UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.minimumPressDuration=0.1;
    longPrees.delegate = self;
    [voiceBtn addGestureRecognizer:longPrees];
    [longPrees release];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.chatArray = tempArray;
	[tempArray release];
    tempArray=nil;
	
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
    [tempStr release];
    tempStr=nil;
    
	NSDate *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	[tempDate release];
    tempDate=nil;
    
    imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imageBtn.frame = CGRectMake(278, 10, 66/2, 72/2);
    [imageBtn setImage:[UIImage imageNamed:@"chat+(1).png"] forState:UIControlStateNormal];
    [imageBtn setImage:[UIImage imageNamed:@"chat+点击.png"] forState:UIControlStateHighlighted];
    [imageBtn addTarget:self action:@selector(selectOperation:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:imageBtn];
    
    
    UIButton *faceBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    faceBtn.frame = CGRectMake(230, 10, 33, 72/2);
    [faceBtn addTarget:self action:@selector(selectFaceImage:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:faceBtn];

    self.selfImageUrl = [ALUserEngine defauleEngine].user.headView.url;
    self.otherImageUrl = self.chatUser.headView.url;
    
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (isFromNotifition==YES)
    {
        [self takeMessageFromRemind];
    }
    
    [self addRefreshHeaderView];
}

#pragma mark -添加表情、更多操作-
- (void)addOperationView
{
    operationView = [[UIView alloc] initWithFrame:CGRectMake(0, textBackView.frame.size.height, 320, textBackView.frame.size.height-49)];
    operationView.backgroundColor = [UIColor clearColor];
    [textBackView addSubview:operationView];
    [operationView release];
    
    UIButton *openphotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openphotoBtn.frame = CGRectMake(20, 50, 70, 70);
    [openphotoBtn setImage:[UIImage imageNamed:@"_0002_Gallery.png"] forState:UIControlStateNormal];
    [openphotoBtn addTarget:self action:@selector(openPhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
    [operationView addSubview:openphotoBtn];
    
    UILabel *photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 130, 50, 20)];
    photoLabel.text = @"相册";
    photoLabel.backgroundColor = [UIColor clearColor];
    photoLabel.textColor = [UIColor whiteColor];
    photoLabel.font = [UIFont systemFontOfSize:15];
    [operationView addSubview:photoLabel];
    [photoLabel release];
    
    UIButton *openCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openCameraBtn.frame = CGRectMake(125, 50, 70, 70);
    [openCameraBtn setImage:[UIImage imageNamed:@"_0001_Camera.png"] forState:UIControlStateNormal];
    [openCameraBtn addTarget:self action:@selector(userCamera) forControlEvents:UIControlEventTouchUpInside];
    [operationView addSubview:openCameraBtn];
    
    UILabel *cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 130, 50, 20)];
    cameraLabel.text = @"相机";
    cameraLabel.backgroundColor = [UIColor clearColor];
    cameraLabel.textColor = [UIColor whiteColor];
    cameraLabel.font = [UIFont systemFontOfSize:15];
    [operationView addSubview:cameraLabel];
    [cameraLabel release];
    
    UIButton *userVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    userVideoBtn.frame = CGRectMake(225, 50, 70, 70);
    [userVideoBtn setImage:[UIImage imageNamed:@"_0000_Play.png"] forState:UIControlStateNormal];
    [userVideoBtn addTarget:self action:@selector(userVideo) forControlEvents:UIControlEventTouchUpInside];
    [operationView addSubview:userVideoBtn];
    
    UILabel *videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 130, 50, 20)];
    videoLabel.text = @"视频";
    videoLabel.backgroundColor = [UIColor clearColor];
    videoLabel.textColor = [UIColor whiteColor];
    videoLabel.font = [UIFont systemFontOfSize:15];
    [operationView addSubview:videoLabel];
    [videoLabel release];
}


- (void)addFaceView
{
    faceBackView = [[UIView alloc] initWithFrame:CGRectMake(0, textBackView.frame.size.height, 320, textBackView.frame.size.height-49)];
    faceBackView.backgroundColor = [UIColor clearColor];
    [textBackView addSubview:faceBackView];
    [faceBackView release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    if ([[languages objectAtIndex:0] hasPrefix:@"zh"])
    {
        _faceMap = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceMap_ch" ofType:@"plist"]] retain];
    } else
    {
        _faceMap = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceMap_en" ofType:@"plist"]] retain];
    }
    
    //表情盘
    faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, 320, faceBackView.frame.size.height)];
    faceView.pagingEnabled = YES;
    faceView.contentSize = CGSizeMake((85/28+1)*320, 200);
    faceView.showsHorizontalScrollIndicator = NO;
    faceView.showsVerticalScrollIndicator = NO;
    faceView.delegate = self;
    faceView.tag = 5000;
    faceView.backgroundColor = [UIColor clearColor];
    [faceBackView addSubview:faceView];
    [faceView release];
    
    for (int i = 1; i<=85; i++)
    {
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.tag = i;
        
        [faceButton addTarget:self
                       action:@selector(faceButton:)
             forControlEvents:UIControlEventTouchUpInside];
        
        //计算每一个表情按钮的坐标和在哪一屏
        faceButton.frame = CGRectMake((((i-1)%28)%7)*44+6+((i-1)/28*320), (((i-1)%28)/7)*44, 44, 44);
        
        NSLog(@"%@",[NSString stringWithFormat:@"0%d.png",i]);
        if (i>=10)
        {
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"0%d.png",i]] forState:UIControlStateNormal];
            
        }
        else
        {
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"00%d.png",i]] forState:UIControlStateNormal];
            
        }
        
        [faceView addSubview:faceButton];
    }
    
    
    //添加PageControl
    facePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(110, 190, 100, 20)];
    facePageControl.numberOfPages = 85/28+1;
    facePageControl.currentPage = 0;
    facePageControl.userInteractionEnabled = NO;
    [faceBackView addSubview:facePageControl];
    [facePageControl release];
    
    //删除键
    UIButton *deleteFace = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteFace setImage:[UIImage imageNamed:@"backFace.png"] forState:UIControlStateNormal];
    [deleteFace setImage:[UIImage imageNamed:@"backFaceSelect.png"] forState:UIControlStateSelected];
    [deleteFace addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
    deleteFace.frame = CGRectMake(270, 185, 38, 27);
    [faceBackView addSubview:deleteFace];
}

- (void)selectOperation:(UIButton *)sender
{
    if (keyboardshow==NO)
    {
        [self autoMovekeyBoard:216 times:0.2];
    }
    
    [self.messageTextView resignFirstResponder];
    [self showFaceView:textBackView.frame.size.height time:0.2];
    [self showOperationView:49 time:0.2];
}

- (void)selectFaceImage:(UIButton *)sender
{
    if (isVoice==YES)
    {
        [self.messageTextView becomeFirstResponder];
        
        [inputBtn setImage:[UIImage imageNamed:@"_0009_语音.png"] forState:UIControlStateNormal];
        [inputBtn setImage:[UIImage imageNamed:@"_0008_语音--点击.png"] forState:UIControlStateHighlighted];
        
        self.messageTextView.hidden = NO;
        textImage.hidden = NO;
        voiceBtn.hidden = YES;
        
        isVoice = NO;
    }
    
    
    if (keyboardshow==NO)
    {
        [self autoMovekeyBoard:216 times:0.2];
    }
    
    [self.messageTextView resignFirstResponder];
    [self showOperationView:textBackView.frame.size.height time:0.2];
    [self showFaceView:49 time:0.2];
}

- (void)showOperationView:(float)height time:(float)time
{
    [UIView animateWithDuration:time animations:^{
        
        operationView.frame = CGRectMake(0, height, 320, 216);
        
    } completion:^(BOOL finished) {
        isShowOperationView = YES;
    }];
}

- (void)showFaceView:(float)height time:(float)time
{
    [UIView animateWithDuration:time animations:^{
        
        faceBackView.frame = CGRectMake(0, height, 320, 216);
        
    } completion:^(BOOL finished) {
        isShowFaceView = YES;
    }];
}


#pragma mark -选择表情-
- (void)faceButton:(UIButton *)sender
{
    int i = sender.tag;
    
    NSMutableString *faceString = [[NSMutableString alloc] init];
    
    if (self.messageTextView.text.length>0)
    {
        [faceString appendString:self.messageTextView.text];
    }
    
    [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
    self.messageTextView.text = faceString;
    [faceString release];
    
    [self.messageTextView becomeFirstResponder];
    
}

- (void)backFace
{
    NSString *inputString;
    inputString = self.messageTextView.text;
    
    
    NSString *string = nil;
    NSInteger stringLength = inputString.length;
    if (stringLength > 0) {
        if ([@"]" isEqualToString:[inputString substringFromIndex:stringLength-1]]) {
            if ([inputString rangeOfString:@"["].location == NSNotFound){
                string = [inputString substringToIndex:stringLength - 1];
            } else {
                string = [inputString substringToIndex:[inputString rangeOfString:@"[" options:NSBackwardsSearch].location];
            }
        } else {
            string = [inputString substringToIndex:stringLength - 1];
        }
    }
    self.messageTextView.text = string;
}

#pragma mark -发图片-
- (ALProgressImageView *)sendImage:(UIImage *)image fromSelf:(BOOL)from OrginImage:(UIImage *)orgImage isHistroy:(BOOL)histroy
{
    NSDate *nowTime = [NSDate date];
	
	if ([self.chatArray lastObject] == nil)
    {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	
    
	if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120)
    {
		self.lastTime = [NSDate date];
		[self.chatArray addObject:[NSDate date]];
	}
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
    from = YES;
    
	UIImage *arrowsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:from?@"arrowsImageSelf":@"arrowsImageOthers" ofType:@"png"]];
	UIImageView *arrowsImageView = [[UIImageView alloc] initWithImage:arrowsImage];
    arrowsImageView.frame = CGRectMake(230, 21, 4, 7);
    
    
    UIImage *bubble = [UIImage imageNamed:@"chatviewimage.png"];
    
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 伸缩后重新赋值
    
    bubble = [bubble resizableImageWithCapInsets:insets];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubble];
    
    UIImageView *touxiang = [[UIImageView alloc] init];

    if (_sendUsergender==0)
    {
        touxiang.image = [UIImage imageNamed:@"nv.png"];
    }
    else
    {
        touxiang.image = [UIImage imageNamed:@"nan.png"];
    }
    
    ALProgressImageView *imgView = nil;

    UIButton *showImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showImageBtn addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];

    
    float weight;
    float height;
    
    if(image.size.width>100)
    {
        weight=100;
        height = image.size.height/(image.size.width/100);
        
        imgView = [[ALProgressImageView alloc] initWithFrame:CGRectMake(0, 0, weight, height)];
    }
    else
    {
        weight = 100;
        height = image.size.height/(image.size.width/100);
        imgView = [[ALProgressImageView alloc] initWithFrame:CGRectMake(0, 0, weight, height)];
    }
    imgView.image = image;
    
    bubbleImageView.frame = CGRectMake(210-weight, 10.0f, weight+20.0f, height+20.0f );
        
    imgView.frame= CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
    showImageBtn.frame = CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
        
    cellView.frame = CGRectMake(10, 0.0f,300, bubbleImageView.frame.size.height+30.0f);
        
    touxiang.frame = CGRectMake(300-60, 0, 46, 46);
    
    AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
    headimage.urlString = self.selfImageUrl;
    
    [touxiang addSubview:headimage];
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:imgView];
    [cellView addSubview:touxiang];
    [cellView addSubview:showImageBtn];
    [cellView addSubview:arrowsImageView];
    
    [bubbleImageView release];
    [imgView release];
    [touxiang release];
    [headimage release];
    [arrowsImageView release];
    
    if(histroy==YES)
    {
        imgView.progress = 1;
        
        [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendImage", @"speaker", cellView, @"view", orgImage,@"orgImage", nil] atIndex:0];
        
        [self.chatTableView reloadData];
       
    }
    else
    {
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendImage", @"speaker", cellView, @"view", orgImage,@"orgImage", nil]];
        
        [self.chatTableView reloadData];
        
        NSLog(@"count:%d",self.chatArray.count);
        
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
            
        } completion:^(BOOL finished) {
            
        }];
        
       
        
    }
    
    [cellView release];

    return imgView;
}

- (void)showImage:(UIButton *)sender
{
    NSString *stateStr = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"speaker"];
    NSString *isfromhistory = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"history"];
    
    UIImage *_image=nil;
    NSString *url=nil;
    
    if ([isfromhistory isEqualToString:@"YES"])
    {
        url = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"imgurl"];
    }
    else
    {
        if([stateStr isEqualToString:@"sendImage"])
        {
            _image = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"orgImage"];
        }
        else
        {
            url = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"imgurl"];
        }
    }
    
    
    if(showImageView==nil)
    {
        showImageView = [[ShowImageViewController alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) ImageUrl:url Image:_image];
        [self.view addSubview:showImageView.view];
    }
}

- (void)removeOriginalImageView:(NSNotification *)info
{
    [showImageView release];
    showImageView=nil;
}

#pragma mark 发送图片
- (void)sendImage:(UIImage *)img
{
    UIImage *img1;
    UIImage *previewImage;
    
    float resolution = img.size.width*img.size.height;
    float i = resolution/150000;
    
    NSLog(@"%f",resolution/150000);
    
    if (i>=8)
    {
        i=8;
    }
    
    img1 = [img imageScaled:i];
    
    previewImage = [img imageScaled:15];
    
    //压缩图
    NSData *_postImgData = UIImageJPEGRepresentation(img1, 1);
    //缩略图
    NSData *_tempPreviewData = UIImageJPEGRepresentation(previewImage, 0.1);
    
    NSLog(@"图片质量:%d",_postImgData.length);

    __block ALProgressImageView *imgView = [self sendImage:img1 fromSelf:YES OrginImage:img isHistroy:NO];
    
    
    CGSize _imageSize = CGSizeMake(img1.size.width, img1.size.height);
    
    
    if (imgView)
    {
        imgView.progress = 0.0;
    }
    
    [[ALXMPPEngine defauleEngine] postMessageWithImage:_postImgData extension:@"jpg" preview:_tempPreviewData size:_imageSize block:^(NSString *string , NSError *error) {
        
        if (string.length>0 && !error)
        {
            NSLog(@"图片发送成功");
            if (imgView) imgView.progress = 1.0;
        }
        else
        {
            NSLog(@"图片发送失败");
        }
        
    } progressBlock:^(float percentDone) {
        
        NSLog(@"%f",percentDone);
        imgView.progress = percentDone;

    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];

    
    NSLog(@"%@",info);
    //原图
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //   UIImageWriteToSavedPhotosAlbum(img, nil, nil,nil);
   
    
    if(img)
    {
        //发送图片
        [self performSelectorInBackground:@selector(sendImage:) withObject:img];
    }
    else
    {
        
        NSURL* path = [info objectForKey:@"UIImagePickerControllerMediaURL"];
        
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
            
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if (*stop) {
                    //点击“好”回调方法:
                    NSLog(@"好");
                    
                    [self dismissViewControllerAnimated:YES completion:nil];

                    [self performSelectorInBackground:@selector(videoselect:) withObject:path];

                    return;
                    
                }
                
                *stop = TRUE;
                
            } failureBlock:^(NSError *error) {
                
                //点击“不允许”回调方法:
                NSLog(@"不允许");
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];

            [self performSelectorInBackground:@selector(videoselect:) withObject:path];
        }
        
    }

}

#pragma mark 发送视频
- (void)videoselect:(NSURL *)path
{
    NSArray *array = [self sendVideo:[NSString stringWithFormat:@"%@",path] fromself:YES isHistroy:NO];
    
    NSLog(@"%@",array);
    
    __block ALProgressImageView *imgView = [array objectAtIndex:0];
    __block UIButton *playBtn = [array objectAtIndex:1];
    
    NSData *_tempVideoData = [NSData dataWithContentsOfURL:path];
    
    if (imgView) imgView.progress = 0.0;
    
    __block typeof(self) bself = self;
    
    [[ALXMPPEngine defauleEngine] postMessageWithVideo:_tempVideoData extension:@"mov" preview:self.previewData block:^(NSString *string , NSError *error) {
        
        if (string.length>0)
        {
            [bself.messageIDArray addObject:string];
            
            imgView.progress=1;
            playBtn.hidden = NO;
            
            NSLog(@"视频发送成功");
        }
        else
        {
            NSLog(@"视频发送失败");
            
        }

    } progressBlock:^(float percentDone) {
        imgView.progress = percentDone;

    }];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
        imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePiker.delegate = self;
        [self presentViewController:imagePiker
                               animated:YES
                             completion:NULL];
        [imagePiker release];
    }
    if (buttonIndex == 1)
    {
            
        UIImagePickerController *imagPickerC = [[UIImagePickerController alloc] init];//图像选取器
        imagPickerC.delegate = self;
        imagPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
        imagPickerC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
        [self presentViewController:imagPickerC animated:YES completion:nil];//打开模态视图控制器选择图像
        [imagPickerC release];
            
    }
    if(buttonIndex == 2)
    {
        UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
        pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        [self presentViewController:pickerView animated:YES completion:nil];
        pickerView.videoMaximumDuration = 10;
        pickerView.delegate = self;
        [pickerView release];
    }
    
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[[UIImage alloc] initWithCGImage:thumbnailImageRef] autorelease] : nil;
    
    return thumbnailImage;
}

- (NSArray *)sendVideo:(NSString *)filepath fromself:(BOOL)from isHistroy:(BOOL)histroy
{
    NSDate *nowTime = [NSDate date];
	
	if ([self.chatArray lastObject] == nil)
    {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	
    
	if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
		self.lastTime = [NSDate date];
		[self.chatArray addObject:[NSDate date]];
	}


    //视频截图 thumbnailImageAtTime当前帧数
    UIImage *image = [self thumbnailImageForVideo:[NSURL URLWithString:filepath] atTime:2];
    
    self.previewData = UIImageJPEGRepresentation(image, 0.01);
    
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero]; 
    cellView.backgroundColor = [UIColor clearColor];
    
    from = YES;
    
	UIImage *arrowsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:from?@"arrowsImageSelf":@"arrowsImageOthers" ofType:@"png"]];
	UIImageView *arrowsImageView = [[UIImageView alloc] initWithImage:arrowsImage];
    arrowsImageView.frame = CGRectMake(230, 21, 4, 7);
    
    
    UIImage *bubble = [UIImage imageNamed:@"chatviewimage.png"];
    
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 伸缩后重新赋值
    
    bubble = [bubble resizableImageWithCapInsets:insets];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubble];
    
    UIImageView *touxiang = [[UIImageView alloc] init];
    
    if (_sendUsergender==0)
    {
        touxiang.image = [UIImage imageNamed:@"nv.png"];
    }
    else
    {
        touxiang.image = [UIImage imageNamed:@"nan.png"];
    }
    
    ALProgressImageView *imgView = nil;
    

    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoBtn addTarget:self action:@selector(playLocalVideo:) forControlEvents:UIControlEventTouchUpInside];
    videoBtn.hidden = YES;
    
   
    
    float weight;
    float height;
    
    if(image.size.width>100)
    {
        weight=100;
        height = image.size.height/(image.size.width/100);
        imgView = [[ALProgressImageView alloc] initWithFrame:CGRectMake(0, 0, weight, height)];
    }
    else
    {
        weight = 100;
        height = image.size.height/(image.size.width/100);
        imgView = [[ALProgressImageView alloc] initWithFrame:CGRectMake(0, 0, weight, height)];
    }
    imgView.image = image;
    
    
   touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
    AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
    headimage.urlString = self.selfImageUrl;
        
    [touxiang addSubview:headimage];
        
    bubbleImageView.frame = CGRectMake(210-weight, 10.0f, weight+20.0f, height+20.0f );
        
    imgView.frame= CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
    videoBtn.frame = CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
        
    cellView.frame = CGRectMake(10, 0.0f,300, bubbleImageView.frame.size.height+30.0f);
    cellView.backgroundColor = [UIColor clearColor];
    
    UIImageView *playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_播放.png"]];
    playImageView.frame = CGRectMake(0, 0, 61, 61);
    playImageView.center = CGPointMake(50, videoBtn.frame.size.height/2);
    [videoBtn addSubview:playImageView];

    [cellView addSubview:bubbleImageView];
    [cellView addSubview:imgView];
    [cellView addSubview:videoBtn];
    [cellView addSubview:touxiang];
    [cellView addSubview:arrowsImageView];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    [array addObject:imgView];
    [array addObject:videoBtn];
    
    [bubbleImageView release];
    [imgView release];
    [touxiang release];
    [arrowsImageView release];
    [headimage release];
    [playImageView release];
   
    
    if(histroy==YES)
    {
        [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendVideo", @"speaker", cellView, @"view", filepath,@"path",nil] atIndex:0];
        
        [self.chatTableView reloadData];
     
    }
    else
    {
         [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendVideo", @"speaker", cellView, @"view", filepath,@"path",nil]];
        
        
        [self.chatTableView reloadData];

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
   
    
   
    [cellView release];
    

    return array;
}

- (void)playLocalVideo:(UIButton *)sender
{
    NSString *path = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"path"];

    MPMoviePlayerViewController *MPVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:path]];
    [self presentMoviePlayerViewControllerAnimated:MPVC];
    [MPVC release];
}

- (void)playVideo:(UIButton *)sender
{
    NSString *videoUrl = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"path"];
    
    if (videoUrl)
    {
        MPMoviePlayerViewController *MPVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoUrl]];
        [self presentMoviePlayerViewControllerAnimated:MPVC];
        [MPVC release];
    }
  
//    NSString *key = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"path"];
//    
//    __block typeof(self) bself = self;
//    
//    BOOL isdownvideo;
//    
//    isdownvideo = NO;
//    NSString *_videoUrl;
//    
//    for(NSDictionary *dic in self.isDownLoadVideoPath)
//    {
//        if([key isEqualToString:[[dic allKeys] objectAtIndex:0]])
//        {
//            isdownvideo = YES;
//            _videoUrl = [dic objectForKey:key];
//        }
//    }
//    
//    if (isdownvideo==YES)
//    {
//        
//        MPMoviePlayerViewController *MPVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:_videoUrl]];
//        [self presentMoviePlayerViewControllerAnimated:MPVC];
//        
//        [MPVC release];
//    }
//    else
//    {
//        
//        UIView *chatView = [[bself.chatArray objectAtIndex:sender.tag] objectForKey:@"view"];
//        __block ALProgressImageView *imgview = [[chatView subviews] objectAtIndex:1];
//        
        //liujia
//        [ALQiniuDownloader downloadVideoInBackgroundWithKey:key thumbnailSize:CGSizeZero block:^(NSDictionary *result, BOOL success) {
//            
//            if (result)
//            {
//              
//                
//                NSString *videoPath = result[@"dataPath"];
//                
//                [self.isDownLoadVideoPath addObject:[NSDictionary dictionaryWithObjectsAndKeys:videoPath,key, nil]];
//                
//                MPMoviePlayerViewController *MPVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoPath]];
//                [bself presentMoviePlayerViewControllerAnimated:MPVC];
//                
//                [MPVC release];
//            }
//            
//        } progressBlock:^(float percentDone) {
//            
//            imgview.progress = percentDone;
//        }];
 //   }
    
    //http://iliuxue.qiniudn.com/2013-08-23-16-15-44-i3zu3jq0u3mS.mov
//    if(video!=nil)
//    {
//        [video removeFromSuperview];
//        video=nil;
//    }
//    
//    video = nil;
    
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
//    video = [videoView playVideoWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) path:path superView:self.view];
//    [video playVideo];
//    video = [[videoView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) path:path];
//    [self.view addSubview:video];
//    path = @"http://iliuxue.qiniudn.com/2013-08-23-16-15-44-i3zu3jq0u3mS.mov";
    
//    NSString *key = @"2013-08-23-16-15-44-i3zu3jq0u3mS.mov";
    
    
//    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.view.frame];
//    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://iliuxue.qiniudn.com/2013-08-23-16-15-44-i3zu3jq0u3mS.mov"]]];
//    [self.view addSubview:wv];
    
    //视频截图 thumbnailImageAtTime当前帧数
//    UIImage *image = [MPVC.moviePlayer thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
    //    [video stopVideo];
    
    
}




//打开相册
- (void)openPhotoAlbum
{

    UIImagePickerController *imagPickerC = [[UIImagePickerController alloc] init];//图像选取器
    imagPickerC.delegate = self;
    imagPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
    imagPickerC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
    //        imagePicker.allowsEditing = NO;//禁止对图片进行编辑
    [self presentViewController:imagPickerC animated:YES completion:nil];
    [imagPickerC release];

    [self autoMovekeyBoard:0 times:0.2];

}

//使用相机
- (void)userCamera
{

    UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
    imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //        imagePiker.allowsEditing = YES;
    imagePiker.delegate = self;
    [self presentViewController:imagePiker
                       animated:YES
                     completion:NULL];
    [imagePiker release];

    [self autoMovekeyBoard:0 times:0.2];

}

//拍摄视频
- (void)userVideo
{

    UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
    pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentViewController:pickerView animated:YES completion:nil];
    pickerView.videoMaximumDuration = 60;
    pickerView.delegate = self;
    [pickerView release];

    [self autoMovekeyBoard:0 times:0.2];

}


- (void)beginRecord:(UIButton *)sender
{
    
}


- (void)changeInputState:(UIButton *)sender
{
    if(isVoice==NO)
    {
        [self autoMovekeyBoard:0 times:0.2];

        [self.messageTextView resignFirstResponder];
        
        [inputBtn setImage:[UIImage imageNamed:@"_0013_写.png"] forState:UIControlStateNormal];
        [inputBtn setImage:[UIImage imageNamed:@"_0011_写---点击.png"] forState:UIControlStateHighlighted];
        
        self.messageTextView.hidden = YES;
        textImage.hidden = YES;
        voiceBtn.hidden = NO;
        
        isVoice = YES;
    }
    else
    {
        [self.messageTextView becomeFirstResponder];

        [inputBtn setImage:[UIImage imageNamed:@"_0009_语音.png"] forState:UIControlStateNormal];
        [inputBtn setImage:[UIImage imageNamed:@"_0008_语音--点击.png"] forState:UIControlStateHighlighted];
        
        self.messageTextView.hidden = NO;
        textImage.hidden = NO;
        voiceBtn.hidden = YES;
        
        isVoice = NO;
    }
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

#pragma mark 发送文字消息
-(void)sendMessage_Click:(id)sender
{
    int textlength = 0;
    
    if (isShowTextView)
    {
        textlength=1;
    }
    
    isShowTextView=YES;
    
    if (self.messageTextView.text.length == textlength)
    {
        [self.messageTextView resignFirstResponder];
        self.messageTextView.text = @"";

        return;
        
    }else
    {
        __block typeof(self) bself = self;

        [self.messageTextView resignFirstResponder];
        
        [self sendMassage:self.messageTextView.text from:YES isHistroy:NO];
    
        [[ALXMPPEngine defauleEngine] postMessageWithText:self.messageTextView.text block:^(NSString *string, NSError *error) {
            
            if (string.length>0)
            {
                [bself.messageIDArray addObject:string];
                
                NSLog(@"文字成功：%@",self.messageTextView.text);
            }
            else
            {
                NSLog(@"文字失败");
            }
            
        }];
    }
    
	self.messageTextView.text = @"";
    
}

#pragma mark - 读取历史记录
- (void)readHistoryMessage
{
    if (isRefresh)
    {
        return;
    }
    
    isRefresh=YES;
    
    __block typeof(self) bself = self;

    [[ALXMPPEngine defauleEngine] getUserMessageWithUser:self.chatUser notContainedIn:self.messageIDArray block:^(NSDictionary *messages, NSError *error) {
        
        NSLog(@"%@",messages);
        
        NSArray *temp = [messages objectForKey:@"chat"];

        if (temp.count>0)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:messages[@"chat"][0][@"message"]];

            [bself performSelectorInBackground:@selector(readData:) withObject:array];
        }
        else
        {
            [bself performSelector:@selector(completeReadHistoryMessage)
                        withObject:nil
                        afterDelay:1];
        }
        
    }];
}


- (void)readData:(NSArray *)array
{
    long long _historyDate=0;
    long long  _nextTime=0;
    
    for (int i=0; i<array.count; i++)
    {
        NSString *_type = [[array objectAtIndex:i] objectForKey:@"subType"];
        int _isSender = [[[array objectAtIndex:i] objectForKey:@"isSender"] intValue];
        NSString *msgId = [[array objectAtIndex:i] objectForKey:@"msgid"];


        if ([_type isEqualToString:@"text"])
        {
            NSString *_content = [[array objectAtIndex:i] objectForKey:@"url"];
            
            if (_content.length>0)
            {
                [self.messageIDArray addObject:msgId];
                
                if (_isSender==0)
                {
                    [self sendMassage:_content from:NO isHistroy:YES];
                }
                else
                {
                    [self sendMassage:_content from:YES isHistroy:YES];
                }
            }

        }
        
        if ([_type isEqualToString:@"image"])
        {
            CGSize _imageSize = CGSizeFromString([[array objectAtIndex:i] objectForKey:@"size"]);
            NSString *_url = [[array objectAtIndex:i] objectForKey:@"url"];
            NSString *_previewUrl = [[array objectAtIndex:i] objectForKey:@"preview"];
            
            [self.messageIDArray addObject:msgId];

            if (_isSender==0)
            {
                [self creatImagebubbleViewSize:_imageSize ImgURL:_url priViewUrl:_previewUrl isHistroy:YES From:NO];
            }
            else
            {
                [self creatImagebubbleViewSize:_imageSize ImgURL:_url priViewUrl:_previewUrl isHistroy:YES From:YES];
            }
        }
        
        if ([_type isEqualToString:@"voice"])
        {
            NSString *_dataUrl = [[array objectAtIndex:i] objectForKey:@"url"];
            NSData *_voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_dataUrl]];
            
            AVAudioPlayer *amrPlayerLength = [[AVAudioPlayer alloc] initWithData:_voiceData error:nil];
            
            [self.messageIDArray addObject:msgId];

            if (_isSender==0)
            {
                [self sendVoice:[NSString stringWithFormat:@"%d",(int)amrPlayerLength.duration] fromself:NO voiceData:_voiceData isHistroy:YES];
            }
            else
            {
                [self sendVoice:[NSString stringWithFormat:@"%d",(int)amrPlayerLength.duration] fromself:YES voiceData:_voiceData isHistroy:YES];
            }
            
            [amrPlayerLength release];
            amrPlayerLength = nil;
        }
        
        if ([_type isEqualToString:@"video"])
        {
            NSString *_videoUrl = [[array objectAtIndex:i] objectForKey:@"url"];
            NSString *_preview = [[array objectAtIndex:i] objectForKey:@"preview"];
            NSData *previewData = [NSData dataWithContentsOfURL:[NSURL  URLWithString:_preview]];
            
            [self.messageIDArray addObject:msgId];

            if (_isSender==0)
            {
                [self creatVideobubbliView:previewData Video:_videoUrl isHistroy:YES From:NO];
            }
            else
            {
                [self creatVideobubbliView:previewData Video:_videoUrl isHistroy:YES From:YES];
            }
        }
        
        
        _nextTime = [[[array objectAtIndex:i] objectForKey:@"curDate"] longLongValue];
        
        
        if (i==0)
        {
            _historyDate = [[[array objectAtIndex:i] objectForKey:@"curDate"] longLongValue];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
            NSDate *destDate= [dateFormatter dateFromString:[NSString stringWithFormat:@"%lld",_nextTime]];
            
            [self.chatArray insertObject:destDate atIndex:0];
            
            [dateFormatter release];
        }
        
        NSLog(@"%lld",_historyDate-_nextTime);
        
        if (_nextTime-_historyDate>120)
        {
            _historyDate = _nextTime;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
            NSDate *destDate= [dateFormatter dateFromString:[NSString stringWithFormat:@"%lld",_nextTime]];
            
            [self.chatArray insertObject:destDate atIndex:0];
            
            [dateFormatter release];
        }
        
    }
    
 
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];

    
}

- (void)refreshUI
{
    [self.chatTableView reloadData];
    [self completeReadHistoryMessage];
}

- (void)readHistoryUnReadMessage
{
    if (isRefresh)
    {
        return;
    }
    
    isRefresh=YES;
    
    if (coverView!=nil)
    {
        [coverView removeFromSuperview];
        coverView=nil;
    }
    
    coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:coverView];
    [coverView release];
    
    UIView *loadview = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loadview.backgroundColor = [UIColor blackColor];
    loadview.center = CGPointMake(coverView.frame.size.width/2, coverView.frame.size.height/2);
    loadview.layer.cornerRadius = 6;
    [coverView addSubview:loadview];
    [loadview release];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.frame = CGRectMake(0, 0, 20, 20);
    activity.center = CGPointMake(loadview.frame.size.width/2, loadview.frame.size.height/2);
    [loadview addSubview:activity];
    [activity startAnimating];
    [activity release];
    
    __block typeof(self) bself = self;
    
    [[ALXMPPEngine defauleEngine] getUserUnreadMessageWithUser:self.chatUser notContainedIn:self.messageIDArray block:^(NSDictionary *messages, NSError *error) {
        
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[messages objectForKey:@"chat"]];
        
        if (array.count>0)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:messages[@"chat"][0][@"message"]];

            [bself performSelectorInBackground:@selector(readData:) withObject:array];
        }
        else
        {
            [bself performSelector:@selector(completeReadHistoryMessage)
                        withObject:nil
                        afterDelay:1];
        }
    }];
}

- (void)completeReadHistoryMessage
{
    [self doneLoadingTableViewData];
    isRefresh=NO;

    if (coverView!=nil)
    {
        [coverView removeFromSuperview];
        coverView=nil;
    }
}

#pragma mark 接收消息
- (void)takeMessageFromRemind
{
    [self readHistoryUnReadMessage];
}


//通过UDP,发送消息
-(void)sendMassage:(NSString *)message from:(BOOL)fromSelf isHistroy:(BOOL)histroy
{
    if (histroy==NO)
    {
        NSDate *nowTime = [NSDate date];
        
        NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
        [sendString appendString:message];
        
        
        if ([self.chatArray lastObject] == nil) {
            self.lastTime = nowTime;
            [self.chatArray addObject:nowTime];
        }
        // 发送后生成泡泡显示出来
        
        
        if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
            self.lastTime = [NSDate date];
            [self.chatArray addObject:[NSDate date]];
        }
    }
	
    
    UIView *chatView = [self bubbleView:message from:fromSelf];
    
    
    if(histroy==YES)
    {
        if(fromSelf==YES)
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"self", @"speaker", chatView, @"view", nil] atIndex:0];
        }
        else
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"other", @"speaker", chatView, @"view", nil] atIndex:0];
            
        }
        
    }
    else
    {
        if(fromSelf==YES)
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"self", @"speaker", chatView, @"view", nil]];
        }
        else
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"other", @"speaker", chatView, @"view", nil]];
            
        }
        
        [self.chatTableView reloadData];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
                                          animated:YES];
    }
   
    
    	
	
}


//选择系统表情
//-(IBAction)showPhraseInfo:(id)sender
//{
//    self.messageString =[NSMutableString stringWithFormat:@"%@",self.messageTextField.text];
//	[self.messageTextField resignFirstResponder];
//	if (self.phraseViewController == nil) {
//		FaceViewController *temp = [[FaceViewController alloc] initWithNibName:@"FaceViewController" bundle:nil];
//		self.phraseViewController = temp;
//		[temp release];
//	}
//	[self presentModalViewController:self.phraseViewController animated:YES];
//}


- (void)creatVideobubbliView:(NSData *)videoData Video:(NSString *)videourl isHistroy:(BOOL)histroy From:(BOOL)from
{
    if (histroy==NO)
    {
        NSDate *nowTime = [NSDate date];
        
        if ([self.chatArray lastObject] == nil)
        {
            self.lastTime = nowTime;
            [self.chatArray addObject:nowTime];
        }
        // 发送后生成泡泡显示出来
        
        NSLog(@"%f",[[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]);
        
        if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
            self.lastTime = [NSDate date];
            [self.chatArray addObject:[NSDate date]];
        }
    }
  
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
        
    
    UIImage *videoImage = [UIImage imageWithData:videoData];
    
    UIImage *arrowsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:from?@"arrowsImageSelf":@"arrowsImageOthers" ofType:@"png"]];
	UIImageView *arrowsImageView = [[UIImageView alloc] initWithImage:arrowsImage];
    
    UIImage *bubble = [UIImage imageNamed:@"chatviewimage.png"];
    
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 伸缩后重新赋值
    
    bubble = [bubble resizableImageWithCapInsets:insets];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubble];
    
    UIImageView *touxiang = [[UIImageView alloc] init];
    
    if (_takeUsergender==0)
    {
        touxiang.image = [UIImage imageNamed:@"nv.png"];
    }
    else
    {
        touxiang.image = [UIImage imageNamed:@"nan.png"];
    }
    
    ALProgressImageView *imgView = [[ALProgressImageView alloc] initWithImage:videoImage];
    imgView.progress = 1.0;
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    
    float weight;
    float height;
    
    if(videoImage.size.width>100)
    {
        weight=100;
        height = videoImage.size.height/(videoImage.size.width/100);
        
    }
    else
    {
        weight = 100;
        height = videoImage.size.height/(videoImage.size.width/100);
    }
    
    UIImageView *playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_播放.png"]];
    playImageView.frame = CGRectMake(0, 0, 61, 61);
    [videoBtn addSubview:playImageView];
    
    
    if (from==YES)
    {
        arrowsImageView.frame = CGRectMake(230, 21, 4, 7);
        
        touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
        AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        headimage.urlString = self.selfImageUrl;
        
        [touxiang addSubview:headimage];
        
        bubbleImageView.frame = CGRectMake(210-weight, 10.0f, weight+20.0f, height+20.0f );
        
        imgView.frame= CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
        videoBtn.frame = CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
        
        playImageView.center = CGPointMake(50, videoBtn.frame.size.height/2);

        cellView.frame = CGRectMake(10, 0.0f,300, bubbleImageView.frame.size.height+30.0f);
        cellView.backgroundColor = [UIColor clearColor];
        

    }
    else
    {
        arrowsImageView.frame = CGRectMake(68, 21, 4, 7);
        
        touxiang.frame = CGRectMake(15, 0, 46, 46);
        
        AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        link.urlString = self.otherImageUrl;
        
        imgView.frame= CGRectMake(82.0f, 20.0f, weight, height);
        videoBtn.frame = CGRectMake(82.0f, 20.0f, weight, height);
        
        playImageView.center = CGPointMake(50, videoBtn.frame.size.height/2);
        
        bubbleImageView.frame = CGRectMake(72.0f, 10.0f, weight+20.0f, height+20.0f);
        cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
        
        [touxiang addSubview:link];
        [link release];
    }
    

    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:imgView];
    [cellView addSubview:videoBtn];
    [cellView addSubview:touxiang];
    [cellView addSubview:arrowsImageView];
    
    [bubbleImageView release];
    [imgView release];
    [touxiang release];
    [arrowsImageView release];
    [playImageView release];
    
    
    if(histroy==YES)
    {
        if (from==YES)
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVideo", @"speaker", cellView, @"view", videourl ,@"path",nil] atIndex:0];
        }
        else
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVideo", @"speaker", cellView, @"view", videourl ,@"path",nil] atIndex:0];
        }
        
        
    
    }
    else
    {
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVideo", @"speaker", cellView, @"view", videourl ,@"path",nil]];
        
        [self.chatTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
    
    
    [cellView release];
    
    
    

}

- (void)creatImagebubbleViewSize:(CGSize)imageSize ImgURL:(NSString *)imgurl priViewUrl:(NSString *)priviewurl isHistroy:(BOOL)histroy From:(BOOL)from
{
    if (histroy==NO)
    {
        NSDate *nowTime = [NSDate date];
        
        if ([self.chatArray lastObject] == nil) {
            self.lastTime = nowTime;
            [self.chatArray addObject:nowTime];
        }
        
        NSLog(@"%f",[[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]);
        
        if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
            self.lastTime = [NSDate date];
            [self.chatArray addObject:[NSDate date]];
        }
    }
    
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
    
    UIImage *arrowsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:from?@"arrowsImageSelf":@"arrowsImageOthers" ofType:@"png"]];
	UIImageView *arrowsImageView = [[UIImageView alloc] initWithImage:arrowsImage];
    
    
    UIImage *bubble = [UIImage imageNamed:@"chatviewimage.png"];
    
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 伸缩后重新赋值
    
    bubble = [bubble resizableImageWithCapInsets:insets];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubble];
    
    UIImageView *touxiang = [[UIImageView alloc] init];
    
    if (_takeUsergender==0)
    {
        touxiang.image = [UIImage imageNamed:@"nv.png"];
    }
    else
    {
        touxiang.image = [UIImage imageNamed:@"nan.png"];
    }
    
    AsyncImageView *imgView = nil;
    
    
    float weight;
    float height;
    
    if(imageSize.width>100)
    {
        weight=100;
        height = imageSize.height/(imageSize.width/100);
        
        imgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, weight, height) ImageState:1];

    }
    else
    {
        weight = 100;
        height = imageSize.height/(imageSize.width/100);
        imgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, weight, height) ImageState:1];
    }
    
    if (from==YES)
    {
        arrowsImageView.frame = CGRectMake(230, 21, 4, 7);

        bubbleImageView.frame = CGRectMake(210-weight, 10.0f, weight+20.0f, height+20.0f );
        
        imgView.frame= CGRectMake(bubbleImageView.frame.origin.x+10, 20.0f, weight, height);
        imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:priviewurl]]];
        imgView.urlString = imgurl;
        [imgView addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
        
        cellView.frame = CGRectMake(10, 0.0f,300, bubbleImageView.frame.size.height+30.0f);
        
        touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
        AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        headimage.urlString = self.selfImageUrl;
        
        [touxiang addSubview:headimage];
    }
    else
    {
        arrowsImageView.frame = CGRectMake(68, 21, 4, 7);
        
        touxiang.frame = CGRectMake(15, 0, 46, 46);
        
        AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        link.urlString = self.otherImageUrl;
        
        
        imgView.frame= CGRectMake(82.0f, 20.0f, weight, height);
        imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:priviewurl]]];
        imgView.urlString = imgurl;
        [imgView addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
        
        bubbleImageView.frame = CGRectMake(72, 10.0f, weight+20.0f, height+20.0f);
        cellView.frame = CGRectMake(0.0f, 0.0f, 300 ,bubbleImageView.frame.size.height+30.0f);
        
        [touxiang addSubview:link];
        [link release];
    }
        
 
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:imgView];
    [cellView addSubview:touxiang];
    [cellView addSubview:arrowsImageView];
    
    
    [bubbleImageView release];
    [imgView release];
    [touxiang release];
    [arrowsImageView release];
    
    if(histroy==YES)
    {
        if (from==YES)
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendImage", @"speaker", cellView, @"view", imgurl,@"imgurl",@"YES",@"history",nil] atIndex:0];
        }
        else
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeImage", @"speaker", cellView, @"view", imgurl,@"imgurl",@"YES",@"history",nil] atIndex:0];
        }
        
    
    }
    else
    {
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeImage", @"speaker", cellView, @"view", imgurl,@"imgurl",nil]];
        
        [self.chatTableView reloadData];
        
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
            
        } completion:^(BOOL finished) {
            
        }];
    
    }
  
    
        
    
    [cellView release];
    
    
	
}
/*
 生成泡泡UIView
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf
{
	// build single chat bubble cell with given text
    
    
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf];
    returnView.backgroundColor = [UIColor clearColor];
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *arrowsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"arrowsImageSelf":@"arrowsImageOthers" ofType:@"png"]];
    
    UIImageView *arrowsImageView = [[UIImageView alloc] initWithImage:arrowsImage];

    
    UIImage *bubble = [UIImage imageNamed:@"chatviewimage.png"];

    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 伸缩后重新赋值
    
    bubble = [bubble resizableImageWithCapInsets:insets];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubble];
    
    UIImageView *touxiang = [[UIImageView alloc] init];
    
   
    
    if(fromSelf)
    {
        if (_sendUsergender==0)
        {
            touxiang.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            touxiang.image = [UIImage imageNamed:@"nan.png"];
        }
        
        arrowsImageView.frame = CGRectMake(230, 21, 4, 7);
        
        bubbleImageView.frame = CGRectMake(210-returnView.frame.size.width, 10.0f, returnView.frame.size.width+20.0f, returnView.frame.size.height+30.0f );
        
        returnView.frame= CGRectMake(bubbleImageView.frame.origin.x+10, 16.0f, returnView.frame.size.width, returnView.frame.size.height);
        
        cellView.frame = CGRectMake(10, 0.0f, 300, bubbleImageView.frame.size.height+30.0f);
        
        touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
        AsyncImageView *headimaga = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        headimaga.urlString = self.selfImageUrl;
        
        [touxiang addSubview:headimaga];
        [headimaga release];
    }
	else
    {
        if (_takeUsergender==0)
        {
            touxiang.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            touxiang.image = [UIImage imageNamed:@"nan.png"];
        }
        
        arrowsImageView.frame = CGRectMake(68, 21, 4, 7);

        touxiang.frame = CGRectMake(15, 0, 46, 46);
        
        AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        link.urlString = self.otherImageUrl;

        returnView.frame= CGRectMake(82.0f, 16.0f, returnView.frame.size.width, returnView.frame.size.height);
        
        bubbleImageView.frame = CGRectMake(72, 10.0f, returnView.frame.size.width+20.0f, returnView.frame.size.height+30.0f);
        
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
        
        [touxiang addSubview:link];
        [link release];
    }
    
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:returnView];
    [cellView addSubview:touxiang];
    
    [cellView addSubview:arrowsImageView];
    
    [bubbleImageView release];
    [returnView release];
    [touxiang release];
    [arrowsImageView release];
    
	return [cellView autorelease];
    
}


#pragma mark -
#pragma mark Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]])
    {
		return 40;
	}
    else
    {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height+20;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    static NSString *Celldentifier1 = @"Cell1";
    static NSString *Celldentifier2 = @"Cell2";
    static NSString *Celldentifier3 = @"Cell3";
    static NSString *Celldentifier4 = @"Cell4";
    static NSString *Celldentifier5 = @"Cell5";
    static NSString *Celldentifier6 = @"Cell6";
    static NSString *Celldentifier7 = @"Cell7";
    static NSString *Celldentifier8 = @"Cell8";
    static NSString *Celldentifier9 = @"Cell9";

    
    //显示消息时间
    if([[self.chatArray objectAtIndex:indexPath.row] isKindOfClass:[NSDate class]])
    {
        ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier1];
        if(cell==nil)
        {
            cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier1] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
        NSString *destDateString = [formatter stringFromDate:[self.chatArray objectAtIndex:indexPath.row]];
        [formatter release];
        
        cell.linkManNameLabel.hidden=NO;
        cell.linkManNameLabel.center = CGPointMake(160, 10);
        [cell.linkManNameLabel setTextAlignment:NSTextAlignmentCenter];
        cell.linkManNameLabel.textColor = [UIColor whiteColor];
		[cell.linkManNameLabel setText:destDateString];
        
        
        return cell;
        
    }
    else
    {
        NSDictionary *dic = [self.chatArray objectAtIndex:indexPath.row];
        
        //发送消息
        if([[dic objectForKey:@"speaker"] isEqualToString:@"self"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier2];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier2] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;


            return cell;
            
        }
        //接收消息
        if([[dic objectForKey:@"speaker"] isEqualToString:@"other"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier3];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier3] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
    
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
          
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;
            

    
            return cell;
    
        }
        
        //发送语音
        if([[dic objectForKey:@"state"] isEqualToString:@"sendVoice"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier4];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier4] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;
       
            UIButton *temp = [[chatView subviews] objectAtIndex:4];
            temp.tag = indexPath.row;
            
            
            
            return cell;
            
        }
        
        //接收语音
        if([[dic objectForKey:@"state"] isEqualToString:@"takeVoice"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier5];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier5] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;
            
            UIButton *temp = [[chatView subviews] objectAtIndex:4];
            temp.tag = indexPath.row;
            
            
            
            return cell;
            
        }
        
        //发送图片
        if([[dic objectForKey:@"speaker"] isEqualToString:@"sendImage"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier6];
            
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier6] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;

            UIButton *temp = [[chatView subviews] objectAtIndex:3];
            temp.tag = indexPath.row;
            
            
            
            return cell;
            
        }
        //接收图片
        if([[dic objectForKey:@"speaker"] isEqualToString:@"takeImage"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier7];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier7] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;
            
            AsyncImageView *temp = [[chatView subviews] objectAtIndex:1];
            temp.tag = indexPath.row;
            
            
            
            return cell;
            
        }
        
        
        //发送视频
        if([[dic objectForKey:@"speaker"] isEqualToString:@"sendVideo"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier8];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier8] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;
            
            UIButton *temp = [[chatView subviews] objectAtIndex:2];
            temp.tag = indexPath.row;
            
            
            
            return cell;
            
        }
        //接收视频
        if([[dic objectForKey:@"speaker"] isEqualToString:@"takeVideo"])
        {
            ChatCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier9];
            if(cell==nil)
            {
                cell = [[[ChatCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier9] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
            UIView *chatView = [chatInfo objectForKey:@"view"];
            
            UIView *tempview = [[cell.popview subviews] lastObject];
            if(tempview!=nil)
            {
                [tempview removeFromSuperview];
            }
            [cell.popview addSubview:chatView];
            cell.popview.frame = chatView.frame;
            
            UIButton *temp = [[chatView subviews] objectAtIndex:2];
            temp.tag = indexPath.row;
            
            
            
            return cell;
            
        }

    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIView *chatView = [[self.chatArray objectAtIndex:_row] objectForKey:@"view"];
    
    UIImageView *imgview = [[chatView subviews] objectAtIndex:2];
    [imgview stopAnimating];
}

- (void)beginPlayVoice:(UIButton *)sender
{
    
    NSData *voiceData = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"voicefilepath"];
    NSFileManager *fileMC = [NSFileManager defaultManager];
     NSString *Rpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"RVoice.amr"];
    [fileMC createFileAtPath:Rpath contents:voiceData attributes:nil];
    
    NSDictionary *_dic = [self.chatArray objectAtIndex:sender.tag];
    UIView *chatView = [_dic objectForKey:@"view"];
    
    if(chatView.subviews.count==7)
    {
        UIImageView *readImage = [[chatView subviews] objectAtIndex:6];
        [readImage removeFromSuperview];
    }
    
    
    _row = sender.tag;
    
    if(amrPlayer.playing==YES)
    {
        [amrPlayer stop];
        [amrPlayer release];
        amrPlayer=nil;
        
        if(_row==_lastViewRow)
        {
            UIView *chatView = [[self.chatArray objectAtIndex:_row] objectForKey:@"view"];
            UIImageView *imgview = [[chatView subviews] objectAtIndex:2];
            [imgview stopAnimating];
            return;
        }
        else
        {
            UIView *chatView = [[self.chatArray objectAtIndex:_lastViewRow] objectForKey:@"view"];
            UIImageView *imgview = [[chatView subviews] objectAtIndex:2];
            [imgview stopAnimating];
        }
        
       
    }
    NSString *RWAVpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"RVoice.wav"];
    [VoiceConverter amrToWav:Rpath wavSavePath:RWAVpath];
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
    amrPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:RWAVpath] error:nil];
    [self isHeadphone];
    amrPlayer.delegate = self;
    [amrPlayer play];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if([[[self.chatArray objectAtIndex:sender.tag] objectForKey:@"state"] isEqualToString:@"sendVoice"])
    {
        for(int i=0;i<4;i++)
        {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"_0005_语音标示self_%d.png",i+1]];
            [array addObject:img];
        }
    }
    else
    {
        for(int i=0;i<4;i++)
        {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"_0005_语音标示_%d.png",i+1]];
            [array addObject:img];
        }
    }
   
    
    UIImageView *imgview = [[chatView subviews] objectAtIndex:2];
    imgview.animationImages = array;
    imgview.animationDuration = 1;
    [imgview startAnimating];
    
    [array release]; array=nil;
    
    _lastViewRow = sender.tag;
}

//#pragma mark Table View Delegate Methods
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self.messageTextField resignFirstResponder];
//}

#pragma mark -
#pragma mark TextView Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        isShowFaceView=NO;
        isShowOperationView=NO;
        keyboardshow=NO;
        
        [self sendMessage_Click:nil];
    }
    
    return YES;
}

-(void)autoMovekeyBoard: (float)h times:(NSTimeInterval)time
{
    CGRect f = [ UIScreen mainScreen ].applicationFrame;

    [self.view bringSubviewToFront:stateView];
    if(f.size.height==460)
    {
        if(self.chatTableView.contentSize.height>150)
        {
            if(h>0)
            {
                
                if(self.chatTableView.contentSize.height>300)
                {
                    [UIView animateWithDuration:time animations:^{
                        self.chatTableView.frame = CGRectMake(0.0f, -140, 320.0f,SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight);
                    }];
                }
                else
                {
                    [UIView animateWithDuration:time animations:^{
                        self.chatTableView.frame = CGRectMake(0.0f, -self.chatTableView.contentSize.height+210, 320, SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight);
                    }];
                }
            }
            else
            {
                
                [UIView animateWithDuration:time animations:^{
                    self.chatTableView.frame = CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight);
                }];
                
            }
            
        }
    }
    else
    {
        if(self.chatTableView.contentSize.height>150)
        {
            if(h>0)
            {
                
                if(self.chatTableView.contentSize.height>300)
                {
                    [UIView animateWithDuration:time animations:^{
                        self.chatTableView.frame = CGRectMake(0.0f, -150, 320.0f,SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight);
                    }];
                }
                else
                {
                    [UIView animateWithDuration:time animations:^{
                        self.chatTableView.frame = CGRectMake(0.0f, -self.chatTableView.contentSize.height+210, 320, SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight);
                    }];
                } 
                
            }
            else
            {
                
                [UIView animateWithDuration:time animations:^{
                    self.chatTableView.frame = CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight);
                }];
                
            }
            
        }
    }
    
   
    NSLog(@"%f",h);
    if(h>0)
    {
        keyboardshow = YES;
    }
    else
    {
        keyboardshow = NO;
    }
    
    [UIView animateWithDuration:time animations:^{
        
        textBackView.frame = CGRectMake(0.0f, (float)(SCREEN_HEIGHT-h-49-[ViewData defaultManager].versionHeight), 320.0f, 49+h);
    }];
    
    
}

#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification
{
    
    [self showFaceView:216 time:0.2];
    [self showOperationView:216 time:0.2];
    isShowFaceView=NO;
    isShowFaceView=NO;
    
    keyboardshow=YES;
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    

    textBackView.frame = CGRectMake(0, textBackView.frame.origin.y, 320, keyboardRect.size.height+49);
    
    [self autoMovekeyBoard:keyboardRect.size.height times:animationDuration];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    textBackView.frame = CGRectMake(0, textBackView.frame.origin.y, 320, keyboardRect.size.height+49);

    
    if (isShowOperationView==YES || isShowFaceView==YES)
    {
        return;
    }
    
    [self autoMovekeyBoard:0 times:animationDuration];
}




//图文混排

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

#define KFacialSizeWidth  20
#define KFacialSizeHeight 20
#define MAX_WIDTH 200
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = [array retain];
    [array release];
    UIFont *fon = [UIFont systemFontOfSize:14.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++)
        {
            NSString *str=[data objectAtIndex:i];
            NSLog(@"str--->%@",str);
            
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                NSLog(@"str(image)---->%@",str);
                
                
                NSString *name = [NSString stringWithFormat:@"[%@]",[str substringWithRange:NSMakeRange(1, str.length - 2)]];
                NSLog(@"%@",_faceMap);
                
                NSString *imageNameKey;
                
                NSArray *array = [_faceMap allKeys];
                for (int i=0; i<array.count; i++)
                {
                    NSString *_value = [_faceMap objectForKey:[array objectAtIndex:i]];
                    
                    if ([_value isEqualToString:name])
                    {
                        imageNameKey = [array objectAtIndex:i];
                        
                        NSLog(@"%@",imageNameKey);
                        
                    }
                }
                
                
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageNameKey]]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                upX=KFacialSizeWidth+upX;
                if (X<200) X = upX;
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 200;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(200, 40)];
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.textColor = [UIColor whiteColor];
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X<200) {
                        X = upX;
                    }
                }
            }
        }
    }
    [data release];
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    // NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}

- (void)updateChatHistory
{
   
}

- (void)back:(UIButton *)sender
{
    if (isFromNotifition==YES)
    {
        [[ALXMPPEngine defauleEngine] updateUnreadStateOfUser:self.chatUser block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                NSLog(@"更新聊天记录成功！！！");
            }
            else
            {
                NSLog(@"更新聊天记录失败！！！");
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeImageView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [ViewData defaultManager].isShowChatView=NO;
    
    [self.navigationController popViewControllerAnimated];
}


#pragma mark 长按录音
- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if(_animationView==nil)
        {
            _animationView = [[VoiceAnimationView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT)];
            _animationView.userInteractionEnabled = NO;
            [self.view addSubview:_animationView];
            [_animationView release];
        }
        
        _animationView.hidden = NO;
        [_animationView startAnimation];
        
        //设置文件名
        self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
        NSLog(@"bug:%@",self.originWav);
        //开始录音
        [recorderVC beginRecordByFileName:self.originWav];
        
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        _animationView.hidden = YES;
        [_animationView stopAnimation];
    }
}

#pragma mark - amr转wav
- (void)amrToWavBtnPressed {
    if (convertAmr.length > 0){
        
        self.convertWav = [originWav stringByAppendingString:@"amrToWav"];
        
        //转格式
        [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:[NSString stringWithFormat:@"recr%@",convertAmr] ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:@"end" ofType:@"wav"]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSLog(@"documentsDirectory%@",documentsDirectory);
        player = [player initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/end.wav",documentsDirectory]] error:nil];
        player.volume=1.0;
        [self isHeadphone];
        [player prepareToPlay];
        [player play];
    }
}

#pragma mark - wav转amr/发送声音
- (void)wavToAmrBtnPressed {
    if (originWav.length > 0){
        
        self.convertAmr = [originWav stringByAppendingString:@"wavToAmr"];
   
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"]];
        
        if (sendAmrData!=nil)
        {
            [sendAmrData release];
            sendAmrData=nil;
            
        }
        sendAmrData = [[NSData alloc]initWithContentsOfFile:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"]];
        
        if (amrPlayersend!=nil)
        {
            [amrPlayersend release];
            amrPlayersend=nil;
        }
        
        amrPlayersend = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"]] error:nil];

        
        if((int)amrPlayersend.duration>=1)
        {
            if (sendAmrData)
            {
                __block typeof(self) bself = self;

                
                [self sendVoice:[NSString stringWithFormat:@"%d",(int)amrPlayersend.duration] fromself:YES voiceData:sendAmrData isHistroy:NO];
                
                [[ALXMPPEngine defauleEngine] postMessageWithVoice:sendAmrData extension:@"amr" block:^(NSString *string, NSError *error) {
                    
                    if (string.length>0)
                    {
                        [bself.messageIDArray addObject:string];

                        NSLog(@"声音发送成功");
                    }
                    else
                    {
                        NSLog(@"声音发送失败");

                    }
                
                }];
            }
        }
    
    }
}

- (void)takeVoice:(NSData *)voiceData fromSelf:(BOOL)from isHistroy:(BOOL)histroy
{
    AVAudioPlayer *amrPlayerLength = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
    [self sendVoice:[NSString stringWithFormat:@"%d",(int)amrPlayerLength.duration] fromself:from voiceData:voiceData isHistroy:histroy];
    
    [amrPlayerLength release];
    amrPlayerLength = nil;
}



- (void)sendVoice:(NSString *)voicelength fromself:(BOOL)from voiceData:(NSData *)voiceData isHistroy:(BOOL)histroy
{
    if([voicelength intValue]<1)
    {
        return;
    }
    
    
    if (histroy==NO)
    {
        NSDate *nowTime = [NSDate date];
        
        if ([self.chatArray lastObject] == nil)
        {
            self.lastTime = nowTime;
            [self.chatArray addObject:nowTime];
        }
        
        NSLog(@"%f",[[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]);
        
        if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
            self.lastTime = [NSDate date];
            [self.chatArray addObject:[NSDate date]];
        }
    }
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    

    
	UIImage *arrowsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:from?@"arrowsImageSelf":@"arrowsImageOthers" ofType:@"png"]];
    
    UIImageView *arrowsImageView = [[UIImageView alloc] initWithImage:arrowsImage];
    
    
    UIImage *bubble = [UIImage imageNamed:@"chatviewimage.png"];
    
    CGFloat top = 10; // 顶端盖高度
    CGFloat bottom = 10; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 伸缩后重新赋值
    
    bubble = [bubble resizableImageWithCapInsets:insets];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:bubble];
    
    UIImageView *touxiang = [[UIImageView alloc] init];

    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = [NSString stringWithFormat:@"%@'",voicelength];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:14];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn addTarget:self action:@selector(beginPlayVoice:) forControlEvents:UIControlEventTouchUpInside];
    
    int length;

    //语音气泡长度
    length = 70+10*[voicelength intValue]/6;
    
    
  //  UIImageView *_readImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007_o未读.png"]];
    
    
    if(from==YES)
    {
        if (_sendUsergender==0)
        {
            touxiang.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            touxiang.image = [UIImage imageNamed:@"nan.png"];
        }
     
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0005_语音标示self.png"]];
        
        arrowsImageView.frame = CGRectMake(230, 21, 4, 7);

        bubbleImageView.frame = CGRectMake(300-70-length, 10.0f, length, 31);
        
        imgView.frame= CGRectMake(210, 18, 10, 14);
        
        textLabel.frame = CGRectMake(bubbleImageView.frame.origin.x+15, 15, 50, 20);
        [textLabel setTextAlignment:NSTextAlignmentLeft];

        cellView.frame = CGRectMake(10, 0.0f,300, bubbleImageView.frame.size.height+30.0f);
        cellView.backgroundColor = [UIColor clearColor];
        
        touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
        AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        headimage.urlString = self.selfImageUrl;
        [touxiang addSubview:headimage];
        
        playBtn.frame = CGRectMake(bubbleImageView.frame.origin.x, 10, length, 31);
        
        [cellView addSubview:bubbleImageView];
        [cellView addSubview:touxiang];
        [cellView addSubview:imgView];
        [cellView addSubview:textLabel];
        [cellView addSubview:playBtn];
        [cellView addSubview:arrowsImageView];
        
        [bubbleImageView release];
        [imgView release];
        [touxiang release];
        [headimage release];
        [arrowsImageView release];
    }
	else
    {
        if (_takeUsergender==0)
        {
            touxiang.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            touxiang.image = [UIImage imageNamed:@"nan.png"];
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0005_语音标示.png"]];

        arrowsImageView.frame = CGRectMake(68, 21, 4, 7);
        
        touxiang.frame = CGRectMake(15, 0, 46, 46);
        
        AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        link.urlString = self.otherImageUrl;
        
        imgView.frame= CGRectMake(80.0f, 18.0f, 10, 14);
        
        bubbleImageView.frame = CGRectMake(72.0f, 10.0f, length, 31);

        textLabel.frame = CGRectMake(length+72-60, 15, 50, 20);
        [textLabel setTextAlignment:NSTextAlignmentRight];
        
		cellView.frame = CGRectMake(0.0f, 0.0f, 300 ,bubbleImageView.frame.size.height+30.0f);
        
        playBtn.frame = CGRectMake(72, 10, length, 31);

        [touxiang addSubview:link];
        [cellView addSubview:bubbleImageView];
        [cellView addSubview:touxiang];
        [cellView addSubview:imgView];
        [cellView addSubview:textLabel];
        [cellView addSubview:playBtn];
        [cellView addSubview:arrowsImageView];
        
        [bubbleImageView release];
        [imgView release];
        [touxiang release];
        [link release];
        [arrowsImageView release];
    }
    
    
    
    if(histroy==YES)
    {
        if(from==YES)
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendVoice", @"speaker", cellView, @"view", voiceData ,@"voicefilepath",@"sendVoice",@"state",nil] atIndex:0];
        }
        else
        {
            [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVoice", @"speaker", cellView, @"view", voiceData ,@"voicefilepath",@"takeVoice",@"state",nil] atIndex:0];
        }
        
      
    }
    else
    {
        if(from==YES)
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendVoice", @"speaker", cellView, @"view", voiceData ,@"voicefilepath",@"sendVoice",@"state",nil]];
        }
        else
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVoice", @"speaker", cellView, @"view", voiceData ,@"voicefilepath",@"takeVoice",@"state",nil]];
        }
        
        
        [self.chatTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
            
        } completion:^(BOOL finished) {
            
        }];

    }
    
   
    
    [textLabel release];
    [cellView release];
    
    
    
    

}
#pragma mark 录音完成回调

- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    
    [self wavToAmrBtnPressed];
    
}

#pragma mark - 发生源
- (void)isHeadphone
{
    UInt32 propertySize = sizeof(CFStringRef);
    CFStringRef state = nil;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute
                            ,&propertySize,&state);
    //return @"Headphone" or @"Speaker" and so on.
    //根据状态判断是否为耳机状态
    if ([(NSString *)state isEqualToString:@"Headphone"] ||[(NSString *)state isEqualToString:@"HeadsetInOut"])
    {
        UInt32 audioRote = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRote), &audioRote);
    }
    else {
        UInt32 audioRote = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRote), &audioRote);
    }
}

#pragma mark 显示好友信息
- (void)showFriendInfo:(UIButton *)sender
{
    PersonalDataViewController *person = [[PersonalDataViewController alloc] initWithUser:self.chatUser FromSelf:NO SelectFromCenter:YES];
    [self.navigationController pushViewController:person AnimatedType:MLNavigationAnimationTypeOfScale];
    [person release];
}

#pragma mark - addHeader&addFooter
- (void)addRefreshHeaderView
{
    if (_refreshHeaderView == nil)
    {
        _reloading = NO;
        
        _refreshHeaderView=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.chatTableView.bounds.size.height, self.view.frame.size.width, self.chatTableView.bounds.size.height) textColor:[UIColor whiteColor] beginStr:@"拉取历史记录" stateStr:@"松开加载" endStr:@"加载中" haveArrow:NO];
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
        _refreshHeaderView.delegate = self;
        [self.chatTableView addSubview:_refreshHeaderView];
        [self.chatTableView sendSubviewToBack:_refreshHeaderView];
        [_refreshHeaderView release];
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
    }
}



#pragma mark - headerView Delegate
//拖拽到位松手触发（刷新）
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self readHistoryMessage]; //从新读取数据
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.chatTableView];
}



//是否正在刷新中（返回值判断）
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

//下拉完，收回时执行（载入日期）
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    int _page = scrollView.contentOffset.x/320;
    facePageControl.currentPage=_page;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   // NSLog(@"tag=%d",scrollView.tag);
    
    if(keyboardshow==YES && scrollView.tag==1000)
    {
        [self.messageTextView resignFirstResponder];
        [self autoMovekeyBoard:0 times:0.2];
        
    }
    
}



@end
