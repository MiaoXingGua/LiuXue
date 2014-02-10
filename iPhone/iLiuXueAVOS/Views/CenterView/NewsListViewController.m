//
//  NewsListViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-20.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "NewsListViewController.h"
#import "AsyncImageView.h"
#import "NewsCustomCell.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "ViewData.h"
#import "NewsInfoViewController.h"

@interface NewsListViewController ()

@end

@implementation NewsListViewController
@synthesize forum = _forum;
@synthesize collectNumArray = _collectNumArray;
@synthesize datalist = _datalist;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESHUI object:nil];
    
    [_datalist release]; _datalist=nil;
    [_forum release]; _forum=nil;
    [_collectNumArray release]; _collectNumArray=nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [ViewData defaultManager].showVc = 3;
}

- (void)beginPulldownAnimation
{
    [_tableView setContentOffset:CGPointMake(0, -75) animated:YES];
    [_refreshHeaderView performSelector:@selector(egoRefreshScrollViewDidEndDragging:) withObject:_tableView afterDelay:0.5];
}

- (void)refrashTableView
{
    [self showF3HUDLoad:nil];
    
    [self beginPulldownAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refrashTableView) name:REFRESHUI object:nil];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];

    self.datalist = [NSMutableArray arrayWithCapacity:0];
    self.collectNumArray = [NSMutableArray arrayWithCapacity:0];
    self.forum=nil;
    
    
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
    titleLabel.text = @"美国轶事";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
    [showLeftViewBtn setImage:[UIImage imageNamed:@"_0025_menu@2x.png"] forState:UIControlStateNormal];
    [showLeftViewBtn addTarget:self action:@selector(showLeftView) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showLeftViewBtn];
    
    UIButton *showrRightViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showrRightViewBtn.frame = CGRectMake(280, 10, 30, 30);
    [showrRightViewBtn setImage:[UIImage imageNamed:@"_0027_friends@2x.png"] forState:UIControlStateNormal];
    [showrRightViewBtn addTarget:self action:@selector(showRightView) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showrRightViewBtn];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
    headView.backgroundColor = [UIColor clearColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 5000;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.tableHeaderView = headView;
    [backgroundView addSubview:_tableView];
    [headView release];
    [_tableView release];

    
    [self addRefreshHeaderView];
    [self addFootView];
    
    [self requestForum];
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

- (void)showMoreComments:(UIButton *)sender
{
    if (self.isShowMore)
    {
        return;
    }
    
    self.isShowMore = YES;
    
    [self requestCollect];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d",self.datalist.count);
    
    if (self.datalist.count>0)
    {
        return self.datalist.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    NewsCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil)
    {
        cell = [[[NewsCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (self.datalist.count>0)
    {
        NSMutableDictionary *_dic = [self.datalist objectAtIndex:indexPath.row];
        
        cell.asyImage.urlString = [[[_dic objectForKey:@"imageAry"] objectAtIndex:0] objectForKey:@"imageUrl"];
        [cell.asyImage addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.asyImage.tag = indexPath.row;
        
        cell.title.text = [_dic objectForKey:@"title"];
        
        cell.content.text = [_dic objectForKey:@"content"];
        
        
        cell.userName.text = @"官方发布";
        
        cell.sendTime.text = [_dic objectForKey:@"sendTime"];
        
        
        int _clickNum = [[_dic objectForKey:@"click"] intValue];
        
        if(_clickNum>=10000)
        {
            int num = _clickNum/10000;
            cell.click.text = [NSString stringWithFormat:@"%d万",num];
        }
        else
        {
            cell.click.text = [NSString stringWithFormat:@"%d",_clickNum];
        }
        
        int _commentNum = [[_dic objectForKey:@"commentNum"] intValue];
        
        
        if(_commentNum>=10000)
        {
            int num = _commentNum/10000;
            cell.comments.text = [NSString stringWithFormat:@"%d万",num];
        }
        else
        {
            cell.comments.text = [NSString stringWithFormat:@"%d",_commentNum];
        }
        
        
        if([[_dic objectForKey:@"collect"] intValue]==1)
        {
            [cell.collect setImage:[UIImage imageNamed:@"_0021_Small-favourit@2x.png"] forState:UIControlStateNormal];
        }
        if([[_dic objectForKey:@"collect"] intValue]==0)
        {
            [cell.collect setImage:[UIImage imageNamed:@"_0020_unfavourit@2x.png"] forState:UIControlStateNormal];
        }
        
        [cell.collect addTarget:self action:@selector(collectNews:) forControlEvents:UIControlEventTouchUpInside];
        cell.collect.tag = indexPath.row;
    }

    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)requestForum
{
    [self showF3HUDLoad:@""];

    __block typeof(self) bself = self;
    
    [[ALThreadEngine defauleEngine] getForumsWithBlock:^(NSArray *forums, NSError *error) {
        
        if (forums && !error)
        {
            for (int i=0; i<forums.count; i++)
            {
                Forum *temp = [forums objectAtIndex:i];
                
                if ([temp.name isEqualToString:@"新闻"])
                {
                    bself.forum = temp;
                    
                    [bself requestCollect];
                }

            }
        }
    }];
   
}

- (void)requestCollect
{
    if(self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest = YES;
    
    if (self.isShowMore)
    {
        [loadCommentsBtn setTitle:@"加载中" forState:UIControlStateNormal];
        [_activityView startAnimating];
    }
    
    __block typeof(self) bself = self;
    
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        [self requestThreadOfNews];
        
        return;
    }

    
    if (self.isShowMore)
    {
        [self requestThreadOfNews];
    }
    else
    {
        [[ALThreadEngine defauleEngine] getMyFaviconThreadNotContainedIn:nil block:^(NSArray *threads, NSError *error) {
            
            [bself.collectNumArray removeAllObjects];

            if(threads.count>0 && !error)
            {
                int count = threads.count;
                for (int i=0; i<count; i++)
                {
                    Thread *_thread = [threads objectAtIndex:i];
                    [bself.collectNumArray addObject:_thread.objectId];
                }
            }
            
   
            [bself requestThreadOfNews];
            
        }];
    }
  
    
    
}

- (void)requestThreadOfNews
{
    __block typeof(self) bself = self;
    
    __block UIButton *__loadbtn = loadCommentsBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    if (self.isShowMore==YES)
    {
        __block NSMutableArray *array = [NSMutableArray array];

        for (int i=0; i<self.datalist.count; i++)
        {
            NSThread *_threads = [[self.datalist objectAtIndex:i] objectForKey:@"thread"];
            [array addObject:_threads];
        }
        
        [[ALThreadEngine defauleEngine] getThreadsWithForum:self.forum notContainedIn:array block:^(NSArray *threads, NSError *error)
         {
             
             int counts = threads.count;
             
             
             if (counts>0 && !error)
             {
                 [bself performSelectorInBackground:@selector(downloadthreads:) withObject:threads];
             }
             
             if (counts==0)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                 [alert show];
                 [alert release];
                 alert=nil;
                 
                 [bself hideF3HUDSucceed:nil];
                 
                 [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                 [__activity stopAnimating];
                 
                 bself.isRequest=NO;
                 bself.isShowMore=NO;
             }
             
             if (error)
             {
                 [bself hideF3HUDError:nil];
                 
                 [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                 [__activity stopAnimating];
                 
                 bself.isRequest=NO;
                 bself.isShowMore=NO;
                 
             }
             
         }];
    }
    else
    {

        [[ALThreadEngine defauleEngine] getThreadsWithForum:self.forum notContainedIn:nil block:^(NSArray *threads, NSError *error)
         {
             
             int counts = threads.count;
             
             if (counts>0 && !error)
             {
                 [bself performSelectorInBackground:@selector(downloadthreads:) withObject:threads];
             }
             
             if (counts==0)
             {
                 [bself.datalist removeAllObjects];

                 [bself hideF3HUDSucceed:nil];
                 
                 [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                 [__activity stopAnimating];
                 
                 bself.isRequest=NO;
                 bself.isShowMore=NO;
             }
             
             if (error)
             {
                 [bself hideF3HUDError:nil];
                 
                 [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                 [__activity stopAnimating];
                 
                 bself.isRequest=NO;
                 bself.isShowMore=NO;
                 
             }
             
         }];
    }
    
}


- (void)downloadthreads:(NSArray *)array
{
    NSMutableArray *ary = [NSMutableArray array];
    
    for (int i=0; i<array.count; i++)
    {
        Thread *_temp = [array objectAtIndex:i];
        
        ThreadContent *_contens = (ThreadContent *)[_temp.content fetchIfNeeded];
        
        if(_contens.images)
        {
            AVRelation *_imagePF = _contens.images;
            
            NSArray *_array = [[_imagePF query] findObjects];
            
            if (_array.count>0)
            {
                NSMutableArray *imageAry = [NSMutableArray arrayWithCapacity:0];
                
                for (int i=0; i<_array.count; i++)
                {
                    ThreadImage *_image = [_array objectAtIndex:i];
                    
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                    [_dic setValue:_image.image.url forKey:@"imageUrl"];
                    [_dic setValue:_image.imageSize forKey:@"imageSize"];
                    [imageAry addObject:_dic];
                }
                
                NSString *sendtime = [self calculateDate:_temp.createdAt];
                NSString *click = [NSString stringWithFormat:@"%d",_temp.views];
                NSString *comments = [NSString stringWithFormat:@"%d",_temp.numberOfPosts];
                NSString *state = [NSString stringWithFormat:@"%d",_temp.state];
                
                NSNumber *collect;
                
                if([self.collectNumArray containsObject:_temp.objectId])
                {
                    collect = [NSNumber numberWithInt:1];
                }
                else
                {
                    collect = [NSNumber numberWithInt:0];
                }
                
                
                NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                
                [_dic setValue:_temp forKey:@"thread"];
                [_dic setValue:_temp.title forKey:@"title"];
                [_dic setValue:_contens.text forKey:@"content"];
                [_dic setValue:sendtime forKey:@"sendTime"];
                [_dic setValue:click forKey:@"click"];
                [_dic setValue:comments forKey:@"comments"];
                [_dic setValue:collect forKey:@"collect"];
                [_dic setValue:state forKey:@"state"];
                [_dic setValue:imageAry forKey:@"imageAry"];
                
                [ary addObject:_dic];
                
            }
        }
    }
    
    
    if (self.isShowMore==NO)
    {
        [self.datalist removeAllObjects];

    }
    
    [self.datalist addObjectsFromArray:ary];
    
    [self performSelectorOnMainThread:@selector(refreshThreads) withObject:nil waitUntilDone:NO];

}

- (void)refreshThreads
{
    if (self.isShowMore==YES)
    {
        [loadCommentsBtn setTitle:@"显示更多" forState:UIControlStateNormal];
        [_activityView stopAnimating];
    }
    
    
    [_tableView reloadData];
    [self doneLoadingTableViewData];
    
    [self hideF3HUDSucceed:nil];
    
    self.isRequest=NO;
    self.isShowMore=NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Thread *_temp = nil;
    _temp = [[self.datalist objectAtIndex:indexPath.row] objectForKey:@"thread"];
    
    NSDictionary *_dic = [self.datalist objectAtIndex:indexPath.row];
    BOOL _collect = [[_dic objectForKey:@"collect"] boolValue];
    int _state = [[_dic objectForKey:@"state"] intValue];
    NSMutableArray *_array = [_dic objectForKey:@"imageAry"];
    
    if(_temp)
    {
        NewsInfoViewController *info = [[NewsInfoViewController alloc] initWithThread:_temp Collect:_collect ThreadState:_state Image:_array];
        [self.navigationController pushViewController:info AnimatedType:MLNavigationAnimationTypeOfScale];
        [info release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
}


- (void)collectNews:(UIButton *)sender
{
    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest = YES;
    
    Thread *_thread = nil;
    _thread = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"thread"];
    
    if (!_thread)
    {
        return;
    }
    
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
            
            bself.isRequest = NO;
            
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
            
            bself.isRequest = NO;
        }];
    }
}

- (void)showInfo:(AsyncImageView *)sender
{
    Thread *_temp = nil;
    _temp = [[self.datalist objectAtIndex:sender.tag] objectForKey:@"thread"];
    
    NSDictionary *_dic = [self.datalist objectAtIndex:sender.tag];
    BOOL _collect = [[_dic objectForKey:@"collect"] boolValue];
    int _state = [[_dic objectForKey:@"state"] intValue];
    NSMutableArray *_array = [_dic objectForKey:@"imageAry"];
    
    if(_temp)
    {
        NewsInfoViewController *info = [[NewsInfoViewController alloc] initWithThread:_temp Collect:_collect ThreadState:_state Image:_array];
        [self.navigationController pushViewController:info AnimatedType:MLNavigationAnimationTypeOfScale];
        [info release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
    
}

- (void)showLeftView
{
    [self.sidePanelController showLeftPanelAnimated:YES];
}

- (void)showRightView
{
    [self.sidePanelController showRightPanelAnimated:YES];
    
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
    [self requestCollect]; //从新读取数据
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
