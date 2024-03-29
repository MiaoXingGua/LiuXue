//
//  InfoViewController.m
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "InfoViewController.h"
#import "ViewData.h"
#import "HomeViewController.h"
#import "MLNavigationController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "InfoCustomCell.h"
#import "AsyncImageView.h"
#import "ALProgressImageView.h"
#import "AsyncImageView.h"
#import "VCConfig.h"
#import "CommentViewController.h"
#import "AppDelegate.h"
//#import "ImageCropper.h"
#import "ALUserEngine.h"
#import "ShowCommentViewController.h"
#import "ALUserEngine.h"
#import "ReportThreadViewController.h"
#import "PersonalDataViewController.h"
//#import <ShareSDK/ShareSDK.h>

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize tdic = _tdic;
@synthesize datalist = _datalist;
@synthesize voiceData = _voiceData;
@synthesize imageArray = _imageArray;
@synthesize voiceArray = _voiceArray;
@synthesize voiceDataArray = _voiceDataArray;
@synthesize tempArray = _tempArray;
@synthesize headVoiceData = _headVoiceData;
@synthesize videoFilePath = _videoFilePath;
@synthesize showImageArray = _showImageArray;
@synthesize threads = _threads;
@synthesize loginUserId = _loginUserId;
@synthesize postsArray = _postsArray;
@synthesize user = _user;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commentsucceed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeImageView" object:nil];

    [self.postsArray removeAllObjects];
    [self.datalist removeAllObjects];
    [self.imageArray removeAllObjects];
    [self.voiceArray removeAllObjects];
    [self.showImageArray removeAllObjects];
    [self.tdic removeAllObjects];
    [self.voiceDataArray removeAllObjects];
    [self.tempArray removeAllObjects];
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
    [_user release]; _user=nil;
    [_postsArray release]; _postsArray=nil;
    [_loginUserId release]; _loginUserId=nil;
    [_threads release]; _threads=nil;
    [_showImageArray release]; _showImageArray=nil;
    [_videoFilePath release]; _videoFilePath=nil;
    [_headVoiceData release]; _headVoiceData=nil;
    [_tempArray release]; _tempArray=nil;
    [_voiceDataArray release]; _voiceDataArray=nil;
    [_voiceArray release]; _voiceArray=nil;
    [_imageArray release]; _imageArray=nil;
    [_voiceData release]; _voiceData=nil;
    [_datalist release]; _datalist=nil;
    [_tdic release]; _tdic=nil;
    
    
    [super dealloc];
}

- (id)initWithThread:(Thread *)threads Collect:(BOOL)collect ThreadState:(int)tState
{
    if(self = [super init])
    {
        self.threads = threads;
        self.isCollect = collect;
        self.threadStates = tState;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
}

#pragma mark 数据请求
- (void)requestPosts:(NSArray *)posts
{
    int count = posts.count;
    
    NSMutableArray *ary1 = [NSMutableArray array];
    NSMutableArray *ary2 = [NSMutableArray array];
    
    for(int i=0; i<count; i++)
    {
        Post *_tempPost = [posts objectAtIndex:i];
        ThreadContent *_content = (ThreadContent *)[_tempPost.content fetchIfNeeded];
        
        NSString *_username;
        NSString *_userUrl;
        NSNumber *_sex;
        
        User *_tempusers = nil;
        _tempusers = (User *)[_tempPost.postUser fetchIfNeeded];
        
        if (_tempusers)
        {
            if (_tempusers.nickName.length==0)
            {
                _username = @"用户已注销";
                _sex = [NSNumber numberWithInt:2];
            }
            else
            {
                _sex = [NSNumber numberWithBool:_tempusers.gender];
                _username = [NSString stringWithFormat:@"%@",_tempusers.nickName];
            }
            
            _userUrl = [NSString stringWithFormat:@"%@",_tempusers.headView.url];
        }
        else
        {
            _username = @"用户已注销";
            _userUrl = @"0";
            _sex = [NSNumber numberWithInt:2];
        }
        
      
        NSString *_sendtime = [NSString stringWithFormat:@"%@",[self calculateDate:_tempPost.createdAt]];
        int _commentNum = _tempPost.numberOfComments;
        int _supportsNum = _tempPost.numberOfSupports;
        int _commentState = _tempPost.state;
        NSString *_place;
        
        NSLog(@"%d,%@",_tempPost.place.length,_tempPost.place);
        
        if (_tempPost.place.length>0)
        {
            _place = [NSString stringWithFormat:@"%@",_tempPost.place];
        }
        else
        {
            _place = @"暂无";
        }
        

        [ary1 addObject:_tempPost];
        
        NSData *_tVoiceData = nil;
        
        _tVoiceData = [_content.voice getData];
   
        NSString *_tcontent =  _content.text;
        
        //回复文字
        if(_tcontent.length>0)
        {
            NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_place,@"place",_sex, @"gender",@"text", @"textOrvoice",_sendtime, @"sendTime",_tcontent,@"tContents",_tempPost,@"tPost", [NSNumber numberWithInt:_commentNum], @"commentNum", [NSNumber numberWithInt:_supportsNum],@"supportsNum",[NSNumber numberWithInt:_commentState], @"state", _username, @"userName", _userUrl, @"headview",_tempusers, @"user", nil];
            
            [ary2 addObject:_dic];
        }
        
        //回复语音
        if(_tVoiceData!=nil)
        {
            NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_place,@"place",_sex, @"gender",@"voice", @"textOrvoice",_sendtime, @"sendTime",_tVoiceData,@"tContents", _tempPost, @"tPost", [NSNumber numberWithInt:_commentNum], @"commentNum", [NSNumber numberWithInt:_supportsNum], @"supportsNum",[NSNumber numberWithInt:_commentState],@"state", _username, @"userName", _userUrl, @"headview",_tempusers, @"user",nil];
            
            [ary2 addObject:_dic];
        }
    }
    
    if (self.isloadMore==NO)
    {
        [self.datalist removeAllObjects];
        [self.postsArray removeAllObjects];
        
        [self.postsArray addObjectsFromArray:ary1];
        [self.datalist addObjectsFromArray:ary2];
    }
    else
    {
        [self.postsArray addObjectsFromArray:ary1];
        [self.datalist addObjectsFromArray:ary2];
    }
    
    
    [self performSelectorOnMainThread:@selector(refreshPost) withObject:nil waitUntilDone:NO];

}


