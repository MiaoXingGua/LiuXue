//
//  UnReadNotificationViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-11-2.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "UnReadNotificationViewController.h"
#import "ViewData.h"
#import "QuartzCore/QuartzCore.h"
#import "InfoCustomCell.h"
#import "ALUserEngine.h"
#import "ThreadContent.h"
#import "InfoViewController.h"
#import "ALNotificationCenter.h"

@interface UnReadNotificationViewController ()

@end

@implementation UnReadNotificationViewController
@synthesize unreaddatalist = _unreaddatalist;
@synthesize voiceData = _voiceData;
@synthesize collectNumArray = _collectNumArray;

- (void)dealloc
{
    [_collectNumArray release]; _collectNumArray=nil;
    [_voiceData release]; _voiceData=nil;
    [_unreaddatalist release]; _unreaddatalist=nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSLog(@"unreadViewAppear!!!");
    
    [self showF3HUDLoad:nil];
    [self beginPulldownAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    self.unreaddatalist = [NSMutableArray arrayWithCapacity:0];
    self.collectNumArray = [NSMutableArray arrayWithCapacity:0];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, SCREEN_HEIGHT-80) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    _tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
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
    
    [self addRefreshHeaderView];
    [self addFootView];

}



#pragma mark -添加footView
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
    [loadCommentsBtn addTarget:self action:@selector(showMoreNotification:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:loadCommentsBtn];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(0, 0, 20, 20);
    _activityView.center = CGPointMake(100, 20);
    [loadCommentsBtn addSubview:_activityView];
    [_activityView release];
    
    _tableView.tableFooterView = footView;
    [footView release];
    
}

#pragma mark - 执行下拉动画
- (void)beginPulldownAnimation
{
    [_tableView setContentOffset:CGPointMake(0, -75) animated:YES];
    [_refreshHeaderView performSelector:@selector(egoRefreshScrollViewDidEndDragging:) withObject:_tableView afterDelay:0.4];
}

#pragma mark - 请求数据
- (void)requestCollectNum
{
    if(self.isRequest==YES)
    {
        return;
        
    }
    
    self.isRequest = YES;
    
    __block typeof(self) bself = self;
    
    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        [self requestNotificationIsUnread];
        
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
        
        [bself requestNotificationIsUnread];
        
    }];
    
    
    
}

- (void)requestNotificationIsUnread
{
    __block typeof(self) bself = self;

    __block UITableView *__tableview = _tableView;
    
    [[ALNotificationCenter defauleCenter] getNotificationsOfThreadNotContainedIn:nil type:ALThreadNotificationTypeOfThreadNewPost isUnread:YES block:^(NSArray *notifications, NSError *error) {
        
        int counts = notifications.count;
        
        if(counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(loadMessages:) withObject:notifications];
        }
        
        if (counts==0 && !error)
        {
            [bself doneLoadingTableViewData];
            
            [bself.unreaddatalist removeAllObjects];
            
            [bself hideF3HUDSucceed:nil];
            bself.isRequest = NO;
            [__tableview reloadData];
        }
        
        if (error)
        {
            [bself hideF3HUDError:nil];
            [bself doneLoadingTableViewData];
            bself.isRequest = NO;
            [__tableview reloadData];
        }
    }];
    
}

