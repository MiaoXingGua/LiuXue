//
//  PublishRequirementsViewController.m
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "PublishRequirementsViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "HomeViewController.h"
#import "MLNavigationController.h"
#import "ViewData.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ALProgressImageView.h"
#import "CustomCell.h"
#import "AppDelegate.h"
//#import "CPTextViewPlaceholder.h"
#import "QuartzCore/QuartzCore.h"

@interface PublishRequirementsViewController ()

@end

@implementation PublishRequirementsViewController
@synthesize classAry = _classAry;
@synthesize imageArray = _imageArray;
@synthesize tempArray = _tempArray;
@synthesize originWav = _originWav;
@synthesize convertAmr = _convertAmr;
@synthesize convertWav = _convertWav;
@synthesize amrData = _amrData;
@synthesize videoData = _videoData;
@synthesize amrfile = _amrfile;
@synthesize videofile = _videofile;
@synthesize defaultArray = _defaultArray;
@synthesize imageFileArray = _imageFileArray;
@synthesize forums = _forums;
@synthesize typeArray = _typeArray;
@synthesize selectType = _selectType;
@synthesize selectFlag = _selectFlag;
@synthesize atUserArray = _atUserArray;

//@dynamic selectFlag,selectType,altype,forums,videofile,amrfile;

