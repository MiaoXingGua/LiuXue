//
//  ShowMyThreadsViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-10-5.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ShowMyThreadsViewController.h"
#import "ViewData.h"
#import "CustomCell.h"
#import "InfoViewController.h"
#import "CommentCustomCell.h"
#import "NewsInfoViewController.h"

@interface ShowMyThreadsViewController ()

@end

@implementation ShowMyThreadsViewController
@synthesize titles = _titles;
@synthesize users = _users;
@synthesize datalist = _datalist;
@synthesize threadArry = _threadArry;
@synthesize collectNumArray = _collectNumArray;
@synthesize voiceData = _voiceData;

- (void)dealloc
{
    [_voiceData release]; _voiceData=nil;
    [_collectNumArray release]; _collectNumArray=nil;
    [_datalist release]; _datalist=nil;
    [_threadArry release]; _threadArry=nil;
    [_users release]; _users=nil;
    [_titles release]; _titles=nil;
    [amrPlayer release]; amrPlayer=nil;
    [animationImgview release]; animationImgview=nil;
    
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
}

- (id)initWithTitle:(NSString *)title User:(User *)user Tag:(int)tag FromSelf:(BOOL)fromself
{
    if (self = [super init])
    {
        self.titles = title;
        self.users = user;
        self.selecttag = tag;
        _fromself = fromself;
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];;
    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    self.threadArry = [NSMutableArray arrayWithCapacity:0];
    self.collectNumArray = [NSMutableArray arrayWithCapacity:0];
    
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
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
    [showLeftViewBtn setImage:[UIImage imageNamed:@"_0010_chat_返回.png"] forState:UIControlStateNormal];
    [showLeftViewBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showLeftViewBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = self.titles;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    [self showF3HUDLoad:nil];
    
    switch (self.selecttag)
    {
        //显示主题列表
        case 1:
            [self requestCollectNum];
            break;
        
        //显示回复列表
        case 2:
            [self requestCollectNum];
            break;
            
        //显示评论列表
        case 3:
            [self requestCollectNum];
            break;
            
        //显示粉丝列表
        case 4:
            [self requestFriendList];
            break;
            
        //显示关注列表
        case 5:
            [self requestFriendList];
            break;
            
        //显示互粉列表
        case 6:
            [self requestFriendList];
            break;
            
        //收藏
        case 7:
            [self requestCollects];
            break;
            
        //显示最佳答案
        case 8:
            [self requestCollectNum];
            break;
           
        //显示黑名单
        case 9:
            [self requestFriendList];
            break;
            
        default:
            break;
    }
    
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
    
    [self addRefreshHeaderView];
}


- (void)requestFriendList
{
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest = YES;
    
    __block typeof(self) bself = self;
    
    __block UITableView *__tableview = _tableView;
    
    [[ALUserEngine defauleEngine] refreashRelationWithUser:self.users block:^(NSDictionary *relationInfo, NSError *error) {
    
        if (relationInfo && !error)
        {
            int counts;
            
            NSMutableArray *ary = [NSMutableArray array];
            
            //粉丝
            if (bself.selecttag==4)
            {
                NSArray *array = [relationInfo objectForKey:@"follows"];
                
                counts = array.count;
                
                for (int i=0; i<counts; i++)
                {
                    [ary addObject:[array objectAtIndex:i]];
                }
            }
            //关注
            if (bself.selecttag==5)
            {
                NSArray *array = [relationInfo objectForKey:@"friends"];
                
                counts = array.count;
                
                for (int i=0; i<counts; i++)
                {
                    [ary addObject:[array objectAtIndex:i]];
                }
                
            }
            //互粉
            if (bself.selecttag==6)
            {
                NSArray *array = [relationInfo objectForKey:@"bilaterals"];
                
                counts = array.count;
                
                for (int i=0; i<counts; i++)
                {
                    [ary addObject:[array objectAtIndex:i]];
                }
            }
            //黑名单
            if (bself.selecttag==9)
            {
                NSArray *array = [relationInfo objectForKey:@"banList"];
                
                counts = array.count;
                
                for (int i=0; i<counts; i++)
                {
                    [ary addObject:[array objectAtIndex:i]];
                }
            }
            
            [bself.datalist removeAllObjects];

            [bself.datalist addObjectsFromArray:ary];
            
            [__tableview reloadData];
            [bself hideF3HUDSucceed:nil];
            [bself doneLoadingTableViewData];
            bself.isRequest = NO;
        }
        else
        {
            [bself hideF3HUDError:nil];
            [bself doneLoadingTableViewData];

            bself.isRequest = NO;
        }
    }];
}

//请求回复
- (void)requestPosts
{
    __block typeof(self) bself = self;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (self.isShowMore==YES)
    {
        [array addObjectsFromArray:self.threadArry];
    }

    __block UIButton *__loadbtn = showMoreBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALThreadEngine defauleEngine] getPostsWithUser:self.users notContainedIn:array block:^(NSArray *posts, NSError *error) {
        
        int counts = posts.count;
        
        if (counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(readData:) withObject:posts];
        }
        
        if (counts==0 && !error)
        {
            
            if (bself.isShowMore==YES)
            {
                [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                [__activity stopAnimating];
        
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
                
            }
            else
            {
                [bself hideF3HUDSucceed:nil];
            }
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];
        }
        
        if (error)
        {
            if (bself.isShowMore==NO)
            {
                [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                [__activity stopAnimating];

                
                [bself hideF3HUDError:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];
        }
        
        [array release];
        array=nil;
       
    }];
    
}

//请求评论
- (void)requestComments
{
    __block typeof(self) bself = self;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (self.isShowMore==YES)
    {
        [array addObjectsFromArray:self.threadArry];
    }

    __block UIButton *__loadbtn = showMoreBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALThreadEngine defauleEngine] getCommentWithUser:self.users notContainedIn:array block:^(NSArray *comments, NSError *error) {
        
        int counts = comments.count;
        
        if (counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(readData:) withObject:comments];
        }
        
        if (counts==0 && !error)
        {
            
            if (bself.isShowMore==YES)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
                
                [__activity stopAnimating];
                [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            }
            else
            {
                [bself hideF3HUDSucceed:nil];
            }
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];
        }
        
        if (error)
        {
            if (bself.isShowMore==NO)
            {
                [bself hideF3HUDError:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
                
                [__activity stopAnimating];
                [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            }
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];
        }
      
        [array release];
        array=nil;
    }];

}

