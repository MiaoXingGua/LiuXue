//
//  GroupViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-23.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "GroupViewController.h"
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
#import "GroupMembersViewController.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@interface GroupViewController ()

@end

@implementation GroupViewController
@synthesize chatArray = _chatArray;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextView = _messageTextView;
@synthesize lastTime = _lastTime;
@synthesize recorderVC,player,originWav,convertAmr,convertWav;
@synthesize selfheadImg = _selfheadImg,otherheadImg = _otherheadImg;
@synthesize selfImageUrl = _selfImageUrl,otherImageUrl = _otherImageUrl;
@synthesize previewData = _previewData;
@synthesize gid = _gid;
@synthesize gname = _gname;
@synthesize sendUser = _sendUser;
@synthesize messageId = _messageId;

- (void)dealloc
{
    [_messageId release]; _messageId=nil;
    [_faceMap release]; _faceMap=nil;
    [_sendUser release]; _sendUser=nil;
    [_gid release]; _gid=nil;
    [_gname release]; _gname=nil;
    [_previewData release]; _previewData=nil;
    [_selfImageUrl release]; _selfImageUrl=nil;
    [_otherImageUrl release]; _otherImageUrl=nil;
    [_selfheadImg release]; _selfheadImg=nil;
    [_otherheadImg release]; _otherheadImg=nil;
	[_lastTime release]; _lastTime=nil;
    [_messageTextView release]; _messageTextView=nil;
	[_chatArray release]; _chatArray=nil;
	[_chatTableView release]; _chatTableView=nil;
    [recorderVC release]; recorderVC=nil;
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
    [super dealloc];
}

- (id)initWithGroupId:(NSString *)gId GroupName:(NSString *)gName
{
    if (self = [super init])
    {
        self.gid = gId;
        self.gname = gName;
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
- (void)receiveNewGroupMessage:(NSNotification *)info
{
    NSDictionary *_tempDic = [NSDictionary dictionaryWithDictionary:[info userInfo]];
    
    NSString *typeStr = [_tempDic objectForKey:@"subType"];
    
    NSString *msgId = [_tempDic objectForKey:@"msgId"];

    //文字类型
    if ([typeStr isEqualToString:@"text"])
    {
        NSString *_content = [_tempDic objectForKey:@"url"];
        User *_temp = [_tempDic objectForKey:@"sender"];
        
        [_temp fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
            User *_user = (User *)object;
            
            if (_content.length>0)
            {
                [self.messageId addObject:msgId];
                
                [self sendMassage:_content from:NO isHistroy:NO SendUser:_user];
            }
        }];
        
    }
    
    //声音类型
    if ([typeStr isEqualToString:@"voice"])
    {
        __block NSString *_voiceStr = [[_tempDic objectForKey:@"url"] retain];
        User *_temp = [_tempDic objectForKey:@"sender"];

        [_temp fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
            User *_user = (User *)object;
            
            if (_voiceStr.length>0)
            {
                [self.messageId addObject:msgId];
                
                
                __block typeof(self) bself = self;
                
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    __block NSData *_voiceData = [[NSData dataWithContentsOfURL:[NSURL URLWithString:_voiceStr]] retain];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [bself takeVoice:_voiceData fromSelf:NO isHistroy:NO SendUser:_user];
                        
                        [_voiceData release]; _voiceData=nil;
                        [_voiceStr release]; _voiceStr=nil;
                    });
                });
            }
            
        }];
        
    }

   
}

//- (void)downLoadVoice:(NSArray *)array
//{
//    NSData *_voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[array objectAtIndex:1]]];
//    User *_user = [array objectAtIndex:0];
//    
//    if (_voiceData)
//    {
//        [self takeVoice:_voiceData fromSelf:NO isHistroy:NO SendUser:_user];
//    }
//}

- (void)joinNewUserToGroup:(NSNotification *)info
{
    NSLog(@"user:%@",info);
}

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