- (void)refreshPost
{
    [self doneLoadingTableViewData];
    [_tableView reloadData];
    
    [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    [_activityView stopAnimating];
    
    self.isloadMore = NO;
    self.isrequest = NO;
    self.isPulldown = NO;
    
    [self hideF3HUDSucceed:@""];
}

- (void)showMoreComments:(UIButton *)sender
{
    if (self.isrequest == YES)
    {
        return;
    }
    __block typeof(self) bself = self;
    
    
    self.isrequest = YES;
    self.isloadMore = YES;
    
    [loadCommentsBtn setTitle:@"加载中" forState:UIControlStateNormal];
    [_activityView startAnimating];
    
    
    __block UIButton *__loadbtn = loadCommentsBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALThreadEngine defauleEngine] getPostsWithThread:self.threads notContainedIn:self.postsArray block:^(NSArray *posts, NSError *error) {
        
        int counts = posts.count;
        
        if(counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(requestPosts:) withObject:posts];
            
        }
        if(error)
        {
            bself.isrequest = NO;
            bself.isloadMore = NO;
        }
        
        if(counts==0 && !error)
        {
            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            [__activity stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            bself.isrequest = NO;
            bself.isloadMore = NO;
        }
        
        
    }];

}

- (void)requsetComments
{
    if (self.isrequest == YES)
    {
        return;
    }
    __block typeof(self) bself = self;
    
    
    self.isrequest = YES;
    
    
    [[ALThreadEngine defauleEngine] getPostsWithThread:self.threads notContainedIn:nil block:^(NSArray *posts, NSError *error) {
        
        int count = posts.count;
        
        if(count>0 && !error)
        {
            [bself performSelectorInBackground:@selector(requestPosts:) withObject:posts];

        }
        if(error)
        {
            bself.isrequest = NO;
            
            if(bself.isPulldown==NO)
            {
                [bself hideF3HUDError:nil];
            }
            
            [bself doneLoadingTableViewData];
        }
        
        if(count==0 && !error)
        {
            bself.isrequest = NO;
            
            if(bself.isPulldown==NO)
            {
                [bself hideF3HUDSucceed:nil];
            }
            
            [bself doneLoadingTableViewData];
        }
                
    }];

}

- (void)beginPulldownAnimation
{
    [_tableView setContentOffset:CGPointMake(0, -75) animated:YES];
    [_refreshHeaderView performSelector:@selector(egoRefreshScrollViewDidEndDragging:) withObject:_tableView afterDelay:0.4];
}

- (void)beginRefresh
{
    [self beginPulldownAnimation];
}

