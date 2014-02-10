//
//  ShowCommentViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-23.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ShowCommentViewController.h"
#import "AsyncImageView.h"
#import "CommentCustomCell.h"
#import "MLNavigationController.h"
#import "ViewData.h"
#import "User.h"
#import "ALUserEngine.h"
#import "PersonalDataViewController.h"

@interface ShowCommentViewController ()

@end

@implementation ShowCommentViewController
@synthesize tposts = _tposts;
@synthesize threadDic = _threadDic;
@synthesize datalist = _datalist;
@synthesize loginUserId = _loginUserId;
@synthesize commentsArray = _commentsArray;
@synthesize exChangeUserName = _exChangeUserName;
@synthesize exChangeContents = _exChangeContents;
@synthesize user = _user;
@synthesize amrData = _amrData;
@synthesize amrfile = _amrfile;
@synthesize originWav = _originWav;
@synthesize convertAmr = _convertAmr;
@synthesize convertWav = _convertWav;
@synthesize voiceData = _voiceData;
@synthesize atUserArray = _atUserArray;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [_atUserArray release]; _atUserArray=nil;
    [_voiceData release]; _voiceData=nil;
    [_amrfile release]; _amrfile=nil;
    [_amrData release];_amrData=nil;
    [_originWav release];_originWav=nil;
    [_convertWav release];_convertWav=nil;
    [_convertAmr release];_convertAmr=nil;
    [_user release]; _user=nil;
    [_exChangeContents release]; _exChangeContents=nil;
    [_exChangeUserName release]; _exChangeUserName=nil;
    [_commentsArray release]; _commentsArray=nil;
    [_loginUserId release]; _loginUserId=nil;
    [_datalist release]; _datalist=nil;
    [_threadDic release]; _threadDic=nil;
    [_tposts release]; _tposts=nil;
    
    [super dealloc];
}

- (id)initWithPostDic:(NSDictionary *)tdic ThreadState:(int)tState
{
    if(self = [super init])
    {
        threadState = tState;
        self.threadDic = [NSDictionary dictionaryWithDictionary:tdic];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isPulldown = NO;
    
    self.loginUserId = [ALUserEngine defauleEngine].user.objectId;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardshow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardhide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    self.commentsArray = [NSMutableArray arrayWithCapacity:0];
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
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"评论";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];

    UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
    [showLeftViewBtn setImage:[UIImage imageNamed:@"_0010_chat_返回.png"] forState:UIControlStateNormal];
    [showLeftViewBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showLeftViewBtn];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-85-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    textView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50-[ViewData defaultManager].versionHeight, 320, 50)];
    textView.image = [UIImage imageNamed:@"commenttext.png"];
    textView.userInteractionEnabled = YES;
    [backgroundView addSubview:textView];
    [textView release];
    
    UIImageView *textImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"输入框.png"]];
    textImage.frame = CGRectMake(0, 0, 265, 74/2);
    textImage.center = CGPointMake(140, 25);
    textImage.userInteractionEnabled=YES;
    [textView addSubview:textImage];
    [textImage release];
    
    _textview_content = [[UITextField alloc] initWithFrame:CGRectMake(10, 15, 240, 30)];
    _textview_content.delegate = self;
    _textview_content.returnKeyType = UIReturnKeySend;
    _textview_content.textColor = [UIColor whiteColor];
    _textview_content.font = [UIFont systemFontOfSize:14];
    _textview_content.backgroundColor = [UIColor clearColor];
    [textView addSubview:_textview_content];
    [_textview_content release];
    
    
    recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(230, 0, 40, 40);
    [recordBtn setImage:[UIImage imageNamed:@"录音.png"] forState:UIControlStateNormal];
    [recordBtn addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
    [textImage addSubview:recordBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(280, 10, 40, 25);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [textView addSubview:sendBtn];
    
    voiceLengthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceLengthBtn.frame = CGRectMake(0, 0, 30, 55/2);
    voiceLengthBtn.center = CGPointMake(250, -10);
    [voiceLengthBtn setBackgroundImage:[UIImage imageNamed:@"视频-语音.png"] forState:UIControlStateNormal];
    [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
    voiceLengthBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [textImage addSubview:voiceLengthBtn];
    voiceLengthBtn.hidden = YES;

    //初始化录音vc
    _recorderVC = [[ChatVoiceRecorderVC alloc] init];
    _recorderVC.vrbDelegate = self;
    
    
    //添加手势
    longPrees = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.minimumPressDuration=0.1;
    longPrees.delegate = self;
    [recordBtn addGestureRecognizer:longPrees];
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i=0;i<4;i++)
    {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"_0005_语音标示self_%d.png",i+1]];
        [array addObject:img];
    }
    
    animationImgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0005_语音标示self.png"]];
    animationImgview.frame = CGRectMake(82, 8, 19/2, 27/2);
    animationImgview.animationImages = array;
    animationImgview.animationDuration = 1;
    animationImgview.hidden = YES;
    [array release];
    array=nil;

    [self showF3HUDLoad:nil];
    
    [self creatHeadViewReloadData];
    [self addRefreshHeaderView];
    [self requestInvitation];
}