#pragma mark - ViewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [ViewData defaultManager].isShowGroupView=YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewGroupMessage:) name:NOTIFICATION_NEW_MESSAGE object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalImageView:) name:@"removeImageView" object:nil];
    
    isVoice = NO;
    isSelectSqlite = NO;
    
    self.chatArray = [NSMutableArray arrayWithCapacity:0];
    self.messageId = [NSMutableArray arrayWithCapacity:0];
    
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
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    title.center = CGPointMake(160, 23);
    title.text = self.gname;
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
    [friendBtn addTarget:self action:@selector(showFriendList:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:friendBtn];
    
    textBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-49-[ViewData defaultManager].versionHeight, 320, 216+49)];
    textBackView.userInteractionEnabled = YES;
    textBackView.image = [UIImage imageNamed:@"_0029_Background.png"];
    [backgroundView addSubview:textBackView];
    [textBackView release];
    
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
    faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 240)];
    faceView.pagingEnabled = YES;
    faceView.contentSize = CGSizeMake((85/28+1)*320, 220);
    faceView.showsHorizontalScrollIndicator = NO;
    faceView.showsVerticalScrollIndicator = NO;
    faceView.delegate = self;
    faceView.tag = 5000;
    faceView.backgroundColor = [UIColor clearColor];
    [textBackView addSubview:faceView];
    [faceView release];
    
    for (int i = 1; i<=85; i++)
    {
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.tag = i;
        
        [faceButton addTarget:self
                       action:@selector(faceButton:)
             forControlEvents:UIControlEventTouchUpInside];
        
        //计算每一个表情按钮的坐标和在哪一屏
        faceButton.frame = CGRectMake((((i-1)%28)%7)*44+6+((i-1)/28*320), (((i-1)%28)/7)*44+50, 44, 44);
        
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
    facePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(110, 240, 100, 20)];
    facePageControl.numberOfPages = 85/28+1;
    facePageControl.currentPage = 0;
    facePageControl.userInteractionEnabled = NO;
    [textBackView addSubview:facePageControl];
    [facePageControl release];
    
    //删除键
    UIButton *deleteFace = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteFace setImage:[UIImage imageNamed:@"backFace.png"] forState:UIControlStateNormal];
    [deleteFace setImage:[UIImage imageNamed:@"backFaceSelect.png"] forState:UIControlStateSelected];
    [deleteFace addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
    deleteFace.frame = CGRectMake(270, 230, 38, 27);
    [textBackView addSubview:deleteFace];
    
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
    recorderVC = [[ChatVoiceRecorderVC alloc]init];
    recorderVC.vrbDelegate = self;
    
    //初始化播放器
    player = [[AVAudioPlayer alloc]init];
    
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
    
	NSDate *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	[tempDate release];
    tempDate=nil;
    
    imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imageBtn.frame = CGRectMake(278, 10, 66/2, 72/2);
    [imageBtn setImage:[UIImage imageNamed:@"chat+(1).png"] forState:UIControlStateNormal];
    [imageBtn setImage:[UIImage imageNamed:@"chat+点击.png"] forState:UIControlStateHighlighted];
    [imageBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:imageBtn];
    
    self.selfImageUrl = [ALUserEngine defauleEngine].user.headView.url;
    
    _sendUsergender = [ALUserEngine defauleEngine].user.gender;
        
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    if (isFromNotifition==YES)
//    {
//        [self takeMessageFromRemind];
//    }
    
}