#pragma mark viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRefresh) name:@"commentsucceed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalImageView:) name:@"removeImageView" object:nil];
    
    showOperation = NO;
    
    self.loginUserId = [ALUserEngine defauleEngine].user.objectId;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    self.tdic = [NSMutableDictionary dictionaryWithCapacity:0];
    self.imageArray = [NSMutableArray arrayWithCapacity:0];
    self.voiceArray = [NSMutableArray arrayWithCapacity:0];
    self.voiceDataArray = [NSMutableArray arrayWithCapacity:0];
    self.tempArray = [NSMutableArray arrayWithCapacity:0];
    self.showImageArray = [NSMutableArray arrayWithCapacity:0];
    self.postsArray = [NSMutableArray arrayWithCapacity:0];
    
    
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
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"需求详情";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(235, 10, 30, 30);
    [commentBtn setImage:[UIImage imageNamed:@"回复.png"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(commentTiezi) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:commentBtn];
    
    UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
    [showLeftViewBtn setImage:[UIImage imageNamed:@"_0010_chat_返回.png"] forState:UIControlStateNormal];
    [showLeftViewBtn addTarget:self action:@selector(backToHomeView) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showLeftViewBtn];
    
    UIButton *showrRightViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showrRightViewBtn.frame = CGRectMake(283, 10, 30, 30);
    [showrRightViewBtn setImage:[UIImage imageNamed:@"_0005s_0000_louzhu.png"] forState:UIControlStateNormal];
    [showrRightViewBtn addTarget:self action:@selector(showMoreOperation:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showrRightViewBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    
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
    
    moreOperation = [[UIView alloc] init];
    moreOperation.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.85];
    [backgroundView addSubview:moreOperation];
    moreOperation.alpha = 0;
    [moreOperation release];
    
    collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(10, 10, 90, 30);
    collectBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [collectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [collectBtn addTarget:self action:@selector(beginCollect:) forControlEvents:UIControlEventTouchUpInside];
    [moreOperation addSubview:collectBtn];
    
    if(self.isCollect==YES)
    {
        [collectBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
    }
    else
    {
        [collectBtn setTitle:@"收 藏" forState:UIControlStateNormal];
    }
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(10, 45, 90, 30);
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareBtn setTitle:@"分 享" forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(beginShare:) forControlEvents:UIControlEventTouchUpInside];
    [moreOperation addSubview:shareBtn];
    
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(10, 80, 90, 30);
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setTitle:@"关 闭" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(beginClose:) forControlEvents:UIControlEventTouchUpInside];
    [moreOperation addSubview:closeBtn];
    
    if(self.threadStates==-1)
    {
        [closeBtn setTitle:@"已关闭" forState:UIControlStateNormal];
        closeBtn.userInteractionEnabled = NO;
    }
    
//    UIButton *ownerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    ownerBtn.frame = CGRectMake(10, 115, 80, 30);
//    [ownerBtn setTitle:@"楼主" forState:UIControlStateNormal];
//    [ownerBtn addTarget:self action:@selector(onlyShowOwner:) forControlEvents:UIControlEventTouchUpInside];
//    [moreOperation addSubview:ownerBtn];
    
    UIButton *reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reportBtn.frame = CGRectMake(10, 115, 90, 30);
    reportBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [reportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reportBtn setTitle:@"举 报" forState:UIControlStateNormal];
    [reportBtn addTarget:self action:@selector(reportThread:) forControlEvents:UIControlEventTouchUpInside];
    [moreOperation addSubview:reportBtn];
    
    
    if (![self.threads.postUser.objectId isEqualToString:self.loginUserId])
    {
        fromSelf = NO;
        
        [closeBtn removeFromSuperview];
        
        moreOperation.frame = CGRectMake(220, 45, 100, 120);

        reportBtn.frame = CGRectMake(10, 80, 90, 30);
    }
    else
    {
        fromSelf = YES;
        moreOperation.frame = CGRectMake(220, 45, 100, 150);
    }
    
    
    [self showF3HUDLoad:@""];
    
    
    [self performSelector:@selector(creatHeadViewReloadData) withObject:nil afterDelay:0.5];
    

}

#pragma mark 更多操作

- (void)showOperationAnimation
{
    showOperation = YES;
    [UIView animateWithDuration:0.3 animations:^{
        moreOperation.alpha = 1;
    }];
}

- (void)hideOperationAnimation
{
    showOperation = NO;
    [UIView animateWithDuration:0.3 animations:^{
        moreOperation.alpha = 0;
    }];
}

- (void)showMoreOperation:(UIButton *)sender
{
    if(showOperation==NO)
    {
        [self showOperationAnimation];
    }
    else
    {
        [self hideOperationAnimation];
    }
}

- (void)beginCollect:(UIButton *)sender
{
    [self hideOperationAnimation];
    
    
    if(![[ALUserEngine defauleEngine] isLoggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        
        return;
    }
    
    
    __block typeof(self) bself = self;
    
    if(self.isCollect==YES)
    {
        [self showF3HUDLoad:nil];
        
        __block UIButton *__collectbtn = collectBtn;
        __block UITableView *__tableview = _tableView;

        [[ALThreadEngine defauleEngine] unfaviconThread:self.threads block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHUI object:nil];

                [__collectbtn setTitle:@"收 藏" forState:UIControlStateNormal];
                
                [bself hideF3HUDSucceed:nil];
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
            
            [__tableview reloadData];
            
        }];
    }
    else
    {
        [self showF3HUDLoad:nil];
        
        __block UIButton *__collectbtn = collectBtn;
        __block UITableView *__tableview = _tableView;
        
        [[ALThreadEngine defauleEngine] faviconThread:self.threads block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHUI object:nil];
                
                [__collectbtn setTitle:@"取消收藏" forState:UIControlStateNormal];

                [bself hideF3HUDSucceed:nil];
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
            
            [__tableview reloadData];
        }];
    }
}

- (void)beginShare:(UIButton *)sender
{
    [self hideOperationAnimation];
    
//    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
//                                       defaultContent:@"默认分享内容，没内容时显示"
//                                                image:nil
//                                                title:@"ShareSDK"
//                                                  url:@"http://www.sharesdk.cn"
//                                          description:@"这是一条测试信息"
//                                            mediaType:SSPublishContentMediaTypeNews];
//    
//    [ShareSDK showShareActionSheet:nil
//                         shareList:[ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeTencentWeibo,ShareTypeQQSpace,nil]
//                           content:publishContent
//                     statusBarTips:YES
//                       authOptions:nil
//                      shareOptions: nil
//                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                if (state == SSPublishContentStateSuccess)
//                                {
//                                    NSLog(@"分享成功");
//                                }
//                                else if (state == SSPublishContentStateFail)
//                                {
//                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
//                                }
//                            }];
}

- (void)beginDelete:(UIButton *)sender
{
    [self hideOperationAnimation];
    
    
    if(self.threads)
    {
        [self showF3HUDLoad:nil];

        __block typeof(self) bself = self;

        [[ALThreadEngine defauleEngine] deleteThread:self.threads block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded && !error)
            {
                [bself hideF3HUDSucceed:nil];
              //  [bself hideHUDWithSuccess:@"成功" title:@"提示"];
                
                [bself performSelector:@selector(pulldownView) withObject:Nil afterDelay:3];
            }
            else
            {
                [bself hideF3HUDError:nil];
                //[bself hideHUDWithError:@"失败" title:@"提示"];
            }
        }];
    }

}

- (void)pulldownView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteThreadSucceed" object:Nil];

    [self.navigationController popViewControllerAnimated];
}

- (void)onlyShowOwner:(UIButton *)sender
{
    [self hideOperationAnimation];
    
    [ALThreadEngine defauleEngine] ;

}