- (void)loadMessages:(NSArray *)array
{
    int counts = array.count;
    
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    
    for (int i=0; i<counts; i++)
    {
        NotificationOfThread *_notification = [array objectAtIndex:i];
        Thread *_threads = (Thread *)[_notification.thread fetchIfNeeded];
        Post *_posts = (Post *)[_notification.post fetchIfNeeded];
        NSNumber *_state;
        NSString *_titles;
        NSString *sendtime;
        
        
        if (_posts)
        {
            sendtime = [NSString stringWithFormat:@"%@",[self calculateDate:_posts.createdAt]];
        }
        else
        {
            sendtime = @"";
        }
        
        if (_threads)
        {
            _state = [NSNumber numberWithInt:_threads.state];
            _titles = [NSString stringWithFormat:@"%@",_threads.title];
        }
        else
        {
            _state = [NSNumber numberWithInt:0];
            _titles = @"主题已被删除";
        }
        
        NSString *_username;
        NSString *_userurl;
        NSNumber *_sex;
        
        User *_fromuser = (User *)[_notification.fromUser fetchIfNeeded];
        
        if (_fromuser)
        {
            _username = [NSString stringWithFormat:@"%@",_fromuser.nickName];
            _userurl = [NSString stringWithFormat:@"%@",_fromuser.headView.url];
            _sex = [NSNumber numberWithBool:_fromuser.gender];
        }
        else
        {
            _username = @"用户已注销";
            _userurl = @"0";
            _sex = [NSNumber numberWithInt:2];
        }
        
        
        ThreadContent *_content = (ThreadContent *)[_posts.content fetchIfNeeded];
        
        if(_content)
        {
            NSString *_text = nil;
            _text = _content.text;
            
            NSData *_tempvoiceData = nil;
            _tempvoiceData = (NSData *)[_content.voice getData];
            
            
            if (_text)
            {
                NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_notification,@"notification",_sex, @"gender",@"text", @"textOrVoice", _username, @"userName",_userurl, @"userUrl", _text, @"content", sendtime, @"sendTime",_titles, @"threaTitle", _state, @"state",_threads, @"thread",nil];
                
                if (_dic)
                {
                    [ary addObject:_dic];
                }
            }
            if (_tempvoiceData)
            {
                NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_notification,@"notification",_sex, @"gender",@"voice", @"textOrVoice", _username, @"userName",_userurl, @"userUrl", _tempvoiceData, @"content", sendtime, @"sendTime",_titles, @"threaTitle", _state, @"state",_threads, @"thread",nil];
                
                if (_dic)
                {
                    [ary addObject:_dic];
                }
            }
            
        }
        else
        {
            NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_notification,@"notification",_sex, @"gender",@"text", @"textOrVoice", _username, @"userName",_userurl, @"userUrl", @"回复已删除", @"content", sendtime, @"sendTime",_titles, @"threaTitle", _state, @"state",_threads, @"thread",nil];
            
            if (_dic)
            {
                [ary addObject:_dic];
            }
        }
    }
    
    [self.unreaddatalist removeAllObjects];
    [self.unreaddatalist addObjectsFromArray:ary];
    
    [ary release]; ary=nil;
    
    [self performSelectorOnMainThread:@selector(refreshMessages) withObject:nil waitUntilDone:NO];

    
}

- (void)refreshMessages
{
    [_tableView reloadData];
    [self hideF3HUDSucceed:nil];
    [self doneLoadingTableViewData];
    
    self.isRequest = NO;
}


#pragma mark - 加载更多
- (void)showMoreNotification:(UIButton *)sender
{
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest = YES;
    
    [_activityView startAnimating];
    [loadCommentsBtn setTitle:@"加载中" forState:UIControlStateNormal];
    loadCommentsBtn.userInteractionEnabled = NO;
    
    __block typeof(self) bself = self;
    
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.unreaddatalist.count; i++)
    {
        [array addObject:[[self.unreaddatalist objectAtIndex:i] objectForKey:@"notification"]];
    }
    
    __block UIButton *__loadbtn = loadCommentsBtn;
    __block UIActivityIndicatorView *__acvitity = _activityView;

    [[ALNotificationCenter defauleCenter] getNotificationsOfThreadNotContainedIn:array type:ALThreadNotificationTypeOfThreadNewPost isUnread:YES block:^(NSArray *notifications, NSError *error) {
        
        int counts = notifications.count;
        if(counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(readData:) withObject:notifications];
        }
        
        if (counts==0 && !error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
            
            bself.isRequest = NO;
            
            [__acvitity stopAnimating];
            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
            __loadbtn.userInteractionEnabled = YES;
        }
        
        [array release];
        array=nil;
    }];

}