//请求最佳答案
- (void)requestBestAnswers
{
    __block typeof(self) bself = self;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (self.isShowMore==YES)
    {
        [array addObjectsFromArray:self.threadArry];
    }
    
    __block UIButton *__loadbtn = showMoreBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALThreadEngine defauleEngine] getBestPostsWithUser:self.users notContainedIn:array block:^(NSArray *posts, NSError *error) {
        
        int counts = posts.count;
        
        if (counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(readData:) withObject:posts];
        }
        
        if (counts==0 && !error)
        {
            
            if (bself.isShowMore==YES)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
            else
            {
                [bself hideF3HUDSucceed:nil];
            }
        }
        
        if (error)
        {
            if (bself.isShowMore==NO)
            {
                [bself hideF3HUDError:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
        }
        
        if (bself.isShowMore==YES)
        {
            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            [__activity stopAnimating];
        }
        
        bself.isRequest = NO;
        bself.isShowMore = NO;
        [bself doneLoadingTableViewData];
        
    }];

    
    [array release];
    array=nil;
}

#pragma mark 请求主题收藏数/主题内容
- (void)requestCollectNum
{
    
    if(self.isRequest==YES)
    {
        return;
        
    }
    self.isRequest = YES;

    if (self.isShowMore==YES)
    {
        [_activityView startAnimating];
        [showMoreBtn setTitle:@"加载中" forState:UIControlStateNormal];
    }
   
    
    __block typeof(self) bself = self;
    
    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        if (self.selecttag==1)
        {
            [self requestThreads];
        }
        if (self.selecttag==2)
        {
            [self requestPosts];
        }
        if (self.selecttag==3)
        {
            [self requestComments];
        }
        if (self.selecttag==8)
        {
            [self requestBestAnswers];
        }
        
        return;
    }

    
    [[ALThreadEngine defauleEngine] getMyFaviconThreadNotContainedIn:nil block:^(NSArray *threads, NSError *error) {
        
        
        if(threads.count>0 && !error)
        {
            [bself.collectNumArray removeAllObjects];

            int count = threads.count;
            for (int i=0; i<count; i++)
            {
                Thread *_thread = [threads objectAtIndex:i];
                [bself.collectNumArray addObject:_thread.objectId];
            }
        }
        
        if (bself.selecttag==1)
        {
            [bself requestThreads];
        }
        if (bself.selecttag==2)
        {
            [bself requestPosts];
        }
        if (bself.selecttag==3)
        {
            [bself requestComments];
        }
        if (bself.selecttag==8)
        {
            [bself requestBestAnswers];
        }
        
        
    }];
}

//读取主题列表
- (void)requestThreads
{
    __block typeof(self) bself = self;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (self.isShowMore==YES)
    {
        [array addObjectsFromArray:self.threadArry];
    }
    
    __block UIButton *__loadbtn = showMoreBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALThreadEngine defauleEngine] getThreadsWithUser:self.users notContainedIn:array block:^(NSArray *threads, NSError *error) {
        
        int counts = threads.count;
        
        if (counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(readData:) withObject:threads];
        }
        
        if (counts==0 && !error)
        {
            
            if (bself.isShowMore==YES)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
                
                [__activity stopAnimating];
                [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                
            }
            else
            {
                [bself hideF3HUDSucceed:nil];
            }
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];
        }
        
        if (error)
        {
            if (bself.isShowMore==NO)
            {
                [bself hideF3HUDError:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
                
                [__activity stopAnimating];
                [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            }
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [bself doneLoadingTableViewData];
        }
        
        [array release];
        array=nil;
    }];
    
}