- (void)beginClose:(UIButton *)sender
{
    
    [self hideOperationAnimation];
    
    if(self.threads)
    {
        [self showF3HUDLoad:nil];
        
        __block typeof(self) bself = self;
        
        __block UIButton *__closebtn = closeBtn;
        __block UITableView *__tableview = _tableView;
        
        [[ALThreadEngine defauleEngine] closeThread:self.threads block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded && !error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHUI object:nil];

                bself.threadStates = -1;
                [__closebtn setTitle:@"已关闭" forState:UIControlStateNormal];
                __closebtn.userInteractionEnabled = NO;
                [bself hideF3HUDSucceed:nil];
                [__tableview reloadData];
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)reportThread:(UIButton *)sender
{
    [self hideOperationAnimation];

    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    if(self.threads)
    {
        ReportThreadViewController *report = [[ReportThreadViewController alloc] initWIthThread:self.threads];
        [self.navigationController pushViewController:report AnimatedType:MLNavigationAnimationTypeOfScale];
        [report release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
    
    NSString *_tState = [tempDic objectForKey:@"textOrvoice"];
    
    
    if([_tState isEqualToString:@"text"])
    {
        CGSize contentSize = [[tempDic objectForKey:@"tContents"] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        
        return 140+contentSize.height;
    }
    
    if([_tState isEqualToString:@"voice"])
    {
        return 170;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datalist.count;
}


- (void)reloadContentView
{
    __block typeof(self) bself = self;

    [self.threads.content fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        if(object && !error)
        {
            ThreadContent *_content = (ThreadContent *)object;
            
            if(_content.images)
            {
                AVRelation *_imagePF = [_content relationforKey:@"images"];//BUG?????????
                
                [[_imagePF query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if(objects.count>0 && !error)
                    {
                        int count = objects.count;
                        for(int i=0; i<count; i++)
                        {
                            ThreadImage *_thImages = [objects objectAtIndex:i];
                            
                            AsyncImageView *_asyImageView=nil;
                            
                            CGSize imageSize = CGSizeFromString(_thImages.imageSize);
                            NSString *_imgurl = _thImages.image.url;
                            
                            if(imageSize.width>240)
                            {
                                float i = 240/imageSize.width;
                                _asyImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(70, headViewHeight, 240, imageSize.height*i) ImageState:1];
                                headViewHeight += imageSize.height*i+10;
                            }
                            else
                            {
                                float i = 240/imageSize.width;
                                
                                _asyImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(70, headViewHeight, 240, imageSize.height*i) ImageState:1];
                                headViewHeight += imageSize.height*i+10;
                            }
                            _asyImageView.defaultImage = 1;
                            _asyImageView.image = [UIImage imageNamed:@"adImage.png"];
                            _asyImageView.urlString = _imgurl;
                            [headView addSubview:_asyImageView];
                            [_asyImageView addTarget:self action:@selector(showOriginalImage:) forControlEvents:UIControlEventTouchUpInside];
                            _asyImageView.tag = bself.showImageArray.count;
                            [_asyImageView release];
                            
                            
                            [bself.showImageArray addObject:_imgurl];
                            
                            headView.frame = CGRectMake(0, 0, 320, headViewHeight+10);
                        }
                        
                        _tableView.tableHeaderView = headView;
                        
                    }
                    
                }];
            }
            if(_content.voice)
            {
                voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [voiceBtn setBackgroundImage:[UIImage imageNamed:@"info_voice.png"] forState:UIControlStateNormal];
                [voiceBtn addTarget:self action:@selector(playHeadVoice) forControlEvents:UIControlEventTouchUpInside];
                voiceBtn.userInteractionEnabled = NO;
                voiceBtn.titleLabel.font = [UIFont systemFontOfSize:8];
                voiceBtn.titleLabel.font = [UIFont systemFontOfSize:10];
                voiceBtn.frame = CGRectMake(280, 15, 47/2, 38/2);
                [headView addSubview:voiceBtn];
                
                AVFile *_voice = _content.voice;
                [_voice getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    if(data && !error)
                    {
                        bself.headVoiceData = data;
                        [voiceBtn setTitle:@"" forState:UIControlStateNormal];
                        voiceBtn.userInteractionEnabled = YES;
                    }
                    
                } progressBlock:^(int percentDone) {
                    
                    float i = percentDone/100.0;
                    
                    [voiceBtn setTitle:[NSString stringWithFormat:@"%f",i] forState:UIControlStateNormal];
                }];
            }
            if(_content.video)
            {
                videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [videoBtn setBackgroundImage:[UIImage imageNamed:@"info_video.png"] forState:UIControlStateNormal];
                videoBtn.titleLabel.font = [UIFont systemFontOfSize:8];
                [videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [videoBtn addTarget:self action:@selector(playThreadVideo) forControlEvents:UIControlEventTouchUpInside];
                videoBtn.titleLabel.font = [UIFont systemFontOfSize:10];
                videoBtn.userInteractionEnabled = YES;
                videoBtn.frame = CGRectMake(280, 50, 47/2, 38/2);
                [headView addSubview:videoBtn];
                
                AVFile *_video = _content.video;
                
                self.videoFilePath = _video.url;
            }
            
            _tableView.tableHeaderView = headView;
            
            [bself requsetComments];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
    }];
   
}

- (void)showOriginalImage:(AsyncImageView *)sender
{
    
    NSString *_imgUrl = [self.showImageArray objectAtIndex:sender.tag];
    
    if(_imgUrl)
    {
        if(showImageView==nil)
        {
            showImageView = [[ShowImageViewController alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) ImageUrl:_imgUrl Image:nil];
            [self.view addSubview:showImageView.view];
        }
    }
}

- (void)removeOriginalImageView:(NSNotification *)info
{
    [showImageView release];
    showImageView=nil;
}

#pragma mark 播放楼主视频
- (void)playThreadVideo
{
    NSLog(@"%@",self.videoFilePath);
    
    MPMoviePlayerViewController *MPVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.videoFilePath]];
    [self presentMoviePlayerViewControllerAnimated:MPVC];
    [MPVC release];
}

#pragma mark 播放回复声音
- (void)playCommentVoice:(UIButton *)sender
{
    self.voiceData=nil;
    self.voiceData = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"tContents"];
    
    if(self.voiceData==nil)
    {
        return;
    }
    
    
//    InfoCustomCell * cell = (InfoCustomCell *)[[sender superview] superview];
    
    InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
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
            InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSender.tag inSection:0]];
            [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
            [animationImgview stopAnimating];
            animationImgview.hidden = YES;
            isPlayCellVoice = NO;
            
            return;
        }
        else
        {
            InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
            [cell.voiceBtn setTitle:@"播放中" forState:UIControlStateNormal];
            [cell.voiceBtn addSubview:animationImgview];
            animationImgview.hidden = NO;

            InfoCustomCell *cell2 = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSender.tag inSection:0]];
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
    self.voiceData=nil;
    self.voiceData = self.headVoiceData;
    
    [voiceBtn setTitle:@"" forState:UIControlStateNormal];
    
    
    if(isPlayCellVoice==YES)
    {
        isPlayCellVoice=NO;
        [amrPlayer release];
        amrPlayer=nil;
        InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sender.tag inSection:0]];
        [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
    }
    
    if(isPlayHeadVoice==YES)
    {
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
    [animationImgview stopAnimating];
    animationImgview.hidden = YES;

   if(isPlayHeadVoice==YES)
   {

       isPlayHeadVoice=NO;
   }
   
   if(isPlayCellVoice==YES)
   {
       InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sender.tag inSection:0]];
       [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
       isPlayCellVoice = NO;
   }
  
    
    [amrPlayer release];
    amrPlayer=nil;
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cellidentifier1 = @"cell1";
    static NSString *Cellidentifier2 = @"cell2";

    NSMutableDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];

    NSString *_tState = [[tempDic objectForKey:@"textOrvoice"] retain];
    User *_tempuser = [tempDic objectForKey:@"user"];
    NSString *_userid = [(NSString *)_tempuser.objectId retain];
    NSString *_sendThreadUserid = [self.threads.postUser.objectId retain];
    
    int _cState = [[tempDic objectForKey:@"state"] intValue];
    
    //回复内容为文字
