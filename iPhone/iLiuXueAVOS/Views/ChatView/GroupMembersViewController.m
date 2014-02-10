//
//  GroupMembersViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-21.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "GroupMembersViewController.h"

@interface GroupMembersViewController ()

@end

@implementation GroupMembersViewController
@synthesize gId = _gId;
@synthesize datalist = _datalist;


- (void)dealloc
{
    [_datalist release]; _datalist=nil;
    [_gId release]; _gId=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    
    [super dealloc];
    
}


- (id)initWithGroupID:(NSString *)gId
{
    if (self = [super init])
    {
        self.gId = gId;
    }
    
    return self;
}


#pragma mark - 被迫下线
- (void)userLogOut
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的账号已下线" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = 202;
    [alert show];
    [alert release];
    alert=nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    
    UIView *stateView = [[UIView alloc] init];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    stateView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:stateView];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0032_Background-副本.png"]];
    backgroundImage.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    [self.view addSubview:backgroundImage];
    [backgroundImage release];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIImageView *navigationBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0011111111_bg.png"]];
    navigationBarView.frame = CGRectMake(0, 0, 320, 45);
    [backgroundView addSubview:navigationBarView];
    navigationBarView.userInteractionEnabled = YES;
    [navigationBarView release];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    title.center = CGPointMake(160, 23);
    title.text = @"群成员";
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
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:backBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 5000;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    [self addRefreshHeaderView];
    [self requestGroupMembers];
    
}

- (void)requestGroupMembers
{
    if (self.isRequest)
    {
        return;
    }
    
    self.isRequest = YES;
    
    __block typeof(self) bself = self;

    [self showF3HUDLoad:nil];
    
    [[ALXMPPEngine defauleEngine] getMemberWithGroup:self.gId block:^(NSArray *array, NSError *error) {
        
        int counts = array.count;
        
        if (counts>0 && !error)
        {
            [bself.datalist removeAllObjects];
            [bself.friendList removeAllObjects];
            
            [[ALUserEngine defauleEngine] refreashMyRelationWithBlock:^(NSDictionary *relationInfo, NSError *error) {
                
                if (relationInfo && !error)
                {
                    NSArray *array = (NSArray *)[relationInfo objectForKey:@"friends"];
                    NSArray *array2 = [relationInfo objectForKey:@"bilaterals"];
                    int counts = array.count;
                    int counts2 = array2.count;
                    
                    for (int i=0; i<counts; i++)
                    {
                        User *_friend = [array objectAtIndex:i];
                        
                        if ([_friend.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
                        {
                            [bself.friendList addObject:_friend];
                        }
                    }
                    
                    for (int i=0; i<counts2; i++)
                    {
                        User *_friend = [array2 objectAtIndex:i];
                        
                        if ([_friend.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
                        {
                            [bself.friendList addObject:_friend];
                        }
                        
                    }
                }
            
                [bself performSelectorInBackground:@selector(readData:) withObject:array];

            }];
            

        }
        
        if (counts==0 && !error)
        {
            [bself hideF3HUDSucceed:nil];
            
            bself.isRequest=NO;
            
            [bself doneLoadingTableViewData];
        }
        
        if (error)
        {
            [bself hideF3HUDError:nil];
            bself.isRequest=NO;
            
            [bself doneLoadingTableViewData];
        }
    }];
}

- (void)readData:(NSArray *)array
{
    int counts = array.count;
    
    for (int i=0; i<counts; i++)
    {
        User *_user = (User *)[array objectAtIndex:i];
        [_user fetchIfNeeded];
        
        [self.datalist addObject:_user];
    }
    
    [_tableView reloadData];
    
    [self hideF3HUDSucceed:nil];
    
    self.isRequest=NO;
    
    [self doneLoadingTableViewData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    static NSString *CellIdentifier = @"cell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil)
    {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
    cell.userName.font = [UIFont systemFontOfSize:16];
    cell.userName.textColor = [UIColor whiteColor];

    cell.voiceBtn.hidden = NO;
    cell.voiceBtn.frame = CGRectMake(0, 0, 50, 25);
    cell.voiceBtn.center = CGPointMake(285, 35);
    [cell.voiceBtn setTitle:@"加关注" forState:UIControlStateNormal];
    [cell.voiceBtn addTarget:self action:@selector(attentionUser:) forControlEvents:UIControlEventTouchUpInside];
    cell.voiceBtn.tag = indexPath.row;
    
    cell.homeCellLine.hidden = NO;
    cell.homeCellLine.center = CGPointMake(160, 70);
    cell.homeCellLine.image = [UIImage imageNamed:@"_0004_line-right@2x.png"];
    
    return cell;
}

- (void)attentionUser:(UIButton *)sender
{
    User *_user = [self.datalist objectAtIndex:sender.tag];
    _row = sender.tag;
    
    if (!_user)
    {
        return;
    }
    
    if ([_user.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您不能关注自己" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    BOOL isAttention=NO;
    
    for (User *friend in self.friendList)
    {
        if ([friend.objectId isEqualToString:_user.objectId])
        {
            isAttention=YES;
        }
    }
    
    if (isAttention)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已关注此用户，可以开始聊天" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您需要先关注此用户，才可以开始聊天" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"关注", nil];
        alert.tag = 201;
        [alert show];
        [alert release];
        alert=nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==201)
    {
        if (buttonIndex==1)
        {
            User *_user = [self.datalist objectAtIndex:_row];
            
            if (_user)
            {
                __block typeof(self) bself = self;
                
                [self showF3HUDLoad:nil];
                
                [[ALUserEngine defauleEngine] addFriendWithUser:_user orBkName:nil block:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded && !error)
                    {
                        [bself hideF3HUDSucceed:nil];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已关注此用户，可以开始聊天" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                        [alert release];
                        alert=nil;
                        
                    }
                    else
                    {
                        [bself hideF3HUDError:nil];
                    }
                }];
            }
        }
    }
    
    if (alertView.tag==202)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}


- (void)removeGroupMemebers:(UIButton *)sender
{
    User *_user = nil;
    _user = [self.datalist objectAtIndex:sender.tag];
    
    if (_user)
    {
        __block typeof(self) bself = self;
        
        [self showF3HUDLoad:nil];
        
        __block UITableView *__tableview = _tableView;
        
        [[ALXMPPEngine defauleEngine] removeUsers:[NSArray arrayWithObjects:_user, nil] fromGroup:self.gId block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded && !error)
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
        
        _refreshHeaderView=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height) textColor:[UIColor grayColor] beginStr:@"下拉刷新" stateStr:@"松开即可刷新" endStr:@"加载中" haveArrow:YES];
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
    [self requestGroupMembers]; //从新读取数据
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