- (void)dealloc
{
    if (stackMenu!=nil)
    {
        [stackMenu release];
        stackMenu=nil;
    }
    
    [_atUserArray release]; _atUserArray=nil;
    [_selectFlag release]; _selectFlag=nil;
    [_selectType release]; _selectType=nil;
    [_typeArray release]; _typeArray=nil;
    [_forums release]; _forums=nil;
    [_imageFileArray release]; _imageFileArray=nil;
    [_defaultArray release]; _defaultArray=nil;
    [_videofile release]; _videofile=nil;
    [_amrfile release]; _amrfile=nil;
    [_videoData release]; _videoData=nil;
    [_amrData release]; _amrData=nil;
    [_originWav release]; _originWav=nil;
    [_convertWav release]; _convertWav=nil;
    [_convertAmr release]; _convertAmr=nil;
    [_recorderVC release]; _recorderVC=nil;
    [_uploadImg release]; _uploadImg=nil;
    [_classAry release]; _classAry=nil;
    [_imageArray release]; _imageArray=nil;
    [_tempArray release]; _tempArray=nil;
    [longPrees release]; longPrees=nil;

    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.sidePanelController.recognizesPanGesture = NO;
    
    [ViewData defaultManager].showVc = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectOperationNotification:) name:@"operationNum" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissOperation:) name:@"dismissOperationView" object:nil];

    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.97 blue:0.96 alpha:1];
    
    isHaveImage = NO;
    
    self.classAry = [NSMutableArray arrayWithCapacity:0];
    self.imageArray = [NSMutableArray arrayWithCapacity:0];
    self.tempArray = [NSMutableArray arrayWithCapacity:0];
    self.defaultArray = [NSMutableArray arrayWithCapacity:0];
    self.imageFileArray = [NSMutableArray arrayWithCapacity:0];
    self.typeArray = [NSMutableArray arrayWithCapacity:0];
    self.atUserArray = [NSMutableArray arrayWithCapacity:0];
    
    UIView *stateView = [[UIView alloc] init];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    stateView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [self.view addSubview:stateView];
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 10, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"_0036_确认.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelPublish) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:cancelBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(280, 10, 30, 30);
    [doneBtn setImage:[UIImage imageNamed:@"_0035_取消.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(donePublish) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:doneBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"发布需求";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    
    _scrollViewbg = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT)];
    _scrollViewbg.backgroundColor = [UIColor clearColor];
    [backgroundView addSubview:_scrollViewbg];
    [_scrollViewbg release];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 19, 50, 20)];
    label1.text = @"我要";
    label1.font = [UIFont systemFontOfSize:18];
    label1.textColor = [UIColor redColor];
    label1.backgroundColor = [UIColor clearColor];
    [label1 setTextAlignment:NSTextAlignmentLeft];
    [_scrollViewbg addSubview:label1];
    [label1 release];
    
    UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_______.png"]];
    line1.frame = CGRectMake(0, 55, 320, 1);
    [_scrollViewbg addSubview:line1];
    [line1 release];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 118-45, 50, 20)];
    label2.text = @"悬赏";
    label2.font = [UIFont systemFontOfSize:18];
    label2.textColor = [UIColor redColor];
    label2.backgroundColor = [UIColor clearColor];
    [label2 setTextAlignment:NSTextAlignmentLeft];
    [_scrollViewbg addSubview:label2];
    [label2 release];
    
    UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_______.png"]];
    line2.frame = CGRectMake(0, 155-45, 320, 1);
    [_scrollViewbg addSubview:line2];
    [line2 release];
    
    
    _textfield_title = [[UITextField alloc] initWithFrame:CGRectMake(60, 62-45, 240, 30)];
    _textfield_title.delegate = self;
    _textfield_title.placeholder = @"标题";
    _textfield_title.borderStyle = UITextBorderStyleNone;
    _textfield_title.returnKeyType = UIReturnKeyDone;
    _textfield_title.textColor = [UIColor grayColor];
    [_scrollViewbg addSubview:_textfield_title];
    [_textfield_title release];
    
    _textfield_money = [[UITextField alloc] initWithFrame:CGRectMake(60, 117-45, 240, 30)];
    _textfield_money.delegate = self;
    _textfield_money.placeholder = @"0元";
    _textfield_money.borderStyle = UITextBorderStyleNone;
    _textfield_money.returnKeyType = UIReturnKeyDone;
    _textfield_money.textColor = [UIColor grayColor];
    _textfield_money.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [_scrollViewbg addSubview:_textfield_money];
    [_textfield_money release];

  
    _textview_content = [[UITextView alloc] initWithFrame:CGRectMake(15, 170-45, 290, 130)];
    _textview_content.delegate = self;
    _textview_content.text = @"说说您的具体要求，可以贴图，也可以录音~";
    _textview_content.textColor = [UIColor grayColor];
    _textview_content.font = [UIFont systemFontOfSize:16];
    _textview_content.backgroundColor = [UIColor clearColor];
    _textview_content.returnKeyType = UIReturnKeyDone;
    [_scrollViewbg addSubview:_textview_content];
    [_textview_content release];
    
    
    voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.frame = CGRectMake(10, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight, 40, 40);
    [voiceBtn setImage:[UIImage imageNamed:@"录音.png"] forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:voiceBtn];
    
    
    typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    typeBtn.frame = CGRectMake(60, SCREEN_HEIGHT-40-[ViewData defaultManager].versionHeight, 60, 30);
    [typeBtn setTitle:@"悬赏贴" forState:UIControlStateNormal];
    [typeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    typeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    //   [typeBtn addTarget:self action:@selector(changeType) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:typeBtn];
    
    line3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0030__.png"]];
    line3.frame = CGRectMake(124, SCREEN_HEIGHT-32-[ViewData defaultManager].versionHeight, 1, 16);
    [backgroundView addSubview:line3];
    [line3 release];
    
    classBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    classBtn.frame = CGRectMake(130, SCREEN_HEIGHT-40-[ViewData defaultManager].versionHeight, 60, 30);
    [classBtn setTitle:@"选择标签" forState:UIControlStateNormal];
    [classBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    classBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [classBtn addTarget:self action:@selector(changeClass) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:classBtn];
    
  

    videoLengthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoLengthBtn.frame = CGRectMake(190, SCREEN_HEIGHT-35-[ViewData defaultManager].versionHeight, 40, 20);
    [videoLengthBtn setBackgroundImage:[UIImage imageNamed:@"_0000_bg.png"] forState:UIControlStateNormal];
    [videoLengthBtn addTarget:self action:@selector(deleteVideo) forControlEvents:UIControlEventTouchUpInside];
    [videoLengthBtn setTitle:@"视频上传" forState:UIControlStateNormal];
    videoLengthBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [videoLengthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backgroundView addSubview:videoLengthBtn];
    videoLengthBtn.hidden = YES;
    
    voiceLengthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceLengthBtn.frame = CGRectMake(0, 0, 30, 55/2);
    voiceLengthBtn.center = CGPointMake(30, SCREEN_HEIGHT-50-[ViewData defaultManager].versionHeight);
    [voiceLengthBtn setBackgroundImage:[UIImage imageNamed:@"视频-语音.png"] forState:UIControlStateNormal];
    [voiceLengthBtn addTarget:self action:@selector(deleteVoice) forControlEvents:UIControlEventTouchUpInside];
    [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
    voiceLengthBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [backgroundView addSubview:voiceLengthBtn];
    voiceLengthBtn.hidden = YES;
    
    //初始化录音vc
    _recorderVC = [[ChatVoiceRecorderVC alloc]init];
    _recorderVC.vrbDelegate = self;
    
    operationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    operationBtn.frame = CGRectMake(270, SCREEN_HEIGHT-50-[ViewData defaultManager].versionHeight, 40, 40);
    [operationBtn setImage:[UIImage imageNamed:@"设置.png"] forState:UIControlStateNormal];
    [operationBtn addTarget:self action:@selector(showOperation) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:operationBtn];
    
    //添加手势
    longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.minimumPressDuration=0.1;
    longPrees.delegate = self;
    [voiceBtn addGestureRecognizer:longPrees];
   
    [self requestType];
}



#pragma mark 删除录音
- (void)deleteVoice
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除语音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alert.tag=2000;
    [alert show];
    [alert release];
    alert=nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==2000)
    {
        if (buttonIndex==1)
        {
            [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
            voiceLengthBtn.hidden = YES;
            [voiceBtn addGestureRecognizer:longPrees];
            self.amrData=nil;
            self.amrfile=nil;
        }
    }
    else
    {
        [voiceBtn addGestureRecognizer:longPrees];
    }
    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (playVoice!=nil)
    {
        [playVoice stop];
        [playVoice release];
        playVoice=nil;
    }
}

#pragma mark 删除视频
- (void)deleteVideo
{
    [videoLengthBtn setTitle:@"视频上传" forState:UIControlStateNormal];
    videoLengthBtn.hidden = YES;
    self.videoData=nil;
    self.videofile=nil;
}

#pragma mark 取消发布
- (void)cancelPublish
{

    _textfield_title.text = @"";
    _textfield_money.text = @"";
    _textview_content.text = @"说说您的具体要求，可以贴图，也可以录音~";
    voiceLengthBtn.hidden = YES;
    videoLengthBtn.hidden = YES;
    
    [self deleteAllImage];
    [self.sidePanelController showLeftPanelAnimated:YES];

    [self performSelector:@selector(backto) withObject:nil afterDelay:0.2];
   
}

- (void)backto
{
    self.sidePanelController.recognizesPanGesture = YES;

    if([ViewData defaultManager].homeVc!=nil)
    {
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].homeVc] autorelease];
     
        self.sidePanelController.centerPanel = n;
        
        return;
    }
    
    self.sidePanelController.recognizesPanGesture = YES;
    
    HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
    MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
    self.sidePanelController.centerPanel = n;
}