//    NSLog(@"func = %s",__func__);
    NSLOG_DEBUG;
    InfoCustomCell *cell = nil;
    if([_tState isEqualToString:@"text"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier1];
        
        if(cell==nil)
        {
            cell = [[[InfoCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier1] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        cell.stateLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        
        if (_cState==0)
        {
            cell.stateLabel.text = @"";
        }
        else
        {
            cell.stateLabel.text = @"最佳答案";
            cell.stateLabel.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        }
        
        cell.deleteBtn.hidden = YES;
        
        int _gender = [[tempDic objectForKey:@"gender"] intValue];
        
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
        cell.headImageView.urlString = [tempDic objectForKey:@"headview"];
        cell.headImageView.tag = indexPath.row;
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.userName.text = [tempDic objectForKey:@"userName"];
        
        cell.ownerLabel.hidden = YES;
//        NSLog(@"func = %s",__func__);
        NSLOG_DEBUG;

        
        if ([_sendThreadUserid isEqualToString:_userid])
        {
            cell.ownerLabel.hidden = NO;
            
            CGSize userNameSize = [cell.userName.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
            cell.ownerLabel.frame = CGRectMake(70+userNameSize.width+20, 23, 25, 15);
            cell.ownerLabel.text = @"楼主";
            cell.ownerLabel.font = [UIFont systemFontOfSize:10];
        }
        
        cell.timeImage.frame = CGRectMake(82, 47, 23/2, 22/2);
        cell.cityImage.frame = CGRectMake(155, 47, 19/2, 22/2);
        
        
        cell.timeLabel.text = [tempDic objectForKey:@"sendTime"];
        cell.timeLabel.frame = CGRectMake(100, 43, 100, 20);
        
        cell.cityLabel.text = [tempDic objectForKey:@"place"];
        cell.cityLabel.frame = CGRectMake(170, 43, 240, 20);
        
        NSString *_contentStr = [tempDic objectForKey:@"tContents"];
        CGSize contentSize = [_contentStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        
        cell.content.text = _contentStr;
        cell.content.frame = CGRectMake(80, 75, 220, contentSize.height);
        
        cell.floorImage.hidden = NO;
        cell.floorLabel.text = [NSString stringWithFormat:@"%d楼",indexPath.row+1];
        
        cell.commontBtn.hidden = NO;
        cell.commontBtn.frame = CGRectMake(190, 105+contentSize.height, 61/2.5, 61/2.5);
        [cell.commontBtn addTarget:self action:@selector(commontInvitation:) forControlEvents:UIControlEventTouchUpInside];
        cell.commontBtn.tag = indexPath.row;
        
        cell.commentLabel.frame = CGRectMake(220, 107+contentSize.height, 100, 20);
        cell.commentLabel.text = [NSString stringWithFormat:@"%d",[[tempDic objectForKey:@"commentNum"] intValue]];
        
        cell.goodBtn.hidden = NO;
        cell.goodBtn.frame = CGRectMake(250, 105+contentSize.height, 61/2.5, 61/2.5);
        [cell.goodBtn addTarget:self action:@selector(goodInvitation:) forControlEvents:UIControlEventTouchUpInside];
        cell.goodBtn.tag = indexPath.row;
        
        cell.dingLabel.frame = CGRectMake(280, 107+contentSize.height, 100, 20);
        cell.dingLabel.text = [NSString stringWithFormat:@"%d",[[tempDic objectForKey:@"supportsNum"] intValue]];
    
        cell.deleteBtn.hidden = YES;
        NSLOG_DEBUG;
        if([_userid isEqualToString:self.loginUserId])
        {
            cell.deleteBtn.hidden = NO;
            [cell.deleteBtn setImage:[UIImage imageNamed:@"AHSHANCHU.png"] forState:UIControlStateNormal];
            cell.deleteBtn.frame = CGRectMake(20, 105+contentSize.height, 49/2, 49/2);
            [cell.deleteBtn addTarget:self action:@selector(deleteComments:) forControlEvents:UIControlEventTouchUpInside];
            cell.deleteBtn.tag = indexPath.row;
        }
        NSLOG_DEBUG;
        if([self.loginUserId isEqualToString:self.threads.postUser.objectId] && ![_userid isEqualToString:self.loginUserId] && self.threadStates==0)
        {
            cell.deleteBtn.hidden = NO;
            [cell.deleteBtn setImage:[UIImage imageNamed:@"zuijia.png"] forState:UIControlStateNormal];
            cell.deleteBtn.frame = CGRectMake(20, 105+contentSize.height, 49/2, 49/2);
            [cell.deleteBtn addTarget:self action:@selector(bestAnswer:) forControlEvents:UIControlEventTouchUpInside];
            cell.deleteBtn.tag = indexPath.row;
        }

        
        cell.backView.frame = CGRectMake(5, 5, 310, 135+contentSize.height);
        
        return cell;
    }
    NSLOG_DEBUG;
    //回复内容为声音
    if([_tState isEqualToString:@"voice"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier2];
        
        if(cell==nil)
        {
            cell = [[[InfoCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        cell.stateLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        
        if (_cState==0)
        {
            cell.stateLabel.text = @"";
        }
        else
        {
            cell.stateLabel.text = @"最佳";
            cell.stateLabel.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        }
        
        
        cell.headImageView.hidden = NO;
        cell.headImageView.urlString = [tempDic objectForKey:@"headview"];
        cell.headImageView.tag = indexPath.row;
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        int _gender = [[tempDic objectForKey:@"gender"] intValue];
        
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
        
      

        cell.userName.text = [tempDic objectForKey:@"userName"];
        
        cell.ownerLabel.hidden = YES;
        NSLOG_DEBUG;
        if ([_sendThreadUserid isEqualToString:_userid])
        {
            cell.ownerLabel.hidden = NO;
            
            CGSize userNameSize = [cell.userName.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
            cell.ownerLabel.frame = CGRectMake(70+userNameSize.width+20, 23, 25, 15);
            cell.ownerLabel.text = @"楼主";
            cell.ownerLabel.font = [UIFont systemFontOfSize:10];
        }
        
        cell.timeImage.frame = CGRectMake(82, 47, 23/2, 22/2);
        cell.cityImage.frame = CGRectMake(155, 47, 19/2, 22/2);
 
        cell.timeLabel.text = [tempDic objectForKey:@"sendTime"];
        cell.timeLabel.frame = CGRectMake(100, 43, 100, 20);
        
        cell.cityLabel.text = [tempDic objectForKey:@"place"];
        cell.cityLabel.frame = CGRectMake(170, 43, 240, 20);
        
        cell.voiceBtn.hidden = NO;
        cell.voiceBtn.frame = CGRectMake(80, 80, 100, 30);
        [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
        
        [cell.voiceBtn addTarget:self action:@selector(playCommentVoice:) forControlEvents:UIControlEventTouchUpInside];
        cell.voiceBtn.tag = indexPath.row;
        
        cell.floorImage.hidden = NO;
        cell.floorLabel.text = [NSString stringWithFormat:@"%d楼",indexPath.row+1];
        
        cell.commontBtn.hidden = NO;
        cell.commontBtn.frame = CGRectMake(190, 135, 61/2.5, 61/2.5);
        [cell.commontBtn addTarget:self action:@selector(commontInvitation:) forControlEvents:UIControlEventTouchUpInside];
        cell.commontBtn.tag = indexPath.row;
        
        cell.commentLabel.frame = CGRectMake(220, 137, 100, 20);
        cell.commentLabel.text = [NSString stringWithFormat:@"%d",[[tempDic objectForKey:@"commentNum"] intValue]];
        
        cell.goodBtn.hidden = NO;
        cell.goodBtn.frame = CGRectMake(250, 135, 61/2.5, 61/2.5);
        [cell.goodBtn addTarget:self action:@selector(goodInvitation:) forControlEvents:UIControlEventTouchUpInside];
        cell.goodBtn.tag = indexPath.row;
        
        cell.dingLabel.frame = CGRectMake(280, 137, 100, 20);
        cell.dingLabel.text = [NSString stringWithFormat:@"%d",[[tempDic objectForKey:@"supportsNum"] intValue]];
        
        cell.deleteBtn.hidden = YES;
        NSLOG_DEBUG;
        
        if([_userid isEqualToString:self.loginUserId])
        {
            cell.deleteBtn.hidden = NO;
            [cell.deleteBtn setImage:[UIImage imageNamed:@"AHSHANCHU.png"] forState:UIControlStateNormal];
            cell.deleteBtn.frame = CGRectMake(20, 135, 49/2, 49/2);
            [cell.deleteBtn addTarget:self action:@selector(deleteComments:) forControlEvents:UIControlEventTouchUpInside];
            cell.deleteBtn.tag = indexPath.row;
        }
        
        if([self.loginUserId isEqualToString:self.threads.postUser.objectId] && ![_userid isEqualToString:self.loginUserId] && self.threadStates==0)
        {
            cell.deleteBtn.hidden = NO;
            [cell.deleteBtn setImage:[UIImage imageNamed:@"zuijia.png"] forState:UIControlStateNormal];
            cell.deleteBtn.frame = CGRectMake(20, 135, 49/2, 49/2);
            [cell.deleteBtn addTarget:self action:@selector(bestAnswer:) forControlEvents:UIControlEventTouchUpInside];
            cell.deleteBtn.tag = indexPath.row;
        }
        
        
        cell.backView.frame = CGRectMake(5, 5, 310, 165);

        
        return cell;
    }
    
    [_tState release]; _tState=nil;
    [_userid release]; _userid=nil;
    [_sendThreadUserid release]; _sendThreadUserid=nil;
    
    return cell;
}

#pragma mark 最佳答案
- (void)bestAnswer:(UIButton *)sender
{
    Post *_post = Nil;
    _post = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"tPost"];
    
    if(_post)
    {
        
        if (self.isrequest)
        {
            return;
        }
        
        self.isrequest = YES;
        
        __block typeof(self) bself = self;
        
        __block NSMutableDictionary *_dic = [self.datalist objectAtIndex:sender.tag];
        __block UITableView *__tableview = _tableView;
        
        [self showF3HUDLoad:nil];
        
        [[ALThreadEngine defauleEngine] setBestAnswernWithThread:self.threads andPost:_post block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHUI object:nil];

                bself.threadStates = 1;
                [_dic setObject:[NSNumber numberWithInt:1] forKey:@"state"];
                [bself hideF3HUDSucceed:nil];
                [__tableview reloadData];
                
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
            
            bself.isrequest=NO;
        }];
    }
    
}


#pragma mark 删除回复
- (void)deleteComments:(UIButton *)sender
{
    Post *_post = nil;
    _post = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"tPost"];
    
    if(_post)
    {
        if (self.isrequest)
        {
            return;
        }
        
        self.isrequest = YES;
        
        __block typeof(self) bself = self;

        [self showF3HUDLoad:nil];
        
        __block UITableView *__tableview = _tableView;
        
        [[ALThreadEngine defauleEngine] deletePost:_post block:^(BOOL succeeded, NSError *error) {
            
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
            
            bself.isrequest = NO;
            
        }];
    }
    
}

#pragma mark 赞回复
- (void)goodInvitation:(UIButton *)sender
{
    if(![[ALUserEngine defauleEngine] isLoggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        
        return;
    }
        
    User *_temp = nil;
    _temp = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"user"];
    
    if (!_temp)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已注销" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if(self.threadStates==-1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    __block Post *_post = nil;
    _post = [[[self.datalist objectAtIndex:sender.tag] objectForKey:@"tPost"] retain];
    
    if(_post)
    {
        if (self.isrequest)
        {
            return;
        }
        
        self.isrequest = YES;
        
        
        __block typeof(self) bself = self;

        [self showF3HUDLoad:nil];
        
        __block NSMutableDictionary *_dic = [self.datalist objectAtIndex:sender.tag];
        __block UITableView *__tableview = _tableView;
        
        ALUserEngine *engine = [ALUserEngine defauleEngine];
        [engine.user.userFavicon fetch];

        
        [[ALThreadEngine defauleEngine] sendSupportWithPost:_post block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                int num = [[_dic objectForKey:@"supportsNum"] intValue];
                [_dic setObject:[NSNumber numberWithInt:num+1] forKey:@"supportsNum"];
                [__tableview reloadData];
                
                [bself hideF3HUDSucceed:nil];
            }
            else
            {
                NSLog(@"error=%@",[error userInfo]);
                NSString *errorStr = [[error userInfo] objectForKey:@"error"];
                if (errorStr.length>0)
                {
                    [bself hideF3HUDError:nil];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:errorStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];

                }
                else
                {
                    [bself hideF3HUDError:nil];
                }
            }
            
            bself.isrequest = NO;
            [_post release];
            _post=nil;
        }];
    }
}


#pragma mark 添加footView
- (void)addFootView
{
    if(footView!=nil)
    {
        return;
    }
    
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    footView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
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

#pragma mark 创建headView
- (void)creatHeadViewReloadData
{
    ThreadContent *_content = (ThreadContent *)[self.threads.content fetchIfNeeded];

    self.user = nil;
    self.user = (User *)[self.threads.postUser fetchIfNeeded];
    
    NSString *_username;
    NSString *_userUrl;
    int _gender;
    
    if (self.user)
    {
        _username = self.user.nickName;
        _userUrl = self.user.headView.url;
        _gender = self.user.gender;
    }
    else
    {
        _username = @"该用户已注销";
        _userUrl = @"0";
        _gender = 2;
    }
    
    NSString *_ttitle = self.threads.title;
   
    NSString *_tcontent = _content.text;
    NSString *_place = self.threads.place;
    NSDate *_sendTime = self.threads.createdAt;
    NSString *_price = [NSString stringWithFormat:@"%d元",self.threads.price];
    
    ThreadFlag *_flag = self.threads.flag;
    [_flag fetchIfNeeded];
    
    NSString *_tag = _flag.name;

    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
    headView.backgroundColor = [UIColor whiteColor];
    _tableView.tableHeaderView = headView;
    [headView release];
    
    UIImageView *headImage = [[UIImageView alloc] init];
    headImage.frame = CGRectMake(0, 0, 60, 60);
    headImage.center = CGPointMake(35, 35);
    headImage.userInteractionEnabled = YES;
    
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
    
    [headView addSubview:headImage];
    [headImage release];

    AsyncImageView *headViewAsy = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 53, 53) ImageState:0];
    headViewAsy.center = CGPointMake(35, 35);
    headViewAsy.defaultImage = 0;
    headViewAsy.urlString = _userUrl;
    [headViewAsy addTarget:self action:@selector(showOwnerInfo) forControlEvents:UIControlEventTouchUpInside];
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
    
    CGSize userNameSize = [userName.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *needLabel = [[UILabel alloc] initWithFrame:CGRectMake(70+userNameSize.width+5, 11, 80, 20)];
    needLabel.backgroundColor = [UIColor clearColor];
    needLabel.font = [UIFont systemFontOfSize:14];
    needLabel.text = @"需要";
    needLabel.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [needLabel setTextAlignment:NSTextAlignmentLeft];
    [headView addSubview:needLabel];
    [needLabel release];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(70, 32, 240, 20)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:16];
    title.text = _ttitle;
    title.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [title setTextAlignment:NSTextAlignmentLeft];
    [headView addSubview:title];
    [title release];
    
    
    UIImageView *timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0002_time@2x.png"]];
    timeImage.frame = CGRectMake(72, 60, 23/2, 22/2);
    [headView addSubview:timeImage];
    [timeImage release];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 56, 100, 20)];
    timeLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont systemFontOfSize:11];
    [timeLabel setTextAlignment:NSTextAlignmentLeft];
    timeLabel.text = [self calculateDate:_sendTime];
    [headView addSubview:timeLabel];
    [timeLabel release];
    
    UIImageView *locationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0003_location.png"]];
    locationImage.frame = CGRectMake(145, 60, 19/2, 22/2);
    [headView addSubview:locationImage];
    [locationImage release];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 56, 120, 20)];
    locationLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.font = [UIFont systemFontOfSize:11];
    [locationLabel setTextAlignment:NSTextAlignmentLeft];
    locationLabel.text = _place;
    [headView addSubview:locationLabel];
    [locationLabel release];
    
    if (_place.length==0)
    {
        locationLabel.text = @"暂无";
    }
    
    
    UIImageView *classImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0004_delete-number-副#0.png"]];
    classImage.frame = CGRectMake(72, 80, 24/2, 24/2);
    [headView addSubview:classImage];
    [classImage release];
    

    UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 77, 150, 20)];
    classLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
    classLabel.backgroundColor = [UIColor clearColor];
    classLabel.font = [UIFont systemFontOfSize:11];
    [classLabel setTextAlignment:NSTextAlignmentLeft];
    classLabel.text = _tag;
    [headView addSubview:classLabel];
    [classLabel release];
    
    UIImageView *monryImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0001_about-副本-2.png"]];
    monryImage.frame = CGRectMake(72, 100, 24/2, 24/2);
    [headView addSubview:monryImage];
    [monryImage release];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 97, 150, 20)];
    moneyLabel.textColor = [UIColor redColor];
    moneyLabel.backgroundColor = [UIColor clearColor];
    moneyLabel.font = [UIFont systemFontOfSize:11];
    [moneyLabel setTextAlignment:NSTextAlignmentLeft];
    moneyLabel.text = _price;
    [headView addSubview:moneyLabel];
    [moneyLabel release];
    
    CGSize contentSize = [_tcontent sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
    
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(70, 120, 240, contentSize.height)];
    content.text = _tcontent;
    content.font = [UIFont systemFontOfSize:16];
    content.numberOfLines = 0;
    content.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [content setTextAlignment:NSTextAlignmentLeft];
    [headView addSubview:content];
    [content release];
    
    headView.frame = CGRectMake(0, 0, 320, 130+contentSize.height);
    headViewHeight = 130+contentSize.height;
    
    [self addRefreshHeaderView];
    [self addFootView];
    
    [self reloadContentView];
}