//读取数据
- (void)readData:(NSArray *)threads
{
    NSMutableArray *ary1 = [NSMutableArray array];
    NSMutableArray *ary2 = [NSMutableArray array];
    
    int count = threads.count;
    
    //主题
    if (self.selecttag==1)
    {
        for(int i=0; i<count; i++)
        {
            Thread *_thread = [threads objectAtIndex:i];
            User *_user = (User *)[_thread.postUser fetchIfNeeded];
            ThreadContent *_content = _thread.content;
            
            if (_thread)
            {
                [ary1 addObject:_thread];
            }
            
            NSString *_username;
            NSString *_headViewUrl;
            NSNumber *_sex;
            
            if (_user)
            {
                _username = [NSString stringWithFormat:@"%@",_user.nickName];
                _headViewUrl = [NSString stringWithFormat:@"%@",_user.headView.url];
                _sex = [NSNumber numberWithBool:_user.gender];
            }
            else
            {
                _username = @"该用户已注销";
                _headViewUrl = @"0";
                _sex = [NSNumber numberWithInt:2];
            }
            
           
            
            NSString *_tid = [NSString stringWithFormat:@"%@",_thread.objectId];
            NSString *_ttitle = [NSString stringWithFormat:@"%@",_thread.title];
           
            NSString *_tcontent = [NSString stringWithFormat:@"%@",_content.text];
            // NSString *_place = _thread.place;
            NSString *_sendTime = [NSString stringWithFormat:@"%@",[self calculateDate:_thread.createdAt]];
            NSNumber *_clickNum = [NSNumber numberWithInt:_thread.views];
            NSNumber *_threadState = [NSNumber numberWithInt:_thread.state];
            NSNumber *_commentNum = [NSNumber numberWithInt:_thread.numberOfPosts];
            
            NSNumber *_collectNum;
            
            if([self.collectNumArray containsObject:_thread.objectId])
            {
                _collectNum = [NSNumber numberWithInt:1];
            }
            else
            {
                _collectNum = [NSNumber numberWithInt:0];
            }
            
            NSMutableDictionary *_tempdic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_sex, @"gender",_ttitle,@"tTitle",_tcontent,@"threadContents",_clickNum,@"clickNum",_sendTime,@"sendtime",_tid,@"Tid",_collectNum,@"collect", _threadState, @"state",_username, @"userName", _commentNum, @"commentNum",_headViewUrl , @"headview", nil];
            
            if (_tempdic)
            {
                [ary2 addObject:_tempdic];
            }
            [_tempdic release];
            _tempdic = nil;
        }

    }
    
    //回复
    if (self.selecttag==2 || self.selecttag==8)
    {
        for(int i=0; i<count; i++)
        {
            Post *_tempPost = [threads objectAtIndex:i];
            Thread *_thread = nil;
            
            NSString *_threadtitle;
            NSNumber *_threadState;
            NSString *_threadUsername;
            NSString *_threadUserUrl;
            NSNumber *_collectNum;
            NSNumber *_sex;
            BOOL haveThread;
            
            if (_tempPost.thread)
            {
                _thread = (Thread *)[_tempPost.thread fetchIfNeeded];
                
                if (_thread.isDataAvailable==YES)
                {
                    haveThread = YES;
                    
                    User *_threaduser = (User *)[_thread.postUser fetchIfNeeded];

                    if (_threaduser)
                    {
                        _threadUsername = [NSString stringWithFormat:@"%@",_threaduser.nickName];
                        _threadUserUrl = [NSString stringWithFormat:@"%@",_threaduser.headView.url];
                        _sex = [NSNumber numberWithBool:_threaduser.gender];
                    }
                    else
                    {
                        _threadUsername = @"该用户已注销";
                        _threadUserUrl = @"0";
                        _sex = [NSNumber numberWithInt:2];
                    }
                    
                    _threadtitle = [NSString stringWithFormat:@"%@",_thread.title];
                    _threadState = [NSNumber numberWithInt:_thread.state];
                    
                    
                    if([self.collectNumArray containsObject:_thread.objectId])
                    {
                        _collectNum = [NSNumber numberWithInt:1];
                    }
                    else
                    {
                        _collectNum = [NSNumber numberWithInt:0];
                    }
                }
                else
                {
                    haveThread = NO;
                }
            }
            
            ThreadContent *_content = (ThreadContent *)[_tempPost.content fetchIfNeeded];
            
            NSString *_sendtime = [NSString stringWithFormat:@"%@",[self calculateDate:_tempPost.createdAt]];
       
            
            NSData *_tVoiceData = nil;
            
            _tVoiceData = [_content.voice getData];
            
            NSString *_tcontent = _content.text;
            
            
            [ary1 addObject:_tempPost];
            
            Forum *_forum = (Forum *)[_thread.forum fetchIfNeeded];
            
            if ([_forum.name isEqualToString:@"新闻"])
            {
                ThreadContent *_content = (ThreadContent *)[_thread.content fetchIfNeeded];
                AVRelation *_imagePF = _content.images;
                
                NSArray *_array = (NSArray *)[[_imagePF query] findObjects];
                NSMutableArray *imageAry = [NSMutableArray arrayWithCapacity:0];
                
                for (int i=0; i<_array.count; i++)
                {
                    ThreadImage *_image = [_array objectAtIndex:i];
                    
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                    [_dic setValue:_image.image.url forKey:@"imageUrl"];
                    [_dic setValue:_image.imageSize forKey:@"imageSize"];
                    [imageAry addObject:_dic];
                }
                
                //回复文字
                if(_tcontent.length>0)
                {
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sex, @"gender",@"text", @"textOrvoice",_sendtime, @"sendTime",_tcontent,@"postContents", [NSNumber numberWithBool:haveThread], @"haveThread",_threadState, @"state", @"官方发布", @"userName", _threadUserUrl, @"headview",_collectNum, @"collect", _threadtitle, @"title", _thread, @"threads",imageAry,@"imageAry",@"新闻",@"threadForum",nil];
                    
                    
                    if (_dic)
                    {
                        [ary2 addObject:_dic];
                    }
                }
                
                //回复语音
                else if(_tVoiceData!=nil)
                {
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sex, @"gender",@"voice", @"textOrvoice",_sendtime, @"sendTime",_tVoiceData,@"postContents", [NSNumber numberWithBool:haveThread], @"haveThread", _threadState, @"state", @"官方发布", @"userName", _threadUserUrl, @"headview",_collectNum, @"collect", _threadtitle, @"title", _thread, @"threads",imageAry,@"imageAry",@"新闻",@"threadForum",nil];
                    
                    if (_dic)
                    {
                        [ary2 addObject:_dic];
                    }
                }
            }
            else
            {
                //回复文字
                if(_tcontent.length>0)
                {
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sex, @"gender",@"text", @"textOrvoice",_sendtime, @"sendTime",_tcontent,@"postContents", [NSNumber numberWithBool:haveThread], @"haveThread",_threadState, @"state", _threadUsername, @"userName", _threadUserUrl, @"headview",_collectNum, @"collect", _threadtitle, @"title", _thread, @"threads",@"用户",@"threadForum",nil];
                    
                    
                    if (_dic)
                    {
                        [ary2 addObject:_dic];
                    }
                }
                
                //回复语音
                else if(_tVoiceData!=nil)
                {
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sex, @"gender",@"voice", @"textOrvoice",_sendtime, @"sendTime",_tVoiceData,@"postContents", [NSNumber numberWithBool:haveThread], @"haveThread", _threadState, @"state", _threadUsername, @"userName", _threadUserUrl, @"headview",_collectNum, @"collect", _threadtitle, @"title", _thread, @"threads",@"用户",@"threadForum",nil];
                    
                    if (_dic)
                    {
                        [ary2 addObject:_dic];
                    }
                }

            }
        }
    }
    
    //评论
    if (self.selecttag==3)
    {
        for(int i=0; i<count; i++)
        {
            Comment *_comments = [threads objectAtIndex:i];
            
            Post *_post = (Post *)[_comments.post fetchIfNeeded];
            
            Thread *_thread=nil;
            User *_postuser=nil;
            ThreadContent *_postcontent=nil;
            ThreadContent *_commentcontent=nil;
            NSData *_commentVoiceData = nil;
            NSString *_commentText=nil;
            NSString *_tcontent = nil;
            
            BOOL haveThread;
            BOOL havePost;
            
            NSString *_username;
            NSString *_userurl;
            NSNumber *_threadState;
            NSNumber *_collectNum;
            NSNumber *_sex;
            
            [ary1 addObject:_comments];

            
            if (_post.isDataAvailable==1)
            {
                havePost = YES;
                
                if (_post.thread)
                {
                    _thread = (Thread *)[_post.thread fetchIfNeeded];
                    
                    if (_thread.isDataAvailable==1)
                    {
                        haveThread = YES;
                        
                        _threadState = [NSNumber numberWithInt:_thread.state];
                        
                        if([self.collectNumArray containsObject:_thread.objectId])
                        {
                            _collectNum = [NSNumber numberWithInt:1];
                        }
                        else
                        {
                            _collectNum = [NSNumber numberWithInt:0];
                        }
                    }
                    else
                    {
                        haveThread = NO;
                    }
                }
                
                
                if (_post.postUser)
                {
                    _postuser = (User *)[_post.postUser fetchIfNeeded];
                    
                    if (_postuser)
                    {
                        _username = [NSString stringWithFormat:@"%@",_postuser.nickName];
                        _userurl = [NSString stringWithFormat:@"%@",_postuser.headView.url];
                        _sex = [NSNumber numberWithBool:_postuser.gender];
                    }
                    else
                    {
                        _username = @"该用户已注销";
                        _userurl = @"0";
                        _sex = [NSNumber numberWithInt:2];
                    }
                }
             
                
                if (_post.content)
                {
                    _postcontent = (ThreadContent *)[_post.content fetchIfNeeded];
                    
                    _tcontent = _postcontent.text;
                    
                    if (_tcontent.length<=0)
                    {
                        _tcontent = @"[语音回复]";
                    }
                }
                
                if (_comments.content)
                {
                    _commentcontent = (ThreadContent *)[_comments.content fetchIfNeeded];
                    _commentText = _comments.content.text;
                    _commentVoiceData = [_comments.content.voice getData];
                }

            }
            else
            {
                havePost = NO;
            }
            
            NSString *_sendtime = [NSString stringWithFormat:@"%@",[self calculateDate:_comments.createdAt]];
            
            NSMutableDictionary *_dic = [[NSMutableDictionary alloc] init];
            [_dic setValue:_sex forKey:@"gender"];
            [_dic setValue:_sendtime forKey:@"sendTime"];
            [_dic setValue:_tcontent forKey:@"postContents"];
            [_dic setValue:_username forKey:@"userName"];
            [_dic setValue:_userurl forKey:@"headview"];
            [_dic setValue:[NSNumber numberWithBool:haveThread] forKey:@"haveThread"];
            [_dic setValue:[NSNumber numberWithBool:havePost] forKey:@"havePost"];
            [_dic setValue:_thread forKey:@"threads"];
            [_dic setValue:_collectNum forKey:@"collect"];
            [_dic setValue:_threadState forKey:@"state"];
            
            if (havePost==YES)
            {
                //回复文字
                if(_commentText.length>0)
                {
                    [_dic setValue:@"text" forKey:@"textOrvoice"];
                    [_dic setValue:_commentText forKey:@"commentContents"];
                
                }
                //回复语音
                else
                {
                    [_dic setValue:@"voice" forKey:@"textOrvoice"];
                    [_dic setValue:_commentVoiceData forKey:@"commentContents"];
     
                }
                
                if (_dic)
                {
                    [ary2 addObject:_dic];
                }
            }
        }
    }
    

    if (self.isShowMore==NO)
    {
        [self.datalist removeAllObjects];
        [self.threadArry removeAllObjects];
    }

    [self.threadArry addObjectsFromArray:ary1];
    [self.datalist addObjectsFromArray:ary2];
    
    
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];

}