- (void)moveVoiceAndVideoView:(int)pointY
{
    
    [UIView animateWithDuration:0.2 animations:^{
     
        voiceBtn.frame = CGRectMake(10, SCREEN_HEIGHT-45-pointY-[ViewData defaultManager].versionHeight, 40, 40);
        voiceLengthBtn.center = CGPointMake(30, SCREEN_HEIGHT-50-pointY-[ViewData defaultManager].versionHeight);

        line3.frame = CGRectMake(124, SCREEN_HEIGHT-33-pointY-[ViewData defaultManager].versionHeight, 1, 16);
   
        videoLengthBtn.frame = CGRectMake(190, SCREEN_HEIGHT-35-pointY-[ViewData defaultManager].versionHeight, 40, 20);
        classBtn.frame = CGRectMake(130, SCREEN_HEIGHT-40-pointY-[ViewData defaultManager].versionHeight, 60, 30);
        typeBtn.frame = CGRectMake(60, SCREEN_HEIGHT-40-pointY-[ViewData defaultManager].versionHeight, 60, 30);
    }];
   
}

#pragma mark 增加照片
- (void)addImage
{
    if(isHaveImage == NO)
    {
        isHaveImage=YES;

        [self moveVoiceAndVideoView:50];
    }
    
    if(_scrollView!=nil)
    {
        [_scrollView removeFromSuperview];
        _scrollView=nil;
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT-60-[ViewData defaultManager].versionHeight, 240, 50)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.contentSize = CGSizeMake(240, 50);
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    
    for(int i=0;i<self.tempArray.count;i++)
    {
        UIButton *btn = [self.tempArray objectAtIndex:i];
        [btn removeFromSuperview];
    }
    
    [self.tempArray removeAllObjects];
    
    for(int i=0;i<self.imageArray.count;i++)
    {     

        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(i*60, 0, 50, 50);
        cancelBtn.tag = 1000+i;
        cancelBtn.layer.borderWidth = 0.5;
        cancelBtn.layer.borderColor = [UIColor grayColor].CGColor;
        [cancelBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:cancelBtn];
        
        if([[[self.imageArray objectAtIndex:i] objectForKey:@"image"] isKindOfClass:[UIImage class]])
        {
            UIImage *_img = [[self.imageArray objectAtIndex:i] objectForKey:@"image"];
            [cancelBtn setImage:_img forState:UIControlStateNormal];
        }
        else
        {
            UIImageView *alImage = [[self.imageArray objectAtIndex:i] objectForKey:@"image"];
            [cancelBtn addSubview:alImage];
        }
        [self.tempArray addObject:cancelBtn];
        
    }
    
    if(self.tempArray.count>4)
    {
        [_scrollView setContentOffset:CGPointMake(self.tempArray.count*60, 50)];
    }
    _scrollView.contentSize = CGSizeMake(self.tempArray.count*60, 50);
}

- (void)deleteAllImage
{
    self.amrData=nil;
    self.amrfile=nil;
    self.videoData=nil;
    self.videofile=nil;
    
    if(self.tempArray.count>0)
    {
        for(int i=0;i<self.tempArray.count;i++)
        {
            UIButton *tempImage = [self.tempArray objectAtIndex:i];
            [tempImage removeFromSuperview];
        }
        
        [self.tempArray removeAllObjects];
    }
    
    [self.imageArray removeAllObjects];

    if(self.imageArray.count==0)
    {
        [_scrollView removeFromSuperview];
        _scrollView = nil;

        [self moveVoiceAndVideoView:0];
    }
    
    [self.imageFileArray removeAllObjects];
    
    isHaveImage = NO;
}