- (ALProgressImageView *)sendImage:(UIImage *)image fromSelf:(BOOL)from OrginImage:(UIImage *)orgImage isHistroy:(BOOL)histroy
{
    NSDate *nowTime = [NSDate date];
	
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	
    
	if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
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
    
    UIImage *_image=nil;
    NSString *url=nil;
    if([stateStr isEqualToString:@"sendImage"])
    {
        _image = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"orgImage"];
        
    }
    else
    {
        url = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"imgurl"];
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
    
    __block ALProgressImageView *imgView =[self sendImage:img1 fromSelf:YES OrginImage:img1 isHistroy:NO];
    
    
    CGSize _imageSize = CGSizeMake(img1.size.width, img1.size.height);
    
    
    if (imgView)
    {
        imgView.progress = 0.0;
    }
    
    [[ALXMPPEngine defauleEngine] postMessageWithImage:_postImgData extension:@"jpg" preview:_tempPreviewData size:_imageSize block:^(NSString *string , NSError *error) {
        
        if (string.length>0 && !error)
        {
            NSLog(@"图片发送成功");
        }
        else
        {
            NSLog(@"图片发送失败");
        }
        
    } progressBlock:^(float percentDone) {
      //  imgView.progress = percentDone;
        
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
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
    
    
    [[ALXMPPEngine defauleEngine] postMessageWithVideo:_tempVideoData extension:@"mov" preview:self.previewData block:^(NSString *string , NSError *error) {
        
        if (string.length>0 && !error)
        {
            NSLog(@"视频发送成功");
            imgView.progress=1;
            playBtn.hidden = NO;
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
        } completion:nil];
       
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

//播放完成
//-(void)playBackDidFinish:(NSNotification *)aNoti
//{
//    [video removeFromSuperview];
//    video=nil;
//}

- (void)selectImage:(UIButton *)sender
{
    tapOperation = YES;
    
    if (isShowFace)
    {
       // [self autoMovekeyBoard:0 times:0.2];
        [self.messageTextView becomeFirstResponder];
        
        isShowFace=NO;
    }
    else
    {
        [self autoMovekeyBoard:216 times:0.2];
        [self.messageTextView resignFirstResponder];
        
        isShowFace=YES;
    }
}

//打开相册
- (void)openPhotoAlbum
{
    
    UIImagePickerController *imagPickerC = [[UIImagePickerController alloc] init];//图像选取器
    imagPickerC.delegate = self;
    imagPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
    imagPickerC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
    //        imagePicker.allowsEditing = NO;//禁止对图片进行编辑
    
    [self presentModalViewController:imagPickerC animated:YES];//打开模态视图控制器选择图像
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
    [self presentModalViewController:pickerView animated:YES];
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
        
        return;
        
    }else
    {
        __block typeof(self) bself = self;

        [self.messageTextView resignFirstResponder];
        
        [self sendMassage:self.messageTextView.text from:YES isHistroy:NO SendUser:[ALUserEngine defauleEngine].user];
        
        [[ALXMPPEngine defauleEngine] postMessageToGroupWithText:self.messageTextView.text block:^(NSString *string , NSError *error) {
            
            if (string.length>0 && !error)
            {
                [bself.messageId addObject:string];
                
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


//通过UDP,发送消息
-(void)sendMassage:(NSString *)message from:(BOOL)fromSelf isHistroy:(BOOL)histroy SendUser:(User *)user
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
    
    UIView *chatView = [self bubbleView:message from:fromSelf SendUser:user];
    
    
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
        
        [self.chatTableView reloadData];
        
    }
    else
    {
        if(fromSelf==YES)
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"self", @"speaker", chatView, @"view",user,@"user", nil]];
        }
        else
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, @"text", @"other", @"speaker", chatView, @"view",user,@"user", nil]];
            
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

- (void)takeVideo:(NSDictionary *)dic isHistroy:(BOOL)histroy
{
    if (dic)
    {
        [self creatVideobubbliView:dic[@"preview"] Video:dic[@"key"] isHistroy:histroy];
    }
}
- (void)takeImage:(NSDictionary *)dic isHistroy:(BOOL)histroy
{
    if(dic)
    {
        //liujia
        //        NSString *theImageUrl = [ALQiniuDownloader downloadUrlWithKey:dic[@"key"]];
        //        CGSize imageSize = CGSizeFromString([dic objectForKey:@"size"]);
        //        [self creatImagebubbleViewSize:imageSize ImgURL:theImageUrl isHistroy:histroy];
    }
}

- (void)creatVideobubbliView:(NSData *)videoData Video:(NSString *)videourl isHistroy:(BOOL)histroy
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
    
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
    
    UIImage *videoImage = [UIImage imageWithData:videoData];
    
    UIImage *arrowsImage = [UIImage imageNamed:@"arrowsImageOthers.png"];
    
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
    
    arrowsImageView.frame = CGRectMake(68, 21, 4, 7);
    
    touxiang.frame = CGRectMake(15, 0, 46, 46);
    
    AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
    link.urlString = self.otherImageUrl;
    
    imgView.frame= CGRectMake(82.0f, 20.0f, weight, height);
    videoBtn.frame = CGRectMake(82.0f, 20.0f, weight, height);
    
    UIImageView *playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_播放.png"]];
    playImageView.frame = CGRectMake(0, 0, 61, 61);
    playImageView.center = CGPointMake(50, videoBtn.frame.size.height/2);
    [videoBtn addSubview:playImageView];
    
    bubbleImageView.frame = CGRectMake(72.0f, 10.0f, weight+20.0f, height+20.0f);
    cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
    
    [touxiang addSubview:link];
    [link release];
    
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
        [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVideo", @"speaker", cellView, @"view", videourl ,@"path",nil] atIndex:0];
        
        [self.chatTableView reloadData];
        
    }
    else
    {
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVideo", @"speaker", cellView, @"view", videourl ,@"path",nil]];
        
        [self.chatTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
        } completion:nil];
    }
    
    
    
    [cellView release];
    
    
    
    
}

