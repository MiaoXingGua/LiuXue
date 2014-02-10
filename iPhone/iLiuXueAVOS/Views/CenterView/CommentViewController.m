//
//  CommentViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-30.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "CommentViewController.h"
#import "ALUserEngine.h"
#import "ViewData.h"

@interface CommentViewController ()

@end

@implementation CommentViewController
@synthesize originWav = _originWav;
@synthesize convertAmr = _convertAmr;
@synthesize convertWav = _convertWav;
@synthesize amrData = _amrData;
@synthesize amrfile = _amrfile;
@synthesize threads = _threads;
@synthesize tposts = _tposts;

- (void)dealloc
{
    [_tposts release]; _tposts=nil;
    [_threads release]; _threads=nil;
    [_amrfile release]; _amrfile=nil;
    [_amrData release]; _amrData=nil;
    [_originWav release]; _originWav=nil;
    [_convertWav release]; _convertWav=nil;
    [_convertAmr release]; _convertAmr=nil;
    
    [_recorderVC release]; _recorderVC=nil;
    [longPrees release]; longPrees=nil;

    [super dealloc];
}

- (id)initWithThread:(Thread *)threads
{
    if(self = [super init])
    {
        self.threads = threads;
        iscomment = YES;
    }
    
    return self;
}

- (id)initWithPost:(Post *)tposts
{
    if(self = [super init])
    {
        iscomment = NO;
        self.tposts = tposts;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [_textview_content becomeFirstResponder];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [_textview_content resignFirstResponder];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 10, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"_0036_确认.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelComment) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:cancelBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(280, 10, 30, 30);
    [doneBtn setImage:[UIImage imageNamed:@"_0035_取消.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:doneBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"回复";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];

 
    _textview_content = [[UITextView alloc] initWithFrame:CGRectMake(15, 55, 290, SCREEN_HEIGHT-320-[ViewData defaultManager].versionHeight)];
    _textview_content.delegate = self;
    _textview_content.textColor = [UIColor grayColor];
    _textview_content.font = [UIFont systemFontOfSize:16];
    _textview_content.backgroundColor = [UIColor clearColor];
    _textview_content.returnKeyType = UIReturnKeyDefault;
    [backgroundView addSubview:_textview_content];
    [_textview_content release];
    
 
    //回复
    if(iscomment==YES)
    {
        voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(10, SCREEN_HEIGHT-255-[ViewData defaultManager].versionHeight, 40, 40);
        [voiceBtn setImage:[UIImage imageNamed:@"录音.png"] forState:UIControlStateNormal];
        [voiceBtn addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:voiceBtn];
        
        
        voiceLengthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceLengthBtn.frame = CGRectMake(0, 0, 30, 55/2);
        voiceLengthBtn.center = CGPointMake(30, SCREEN_HEIGHT-265-[ViewData defaultManager].versionHeight);
        [voiceLengthBtn setBackgroundImage:[UIImage imageNamed:@"视频-语音.png"] forState:UIControlStateNormal];
        [voiceLengthBtn addTarget:self action:@selector(deleteVoice) forControlEvents:UIControlEventTouchUpInside];
        [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
        voiceLengthBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [backgroundView addSubview:voiceLengthBtn];
        voiceLengthBtn.hidden = YES;
        
        //初始化录音vc
        _recorderVC = [[ChatVoiceRecorderVC alloc] init];
        _recorderVC.vrbDelegate = self;
        
        
        //添加手势
        longPrees = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordBtnLongPressed:)];
        longPrees.minimumPressDuration=0.1;
        longPrees.delegate = self;
        [voiceBtn addGestureRecognizer:longPrees];
    }
    

}


#pragma mark 提交
- (void)submit
{
    if(_textview_content.text.length==0 && self.amrData==nil)
    {
        return;
    }
    
    if(self.threads)
    {
        [self submitComment];
    }
}


#pragma mark 回复
- (void)submitComment
{
    __block typeof(self) bself = self;
    
    ThreadContent *_content = [ThreadContent object];
    
    if(_textview_content.text.length>0)
    {
        _content.text = _textview_content.text;
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
        
        _content.voice = self.amrfile;
    }
    
    [self showF3HUDLoad:nil];
    
    ALGPSHelper *gps = [ALGPSHelper OpenGPS];
    
    CGFloat latitude = gps.offLatitude;
    CGFloat longitude = gps.offLongitude;
    
    [[ALThreadEngine defauleEngine] sendPostWithThread:self.threads andContent:_content atUsers:nil latitude:latitude longitude:longitude place:gps.LocationName block:^(BOOL succeeded, NSError *error) {
        
        if(succeeded && !error)
        {
            [bself hideF3HUDSucceed:nil];
            
            [bself.navigationController popViewControllerAnimated];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commentsucceed" object:Nil];
            
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        
    }];
 
}


#pragma mark 取消回复
- (void)cancelComment
{
    [_textview_content resignFirstResponder];

    [self.navigationController popViewControllerAnimated];
}

#pragma mark 长按录音
- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        
        if(_textview_content.text.length!=0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文字和声音只能回复一种！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            alertView=nil;
            
            return;
            
        }
        
        
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
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        
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
        NSLog(@"documentsDirectory%@",documentsDirectory);
        _player = [_player initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/end.wav",documentsDirectory]] error:nil];
        _player.volume=1.0;
        [self isHeadphone];
        [_player prepareToPlay];
        [_player play];
    }
}

#pragma mark - wav转amr
- (void)wavToAmrBtnPressed {
    if (self.originWav.length > 0){
        
        
        [voiceBtn removeGestureRecognizer:longPrees];

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
        
        if(_textview_content.text.length==0)
        {
            voiceLengthBtn.hidden = NO;
            [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
        }
        
        self.amrData = [NSData dataWithContentsOfFile:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:@"amr"]];
        
        
        __block typeof(self) bself = self;
        
        __block UIButton *__voicelength = voiceLengthBtn;
        
        AVFile *_voiceFile = [AVFile fileWithName:[NSString stringWithFormat:@"%d.amr",(int)[[NSDate date] timeIntervalSince1970]] data:self.amrData];
        
        [_voiceFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                bself.amrfile = _voiceFile;
                
                AVAudioPlayer *amrPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"]] error:nil];

                [__voicelength setTitle:[NSString stringWithFormat:@"%d秒",(int)amrPlayer.duration] forState:UIControlStateNormal];
                
                [amrPlayer release];
                amrPlayer=nil;
            }
        }];
    }
}



#pragma mark 删除录音
- (void)deleteVoice
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除语音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alert.tag=2000;
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _textview_content.text = @"";
    
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
        [playVoice release];
        playVoice=nil;
    }
}

#pragma mark - 录音
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


#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(self.amrData!=nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文字和声音只能回复一种！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        _textview_content.text = @"";
        
        return YES;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(self.amrData!=nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文字和声音只能回复一种！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        _textview_content.text = @"";
        
        return YES;
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