#pragma mark 删除照片
- (void)deleteImage:(UIButton *)sender
{
   
    
    if(self.tempArray.count>0)
    {
        UIButton *tempImage = [self.tempArray objectAtIndex:sender.tag-1000];
        [tempImage removeFromSuperview];
        
        int tempCount = self.tempArray.count;
        while (self.tempArray.count == tempCount) {
            [self.tempArray removeObject:tempImage];
        }
    }

    
   
    if(self.imageArray.count>0)
    {
        int imageCount = self.imageArray.count;
        while (self.imageArray.count == imageCount) {
            
            AVFile *file = [[self.imageArray objectAtIndex:sender.tag-1000] objectForKey:@"imageFile"];
            [file cancel];
            
            [self.imageArray removeObjectAtIndex:sender.tag-1000];
           
        }
    }


    _scrollView.contentSize = CGSizeMake(self.imageArray.count*60, 50);
    
    for(int i=0;i<self.tempArray.count;i++)
    {
        UIButton *tempImage = [self.tempArray objectAtIndex:i];
        tempImage.tag = i+1000;
        
        [UIView animateWithDuration:0.2 animations:^{
            tempImage.frame = CGRectMake(60*i, 0, 50, 50);

        }];
    }
    
    if(self.imageArray.count==0)
    {
        isHaveImage = NO;
        [_scrollView removeFromSuperview];
        _scrollView = nil;
        [self moveVoiceAndVideoView:0];
    }
}

#pragma mark 选择照片
- (void)selectPhoto
{
    UIActionSheet *_action = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"相机",@"视频", nil];
    [_action showInView:self.view];
    [_action release];
    _action=nil;
}

#pragma mark 录制视频
- (void)userVideo
{
    UIImagePickerController* pickerView = [[UIImagePickerController alloc] init];
    pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerView.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentViewController:pickerView animated:YES completion:nil];
    pickerView.videoMaximumDuration = 30;
    pickerView.delegate = self;
    [pickerView release];

}


#pragma mark 录音
- (void)playRecording
{
    if (self.amrData)
    {
        if (playVoice)
        {
            [playVoice stop];
            [playVoice release];
            playVoice=nil;
            
            return;
        }
        
        NSFileManager *fileMC = [NSFileManager defaultManager];
        NSString *Rpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"RVoice.amr"];
        [fileMC createFileAtPath:Rpath contents:self.amrData attributes:nil];
        
        NSString *RWAVpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"RVoice.wav"];
        [VoiceConverter amrToWav:Rpath wavSavePath:RWAVpath];
        
        [self isHeadphone];
        
        if (playVoice!=nil)
        {
            [playVoice release];
            playVoice=nil;
        }
        
        playVoice = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:RWAVpath] error:nil];
        playVoice.delegate = self;
        [playVoice play];
        
        return;
    }
}

#pragma mark 分享
- (void)shareRequirement
{
    
}

#pragma mark @好友
- (void)atFriend
{
    FriendListViewController *friendlist = [[FriendListViewController alloc] initWithSelectUser:self.atUserArray];
    friendlist.atDelegate = self;
    [self presentViewController:friendlist animated:YES completion:nil];
    [friendlist release];
}

- (void)didSelectAtUser:(NSMutableArray *)userArray
{
    [self.atUserArray removeAllObjects];
    [self.atUserArray addObjectsFromArray:userArray];
}

/*
- (void)getAtFriends:(NSNotification *)info
{
    User *_user = [info object];
    [self.atUserArray addObject:_user];

    [self addAtFriendUser:self.atUserArray];
}


- (void)addAtFriendUser:(NSMutableArray *)array
{
    int counts = array.count;
    
    NSMutableString *_content = [NSMutableString string];
    
    for (int i=0; i<counts; i++)
    {
        User *_temp = [array objectAtIndex:i];
        [_content appendString:[NSString stringWithFormat:@"@%@ ",_temp.nickName]];
    }
    
    CGSize contentSize = [_content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(290, 1000) lineBreakMode:0];
    
    if (_friendLabel==nil)
    {
        UIImageView *line4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_______.png"]];
        line4.frame = CGRectMake(15, 255, 290, 1);
        [_scrollViewbg addSubview:line4];
        [line4 release];
        
        _nameScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 260, 290, 40)];
        _nameScrollView.backgroundColor = [UIColor clearColor];
        _nameScrollView.contentSize = CGSizeMake(290, contentSize.height);
        [_scrollViewbg addSubview:_nameScrollView];
        [_nameScrollView release];
        
        _friendLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(0, 0, 290, contentSize.height)];
        _friendLabel.numberOfLines = 0;
        _friendLabel.font = [UIFont systemFontOfSize:16];
        _friendLabel.colorHashtag = [UIColor blackColor];
        [_friendLabel setText:_content];
        [_friendLabel setDelegate:self];
        [_nameScrollView addSubview:_friendLabel];
        [_friendLabel release];
    }
    else
    {
        _friendLabel.frame = CGRectMake(0, 0, 290, contentSize.height);
        [_friendLabel setText:_content];
        _nameScrollView.contentSize = CGSizeMake(290, contentSize.height);
    }
}



- (void)twitterAccountClicked:(NSString *)link
{
    NSString *str = [[link substringWithRange:NSMakeRange([link rangeOfString:@"@"].location+1, link.length-1)] substringWithRange:NSMakeRange(0, link.length-1)];
    
    NSLog(@"%@",str);
    
    for (int i=0; i<self.atUserArray.count; i++)
    {
        User *_temp = [self.atUserArray objectAtIndex:i];
        
        if ([_temp.nickName isEqualToString:str])
        {
            [self.atUserArray removeObjectAtIndex:i];
            
            [self addAtFriendUser:self.atUserArray];
            
            return;
        }
    }

}

 */