- (void)requestInvitation
{
    if (self.isrequest==YES)
    {
        return;
    }

    self.isrequest = YES;

    __block typeof(self) bself = self;
    
    Post *_post = [self.threadDic objectForKey:@"tPost"];
    
    
    [[ALThreadEngine defauleEngine] getCommentsWithPost:_post notContainedIn:nil block:^(NSArray *comments, NSError *error) {
        
        int counts = comments.count;
        
        if(counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(downloadData:) withObject:comments];
 
        }
       
        if(counts==0 && !error)
        {
            [bself hideF3HUDSucceed:nil];
            bself.isrequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];

        }
        
        if(error)
        {
            [bself hideF3HUDError:nil];
            bself.isrequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];

        }
    }];
    
}

- (void)downloadData:(NSArray *)array
{
    NSMutableArray *ary1 = [[NSMutableArray alloc] init];
    NSMutableArray *ary2 = [[NSMutableArray alloc] init];

    int count = array.count;
    
    for(int i=0; i<count; i++)
    {
        Comment *_comments = [array objectAtIndex:i];
        
        User *_tempuser = (User *)[_comments.postUser fetchIfNeeded];
        
        NSString *_username;
        NSString *_userurl;
        NSNumber *_sex;
        NSString *_sendtime = [NSString stringWithFormat:@"%@",[self calculateDate:_comments.updatedAt]];
        
        if (_tempuser)
        {
            _username = [NSString stringWithFormat:@"%@",_tempuser.nickName];
            _userurl = [NSString stringWithFormat:@"%@",_tempuser.headView.url];
            _sex = [NSNumber numberWithBool:_tempuser.gender];
        }
        else
        {
            _username = @"该用户已注销";
            _userurl = @"0";
            _sex = [NSNumber numberWithInt:2];
        }
        
        
        ThreadContent *_content = (ThreadContent *)[_comments.content fetchIfNeeded];
        
        BOOL haveText=NO;
        BOOL haveVoice=NO;
        
        NSData *_tVoiceData = nil;
        NSString *_text=nil;
        _text = _content.text;
        
        _tVoiceData = [_content.voice getData];
        if (_tVoiceData)
        {
            haveVoice=YES;
        }
        if (_text.length>0)
        {
            haveText=YES;
        }
        
        
        NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
        
        [_dic setValue:_sex forKey:@"gender"];
        [_dic setValue:_sendtime forKey:@"Csendtime"];
        [_dic setValue:_username forKey:@"userName"];
        [_dic setValue:_userurl forKey:@"headview"];
        [_dic setValue:_tempuser forKey:@"user"];
        [_dic setValue:_content.text forKey:@"Ccontents"];
        [_dic setValue:_tVoiceData forKey:@"voiceData"];
        [_dic setValue:[NSNumber numberWithBool:haveText] forKey:@"haveText"];
        [_dic setValue:[NSNumber numberWithBool:haveVoice] forKey:@"haveVoice"];
        
        [ary1 addObject:_dic];
        
        [ary2 addObject:_comments];
    }
    
    if (self.isShowMore==NO)
    {
        [self.datalist removeAllObjects];
        [self.commentsArray removeAllObjects];
    }
    
    [self.datalist addObjectsFromArray:ary1];
    [self.commentsArray addObjectsFromArray:ary2];
    
    [ary1 release]; ary1=nil;
    [ary2 release]; ary2=nil;
 
    [self performSelectorOnMainThread:@selector(refreshComments) withObject:nil waitUntilDone:NO];

}

