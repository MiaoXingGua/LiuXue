//
//  CollectViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-24.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "CollectViewController.h"
#import "ALUserEngine.h"
#import "ViewData.h"

@interface CollectViewController ()

@end

@implementation CollectViewController
@synthesize datalist = _datalist;
@synthesize threadArry = _threadArry;

- (void)dealloc
{
    [_threadArry release];
    [_datalist release];
    [super dealloc];
}

- (void)requestMyCollects
{
    if (isrequest==YES)
    {
        return;
    }
    
    isrequest = YES;
    
    [self showHUDWithTitle:@"加载中" status:@"提示"];
    __block typeof(self) bself = self;
    
    NSArray *array = [[NSArray alloc] init];
        
//    [[ALThreadEngine defauleEngine] getFaviconThreadWithUser: notContainedIn:array block:^(NSArray *threads, NSError *error)
//    {
//        int counts = threads.count;
//        if (counts>0 && !error)
//        {
//            if (isPulldown==NO)
//            {
//                [bself hideHUDWithSuccess:@"成功" title:@"提示"];
//            }
//            else
//            {
//                [bself.datalist removeAllObjects];
//            }
//            
//            for (int i=0; i<counts; i++)
//            {
//                Thread *_thread = [threads objectAtIndex:i];
//                User *_user = _thread.postUser;
//                
//                [bself.threadArry addObject:_thread];
//                //                ThreadContent *_content = _thread.content;
//                //
//                NSString *_username = _user.nickName;
//                NSString *_tid = _thread.objectId;
//                NSString *_ttitle = _thread.title;
//                //   NSString *_place = _thread.place;
//                NSString *_sendTime = [self calculateDate:_thread.createdAt];
//                NSNumber *_state = [NSNumber numberWithInt:_thread.state];
//                
//                NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_tid,@"threadId",_ttitle,@"tTitle", _sendTime, @"sendtime", _thread , @"thread", _state, @"state", _username, @"userName", nil];
//                [bself.datalist addObject:_dic];
//                
//            }
//            
//            [bself addFootView];
//            
//        }
//        
//        if(isPulldown==NO)
//        {
//            if(counts==0 && !error)
//            {
//                editBtn.userInteractionEnabled = NO;
//                [bself hideHUDWithSuccess:@"没有收藏" title:@"提示"];
//            }
//            
//            if (error)
//            {
//                [bself hideHUDWithError:@"失败" title:@"提示"];
//            }
//        }
//        else
//        {
//            [bself doneLoadingTableViewData];
//            
//        }
//        
//        [_tableView reloadData];
//        
//        [_activityView stopAnimating];
//        [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
//        
//        isrequest = NO;
//
//        
//    }];
//    
    [array release];
    array=nil;

}

- (void)showMoreComments:(UIButton *)sender
{
    if (isrequest==YES)
    {
        return;
    }
    
    isrequest = YES;
    
    [_activityView startAnimating];
    [loadCommentsBtn setTitle:@"加载中" forState:UIControlStateNormal];
    
    __block typeof(self) bself = self;
 
    
    [[ALThreadEngine defauleEngine] getMyFaviconThreadNotContainedIn:self.threadArry block:^(NSArray *threads, NSError *error) {
        
        int counts = threads.count;
        if (counts>0 && !error)
        {

            for (int i=0; i<counts; i++)
            {
                Thread *_thread = [threads objectAtIndex:i];
                User *_user = _thread.postUser;
                //                ThreadContent *_content = _thread.content;
                //
                NSString *_username = _user.nickName;
                NSString *_tid = _thread.objectId;
                NSString *_ttitle = _thread.title;
                //   NSString *_place = _thread.place;
                NSString *_sendTime = [self calculateDate:_thread.createdAt];
                NSNumber *_state = [NSNumber numberWithInt:_thread.state];
                
                NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_tid,@"threadId",_ttitle,@"tTitle", _sendTime, @"sendtime", _thread , @"thread", _state, @"state", _username, @"userName", nil];
                [bself.datalist addObject:_dic];
                
            }
        }
        
      
        if(counts==0 && !error)
        {
            editBtn.userInteractionEnabled = NO;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
        }
            
        if (error)
        {
            [bself hideHUDWithError:@"失败" title:@"提示"];
        }
      
        [_tableView reloadData];
        [bself addFootView];
        
        [_activityView stopAnimating];
        [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
        
        isrequest = NO;
    }];
    
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
    footView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    loadCommentsBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadCommentsBtn.frame = CGRectMake(0, 0, 280, 40);
    [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    self.threadArry = [NSMutableArray arrayWithCapacity:0];
    
    
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
    titleLabel.text = @"收藏";
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
    
    
    editBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editBtn.frame = CGRectMake(270, 7, 40, 30);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(showEditBtn) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:editBtn];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    [self requestMyCollects];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
    
    cell.content.text = [NSString stringWithFormat:@"主题:%@",[temp objectForKey:@"tTitle"]];
    cell.content.frame = CGRectMake(20, 20, 280, 20);
    cell.content.font = [UIFont systemFontOfSize:16];
    
    
    cell.userName.text = [temp objectForKey:@"userName"];
    cell.userName.frame = CGRectMake(120, 50, 150, 20);
    cell.userName.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
    
    cell.timeImage.frame = CGRectMake(20, 55, 23/2, 22/2);

    cell.timeLabel.text = [temp objectForKey:@"sendtime"];
    cell.timeLabel.frame = CGRectMake(40, 50, 100, 20);
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Thread *_temp = nil;
    _temp = [[self.datalist objectAtIndex:indexPath.row] objectForKey:@"thread"];
    BOOL _collect = YES;
    int _state = [[[self.datalist objectAtIndex:indexPath.row] objectForKey:@"state"] intValue];
    
    if(_temp)
    {
        InfoViewController *info = [[InfoViewController alloc] initWithThread:_temp Collect:_collect ThreadState:_state];
        [self.navigationController pushViewController:info AnimatedType:MLNavigationAnimationTypeOfScale];
        [info release];
    }
    else
    {
        [self showAlertWithMessage:@"主题已被删除" title:@"提示"];
    }
}

- (void)deleteCollect:(UIButton *)sender
{
    [self showHUDWithTitle:@"取消收藏中" status:@"提示"];
    
    Thread *_temp = nil;
    _temp = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"thread"];
    
    if(_temp)
    {
        __block typeof(self) bself = self;

        [[ALThreadEngine defauleEngine] unfaviconThread:_temp block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [bself.datalist removeObjectAtIndex:sender.tag];
                
                [bself hideHUDWithSuccess:@"成功" title:@"提示"];
            }
            else
            {
                [bself hideHUDWithError:@"失败" title:@"提示"];
            }
            
            [_tableView reloadData];
            
        }];
    }
    else
    {
        [self showAlertWithMessage:@"主题已被删除" title:@"提示"];
    }
    
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"执行删除操作");
//    
//    
//    
//}

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
    isPulldown = YES;
	[self requestMyCollects]; //从新读取数据
}

- (void)doneLoadingTableViewData
{
    isPulldown = NO;
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