#pragma mark 请求发帖类型
- (void)requestType
{
    [self showF3HUDLoad:nil];
    
    __block typeof(self) bself = self;
    
    [[ALThreadEngine defauleEngine] getForumsWithBlock:^(NSArray *forums, NSError *error) {
        
        if(forums.count>0 && !error)
        {
            [bself hideF3HUDSucceed:nil];
            
            for(int i=0;i<forums.count;i++)
            {
                Forum *_tempforum = [forums objectAtIndex:i];
                NSString *_name = _tempforum.name;
                            
                if([_name isEqualToString:@"问答"])
                {
                    bself.forums = _tempforum;
                    
                    AVRelation *_PFType = _tempforum.threadType;
                    AVRelation *_PFFlag = _tempforum.threadFlag;
                    
                    [[_PFType query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if(!error)
                        {
                            for(int i=0;i<objects.count;i++)
                            {
                                ThreadType *_ttype = [objects objectAtIndex:i];
                                [bself.typeArray addObject:_ttype];
                            }
                        }
                    }];
                    
                    [[_PFFlag query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if(!error)
                        {
                            for(int i=0;i<objects.count;i++)
                            {
                                ThreadFlag *_tflag = [objects objectAtIndex:i];
                                [bself.classAry addObject:_tflag];
                            }
                        }
                    }];

                }
            }
            
        }
        else
        {
            [bself requestType];
        }
    }];
}

#pragma mark - 发帖
#pragma mark  -- 发帖
- (void)donePublish
{
    if(_textfield_title.text.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写标题！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView=nil;
        
        return;
    }
    
//    if(_textfield_money.text.length==0)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写赏金！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
//        
//        return;
//    }
    
    if(_textview_content.text.length==0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写需求内容！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView=nil;
        
        return;
    }
    
    //选择帖子类型  只有悬赏贴
    ThreadType *_thType = [self.typeArray objectAtIndex:0];
    self.selectType = _thType;
    
    if(self.selectFlag==nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择发帖标签！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView=nil;
        
        return;
    }
    
    if(self.selectType==nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择发帖类型！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView=nil;
        
        return;
    }

    ThreadContent *content = [ThreadContent object];
    content.text = _textview_content.text;
    
    
    if(self.imageArray.count>0)
    {
        for(int i=0;i<self.imageArray.count;i++)
        {
            NSDictionary *dic = [self.imageArray objectAtIndex:i];
            ThreadImage *temp = nil;
            
            temp = [dic objectForKey:@"threadImage"];
        
            NSLog(@"%@",temp);
            
            if (temp)
            {
//                [content.images addObject:temp];
                [[content relationforKey:@"images"] addObject:temp];

            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片没有上传完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
                
                return;
            }

        }
    
    }
    
    if(self.amrData)
    {
        if(self.amrfile==nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"声音上传中！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            alertView=nil;
            
            return;
        }
        
        content.voice = self.amrfile;
    }
    
    if(self.videoData)
    {
        if(self.uploadVideo==NO)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"视频上传中！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            alertView=nil;
            
            return;
        }
        
        content.video = self.videofile;

    }
    
    [self showF3HUDLoad:nil];
    
    __block typeof(self) bself = self;

    NSLog(@"@friend=%@",self.atUserArray);
    
    ALGPSHelper *gps = [ALGPSHelper OpenGPS];
    
    CGFloat latitude = gps.offLatitude;
    CGFloat longitude = gps.offLongitude;
    
    [content save];
    
    __block UITextField *__title = _textfield_title;
    __block UITextField *__money = _textfield_money;
    __block UITextView *__content = _textview_content;
    __block UIButton *__voice = voiceLengthBtn;
    __block UIButton *__video = videoLengthBtn;
    
    [[ALThreadEngine defauleEngine] sendThreadWithForum:self.forums andTitle:_textfield_title.text andContent:content andType:self.selectType flag:self.selectFlag tags:@"1" price:[_textfield_money.text intValue] atUsers:self.atUserArray latitude:latitude longitude:longitude place:gps.LocationName block:^(BOOL succeeded, NSError *error) {
        
        if(succeeded && !error)
        {
            
            __title.text = @"";
            __money.text = @"";
            __content.text = @"说说您的具体要求，可以贴图，也可以录音~";
            __voice.hidden = YES;
            __video.hidden = YES;
            
            [bself.atUserArray removeAllObjects];
            [bself deleteAllImage];
            
            [bself.sidePanelController showLeftPanelAnimated:YES];
            
            [bself performSelector:@selector(bcakto) withObject:nil afterDelay:0.2];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHUI object:nil];
            
            [bself hideF3HUDSucceed:nil];
            
        }
        else
        {
            NSLog(@"%@",error);
            
            int code = [[[error userInfo] objectForKey:@"code"] intValue];
            
            if (code==142)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发帖失败" message:@"金币余额不足" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
            
            [bself hideF3HUDError:nil];
        }
        
    }];

}