- (void)readData:(NSArray *)notifications
{
    int counts = notifications.count;
    
    for (int i=0; i<counts; i++)
    {
        NotificationOfThread *_notification = [notifications objectAtIndex:i];
        Thread *_threads = _notification.thread;
        
        NSNumber *_state;
        NSString *_titles;
        
        Post *_posts = (Post *)[_notification.post fetchIfNeeded];
        NSString *sendtime;
        if (_posts)
        {
            sendtime = [NSString stringWithFormat:@"%@",[self calculateDate:_posts.createdAt]];
        }
        else
        {
            sendtime = @"";
        }
        
        if (_threads)
        {
            _state = [NSNumber numberWithInt:_threads.state];
            
            
            if (_threads.title.length>0)
            {
                _titles = [NSString stringWithFormat:@"%@",_threads.title];
            }
            else
            {
                _titles = @"该主题已删除";
            }
        }
        else
        {
            _state = [NSNumber numberWithInt:0];
            _titles = @"该主题已删除";
        }
        
        
        NSString *_username;
        NSString *_userurl;
        NSNumber *_sex;
        
        User *_fromuser = (User *)[_notification.fromUser fetchIfNeeded];
        
        if (_fromuser)
        {
            _username = [NSString stringWithFormat:@"%@",_fromuser.nickName];
            _userurl = [NSString stringWithFormat:@"%@",_fromuser.headView.url];
            _sex = [NSNumber numberWithBool:_fromuser.gender];
        }
        else
        {
            _username = @"该用户已注销";
            _userurl = @"0";
            _sex = [NSNumber numberWithInt:2];
        }
        
        
        ThreadContent *_content = (ThreadContent *)[_posts.content fetchIfNeeded];
        
        if(_content)
        {
            NSString *_text = nil;
            _text = _content.text;
            
            NSData *_tempvoiceData = nil;
            _tempvoiceData = (NSData *)[_content.voice getData];
            
            if (_text)
            {
                NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_notification,@"notification",_sex, @"gender",@"text", @"textOrVoice", _username, @"userName",_userurl, @"userUrl", _content.text, @"content", sendtime, @"sendTime",_titles, @"threaTitle", _state, @"state",_threads, @"thread",nil];
                
                if (_dic)
                {
                    [self.unreaddatalist addObject:_dic];
                }
            }
            
            if (_tempvoiceData)
            {
                NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_notification,@"notification",_sex, @"gender",@"voice", @"textOrVoice", _username, @"userName",_userurl, @"userUrl", _tempvoiceData, @"content", sendtime, @"sendTime",_titles, @"threaTitle", _state, @"state",_threads, @"thread",nil];
                
                if (_dic)
                {
                    [self.unreaddatalist addObject:_dic];
                }
            }
        }
        else
        {
            NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_notification,@"notification",_sex, @"gender",@"text", @"textOrVoice", _username, @"userName",_userurl, @"userUrl", @"回复已删除", @"content", sendtime, @"sendTime",_titles, @"threaTitle", _state, @"state",_threads, @"thread",nil];
            
            if (_dic)
            {
                if (_dic)
                {
                    [self.unreaddatalist addObject:_dic];
                }
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}