- (void)refreshComments
{
    if (self.isShowMore==YES)
    {
        [_activityView stopAnimating];
        [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    }
    
    [self addFootView];
    
    [_tableView reloadData];
    [self doneLoadingTableViewData];
    [self hideF3HUDSucceed:nil];
    
    self.isrequest = NO;
    self.isShowMore = NO;
}

#pragma mark 添加footView
- (void)addFootView
{
    if(footView!=nil)
    {
        return;
    }
    
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    footView.backgroundColor = [UIColor clearColor];
    
    loadCommentsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loadCommentsBtn.frame = CGRectMake(0, 0, 280, 40);
    [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    [loadCommentsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    loadCommentsBtn.center = CGPointMake(160, 30);
    [loadCommentsBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [loadCommentsBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:loadCommentsBtn];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(0, 0, 20, 20);
    _activityView.center = CGPointMake(100, 20);
    [loadCommentsBtn addSubview:_activityView];
    [_activityView release];
    
    _tableView.tableFooterView = footView;
    [footView release];

}


- (void)showMoreComments:(UIButton *)sender
{
    if (self.isrequest==YES)
    {
        return;
    }
    
    self.isrequest = YES;
    
    self.isShowMore=YES;
  
    [_activityView startAnimating];
    [loadCommentsBtn setTitle:@"加载中" forState:UIControlStateNormal];
    
  
    __block typeof(self) bself = self;
    
    __block UIButton *__loadbtn = loadCommentsBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    Post *_post = [self.threadDic objectForKey:@"tPost"];
    
    [[ALThreadEngine defauleEngine] getCommentsWithPost:_post notContainedIn:self.commentsArray block:^(NSArray *comments, NSError *error) {
        
        int counts = comments.count;
        
        if(counts>0 && !error)
        {
            
            [bself performSelectorInBackground:@selector(downloadData:) withObject:comments];

        }
        
        if(counts==0 && !error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
            
            [__activity stopAnimating];
            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            
            [bself doneLoadingTableViewData];
            bself.isrequest = NO;
            bself.isShowMore = NO;
        }
        
        if(error)
        {
            [__activity stopAnimating];
            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            
            [bself doneLoadingTableViewData];
            bself.isrequest = NO;
            bself.isShowMore = NO;
            
        }
        
       
    }];

}


#pragma mark 创建headView
- (void)creatHeadViewReloadData
{
    Post *_post = [self.threadDic objectForKey:@"tPost"];
    self.tposts = _post;
    User *_tempuser = _post.postUser;
    [_tempuser fetchIfNeeded];
    
    self.user = _tempuser;
    
    NSString *_tcontent = [self.threadDic objectForKey:@"tContents"];
    NSString *_place = self.tposts.place;
    NSString *_sendTime = [self.threadDic objectForKey:@"sendTime"];
    NSString *_tstate = [self.threadDic objectForKey:@"textOrvoice"];
   
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    headView.backgroundColor = [UIColor whiteColor];
    _tableView.tableHeaderView = headView;
    [headView release];
    
    
    NSString *_username;
    NSString *_userurl;
    int _gender;
    
    if (_tempuser)
    {
        _username = _tempuser.nickName;
        _userurl = _tempuser.headView.url;
        _gender = _tempuser.gender;
    }
    else
    {
        _gender = 2;
    }
    
    
    UIImageView *headImage = [[UIImageView alloc] init];
    
    //女
    if (_gender==0)
    {
        headImage.image = [UIImage imageNamed:@"nv.png"];
    }
    //男
    if (_gender==1)
    {
        headImage.image = [UIImage imageNamed:@"nan.png"];
    }
    //删除
    if (_gender==2)
    {
        headImage.image = [UIImage imageNamed:@"unfinduser.png"];
    }
    
    headImage.frame = CGRectMake(0, 0, 55, 55);
    headImage.center = CGPointMake(35, 35);
    headImage.userInteractionEnabled = YES;
    [headView addSubview:headImage];
    [headImage release];
    
    AsyncImageView *headViewAsy = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 49, 49) ImageState:0];
    headViewAsy.center = CGPointMake(35, 35);
    headViewAsy.defaultImage = 0;
    headViewAsy.urlString = _userurl;
    [headViewAsy addTarget:self action:@selector(showOwner) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:headViewAsy];
    [headViewAsy release];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 20)];
    userName.backgroundColor = [UIColor clearColor];
    userName.font = [UIFont systemFontOfSize:16];
    userName.text = _username;
    userName.textColor = [UIColor colorWithRed:1 green:0.21 blue:0 alpha:1];
    [userName setTextAlignment:NSTextAlignmentLeft];
    [headView addSubview:userName];
    [userName release];
    

    UIImageView *timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0002_time@2x.png"]];
    timeImage.frame = CGRectMake(72, 40, 23/2, 22/2);
    [headView addSubview:timeImage];
    [timeImage release];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 36, 100, 20)];
    timeLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont systemFontOfSize:11];
    [timeLabel setTextAlignment:NSTextAlignmentLeft];
    timeLabel.text = _sendTime;
    [headView addSubview:timeLabel];
    [timeLabel release];
    
    UIImageView *locationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0003_location.png"]];
    locationImage.frame = CGRectMake(150, 40, 19/2, 22/2);
    [headView addSubview:locationImage];
    [locationImage release];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 36, 150, 20)];
    locationLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.font = [UIFont systemFontOfSize:11];
    [locationLabel setTextAlignment:NSTextAlignmentLeft];
    locationLabel.text = _place;
    [headView addSubview:locationLabel];
    [locationLabel release];

    if([_tstate isEqualToString:@"text"])
    {
        CGSize contentSize = [_tcontent sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(70, 65, 240, contentSize.height)];
        content.text = _tcontent;
        content.font = [UIFont systemFontOfSize:16];
        content.numberOfLines = 0;
        content.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
        [content setTextAlignment:NSTextAlignmentLeft];
        [headView addSubview:content];
        [content release];
        
        headView.frame = CGRectMake(0, 0, 320, 80+contentSize.height);
    }
    
    if ([_tstate isEqualToString:@"voice"])
    {
        voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.frame = CGRectMake(70, 65, 100, 30);
        voiceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        [voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
        [voiceBtn addTarget:self action:@selector(playHeadVoice) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:voiceBtn];
        
        headView.frame = CGRectMake(0, 0, 320, 110);
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for(int i=0;i<4;i++)
        {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"_0005_语音标示self_%d.png",i+1]];
            [array addObject:img];
        }
        
        voiceAnimationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0005_语音标示self.png"]];
        voiceAnimationView.frame = CGRectMake(82, 8, 19/2, 27/2);
        voiceAnimationView.animationImages = array;
        voiceAnimationView.animationDuration = 1;
        [voiceBtn addSubview:voiceAnimationView];
        [voiceAnimationView release];
        
        [array release];
        array=nil;

    }
   
    
    _tableView.tableHeaderView = headView;
}