- (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];//???
    [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *timeDesc = [dateformat stringFromDate:[NSDate date]];
    [dateformat release];
    
    return timeDesc;
}

#pragma mark 返回图片/视频
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.uploadImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if(self.uploadImg)
    {
    
        __block UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        imgV.image = self.uploadImg;
        
        __block UIProgressView *_progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 40, 50, 8)];
        _progress.backgroundColor = [UIColor clearColor];
        _progress.progress = 0;
        
        _progress.progressTintColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        [imgV addSubview:_progress];
        
        CGSize _imageSize = CGSizeMake(self.uploadImg.size.width,self.uploadImg.size.height);
        
        __block typeof(self) bself = self;
        
        
        
        __block AVFile *imageAVFile = [[AVFile fileWithName:[NSString stringWithFormat:@"%d.jpg",(int)[[NSDate date] timeIntervalSince1970]] data:UIImageJPEGRepresentation(self.uploadImg, 0.5)] retain];
        
        
        __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:imgV forKey:@"image"];
        [dic setValue:imageAVFile forKey:@"imageFile"];

        [self.imageArray addObject:dic];
        
        [self addImage];

        [_progress release];
        [imgV release];
        
        
        [imageAVFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if(succeeded)
            {
                //
                __block ThreadImage *threadImage = [[ThreadImage object] retain];
                threadImage.image = imageAVFile;
                threadImage.imageSize= NSStringFromCGSize(_imageSize);
                threadImage.state = 0;
                
      
                [threadImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if(succeeded && !error)
                    {
                        
                        [dic setValue:threadImage forKey:@"threadImage"];

                        _progress.hidden = YES;
                    }
                    
                    [threadImage release];

                }];
            }
            
         [imageAVFile release];
         
        } progressBlock:^(int percentDone) {
            
            NSLog(@"%d",percentDone);
            
            _progress.progress = percentDone/100.0;
            
        }];

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
                    
                    [self videoselect:path];
                    
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
            [self videoselect:path];
        }
        
    }
}


#pragma mark 选择发帖操作
- (void)showOperation
{
    if(stackMenu!=nil)
    {
        [stackMenu release];
        stackMenu=nil;
        
        [coverView removeFromSuperview];
        coverView = nil;
    }
    
    
    coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT)];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0;
    coverView.userInteractionEnabled = YES;
    [self.view addSubview:coverView];
    [coverView release];
    
    [UIView animateWithDuration:0.3 animations:^{
        coverView.alpha = 0.6;
        
        operationBtn.transform = CGAffineTransformMakeRotation(M_PI / 180*90);
    }];
    
    
    stackMenu = [[PCStackMenu alloc] initWithTitles:[NSArray arrayWithObjects:@"相册", @"拍照", @"视频",@"好友",nil]
                                         withImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"icon_cover_album@2x.png"], [UIImage imageNamed:@"icon_cover_camera@2x.png"], [UIImage imageNamed:@"shipin.png"],[UIImage imageNamed:@"@好友.png"],nil]
                                       atStartPoint:CGPointMake(270, SCREEN_HEIGHT-65-[ViewData defaultManager].versionHeight)
                                             inView:self.view
                                         itemHeight:40
                                      menuDirection:PCStackMenuDirectionCounterClockWiseUp];
    
	for(PCStackMenuItem *item in stackMenu.items)
        
		item.stackTitleLabel.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
	
	[stackMenu show:^(NSInteger selectedMenuIndex) {
        

        [[NSNotificationCenter defaultCenter] postNotificationName:@"operationNum" object:[NSNumber numberWithInt:selectedMenuIndex]];
	}];
    
    [self.view bringSubviewToFront:stackMenu];
    [self.view bringSubviewToFront:operationBtn];
}


- (void)dismissOperation:(NSNotification *)info
{
    [UIView animateWithDuration:0.3 animations:^{
        coverView.alpha = 0;

        operationBtn.transform = CGAffineTransformIdentity;

    }];
}

- (void)postSelectNotification:(NSNumber *)num
{
    if([num intValue]==0)
    {
        [self openPhotoAlbum];
    }
    if([num intValue]==1)
    {
        [self userCamera];
    }
    if([num intValue]==2)
    {
        [self userVideo];
    }
    if([num intValue]==3)
    {
        [self atFriend];
    }
}

- (void)selectOperationNotification:(NSNotification *)info
{
    int num = [[info object] intValue];
    
    [self performSelector:@selector(postSelectNotification:) withObject:[NSNumber numberWithInt:num] afterDelay:0.1];

    
}