- (void)refreshUI
{
    if (self.isShowMore==YES)
    {
        [showMoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
        [_activityView stopAnimating];
    }
    self.isRequest = NO;
    self.isShowMore = NO;
    
    [self addFootView];
    [_tableView reloadData];
    
    [self hideF3HUDSucceed:nil];
    [self doneLoadingTableViewData];
}

#pragma mark 添加footView
- (void)addFootView
{
    if(footView!=nil)
    {
        [footView removeFromSuperview];
        footView=nil;
    }
    
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    footView.backgroundColor = [UIColor clearColor];
    
    showMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showMoreBtn.frame = CGRectMake(0, 0, 280, 40);
    [showMoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    [showMoreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    showMoreBtn.center = CGPointMake(160, 30);
    [showMoreBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [showMoreBtn addTarget:self action:@selector(showMoreThreads:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:showMoreBtn];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(0, 0, 20, 20);
    _activityView.center = CGPointMake(100, 20);
    [showMoreBtn addSubview:_activityView];
    [_activityView release];
    
    _tableView.tableFooterView = footView;
    [footView release];
}

- (void)showEditBtn
{
    if(isEdit==NO)
    {
        [editBtn setTitle:@"完成" forState:UIControlStateNormal];
        isEdit = YES;
        [_tableView reloadData];
    }
    else
    {
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        isEdit = NO;
        [_tableView reloadData];
    }
    
}

#pragma mark CollectNews 收藏信息
- (void)collectNews:(UIButton *)sender
{
    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (self.isCollect==YES)
    {
        return;
    }
    
    self.isCollect = YES;
    
    Thread *_thread = [self.threadArry objectAtIndex:sender.tag];
    __block NSMutableDictionary *_dic = [self.datalist objectAtIndex:sender.tag];
    
    __block typeof(self) bself = self;
    
    __block UITableView *__tableview = _tableView;
    
    if([[_dic objectForKey:@"collect"] intValue]==0)
    {
        
        [self showF3HUDLoad:nil];
        
        
        [[ALThreadEngine defauleEngine] faviconThread:_thread block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [_dic setObject:[NSNumber numberWithInt:1] forKey:@"collect"];
                
                [bself hideF3HUDSucceed:nil];
                
                [__tableview reloadData];
                
            }
            else
            {
                NSString *errerStr = [[error userInfo] objectForKey:@"error"];
                NSLog(@"%@",error);
                [bself hideF3HUDError:nil];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:errerStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
            
            bself.isCollect = NO;
            
        }];
        
    }
    else
    {
        [self showF3HUDLoad:nil];
        
        [[ALThreadEngine defauleEngine] unfaviconThread:_thread block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [_dic setObject:[NSNumber numberWithInt:0] forKey:@"collect"];
                
                [bself hideF3HUDSucceed:nil];
                
                [__tableview reloadData];
                
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
            
            bself.isCollect = NO;
        }];
    }
    
    
}


- (void)deleteCollect:(UIButton *)sender
{
    [self showF3HUDLoad:nil];
    
    Thread *_temp = nil;
    _temp = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"thread"];
    
    if(_temp)
    {
        __block typeof(self) bself = self;
        
        __block UITableView *__tableview = _tableView;
        
        [[ALThreadEngine defauleEngine] unfaviconThread:_temp block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [bself.datalist removeObjectAtIndex:sender.tag];
                
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
    
}

- (void)downloadCollects:(NSArray *)array
{
    NSMutableArray *ary1 = [NSMutableArray array];
    NSMutableArray *ary2 = [NSMutableArray array];

    for (int i=0; i<array.count; i++)
    {
        Thread *_thread = [array objectAtIndex:i];
        User *_user = (User *)[_thread.postUser fetchIfNeeded];
        
        NSLog(@"forum.name=%@",_thread.forum.name);
        
        NSString *_username = _user.nickName;
        NSString *_tid = _thread.objectId;
        NSString *_ttitle = _thread.title;
        //   NSString *_place = _thread.place;
        NSString *_sendTime = [self calculateDate:_thread.createdAt];
        NSNumber *_state = [NSNumber numberWithInt:_thread.state];
        NSString *_threadForum = [NSString stringWithFormat:@"%@",_thread.forum.name];
        
        NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
        [_dic setValue:_tid forKey:@"threadId"];
        [_dic setValue:_ttitle forKey:@"tTitle"];
        [_dic setValue:_sendTime forKey:@"sendtime"];
        [_dic setValue:_thread forKey:@"thread"];
        [_dic setValue:_state forKey:@"state"];
        [_dic setValue:_username forKey:@"userName"];
        [_dic setValue:@"1" forKey:@"collect"];
        [_dic setValue:_threadForum forKey:@"threadForum"];
        
        if ([_thread.forum.name isEqualToString:@"新闻"])
        {
            ThreadContent *_content = (ThreadContent *)[_thread.content fetchIfNeeded];
            AVRelation *_imagePF = _content.images;
            
            NSArray *_array = (NSArray *)[[_imagePF query] findObjects];
            NSMutableArray *imageAry = [NSMutableArray arrayWithCapacity:0];
            
            for (int i=0; i<_array.count; i++)
            {
                ThreadImage *_image = [_array objectAtIndex:i];
                
                NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                [_dic setValue:_image.image.url forKey:@"imageUrl"];
                [_dic setValue:_image.imageSize forKey:@"imageSize"];
                [imageAry addObject:_dic];
            }
            
            [_dic setValue:imageAry forKey:@"imageAry"];
        }
        
        if (_dic)
        {
            [ary2 addObject:_dic];
        }
        
        if (_thread)
        {
            [ary1 addObject:_thread];
        }
    }
    
    if (self.isShowMore==NO)
    {
        [self.threadArry removeAllObjects];
        [self.datalist removeAllObjects];
    }

    
    [self.threadArry addObjectsFromArray:ary1];
    [self.datalist addObjectsFromArray:ary2];
    
    [self performSelectorOnMainThread:@selector(refreshCollects) withObject:nil waitUntilDone:NO];
    
  
}

- (void)refreshCollects
{
    if (self.isShowMore==YES)
    {
        [_activityView stopAnimating];
        [showMoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    }
    
    [_tableView reloadData];
    
    [self addFootView];
    
    [self doneLoadingTableViewData];
    [self hideF3HUDSucceed:nil];
    
    self.isRequest = NO;
    self.isShowMore = NO;
}

- (void)requestCollects
{
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest = YES;
    
    __block typeof(self) bself = self;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (self.isShowMore==YES)
    {
        [_activityView startAnimating];
        [showMoreBtn setTitle:@"加载中" forState:UIControlStateNormal];
        
        [array addObjectsFromArray:self.threadArry];
    }
  
    __block UIButton *__loadbtn = showMoreBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    __block UIButton *__edit = editBtn;
    
    [[ALThreadEngine defauleEngine] getFaviconThreadWithUser:self.users notContainedIn:array block:^(NSArray *threads, NSError *error)
     {
         int counts = threads.count;
         
         if (counts>0 && !error)
         {
             [bself performSelectorInBackground:@selector(downloadCollects:) withObject:threads];
         }
        
         if(counts==0 && !error)
         {
             if (bself.isShowMore==YES)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                 [alert show];
                 [alert release];
                 alert=nil;
                 
                 [__activity stopAnimating];
                 [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
             }
             else
             {
                 __edit.userInteractionEnabled = NO;
                 [bself hideF3HUDSucceed:nil];
             }
             
             bself.isRequest = NO;
             bself.isShowMore = NO;
             [bself hideF3HUDSucceed:nil];
             [bself doneLoadingTableViewData];
            
         }
         
         if (error)
         {
             if (bself.isShowMore==YES)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                 [alert show];
                 [alert release];
                 alert=nil;
                 
                 [__activity stopAnimating];
                 [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
             }
             else
             {
                 __edit.userInteractionEnabled = NO;
                 [bself hideF3HUDError:nil];
             }
             
             bself.isRequest = NO;
             bself.isShowMore = NO;
             [bself hideF3HUDError:nil];
             [bself doneLoadingTableViewData];
         }
         
         [array release];
         array = nil;

     }];

    
}

#pragma mark 显示更多消息
- (void)showMoreThreads:(UIButton *)sender
{
    self.isShowMore = YES;
    
    if (self.selecttag==1 || self.selecttag==2 || self.selecttag==3 || self.selecttag==8)
    {
        [self requestCollectNum];
    }
    
    if (self.selecttag==7)
    {
        [self requestCollects];
    }
}


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //主题
    if (self.selecttag==1)
    {
        NSDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        NSString *contentste = [tempDic objectForKey:@"threadContents"];
        CGSize Size = [contentste sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        
        return 60+Size.height+40;
    }
    
    //回复
    if (self.selecttag==2 || self.selecttag==8)
    {
        NSDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        NSString *threadState = [tempDic objectForKey:@"textOrvoice"];
        BOOL haveThread = [[tempDic objectForKey:@"haveThread"] boolValue];
        
        //有主题
        if (haveThread)
        {
            if ([threadState isEqualToString:@"text"])
            {
                NSString *contentste = [tempDic objectForKey:@"postContents"];
                CGSize Size = [contentste sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                
                return 100+Size.height;
            }
            else
            {
                return 130;
            }
        }
        //无主题
        else
        {
            if ([threadState isEqualToString:@"text"])
            {
                NSString *contentste = [tempDic objectForKey:@"postContents"];
                CGSize Size = [contentste sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                
                return 70+Size.height;
            }
            else
            {
                return 100;
                
            }
        }
       
        
    }
    
    //评论
    if (self.selecttag==3)
    {
        NSDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        
        BOOL havePost = [[tempDic objectForKey:@"havePost"] boolValue];
        
        
        NSString *threadState = [tempDic objectForKey:@"textOrvoice"];

        //有回复
        if (havePost==YES)
        {
            
            
            if ([threadState isEqualToString:@"text"])
            {
                NSString *contentste = [tempDic objectForKey:@"postContents"];
                CGSize postSize = [contentste sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
                
                NSString *commentcontent = [tempDic objectForKey:@"commentContents"];;
                CGSize commentSize = [commentcontent sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                
                return 90+postSize.height+commentSize.height;
            }
            else
            {
                NSString *contentste = [tempDic objectForKey:@"postContents"];
                CGSize postSize = [contentste sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
                
                
                return 120+postSize.height;
                
            }

        }
        //无回复
        else
        {
            if ([threadState isEqualToString:@"text"])
            {
                
                NSString *commentcontent = [tempDic objectForKey:@"commentContents"];;
                CGSize commentSize = [commentcontent sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:0];
                
                return 80+commentSize.height;
            }
            else
            {
    
                return 100;
                
            }
        }
        
    }
    
    if (self.selecttag==4 || self.selecttag==5 || self.selecttag==6 || self.selecttag==9)
    {
        return 70;
    }
    
    if (self.selecttag==7)
    {
        return 80;
    }
    
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.datalist.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cellidentifier1 = @"cell1";
    
    static NSString *Cellidentifier2_1 = @"cell2_1";
    static NSString *Cellidentifier2_2 = @"cell2_2";
    
    static NSString *Cellidentifier3_1 = @"cell3_1";
    static NSString *Cellidentifier3_2 = @"cell3_2";

    static NSString *Cellidentifier4 = @"cell4";

    static NSString *Cellidentifier7 = @"cell7";

    //主题
    if (self.selecttag==1)
    {

        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier1];
        if(cell==nil)
        {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier1] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSMutableDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        
        //-1:关闭 0:一般 1:完成
        
        int _state = [[tempDic objectForKey:@"state"] intValue];
        cell.stateLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        
        if(_state==0)
        {
            cell.stateLabel.text = @"未解决";
        }
        if(_state==1)
        {
            cell.stateLabel.text = @"已解决";
            cell.stateLabel.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        }
        if(_state==-1)
        {
            cell.stateLabel.text = @"已关闭";
            cell.stateLabel.textColor = [UIColor redColor];
        }
        
        
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
            cell.headCoverImage.image = [UIImage imageNamed:@"图层-20.png"];
        }
        cell.headCoverImage.hidden = NO;
        
        cell.headImageView.hidden = NO;
        
        cell.headImageView.urlString = [tempDic objectForKey:@"headview"];
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.headImageView.tag = indexPath.row;
        
        cell.userName.text = [tempDic objectForKey:@"userName"];
        CGSize userNameSize = [cell.userName.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        cell.needText.frame = CGRectMake(70+userNameSize.width+10, 10, 50,20);
        cell.needText.hidden = NO;
        
        cell.title.text = [tempDic objectForKey:@"tTitle"];
        
        cell.content.text = [tempDic objectForKey:@"threadContents"];
        CGSize contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        cell.content.frame = CGRectMake(70, 60, 240, contentSize.height+10);
        
        cell.timeImage.hidden = NO;
        cell.timeImage.frame = CGRectMake(70, 70+contentSize.height+10, 23/2, 22/2);
        
        cell.sendTime.text = [tempDic objectForKey:@"sendtime"];
        cell.sendTime.frame = CGRectMake(85, 70+contentSize.height+6, 100, 20);
        
        //        cell.city.text = [temp objectAtIndex:5];
        //        cell.city.frame = CGRectMake(130, 70+contentSize.height+6, 100, 20);
        
        cell.friendImage.hidden = NO;
        cell.friendImage.frame = CGRectMake(221, 70+contentSize.height+11, 26/2, 17/2);
        
        cell.friendNum.frame = CGRectMake(240, 70+contentSize.height+6, 50, 20);
        
        
        int _clickNum = [[tempDic objectForKey:@"clickNum"] intValue];
        
        if(_clickNum>=10000)
        {
            int num = _clickNum/10000;
            cell.friendNum.text = [NSString stringWithFormat:@"%d万",num];
        }
        else
        {
            cell.friendNum.text = [NSString stringWithFormat:@"%d",_clickNum];
        }
        
        int _commentNum = [[tempDic objectForKey:@"commentNum"] intValue];
        
        cell.collectImage.hidden = NO;
        cell.collectImage.frame = CGRectMake(270, 70+contentSize.height+12, 18/2, 18/2);
        
        cell.collectNum.frame = CGRectMake(285, 70+contentSize.height+6, 50, 20);
        if(_commentNum>=10000)
        {
            int num = _commentNum/10000;
            cell.collectNum.text = [NSString stringWithFormat:@"%d万",num];
        }
        else
        {
            cell.collectNum.text = [NSString stringWithFormat:@"%d",_commentNum];
        }
        
        
        cell.collect.hidden = NO;
        
        if([[tempDic objectForKey:@"collect"] intValue]==1)
        {
            [cell.collect setImage:[UIImage imageNamed:@"_0021_Small-favourit@2x.png"] forState:UIControlStateNormal];
        }
        if([[tempDic objectForKey:@"collect"] intValue]==0)
        {
            [cell.collect setImage:[UIImage imageNamed:@"_0020_unfavourit@2x.png"] forState:UIControlStateNormal];
        }
        
        
        [cell.collect addTarget:self action:@selector(collectNews:) forControlEvents:UIControlEventTouchUpInside];
        cell.collect.tag = indexPath.row;
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.center = CGPointMake(160, 60+contentSize.height+39.5);
        
        return cell;

    }
    
    
    //回复
    if (self.selecttag==2 || self.selecttag==8)
    {
        NSMutableDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        
        BOOL havePost = [[tempDic objectForKey:@"haveThread"] boolValue];
        
        
        if (havePost==YES)
        {
            
            CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier2_1];
            if(cell==nil)
            {
                cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier2_1] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            //-1:关闭 0:一般 1:完成
            
            int _state = [[tempDic objectForKey:@"state"] intValue];
            cell.stateLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
            
            if(_state==0)
            {
                cell.stateLabel.text = @"未解决";
            }
            if(_state==1)
            {
                cell.stateLabel.text = @"已解决";
                cell.stateLabel.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
            }
            if(_state==-1)
            {
                cell.stateLabel.text = @"已关闭";
                cell.stateLabel.textColor = [UIColor redColor];
            }
            
            cell.stateLabel.frame = CGRectMake(230, 10, 70, 20);
            
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
                cell.headCoverImage.image = [UIImage imageNamed:@"图层-20.png"];
            }
            
            cell.headCoverImage.hidden = NO;
            
            cell.headImageView.hidden = NO;
            
            cell.headImageView.urlString = [tempDic objectForKey:@"headview"];
            [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            cell.headImageView.tag = indexPath.row;
            
            cell.userName.text = [tempDic objectForKey:@"userName"];
            cell.userName.frame = CGRectMake(70, 12, 240, 20);
            
            cell.title.text = [tempDic objectForKey:@"title"];
            cell.title.frame = CGRectMake(70, 38, 230, 20);
            
            
            CGSize contentSize;
            NSString *postsState = [tempDic objectForKey:@"textOrvoice"];
            if ([postsState isEqualToString:@"text"])
            {
                cell.voiceBtn.hidden = YES;
                cell.content.text = [NSString stringWithFormat:@"回复: %@",[tempDic objectForKey:@"postContents"]];
                contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                cell.content.frame = CGRectMake(70, 60, 220, contentSize.height+10);
            }
            else
            {
                cell.content.hidden = YES;
                cell.voiceBtn.hidden = NO;
                cell.voiceBtn.frame = CGRectMake(70, 65, 100, 30);
                [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
                [cell.voiceBtn addTarget:self action:@selector(playCellVoice:) forControlEvents:UIControlEventTouchUpInside];
                cell.voiceBtn.tag = indexPath.row;
                contentSize = CGSizeMake(0, 30);
            }
            
            
            cell.timeImage.hidden = NO;
            cell.timeImage.frame = CGRectMake(70, 71+contentSize.height+5, 23/2, 22/2);
            
            cell.sendTime.text = [tempDic objectForKey:@"sendTime"];
            cell.sendTime.frame = CGRectMake(85, 67+contentSize.height+5, 100, 20);
            
            cell.homeCellLine.hidden = NO;
            cell.homeCellLine.center = CGPointMake(160, 100+contentSize.height);
            
            return cell;
        }
        else
        {
            
            CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier2_2];
            if(cell==nil)
            {
                cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier2_2] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            cell.headCoverImage.hidden = YES;
            cell.headImageView.hidden = YES;
            cell.userName.hidden = YES;
            
            cell.title.text = @"该主题已被删除";
            cell.title.frame = CGRectMake(70, 10, 200, 20);
            
            CGSize contentSize;
            NSString *postsState = [tempDic objectForKey:@"textOrvoice"];
            
            cell.voiceBtn.hidden = YES;

            if ([postsState isEqualToString:@"text"])
            {
                cell.content.text = [NSString stringWithFormat:@"回复: %@",[tempDic objectForKey:@"postContents"]];
                contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                cell.content.frame = CGRectMake(70, 60, 220, contentSize.height+10);
            }
            else
            {
                cell.content.hidden = YES;
                cell.voiceBtn.hidden = NO;
                cell.voiceBtn.frame = CGRectMake(70, 65, 100, 30);
                [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
                [cell.voiceBtn addTarget:self action:@selector(playCellVoice:) forControlEvents:UIControlEventTouchUpInside];
                cell.voiceBtn.tag = indexPath.row;
                contentSize = CGSizeMake(0, 30);
            }
            
            
            cell.timeImage.hidden = NO;
            cell.timeImage.frame = CGRectMake(70, 71+contentSize.height+5, 23/2, 22/2);
            
            cell.sendTime.text = [tempDic objectForKey:@"sendTime"];
            cell.sendTime.frame = CGRectMake(85, 67+contentSize.height+5, 100, 20);
            
            cell.homeCellLine.hidden = NO;
            cell.homeCellLine.center = CGPointMake(160, 100+contentSize.height);
            
            return cell;

        }
    }
    
    
    //评论
    if (self.selecttag==3)
    {
        NSMutableDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        
        BOOL havePost = [[tempDic objectForKey:@"havePost"] boolValue];
        
    
        //有回复
        if (havePost==YES)
        {

            CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier3_1];
            if(cell==nil)
            {
                cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier3_1] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            cell.cellbackground.hidden=YES;
            
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
                cell.headCoverImage.image = [UIImage imageNamed:@"图层-20.png"];
            }
            cell.headCoverImage.hidden = NO;
            cell.headImageView.hidden = NO;
            
            cell.headImageView.urlString = [tempDic objectForKey:@"headview"];
            [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            cell.headImageView.tag = indexPath.row;
            
            cell.userName.text = [tempDic objectForKey:@"userName"];
            cell.userName.frame = CGRectMake(70, 12, 240, 20);
            
            
            cell.title.text = [tempDic objectForKey:@"postContents"];
            cell.title.numberOfLines=0;
            

            CGSize postSize = [cell.title.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
            
            cell.title.frame = CGRectMake(70, 40, 200, postSize.height);
            
            CGSize contentSize;
            NSString *postsState = [tempDic objectForKey:@"textOrvoice"];
            
            cell.voiceBtn.hidden = YES;

            if ([postsState isEqualToString:@"text"])
            {
                cell.content.text = [NSString stringWithFormat:@"回复:%@",[tempDic objectForKey:@"commentContents"]];
                contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                cell.content.frame = CGRectMake(70, 40+postSize.height+10, 220, contentSize.height+10);
            }
            else
            {
                cell.voiceBtn.hidden = NO;
                cell.content.text=@"回复:";
                cell.content.frame = CGRectMake(70, 40+postSize.height+10, 50, 30);
                cell.voiceBtn.frame = CGRectMake(120, 40+postSize.height+10, 100, 30);
                [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
                [cell.voiceBtn addTarget:self action:@selector(playCellVoice:) forControlEvents:UIControlEventTouchUpInside];
                cell.voiceBtn.tag = indexPath.row;
                contentSize = CGSizeMake(0, 30);
            }
     
            cell.timeImage.hidden = NO;
            cell.timeImage.frame = CGRectMake(70, 70+postSize.height+contentSize.height, 23/2, 22/2);
            
            cell.sendTime.text = [tempDic objectForKey:@"sendTime"];
            cell.sendTime.frame = CGRectMake(85, 66+postSize.height+contentSize.height, 100, 20);
            
            cell.homeCellLine.hidden = NO;
            cell.homeCellLine.center = CGPointMake(160, 90+postSize.height+contentSize.height);
            
            return cell;
        }
        //没有回复
        else
        {

            CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier3_2];
            if(cell==nil)
            {
                cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier3_2] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            cell.cellbackground.hidden=YES;
            cell.headCoverImage.hidden = YES;
            cell.headImageView.hidden = YES;
            cell.userName.hidden = YES;
            
            cell.title.text = @"该回复已被删除";
            cell.title.frame = CGRectMake(70, 10, 200, 20);
            
            CGSize contentSize;
            NSString *postsState = [tempDic objectForKey:@"textOrvoice"];
            
            if ([postsState isEqualToString:@"text"])
            {
                cell.voiceBtn.hidden = YES;
                cell.content.text = [NSString stringWithFormat:@"回复:%@",[tempDic objectForKey:@"commentContents"]];
                contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
                cell.content.frame = CGRectMake(70, 40, 200, contentSize.height+10);
                cell.content.font = [UIFont systemFontOfSize:16];
            }
            else
            {
                cell.content.hidden = YES;
                cell.voiceBtn.hidden = NO;
                cell.content.text=@"回复:";
                cell.content.frame = CGRectMake(70, 40, 50, 30);
                cell.voiceBtn.frame = CGRectMake(100, 40, 100, 30);
                [cell.voiceBtn setBackgroundImage:[UIImage imageNamed:@"playvoice_001.png"] forState:UIControlStateNormal];
                [cell.voiceBtn addTarget:self action:@selector(playCellVoice:) forControlEvents:UIControlEventTouchUpInside];
                cell.voiceBtn.tag = indexPath.row;
                contentSize = CGSizeMake(0, 30);
            }
            
            
            cell.timeImage.hidden = NO;
            cell.timeImage.frame = CGRectMake(70, 40+contentSize.height+5, 23/2, 22/2);
            
            cell.sendTime.text = [tempDic objectForKey:@"sendTime"];
            cell.sendTime.frame = CGRectMake(85, 36+contentSize.height+5, 100, 20);
            
            cell.homeCellLine.hidden = NO;
            cell.homeCellLine.center = CGPointMake(160, 70+contentSize.height);
            
            return cell;
        }
    }

    //粉丝 关注 互粉 黑名单
    if (self.selecttag==4 || self.selecttag==5 || self.selecttag==6 || self.selecttag==9)
    {
        
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier4];
        if(cell==nil)
        {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier4] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        User *_tempuser = [self.datalist objectAtIndex:indexPath.row];
        
        int _gender = _tempuser.gender;
        
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
            cell.headCoverImage.image = [UIImage imageNamed:@"图层-20.png"];
        }
        
        cell.headCoverImage.hidden = NO;
        cell.headCoverImage.center = CGPointMake(30, 35);
        
        cell.headImageView.hidden = NO;
        cell.headImageView.urlString = _tempuser.headView.url;
        cell.headImageView.center = CGPointMake(30, 35);

        cell.userName.hidden = NO;
        cell.userName.text = _tempuser.nickName;
        cell.userName.frame = CGRectMake(60, 25, 240, 20);
        cell.userName.font = [UIFont systemFontOfSize:18];
        
        cell.content.text = _tempuser.signature;
        
        cell.content.hidden = YES;
        
        if (cell.content.text.length>0)
        {
            cell.content.hidden = NO;
            
            CGSize contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(1000, 40) lineBreakMode:0];
            cell.content.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
            cell.content.textColor = [UIColor whiteColor];
            cell.content.numberOfLines = 0;
            cell.content.textAlignment = NSTextAlignmentCenter;
            cell.content.layer.cornerRadius = 6;
                        
            if (contentSize.width>120)
            {
                CGSize contentSize2 = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(120, 1000) lineBreakMode:0];
                
                if (contentSize2.height>40)
                {
                    cell.content.frame = CGRectMake(320-120-15, 0, 125, 45);
                    cell.content.center = CGPointMake(cell.content.center.x, 35);
                }
                else
                {
                    cell.content.frame = CGRectMake(320-120-15, 0, 125, contentSize2.height+10);
                    cell.content.center = CGPointMake(cell.content.center.x, 35);
                }
            }
            else
            {
                cell.content.frame = CGRectMake(320-contentSize.width-25, 0, contentSize.width+15, contentSize.height+10);
                
                cell.content.center = CGPointMake(cell.content.center.x, 35);
            }
        }
   
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.center = CGPointMake(160, 70);
        
        return cell;

    }
    
    //收藏
    if (self.selecttag==7)
    {

        CommentCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier7];
        
        if(cell==nil)
        {
            cell = [[[CommentCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier7] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        
        NSDictionary *temp = [self.datalist objectAtIndex:indexPath.row];
        
        NSString *_threadForum = [temp objectForKey:@"threadForum"];
        
        cell.floorImage.hidden = YES;
        
        cell.content.text = [NSString stringWithFormat:@"主题: %@",[temp objectForKey:@"tTitle"]];
        cell.content.frame = CGRectMake(20, 20, 280, 20);
        cell.content.font = [UIFont systemFontOfSize:16];
        cell.content.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
        
        if ([_threadForum isEqualToString:@"新闻"])
        {
            cell.userName.text = @"官方发布";
        }
        else
        {
            cell.userName.text = [NSString stringWithFormat:@"作者: %@",[temp objectForKey:@"userName"]];
        }
        
        cell.userName.frame = CGRectMake(110, 50, 150, 20);
        cell.userName.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        
        cell.timeImage.frame = CGRectMake(20, 55, 23/2, 22/2);
        
        cell.timeLabel.text = [temp objectForKey:@"sendtime"];
        cell.timeLabel.frame = CGRectMake(35, 50, 100, 20);
        
        cell.deleteBtn.hidden = YES;
        
        if (isEdit==YES)
        {
            cell.deleteBtn.hidden = NO;
            cell.deleteBtn.frame = CGRectMake(250, 30, 50, 25);
            [cell.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [cell.deleteBtn addTarget:self action:@selector(deleteCollect:) forControlEvents:UIControlEventTouchUpInside];
            cell.deleteBtn.tag = indexPath.row;
        }
        
        cell.backView.frame = CGRectMake(10, 10, 300, 70);
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selecttag==4 || self.selecttag==5 || self.selecttag==6 || self.selecttag==9)
    {
        User *_temp = nil;
        _temp = [self.datalist objectAtIndex:indexPath.row];
        
        if (_temp)
        {
            PersonalDataViewController *person = [[PersonalDataViewController alloc] initWithUser:_temp FromSelf:NO SelectFromCenter:YES];
            [self.navigationController pushViewController:person AnimatedType:MLNavigationAnimationTypeOfScale];
            [person release];
        }
        
        return;
    }
    
    
    Thread *_temp = nil;
    
    NSDictionary *_dic = [self.datalist objectAtIndex:indexPath.row];

    if (self.selecttag==1 || self.selecttag==7)
    {
        _temp = [self.threadArry objectAtIndex:indexPath.row];
    }
    
    if (self.selecttag==2 || self.selecttag==3 || self.selecttag==8)
    {
        _temp = [_dic objectForKey:@"threads"];
    }
    
    if(_temp)
    {
        BOOL _collect = [[_dic objectForKey:@"collect"] boolValue];
        int _state = [[_dic objectForKey:@"state"] intValue];
        
        NSString *_threadForum = [_dic objectForKey:@"threadForum"];
        
        if ([_threadForum isEqualToString:@"新闻"])
        {
            NewsInfoViewController *newInfo = [[NewsInfoViewController alloc] initWithThread:_temp Collect:_collect ThreadState:_state Image:[_dic objectForKey:@"imageAry"]];
            [self.navigationController pushViewController:newInfo AnimatedType:MLNavigationAnimationTypeOfScale];
            [newInfo release];
        }
        else
        {
            InfoViewController *info = [[InfoViewController alloc] initWithThread:_temp Collect:_collect ThreadState:_state];
            [self.navigationController pushViewController:info AnimatedType:MLNavigationAnimationTypeOfScale];
            [info release];
        }
      
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
    
  
}


- (void)playCellVoice:(UIButton *)sender
{
    self.voiceData=nil;
    
    self.voiceData = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"commentContents"];
    
    self.voiceData = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"postContents"];

    if(self.voiceData==nil)
    {
        return;
    }
    
    CustomCell *cell = (CustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    [cell.voiceBtn setTitle:@"播放中" forState:UIControlStateNormal];
    [cell.voiceBtn addSubview:animationImgview];
    animationImgview.hidden = NO;
    [animationImgview startAnimating];
    _sender = sender;
 
    
    if(isPlayCellVoice==YES)
    {
        [amrPlayer stop];
        [amrPlayer release];
        amrPlayer=nil;
        
        if(_lastSender==sender)
        {
            CustomCell *cell = (CustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSender.tag inSection:0]];
            [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
            [animationImgview stopAnimating];
            animationImgview.hidden = YES;
            isPlayCellVoice = NO;
            
            return;
        }
        else
        {
            CustomCell *cell = (CustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
            [cell.voiceBtn setTitle:@"播放中" forState:UIControlStateNormal];
            [cell.voiceBtn addSubview:animationImgview];
            animationImgview.hidden = NO;
            
            CustomCell *cell2 = (CustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSender.tag inSection:0]];
            [cell2.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        }
        
        
    }
    
    _lastSender = sender;
    
    isPlayCellVoice = YES;
    
    [self playVoice];
}

- (void)playVoice
{
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
    
    
    if(isPlayCellVoice==YES)
    {
        CustomCell *cell = (CustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sender.tag inSection:0]];
        [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        isPlayCellVoice = NO;
    }
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
}

- (void)showUserInfo:(UIButton *)sender
{
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated];
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
        [_refreshHeaderView release];
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
    }
}



#pragma mark - headerView Delegate
//拖拽到位松手触发（刷新）
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.isShowMore = NO;

    if (self.selecttag==7)
    {
        [self requestCollects];
    }
    
    if (self.selecttag==1 || self.selecttag==2 || self.selecttag==3 || self.selecttag==8)
    {
        [self requestCollectNum];
    }
    
    if (self.selecttag==4 || self.selecttag==5 || self.selecttag==6 || self.selecttag==9)
    {
        [self requestFriendList];
    }
 
}

- (void)doneLoadingTableViewData
{
    self.isShowMore = NO;
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