- (void)showOwner
{
    if (self.user)
    {
        BOOL fromSelf;
        
        if ([self.user.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
        {
            fromSelf = YES;
        }
        else
        {
            fromSelf = NO;
        }
        
        PersonalDataViewController *person = [[PersonalDataViewController alloc] initWithUser:self.user FromSelf:fromSelf SelectFromCenter:YES];
        [self.navigationController pushViewController:person AnimatedType:MLNavigationAnimationTypeOfNone];
        [person release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已注销" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
}

- (void)showUserInfo:(AsyncImageView *)sender
{
    User *_tempuser = nil;
    _tempuser = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"user"];
    
    if (!_tempuser)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已注销" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    BOOL froms;
    
    if ([_tempuser.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
    {
        froms = YES;
    }
    else
    {
        froms = NO;
    }
    
    PersonalDataViewController *person = [[PersonalDataViewController alloc] initWithUser:_tempuser FromSelf:froms SelectFromCenter:YES];
    [self.navigationController pushViewController:person AnimatedType:MLNavigationAnimationTypeOfNone];
    [person release];
}

#pragma mark 播放回复声音
- (void)playCommentVoice:(UIButton *)sender
{
    self.voiceData=nil;
    self.voiceData = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"voiceData"];
    
    if(self.voiceData==nil)
    {
        return;
    }
    
    CommentCustomCell *cell = (CommentCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    [cell.voiceBtn setTitle:@"播放中" forState:UIControlStateNormal];
    [cell.voiceBtn addSubview:animationImgview];
    animationImgview.hidden = NO;
    [animationImgview startAnimating];
    _sender = sender;
    
    if(isPlayHeadVoice==YES)
    {
        [amrPlayer stop];
        [amrPlayer release];
        amrPlayer=nil;
        isPlayHeadVoice = NO;
    }
    
    if(isPlayCellVoice==YES)
    {
        [amrPlayer stop];
        [amrPlayer release];
        amrPlayer=nil;
        
        if(_lastSender==sender)
        {
            CommentCustomCell *cell = (CommentCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSender.tag inSection:0]];
            [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
            [animationImgview stopAnimating];
            animationImgview.hidden = YES;
            isPlayCellVoice = NO;
            
            return;
        }
        else
        {
            CommentCustomCell *cell = (CommentCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
            [cell.voiceBtn setTitle:@"播放中" forState:UIControlStateNormal];
            [cell.voiceBtn addSubview:animationImgview];
            animationImgview.hidden = NO;
            
            CommentCustomCell *cell2 = (CommentCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSender.tag inSection:0]];
            [cell2.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        }
        
        
    }
    
    _lastSender = sender;
    
    isPlayCellVoice = YES;
    
    [self playVoice];
}

#pragma mark 播放楼主声音
- (void)playHeadVoice
{
    self.voiceData = nil;
    self.voiceData = [self.threadDic objectForKey:@"tContents"];
    
    if (self.voiceData==nil)
    {
        return;
    }
    
    [voiceAnimationView startAnimating];
    [voiceBtn setTitle:@"播放中" forState:UIControlStateNormal];
    
    
    if(isPlayCellVoice==YES)
    {
        isPlayCellVoice=NO;
        [amrPlayer release];
        amrPlayer=nil;
        CommentCustomCell *cell = (CommentCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sender.tag inSection:0]];
        [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
    }
    
    if(isPlayHeadVoice==YES)
    {
        [voiceAnimationView stopAnimating];
        [amrPlayer stop];
        [amrPlayer release];
        amrPlayer=nil;
        
        isPlayHeadVoice=NO;
        
        return;
    }
    
    isPlayHeadVoice = YES;
    
    [self playVoice];
}

- (void)playVoice
{
    [self isHeadphone];
    
    NSFileManager *fileMC = [NSFileManager defaultManager];
    NSString *Rpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"RVoice.amr"];
    [fileMC createFileAtPath:Rpath contents:self.voiceData attributes:nil];
    
    NSString *RWAVpath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"RVoice.wav"];
    [VoiceConverter amrToWav:Rpath wavSavePath:RWAVpath];
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
    amrPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:RWAVpath] error:nil];
    amrPlayer.volume = 1;
    amrPlayer.delegate = self;
    [amrPlayer prepareToPlay];
    [amrPlayer play];
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(isPlayHeadVoice==YES)
    {
        [voiceAnimationView stopAnimating];
        isPlayHeadVoice=NO;
    }
    
    if(isPlayCellVoice==YES)
    {
        [animationImgview stopAnimating];
        animationImgview.hidden = YES;
        CommentCustomCell *cell = (CommentCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sender.tag inSection:0]];
        [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        isPlayCellVoice = NO;
    }
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
}
#pragma mark 点评
- (void)submitDianPing
{
    if (_textview_content.text.length==0 && !self.amrData)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"回复不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView=nil;
        
        return;
    }
    
    
    if (self.isrequest==YES)
    {
        return;
    }
    
    self.isrequest = YES;
  
    
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

    __block typeof(self) bself = self;
    __block UIButton *__voicebtn = voiceLengthBtn;
    __block UITextField *__textview = _textview_content;
    
    [[ALThreadEngine defauleEngine] sendCommentWithPost:self.tposts andContent:_content atUsers:nil block:^(BOOL succeeded, NSError *error) {
        
        bself.isrequest = NO;
        
        if(succeeded && !error)
        {
            bself.amrData=nil;
            bself.amrfile=nil;
            __voicebtn.hidden=YES;
            __textview.text = @"";
            
            if (bself.datalist.count<20)
            {
                [bself requestInvitation];
            }
            else
            {
                [bself hideF3HUDSucceed:nil];
            }
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        
        
    }];
}

- (void)submitExChange
{
    if (self.isrequest==YES)
    {
        return;
    }
    
    self.isrequest = YES;
    
    if (_textview_content.text.length==0 && !self.amrData)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"回复不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        alertView=nil;
        
        return;
    }
    
    ThreadContent *_content = [ThreadContent object];
    
    NSString *str = [NSString stringWithFormat:@"%@ %@ \n",self.exChangeUserName,_textview_content.text];

    _content.text = str;
   
    
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
    
    __block typeof(self) bself = self;
    
    __block UIButton *__voicebtn = voiceLengthBtn;
    __block UITextField *__textview = _textview_content;
    
    [[ALThreadEngine defauleEngine] sendCommentWithPost:self.tposts andContent:_content atUsers:self.atUserArray block:^(BOOL succeeded, NSError *error) {
    
        bself.isrequest = NO;


        if(succeeded && !error)
        {
            bself.amrData=nil;
            bself.amrfile=nil;
            __voicebtn.hidden=YES;
            __textview.text = @"";
            
            if (bself.datalist.count<20)
            {
                [bself requestInvitation];
            }
            else
            {
                [bself hideF3HUDSucceed:nil];
            }
            
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        

    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_dic = [self.datalist objectAtIndex:indexPath.row];
    NSString *userName = [_dic objectForKey:@"userName"];
    NSString *contents = [_dic objectForKey:@"Ccontents"];
    User *_atuser = [_dic objectForKey:@"user"];
    
    if (userName.length==0)
    {
        return;
    }
    
    if (userNameView!=nil)
    {
        [userNameView removeFromSuperview];
        userNameView=nil;
    }
    
    NSString *str = [NSString stringWithFormat:@"回复%@:",userName];
    self.exChangeUserName=nil;
    self.exChangeUserName = str;
    
    self.exChangeContents=nil;
    self.exChangeContents=contents;
    
    CGSize contentSize = [str sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(1000, 1000) lineBreakMode:0];
    
    
    if (userNameView!=nil)
    {
        [userNameView removeFromSuperview];
        userNameView=nil;
    }
    
    userNameView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, 100, 20)];
    userNameView.backgroundColor = [UIColor clearColor];
    [textView addSubview:userNameView];
    [userNameView release];
    
    
    atNameLabel = [[UILabel alloc] init];
    atNameLabel.font = [UIFont systemFontOfSize:13];
    atNameLabel.backgroundColor = [UIColor clearColor];
    atNameLabel.textColor = [UIColor whiteColor];
    atNameLabel.text = str;

    UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [userBtn addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
    
    if (contentSize.width<80)
    {
        userBtn.frame = CGRectMake(0, 2, contentSize.width, 30);
        atNameLabel.frame = CGRectMake(0, 2, contentSize.width, 30);
        
        _textview_content.frame = CGRectMake(contentSize.width+15, 15, 240-contentSize.width-15, 30);
    }
    else
    {
        userBtn.frame = CGRectMake(0, 2, 80, 30);
        atNameLabel.frame = CGRectMake(0, 2, 80, 30);
        atNameLabel.numberOfLines=0;
        
        _textview_content.frame = CGRectMake(90, 15, 240-90, 30);
    }
    
    [userNameView addSubview:atNameLabel];
    [userNameView addSubview:userBtn];
    [atNameLabel release];
    
    _exchange = YES;
    
    [self.atUserArray removeAllObjects];
    
    if (_atuser)
    {
        [self.atUserArray addObject:_atuser];
    }
    
    
    [_textview_content becomeFirstResponder];
}

- (void)deleteUser:(UIButton *)sender
{
    [userNameView removeFromSuperview];
    userNameView=nil;
    
    _textview_content.frame = CGRectMake(10, 15, 240, 30);
    _textview_content.text = @"";
    _exchange = NO;
}


- (void)twitterAccountClicked:(NSString *)link
{
    
    NSLog(@"username=%@",link);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *temp = [self.datalist objectAtIndex:indexPath.row];
    NSString *contents = [temp objectForKey:@"Ccontents"];
    
    CGSize contentSize = [contents sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
    
    BOOL haveText = [[temp objectForKey:@"haveText"] boolValue];
    BOOL haveVoice = [[temp objectForKey:@"haveVoice"] boolValue];
    
    
    if (haveText && haveVoice)
    {
        return 110+contentSize.height;
    }
    if (haveText && haveVoice==NO)
    {
        return 75+contentSize.height;
    }
    if (haveText==NO && haveVoice)
    {
        return 105+contentSize.height;
    }
    
    
    return 0;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datalist.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cellidentifier1 = @"cell1";
    
    CommentCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier1];
    
    if(cell==nil)
    {
        cell = [[[CommentCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier1] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSDictionary *temp = [self.datalist objectAtIndex:indexPath.row];
    
    NSString *_userid = [[temp objectForKey:@"user"] objectId];
    
    int _gender = [[temp objectForKey:@"gender"] intValue];
    
    //女
    if (_gender==0)
    {
        cell.headCoverImage.image = [UIImage imageNamed:@"nv.png"];
    }
    //男
    if (_gender==1)
    {
        cell.headCoverImage.image = [UIImage imageNamed:@"nan.png"];
    }
    //删除
    if (_gender==2)
    {
        cell.headCoverImage.image = [UIImage imageNamed:@"unfinduser.png"];
    }
    cell.headCoverImage.hidden = NO;
    
    cell.headImageView.hidden = NO;
    cell.headImageView.urlString = [temp objectForKey:@"headview"];
    [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.userName.text = [temp objectForKey:@"userName"];
    
    cell.timeLabel.text = [temp objectForKey:@"Csendtime"];
    
    BOOL haveVoice = [[temp objectForKey:@"haveVoice"] boolValue];
    BOOL haveText = [[temp objectForKey:@"haveText"] boolValue];
  
    NSString *contents = [temp objectForKey:@"Ccontents"];
    
    CGSize contentSize;
    
    cell.voiceBtn.hidden=YES;
    
    if (haveText)
    {
        contentSize = [contents sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        
        cell.content.frame = CGRectMake(70, 65, 230, contentSize.height);
        
        cell.content.text = contents;
        
        if (haveVoice)
        {
            cell.voiceBtn.hidden = NO;
            cell.voiceBtn.frame = CGRectMake(70, 90, 100, 30);
            [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
            [cell.voiceBtn addTarget:self action:@selector(playCommentVoice:) forControlEvents:UIControlEventTouchUpInside];
            cell.voiceBtn.tag = indexPath.row;
        }
    }
    else
    {
        if (haveVoice)
        {
            cell.voiceBtn.hidden = NO;
            cell.voiceBtn.frame = CGRectMake(70, 65, 100, 30);
            [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
            [cell.voiceBtn addTarget:self action:@selector(playCommentVoice:) forControlEvents:UIControlEventTouchUpInside];
            cell.voiceBtn.tag = indexPath.row;
        }
    }
    
    
    cell.floorLabel.text = [NSString stringWithFormat:@"%d楼",indexPath.row+1];

    cell.deleteBtn.hidden = YES;
    
    if([_userid isEqualToString:self.loginUserId])
    {
        cell.deleteBtn.hidden = NO;
        
        if (haveVoice && haveText)
        {
            cell.deleteBtn.frame = CGRectMake(278, 80+contentSize.height, 49/2, 49/2);
        }
        
        if (haveText && haveVoice==NO)
        {
            cell.deleteBtn.frame = CGRectMake(278, 45+contentSize.height, 49/2, 49/2);
        }
        
        if (haveVoice && haveText==NO)
        {
            cell.deleteBtn.frame = CGRectMake(278, 75, 49/2, 49/2);
        }
    
        
        [cell.deleteBtn setImage:[UIImage imageNamed:@"AHSHANCHU.png"] forState:UIControlStateNormal];
        [cell.deleteBtn addTarget:self action:@selector(deleteComments:) forControlEvents:UIControlEventTouchUpInside];
        cell.deleteBtn.tag = indexPath.row;
    }
    
    if (haveText && haveVoice)
    {
        cell.backView.frame = CGRectMake(5, 5, 310, 105+contentSize.height);
    }
    if (haveText && haveVoice==NO)
    {
        cell.backView.frame = CGRectMake(5, 5, 310, 70+contentSize.height);
    }
    if (haveText==NO && haveVoice)
    {
        cell.backView.frame = CGRectMake(5, 5, 310, 100+contentSize.height);
    }
   
    
    return cell;
}

#pragma mark 删除评论
- (void)deleteComments:(UIButton *)sender
{
    Comment *_comment=nil;
    _comment = [[self.commentsArray objectAtIndex:sender.tag] objectForKey:@"comment"];
    
    if(_comment)
    {
        __block typeof(self) bself = self;
        __block UITableView *__tableview = _tableView;
        
        [self showF3HUDLoad:nil];
        
        [[ALThreadEngine defauleEngine] deleteComment:_comment block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [bself.datalist removeObjectAtIndex:sender.tag];
                [__tableview reloadData];
                [bself hideF3HUDSucceed:nil];
                
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
        }];
    }
}

- (void)keyboardshow:(NSNotification *)notification
{
    if(threadState==-1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已关闭，无法回复" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        [_textview_content resignFirstResponder];
        
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        textView.frame = CGRectMake(0, SCREEN_HEIGHT-50-keyboardRect.size.height-[ViewData defaultManager].versionHeight, 320, 50);
        
    } completion:^(BOOL finished) {
        
    }];
}


- (void)keyboardhide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        textView.frame = CGRectMake(0, SCREEN_HEIGHT-50-[ViewData defaultManager].versionHeight, 320, 50);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.amrData!=nil)
    {
        _textview_content.text = @"";

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文字和声音只能回复一种！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 10000;
        [alertView show];
        [alertView release];
        alertView=nil;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.amrData!=nil)
    {
        _textview_content.text = @"";

        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文字和声音只能回复一种！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 10000;
        [alertView show];
        [alertView release];
        alertView=nil;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textview_content resignFirstResponder];

    
    if (_exchange)
    {
        [self submitExChange];
        _exchange=NO;
    }
    else
    {
        [self submitDianPing];
    }
    
    return YES;
}



- (void)submit
{
    if (self.isrequest)
    {
        return;
    }
    
    [_textview_content resignFirstResponder];

    if (_exchange)
    {
        [self submitExChange];
        _exchange=NO;
    }
    else
    {
        [self submitDianPing];
    }
}



- (void)back
{
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
            alertView.tag = 10001;
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



#pragma mark - wav转amr
- (void)wavToAmrBtnPressed {
    if (self.originWav.length > 0){
        

        self.convertAmr = [self.originWav stringByAppendingString:@"wavToAmr"];
        
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:@"amr"]];
        
        
        self.amrData=nil;
        self.amrfile=nil;
        
        
        AVAudioPlayer *amr = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"]] error:nil];
        NSLog(@"changdu:%d",(int)amr.duration);
        
        if(amr.duration<1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音时间需要大于1秒，请重新录制" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
            
            [amr release];
            amr = nil;
            
            return;
        }
        
        [amr release];
        amr = nil;
        
        [recordBtn removeGestureRecognizer:longPrees];
        
        if(_textview_content.text.length==0)
        {
            voiceLengthBtn.hidden = NO;
            [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
        }
        
        self.amrData = [NSData dataWithContentsOfFile:[VoiceRecorderBaseVC getPathByFileName:self.convertAmr ofType:@"amr"]];
        
        
        __block typeof(self) bself = self;
        __block UIButton *__voicebtn = voiceLengthBtn;
        
        AVFile *_voiceFile = [AVFile fileWithName:[NSString stringWithFormat:@"%d.amr",(int)[[NSDate date] timeIntervalSince1970]] data:self.amrData];
        
        [_voiceFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                bself.amrfile = _voiceFile;
                
                
                AVAudioPlayer *amr = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:self.originWav ofType:@"wav"]] error:nil];
                NSLog(@"changdu:%d",(int)amr.duration);
                
                NSLog(@"sucess");
                
                [__voicebtn setTitle:[NSString stringWithFormat:@"%d秒",(int)amr.duration] forState:UIControlStateNormal];
                
                [amr release];
                amr=nil;
            }
        }];
        
        
        
        //test
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000)
    {
        _textview_content.text = @"";
    }
    if (alertView.tag==10001)
    {
        self.voiceData=nil;
    }
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        if (self.amrData)
        {
            if (playVoice!=nil)
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
    
    if (buttonIndex==1)
    {
        [voiceLengthBtn setTitle:@"上传中" forState:UIControlStateNormal];
        voiceLengthBtn.hidden = YES;
        [recordBtn addGestureRecognizer:longPrees];
        self.amrData=nil;
        self.amrfile=nil;
    }
}


#pragma mark - 录音
- (void)playRecording
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"播放",@"删除", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    actionSheet=nil;
}


#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_textview_content resignFirstResponder];
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - addHeader&addFooter
- (void)addRefreshHeaderView
{
    if (_refreshHeaderView == nil)
    {
        _reloading = NO;
        
        _refreshHeaderView=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height) textColor:[UIColor grayColor] beginStr:@"下拉刷新" stateStr:@"松开即可刷新" endStr:@"加载中"haveArrow:YES];
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
        
        _refreshHeaderView.delegate = self;
        [_tableView addSubview:_refreshHeaderView];
        [_tableView sendSubviewToBack:_refreshHeaderView];
        [_refreshHeaderView release];
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
    }
}



#pragma mark - headerView Delegate
//拖拽到位松手触发（刷新）
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self requestInvitation]; //从新读取数据
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