#pragma mark 从相册中获得视频
- (void)videoselect:(NSURL *)path
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    self.videoData=nil;
    self.videofile=nil;
    self.videoData = [NSData dataWithContentsOfURL:path];
    
    self.uploadVideo = NO;
    videoLengthBtn.hidden = NO;
    [videoLengthBtn setTitle:@"视频上传" forState:UIControlStateNormal];

    __block typeof(self) bself = self;

    self.videofile = [AVFile fileWithName:[NSString stringWithFormat:@"%d.mov",(int)[[NSDate date] timeIntervalSince1970]] data:self.videoData];
    
    __block UIButton *__video = videoLengthBtn;

    [self.videofile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(succeeded && !error)
        {
            bself.uploadVideo = YES;
            [__video setTitle:@"完成" forState:UIControlStateNormal];
        }
    }];
}

#pragma mark 打开相机
- (void)userCamera
{
    UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
    imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePiker.delegate = self;
    [self presentViewController:imagePiker animated:YES completion:NULL];
    [imagePiker release];
}

#pragma mark 打开相册
- (void)openPhotoAlbum
{
    UIImagePickerController *imagPickerC = [[UIImagePickerController alloc] init];//图像选取器
    imagPickerC.delegate = self;
    imagPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
    imagPickerC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
    //        imagePicker.allowsEditing = NO;//禁止对图片进行编辑
    
    [self presentViewController:imagPickerC animated:YES completion:NULL];
    [imagPickerC release];
}

#pragma mark 开始编辑
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
//    NSLog(@"%@",text);
    if ([text isEqualToString:@"\n"])
    {
        [self showNavigationView];
        [textView resignFirstResponder];
        return NO;
    }
    
    
    return YES;
}

#pragma mark 显示navigationView
- (void)showNavigationView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _scrollViewbg.frame = CGRectMake(0, 45, 320, SCREEN_HEIGHT);
        naviView.frame = CGRectMake(0, 0, 320, 45);
        
    } completion:^(BOOL finished)
    {
        
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.sidePanelController.recognizesPanGesture = YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.sidePanelController.recognizesPanGesture = NO;
   
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _scrollViewbg.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
        naviView.frame = CGRectMake(0, -45, 320, 45);
    } completion:^(BOOL finished) {
            
    }];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self showNavigationView];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark 切换发帖类型

- (void)changeType
{
    if(isShowClass==YES)
    {
        [self cancelClass];
    }
    
    if(isShowType==NO)
    {
        isShowType = YES;
        
        //  arrowsImage.layer.transform = CATransform3DMakeRotation(M_PI/180*180, 0, 0, 1);
        
        if(_typeTableView==nil)
        {
            typeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xialakuang_2.png"]];
            typeImageView.frame = CGRectMake(90, SCREEN_HEIGHT-270, 361/2, 421/2);
            [self.view addSubview:typeImageView];
            typeImageView.alpha = 0;
            [typeImageView release];
            
            _typeTableView = [[UITableView alloc] initWithFrame:CGRectMake(94, SCREEN_HEIGHT-265, 361/2-8, 421/2-13) style:UITableViewStylePlain];
            _typeTableView.dataSource = self;
            _typeTableView.delegate = self;
            _typeTableView.tag = 6001;
            _typeTableView.backgroundColor = [UIColor clearColor];
            _typeTableView.separatorColor = [UIColor clearColor];
            [self.view addSubview:_typeTableView];
            _typeTableView.alpha = 0;
            _typeTableView.layer.cornerRadius = 8;
            [_typeTableView release];
        }
        
        [_typeTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _typeTableView.alpha = 1;
            typeImageView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self cancelType];
    }

}

#pragma mark 切换标签
- (void)changeClass
{
    if(isShowType==YES)
    {
        [self cancelType];
    }
    
    if(isShowClass==NO)
    {
        isShowClass = YES;
        
        //  arrowsImage.layer.transform = CATransform3DMakeRotation(M_PI/180*180, 0, 0, 1);
        
        if(_classTableView==nil)
        {
            int height;
            if (self.imageArray.count>0)
            {
                height = 320;
            }
            else
            {
                height = 260;
            }
            classImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xialakuang_2.png"]];
            classImageView.frame = CGRectMake(40, SCREEN_HEIGHT-height, 361/2, 421/2);
            [self.view addSubview:classImageView];
            classImageView.alpha = 0;
            [classImageView release];
            
            _classTableView = [[UITableView alloc] initWithFrame:CGRectMake(44, SCREEN_HEIGHT-height-5, 361/2-8, 421/2-13) style:UITableViewStylePlain];
            _classTableView.dataSource = self;
            _classTableView.delegate = self;
            _classTableView.tag = 6000;
            _classTableView.backgroundColor = [UIColor clearColor];
            _classTableView.separatorColor = [UIColor clearColor];
            [self.view addSubview:_classTableView];
            _classTableView.alpha = 0;
            _classTableView.layer.cornerRadius = 8;
            [_classTableView release];
        }
        
        [_classTableView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _classTableView.alpha = 1;
            classImageView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self cancelClass];
    }
    
}

#pragma mark 关闭分类
- (void)cancelClass
{
    isShowClass = NO;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _classTableView.alpha = 0;
        classImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_classTableView removeFromSuperview];
        _classTableView=nil;
        [classImageView removeFromSuperview];
        classImageView=nil;
    }];
}