- (void)refreshUI
{
    [_activityView stopAnimating];
    [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    loadCommentsBtn.userInteractionEnabled = YES;
    
    [_tableView reloadData];
    self.isRequest = NO;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *temp;
    
    temp = [NSDictionary dictionaryWithDictionary:[self.unreaddatalist objectAtIndex:indexPath.row]];

    
    NSString *_state = [temp objectForKey:@"textOrVoice"];
    
    if ([_state isEqualToString:@"text"])
    {
        NSString *content = [NSString stringWithFormat:@"回复我: %@",[temp objectForKey:@"content"]];
        
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
        
        return contentSize.height+95;
    }
    
    if ([_state isEqualToString:@"voice"])
    {
        return 125;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unreaddatalist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *temp = [NSDictionary dictionaryWithDictionary:[self.unreaddatalist objectAtIndex:indexPath.row]];
    
    NSString *_state = [temp objectForKey:@"textOrVoice"];
    
    //回复文字
    if ([_state isEqualToString:@"text"])
    {
        static NSString *Cellidentifier1 = @"cell1";
        
        InfoCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier1];
        
        if(cell==nil)
        {
            cell = [[[InfoCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier1] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        cell.cityImage.hidden = YES;
        cell.levelLabel.hidden = NO;
        
        
        NSString *title = [temp objectForKey:@"threaTitle"];
        
        cell.levelLabel.text = [NSString stringWithFormat:@"主题: %@",title];
        cell.levelLabel.frame = CGRectMake(20, 15, 280, 20);
        
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
        cell.headCoverImage.frame = CGRectMake(0, 0, 47, 47);
        cell.headCoverImage.center = CGPointMake(40, 65);
        
        cell.headImageView.hidden = NO;
        cell.headImageView.frame = CGRectMake(0, 0, 40, 40);
        cell.headImageView.center = CGPointMake(40, 65);
        cell.headImageView.urlString = [temp objectForKey:@"userUrl"];
        
        cell.userName.text = [temp objectForKey:@"userName"];
        cell.userName.frame = CGRectMake(70, 45, 200, 20);
        
        cell.content.text = [NSString stringWithFormat:@"回复我: %@",[temp objectForKey:@"content"]];
        cell.content.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        cell.content.textAlignment = NSTextAlignmentLeft;
        CGSize contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:0];
        
        cell.content.frame = CGRectMake(70, 65, 220, contentSize.height);
        
        cell.timeImage.hidden = NO;
        cell.timeImage.frame = CGRectMake(70, 70+contentSize.height, 23/2, 22/2);
        
        cell.timeLabel.frame = CGRectMake(83, 66+contentSize.height, 150, 20);
        cell.timeLabel.text = [temp objectForKey:@"sendTime"];
        
        cell.backView.frame = CGRectMake(5, 5, 310, contentSize.height+90);
        
        cell.deleteBtn.hidden = NO;
        [cell.deleteBtn setImage:[UIImage imageNamed:@"AHSHANCHU.png"] forState:UIControlStateNormal];
        cell.deleteBtn.frame = CGRectMake(280, 15, 49/2, 49/2);
        [cell.deleteBtn addTarget:self action:@selector(deleteNotifications:) forControlEvents:UIControlEventTouchUpInside];
        cell.deleteBtn.tag = indexPath.row;
        
        
        return cell;
    }
    
    //回复声音
    if ([_state isEqualToString:@"voice"])
    {
        static NSString *Cellidentifier2 = @"cell2";
        
        InfoCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier2];
        
        if(cell==nil)
        {
            cell = [[[InfoCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        cell.cityImage.hidden = YES;
        cell.levelLabel.hidden = NO;
        
        
        NSString *title = [temp objectForKey:@"threaTitle"];
        
        cell.levelLabel.text = [NSString stringWithFormat:@"主题: %@",title];
        cell.levelLabel.frame = CGRectMake(20, 15, 280, 20);
        
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
        cell.headCoverImage.frame = CGRectMake(18, 40, 47, 47);
        
        cell.headImageView.hidden = NO;
        cell.headImageView.frame = CGRectMake(21, 42.5, 40, 40);
        cell.headImageView.urlString = [temp objectForKey:@"userUrl"];
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.headImageView.tag = indexPath.row;
        
        cell.userName.text = [temp objectForKey:@"userName"];
        cell.userName.frame = CGRectMake(70, 45, 200, 20);
        
        cell.content.text = @"回复我:";
        cell.content.frame = CGRectMake(70, 70, 60, 20);
        
        cell.voiceBtn.hidden = NO;
        cell.voiceBtn.frame = CGRectMake(120, 65, 100, 30);
        [cell.voiceBtn addTarget:self action:@selector(playCellVoice:) forControlEvents:UIControlEventTouchUpInside];
        cell.voiceBtn.tag = indexPath.row;
        
        cell.timeImage.hidden = NO;
        cell.timeImage.frame = CGRectMake(70, 100, 23/2, 22/2);
        
        cell.timeLabel.frame = CGRectMake(83, 96, 150, 20);
        cell.timeLabel.text = [temp objectForKey:@"sendTime"];
        
        cell.deleteBtn.hidden = NO;
        [cell.deleteBtn setImage:[UIImage imageNamed:@"AHSHANCHU.png"] forState:UIControlStateNormal];
        cell.deleteBtn.frame = CGRectMake(280, 15, 49/2, 49/2);
        [cell.deleteBtn addTarget:self action:@selector(deleteNotifications:) forControlEvents:UIControlEventTouchUpInside];
        cell.deleteBtn.tag = indexPath.row;
        
        cell.backView.frame = CGRectMake(5, 5, 310, 120);
        
        return cell;
        
    }
    
    
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *temp = [NSDictionary dictionaryWithDictionary:[self.unreaddatalist objectAtIndex:indexPath.row]];
    
    Thread *_thread = nil;
    _thread = [temp objectForKey:@"thread"];
    
    NotificationOfThread *_notification=nil;
    _notification = [temp objectForKey:@"notification"];
    
    NSLog(@"%@",[_notification class]);
    if (_notification)
    {
        [self performSelectorInBackground:@selector(updateNotification:) withObject:_notification];
    }
    
    if(_thread)
    {
        BOOL collect;
        if([self.collectNumArray containsObject:_thread.objectId])
        {
            collect=YES;
        }
        else
        {
            collect=NO;
        }
        
        int state = [[temp objectForKey:@"state"] intValue];
        InfoViewController *info = [[InfoViewController alloc] initWithThread:_thread Collect:collect ThreadState:state];
        [self.navigationController pushViewController:info AnimatedType:MLNavigationAnimationTypeOfScale];
        [info release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该主题已删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


#pragma mark - 删除消息提醒
- (void)deleteNotifications:(UIButton *)sender
{
    NSDictionary *temp = [NSDictionary dictionaryWithDictionary:[self.unreaddatalist objectAtIndex:sender.tag]];
    
    
    Thread *_thread = nil;
    _thread = [temp objectForKey:@"thread"];
    
    NotificationOfThread *_notification=nil;
    _notification = [temp objectForKey:@"notification"];
    
    if (_notification)
    {
        if (self.isRequest)
        {
            return;
        }
        
        self.isRequest = YES;
        
        __block typeof(self) bself = self;
        
        [self showF3HUDLoad:nil];
        
        __block UITableView *__tableview = _tableView;
        
        [[ALNotificationCenter defauleCenter] deleteStateOfNotification:_notification block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded && !error)
            {
                NSLog(@"删除成功");
                [bself hideF3HUDSucceed:nil];
                
                [bself.unreaddatalist removeObjectAtIndex:sender.tag];
                
                [__tableview reloadData];
            }
            else
            {
                NSLog(@"%@",error);
                NSLog(@"删除失败");
                [bself hideF3HUDError:nil];
            }
            
            bself.isRequest = NO;
            
        }];
    }
}

- (void)updateNotification:(NotificationOfThread *)_notification
{
    NSLog(@"%@",_notification);
    
    [[ALNotificationCenter defauleCenter] updateUnreadStateOfNotification:_notification block:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error)
        {
            NSLog(@"修改已读成功");
        }
        else
        {
            NSLog(@"修改已读失败");
        }
    }];
}


#pragma mark - 显示用户信息
- (void)showUserInfo:(AsyncImageView *)sender
{
    
}

#pragma mark - 播放声音
- (void)playCellVoice:(UIButton *)sender
{
    self.voiceData=nil;
    
    self.voiceData = [[self.unreaddatalist objectAtIndex:sender.tag] objectForKey:@"content"];

    if(self.voiceData==nil)
    {
        return;
    }
    
    InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
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
        InfoCustomCell *cell = (InfoCustomCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_sender.tag inSection:0]];
        [cell.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        isPlayCellVoice = NO;
    }
    
    if (amrPlayer!=nil)
    {
        [amrPlayer release];
        amrPlayer=nil;
    }
    
}



#pragma mark - scrollViewDelegate
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
    [self requestNotificationIsUnread]; //从新读取数据
}

- (void)doneLoadingTableViewData
{
    self.isRequest = NO;
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