#pragma mark 显示用户信息
- (void)showOwnerInfo
{
    if (self.user)
    {
        PersonalDataViewController *person = [[PersonalDataViewController alloc] initWithUser:self.user FromSelf:fromSelf SelectFromCenter:YES];
        [self.navigationController pushViewController:person AnimatedType:MLNavigationAnimationTypeOfNone];
        [person release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已注销" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
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
        
        return;
    }
    
    BOOL froms;
//    NSLog(@"func = %s",__func__);
    if ([_tempuser.objectId isEqualToString:self.loginUserId])
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

#pragma mark - 发生源
- (void)isHeadphone
{
    UInt32 propertySize = sizeof(CFStringRef);
    CFStringRef state = nil;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute
                            ,&propertySize,&state);
    //return @"Headphone" or @"Speaker" and so on.
    //根据状态判断是否为耳机状态
//    NSLog(@"func = %s",__func__);
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



#pragma mark 返回首页
- (void)backToHomeView
{
    [self.navigationController popViewControllerAnimated];
}


#pragma mark 回复/点评
- (void)commentTiezi
{
    if(![[ALUserEngine defauleEngine] isLoggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        
        return;
    }
    
    if(self.threadStates==-1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已关闭，无法回复" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if(self.threads.isDataAvailable==1)
    {
        CommentViewController *comment = [[CommentViewController alloc] initWithThread:self.threads];
        [self.navigationController pushViewController:comment AnimatedType:MLNavigationAnimationTypeOfScale];
        [comment release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


- (void)commontInvitation:(UIButton *)sender
{
    if(![[ALUserEngine defauleEngine] isLoggedIn])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    NSMutableDictionary *_dic = [self.datalist objectAtIndex:sender.tag];
    User *_temp = nil;
    _temp = [_dic objectForKey:@"user"];
    
    if(_dic && _temp)
    {
        ShowCommentViewController *comment = [[ShowCommentViewController alloc] initWithPostDic:_dic ThreadState:self.threadStates];
        [self.navigationController pushViewController:comment AnimatedType:MLNavigationAnimationTypeOfScale];
        [comment release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户已注销，无法回复" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.isPulldown = YES;
	[self requsetComments]; //从新读取数据
}

- (void)doneLoadingTableViewData
{
    self.isPulldown = NO;
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


@end