- (void)cancelType
{
    isShowType = NO;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _typeTableView.alpha = 0;
        typeImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_typeTableView removeFromSuperview];
        _typeTableView=nil;
        [typeImageView removeFromSuperview];
        typeImageView=nil;
    }];
}

#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(tableView.tag==6000)
    {
        return self.classAry.count;
    }
    if(tableView.tag==6001)
    {
        return self.typeArray.count;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Cellidentifier = @"cell1";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if(cell==nil)
    {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
  
    if(tableView.tag==6000)
    {
        ThreadFlag *_temp = [self.classAry objectAtIndex:indexPath.row];
        
        [cell.title setTextAlignment:NSTextAlignmentCenter];
        cell.title.text = _temp.name;
        cell.title.frame = CGRectMake(0, 17, 170, 20);
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.image = [UIImage imageNamed:@"_0000_______.png"];
        cell.homeCellLine.frame = CGRectMake(0, 49, 361/2-8, 1);
        
        return cell;

    }
    
    if(tableView.tag==6001)
    {
        ThreadType *_temp = [self.typeArray objectAtIndex:indexPath.row];

        [cell.title setTextAlignment:NSTextAlignmentCenter];
        cell.title.text = _temp.name;
        cell.title.frame = CGRectMake(0, 17, 170, 20);
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.image = [UIImage imageNamed:@"_0000_______.png"];
        cell.homeCellLine.frame = CGRectMake(0, 49, 361/2-8, 1);
        
        return cell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==6000)
    {
        ThreadFlag *_thFlag = [self.classAry objectAtIndex:indexPath.row];
        NSString *_flagStr = _thFlag.name;
        self.selectFlag = _thFlag;

        NSLog(@"%@",_flagStr);
        [classBtn setTitle:_flagStr forState:UIControlStateNormal];
        
        [self cancelClass];

    }
    
    if(tableView.tag==6001)
    {
        ThreadType *_thType = [self.typeArray objectAtIndex:indexPath.row];
        NSString *_typeStr = _thType.name;
        
        NSLog(@"%@",_typeStr);
        self.selectType = _thType;
        
        [typeBtn setTitle:_typeStr forState:UIControlStateNormal];
        
        [self cancelType];

    }
    
    
}

#pragma mark 长按录音
- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        if(_animationView==nil)
        {
            _animationView = [[VoiceAnimationView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT)];
            _animationView.userInteractionEnabled = YES;
            [self.view addSubview:_animationView];
            [_animationView release];
        }
       
        _animationView.hidden = NO;
        [_animationView startAnimation];
        
        
        //设置文件名
        self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
        NSLog(@"bug:%@",self.originWav);
        //开始录音
        [_recorderVC beginRecordByFileName:self.originWav];
        
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        _animationView.hidden = YES;
        [_animationView stopAnimation];
        
       
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

#pragma mark - amr转wav
- (void)amrToWavBtnPressed {
    if (self.convertAmr.length > 0){
        
        self.convertWav = [self.originWav stringByAppendingString:@"amrToWav"];
        
        //转格式
        [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:[NSString stringWithFormat:@"recr%@",self.convertAmr] ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:@"end" ofType:@"wav"]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
    
    }
}

#pragma mark - wav转amr
- (void)wavToAmrBtnPressed {
    if (self.originWav.length > 0){
        
        
        self.convertAmr = [self.originWav stringByAppendingString:@"wavToAmr"];
        
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:@"amr"]];
        
        
        self.amrData=nil;
        self.amrfile=nil;
        
        
        AVAudioPlayer *amrPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"]] error:nil];
        NSLog(@"changdu:%d",(int)amrPlayer.duration);
        
        if(amrPlayer.duration<1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音时间需要大于1秒，请重新录制" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            [amrPlayer release];
            amrPlayer = nil;
            
            return;
        }
        
        [amrPlayer release];
        amrPlayer = nil;
        
        [voiceBtn removeGestureRecognizer:longPrees];

        voiceLengthBtn.hidden = NO;
        [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
        
        self.amrData = [NSData dataWithContentsOfFile:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:@"amr"]];
        

        __block typeof(self) bself = self;

        AVFile *_voiceFile = [AVFile fileWithName:[NSString stringWithFormat:@"%d.amr",(int)[[NSDate date] timeIntervalSince1970]] data:self.amrData];
        
        [_voiceFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                bself.amrfile = _voiceFile;
                
                AVAudioPlayer *amrPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"]] error:nil];
                NSLog(@"changdu:%d",(int)amrPlayer.duration);
                
                NSLog(@"sucess");
                
                [voiceLengthBtn setTitle:[NSString stringWithFormat:@"%d秒",(int)amrPlayer.duration] forState:UIControlStateNormal];
                
                [amrPlayer release];
                amrPlayer=nil;
            }
        }];
    
        
        
        //test
    }
}

//#pragma mark - pop动画
//- (void)popAnimation
//{
//    //动画
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.7f;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    transition.type = @"rippleEffect";
//    transition.subtype = kCATransitionFade;
//    transition.delegate = self;
//    [self.view.layer addAnimation:transition forKey:nil];
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