- (void)creatImagebubbleViewSize:(CGSize)imageSize ImgURL:(NSString *)imgurl priViewUrl:(NSString *)priviewurl isHistroy:(BOOL)histroy
{
    NSDate *nowTime = [NSDate date];
	
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	
    NSLog(@"%f",[[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]);
    
	if ([[NSDate date] timeIntervalSince1970]-[self.lastTime timeIntervalSince1970]>120) {
		self.lastTime = [NSDate date];
		[self.chatArray addObject:[NSDate date]];
	}
    
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
    
    UIImage *arrowsImage = [UIImage imageNamed:@"arrowsImageOthers.png"];
    
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
        [self.chatArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeImage", @"speaker", cellView, @"view", imgurl,@"imgurl",nil] atIndex:0];
        
        [self.chatTableView reloadData];
        
    }
    else
    {
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeImage", @"speaker", cellView, @"view", imgurl,@"imgurl",nil]];
        
        [self.chatTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
        } completion:nil];
       
    }
    
    
    
    
    [cellView release];
    
    
	
}
/*
 生成泡泡UIView
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf SendUser:(User *)user
{
    
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
    touxiang.userInteractionEnabled = YES;
    
    UILabel *userName = [[UILabel alloc] init];
    userName.backgroundColor = [UIColor clearColor];
    userName.font = [UIFont systemFontOfSize:12];
    userName.textColor = [UIColor whiteColor];
    
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
        
        arrowsImageView.frame = CGRectMake(230, 21+5, 4, 7);
        
        bubbleImageView.frame = CGRectMake(210-returnView.frame.size.width, 10.0f+10, returnView.frame.size.width+20.0f, returnView.frame.size.height+30.0f );
        
        returnView.frame= CGRectMake(bubbleImageView.frame.origin.x+10, 16.0f+10, returnView.frame.size.width, returnView.frame.size.height);
        
        cellView.frame = CGRectMake(10, 0.0f, 300, bubbleImageView.frame.size.height+30.0f+10);
        
        touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
        userName.frame = CGRectMake(10, 0, 220, 15);
        userName.text = [ALUserEngine defauleEngine].user.nickName;
        [userName setTextAlignment:NSTextAlignmentRight];
        
        AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        headimage.urlString = self.selfImageUrl;
        [headimage addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        headimage.tag = self.chatArray.count;
        
        [touxiang addSubview:headimage];
        [headimage release];
    }
	else
    {
        if (user.gender==0)
        {
            touxiang.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            touxiang.image = [UIImage imageNamed:@"nan.png"];
        }
        
        arrowsImageView.frame = CGRectMake(68, 21+5, 4, 7);
        
        touxiang.frame = CGRectMake(15, 0, 46, 46);
        
        userName.frame = CGRectMake(72, 0, 200, 15);
        userName.text = user.nickName;
        [userName setTextAlignment:NSTextAlignmentLeft];
        
        AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        link.urlString = user.headView.url;
        [link addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        link.tag = self.chatArray.count;
        
        returnView.frame= CGRectMake(82.0f, 16.0f+10, returnView.frame.size.width, returnView.frame.size.height);
        
        bubbleImageView.frame = CGRectMake(72, 10.0f+10, returnView.frame.size.width+20.0f, returnView.frame.size.height+30.0f);
        
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f+10);
        
        [touxiang addSubview:link];
        [link release];
    }
    
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:returnView];
    [cellView addSubview:touxiang];
    
    [cellView addSubview:arrowsImageView];
    [cellView addSubview:userName];
    
    [bubbleImageView release];
    [returnView release];
    [touxiang release];
    [arrowsImageView release];
    [userName release];
    
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
    
//    if(chatView.subviews.count==7)
//    {
//        UIImageView *readImage = [[chatView subviews] objectAtIndex:6];
//        [readImage removeFromSuperview];
//    }
    
    
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self sendMessage_Click:nil];
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([[[UITextInputMode currentInputMode]primaryLanguage] isEqualToString:@"emoji"])
    {
        return NO;
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
    tapOperation = NO;
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    NSLog(@"%f",keyboardRect.size.height);
    [self autoMovekeyBoard:keyboardRect.size.height times:animationDuration];
    
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    
    if(tapOperation==YES)
    {
        return;
    }
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
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

- (void)back:(UIButton *)sender
{
    [ViewData defaultManager].isShowGroupView=NO;
    
    [[ALXMPPEngine defauleEngine] exitGroup:self.gid block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            NSLog(@"退出群成功");
        }
        else
        {
            NSLog(@"退出群失败");
        }
    }];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NEW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeImageView" object:nil];
    
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
                [self sendVoice:[NSString stringWithFormat:@"%d",(int)amrPlayersend.duration] fromself:YES voiceData:sendAmrData isHistroy:NO SendUser:[ALUserEngine defauleEngine].user];
                
                __block typeof(self) bself = self;
                
                [[ALXMPPEngine defauleEngine] postMessageToGroupWithVoice:sendAmrData extension:@"amr" block:^(NSString *string, NSError *error) {
                    
                    if (string.length>0 && !error)
                    {
                        [bself.messageId addObject:string];
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

- (void)takeVoice:(NSData *)voiceData fromSelf:(BOOL)from isHistroy:(BOOL)histroy SendUser:(User *)user
{
    AVAudioPlayer *amrPlayerLength = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
    [self sendVoice:[NSString stringWithFormat:@"%d",(int)amrPlayerLength.duration] fromself:from voiceData:voiceData isHistroy:histroy SendUser:user];
    
    [amrPlayerLength release];
    amrPlayerLength = nil;
}



- (void)sendVoice:(NSString *)voicelength fromself:(BOOL)from voiceData:(NSData *)voiceData isHistroy:(BOOL)histroy SendUser:(User *)user
{
    if([voicelength intValue]<1)
    {
        return;
    }
    
    
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
    touxiang.userInteractionEnabled = YES;
    
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
    
    
 //   UIImageView *_readImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007_o未读.png"]];
    
    UILabel *userName = [[UILabel alloc] init];
    userName.backgroundColor = [UIColor clearColor];
    userName.font = [UIFont systemFontOfSize:12];
    userName.textColor = [UIColor whiteColor];
    
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
        
        arrowsImageView.frame = CGRectMake(230, 21+5, 4, 7);
        
        bubbleImageView.frame = CGRectMake(300-70-length, 10.0f+10, length, 31);
        
        imgView.frame= CGRectMake(210, 18+10, 10, 14);
        
        textLabel.frame = CGRectMake(bubbleImageView.frame.origin.x+15, 15+10, 50, 20);
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        
        cellView.frame = CGRectMake(10, 0.0f,300, bubbleImageView.frame.size.height+30.0f+10);
        cellView.backgroundColor = [UIColor clearColor];
        
        touxiang.frame = CGRectMake(300-60, 0, 46, 46);
        
        userName.frame = CGRectMake(10, 0, 220, 15);
        userName.text = [ALUserEngine defauleEngine].user.nickName;
        [userName setTextAlignment:NSTextAlignmentRight];
        
        AsyncImageView *headimage = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        headimage.urlString = self.selfImageUrl;
        [headimage addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        headimage.tag = self.chatArray.count;
        
        [touxiang addSubview:headimage];
        
        playBtn.frame = CGRectMake(bubbleImageView.frame.origin.x, 10+10, length, 31);
        
    //    _readImage.frame = CGRectMake(300-length-80, 22+10, 13/2, 13/2);
        
        [cellView addSubview:bubbleImageView];
        [cellView addSubview:touxiang];
        [cellView addSubview:imgView];
        [cellView addSubview:textLabel];
        [cellView addSubview:playBtn];
        [cellView addSubview:arrowsImageView];
    //    [cellView addSubview:_readImage];
        [cellView addSubview:userName];
        
        [bubbleImageView release];
        [imgView release];
        [touxiang release];
        [headimage release];
        [arrowsImageView release];
     //   [_readImage release];
        [userName release];
    }
	else
    {
        if (user.gender==0)
        {
            touxiang.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            touxiang.image = [UIImage imageNamed:@"nan.png"];
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0005_语音标示.png"]];
        
        arrowsImageView.frame = CGRectMake(68, 21+5, 4, 7);
        
        touxiang.frame = CGRectMake(15, 0, 46, 46);
        
        userName.frame = CGRectMake(72, 0, 200, 15);
        userName.text = user.nickName;
        [userName setTextAlignment:NSTextAlignmentLeft];
        
        AsyncImageView *link = [[AsyncImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40) ImageState:0];
        link.urlString = user.headView.url;
        [link addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        link.tag = self.chatArray.count;
        
        imgView.frame= CGRectMake(80.0f, 18.0f+10, 10, 14);
        
        bubbleImageView.frame = CGRectMake(72.0f, 10.0f+10, length, 31);
        
        textLabel.frame = CGRectMake(length+72-60, 15+10, 50, 20);
        [textLabel setTextAlignment:NSTextAlignmentRight];
        
		cellView.frame = CGRectMake(0.0f, 0.0f, 300 ,bubbleImageView.frame.size.height+30.0f+10);
        
        playBtn.frame = CGRectMake(72, 10+10, length, 31);
        
    //    _readImage.frame = CGRectMake(length+76, 22+10, 13/2, 13/2);
        
        [touxiang addSubview:link];
        [cellView addSubview:bubbleImageView];
        [cellView addSubview:touxiang];
        [cellView addSubview:imgView];
        [cellView addSubview:textLabel];
        [cellView addSubview:playBtn];
        [cellView addSubview:arrowsImageView];
   //     [cellView addSubview:_readImage];
        [cellView addSubview:userName];
        
        [bubbleImageView release];
        [imgView release];
        [touxiang release];
        [link release];
        [arrowsImageView release];
    //    [_readImage release];
        [userName release];
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
        
        [self.chatTableView reloadData];
        
    }
    else
    {
        if(from==YES)
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sendVoice", @"speaker", cellView, @"view", voiceData ,@"voicefilepath",@"sendVoice",@"state",user,@"user",nil]];
        }
        else
        {
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"takeVoice", @"speaker", cellView, @"view", voiceData ,@"voicefilepath",@"takeVoice",@"state",user,@"user",nil]];
        }
        
        
        [self.chatTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];
        } completion:nil];
     
    }
    
    
    
    [textLabel release];
    [cellView release];
    
}

#pragma mark -表情-
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

#pragma mark -显示好友资料-
- (void)showUserInfo:(AsyncImageView *)sender
{
    User *_user=nil;
    _user = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"user"];
    NSString *_frmStr = [[self.chatArray objectAtIndex:sender.tag] objectForKey:@"speaker"];
    BOOL from;
    
    if ([_frmStr isEqualToString:@"self"])
    {
        from = YES;
    }
    else
    {
        from = NO;
    }
    
    if (_user)
    {
        PersonalDataViewController *_person = [[PersonalDataViewController alloc] initWithUser:_user FromSelf:from SelectFromCenter:YES];
        [self.navigationController pushViewController:_person AnimatedType:MLNavigationAnimationTypeOfScale];
        [_person release];
    }
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
- (void)showFriendList:(UIButton *)sender
{
    if (self.gid)
    {
        GroupMembersViewController *member = [[GroupMembersViewController alloc] initWithGroupID:self.gid];
        [self.navigationController pushViewController:member AnimatedType:MLNavigationAnimationTypeOfScale];
        [member release];
    }
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
	//[self selectChatHistroy]; //从新读取数据
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
    if (scrollView.tag!=5000)
    {
        if(keyboardshow==YES)
        {
            [self.messageTextView resignFirstResponder];
            [self autoMovekeyBoard:0 times:0.2];
            
        }
    }
 
}


@end
