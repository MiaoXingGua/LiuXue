//
//  HomeViewController.m
//  liuxue
//
//  Created by superhomeliu on 13-7-27.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomCell.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "InfoViewController.h"
#import "MLNavigationController.h"
#import "AsyncImageView.h"
#import "ALUserEngine.h"
#import "ViewPointManager.h"
#import "CHDraggableView.h"
#import "ALThreadEngine.h"
#import "ViewData.h"
#import "PersonalDataViewController.h"
#import "ALXMPPEngine.h"
#import "NewsInfoViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize datalist = _datalist;
@synthesize searchDatalist = _searchDatalist;
@synthesize adDataList = _adDataList;
@synthesize huodeUserInfo = _huodeUserInfo;
@synthesize userId = _userId;
@synthesize forumArray = _forumArray;
@synthesize threadArray = _threadArray;
@synthesize collectNumArray = _collectNumArray;
@synthesize selectFlag = _selectFlag;

#define NOTIFICATION_VIEWCONTROLLER_PUSH @"BAKUEIF6YO2I3G4FOTQWU7ETRO23LBHRDO2847FUIO2GHO84"
#define ADVIEWIMAGENUMBER 5

- (void)dealloc
{
    [_selectFlag release];
    [_collectNumArray release];
    [_threadArray release];
    [_forumArray release];
    [_userId release];
    [_huodeUserInfo release];
    [_adDataList release]; _adDataList=nil;
    [_searchDatalist release]; _searchDatalist=nil;
    [_datalist release]; _datalist=nil;
    
    [super dealloc];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [ViewData defaultManager].showVc = 0;
}

- (void)refrashfordelete
{
    [self beginPulldownAnimation];
    
    self.isPulldown = YES;
    
    [self requestCollectNum];
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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.97 blue:0.96 alpha:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"showLeftView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refrashfordelete) name:@"deleteThreadSucceed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refrashTableView) name:REFRESHUI object:nil];
    

    isSearch = NO;
    isShowClass = NO;
    _classTableView=nil;
    isShowChatView = NO;
    searchDistance = YES;
    isType = NO;

    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    self.adDataList = [NSMutableArray arrayWithCapacity:0];
    self.searchDatalist = [NSMutableArray arrayWithCapacity:0];
    self.forumArray = [NSMutableArray arrayWithCapacity:0];
    self.huodeUserInfo = [NSMutableArray arrayWithCapacity:0];
    self.threadArray = [NSMutableArray arrayWithCapacity:0];
    self.collectNumArray = [NSMutableArray arrayWithCapacity:0];
    
    
    [self.forumArray addObject:@[@"0",@"全部"]];

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
    
    naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    naviView.clipsToBounds = YES;
    [naviView release];
    
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
    
    classLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    classLabel.text = @"全部";
    classLabel.font = [UIFont systemFontOfSize:20];
    classLabel.textColor = [UIColor whiteColor];
    classLabel.backgroundColor = [UIColor clearColor];
    [classLabel setTextAlignment:NSTextAlignmentCenter];
    classLabel.center = CGPointMake(160, 23);
    [naviView addSubview:classLabel];
    [classLabel release];

    
    UIButton *changeLabelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeLabelBtn.frame = CGRectMake(0, 0, 80, 30);
    [changeLabelBtn addTarget:self action:@selector(changeLabel:) forControlEvents:UIControlEventTouchUpInside];
    changeLabelBtn.center = CGPointMake(160, 25);
    [naviView addSubview:changeLabelBtn];
    
    
    textfieldImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0029_Search_1.png"]];
    textfieldImage1.frame = CGRectMake(10, 50, 90, 34);
    [backgroundView addSubview:textfieldImage1];
    textfieldImage1.userInteractionEnabled = YES;
    [textfieldImage1 release];
    
    textfieldImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0029_Search_2.png"]];
    textfieldImage2.frame = CGRectMake(100, 50, 160, 34);
    [backgroundView addSubview:textfieldImage2];
    textfieldImage2.userInteractionEnabled = YES;
    [textfieldImage2 release];
    
    textfieldImage3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0029_Search_3.png"]];
    textfieldImage3.frame = CGRectMake(textfieldImage2.frame.origin.x+textfieldImage2.frame.size.width, 50, 50, 34);
    [backgroundView addSubview:textfieldImage3];
    textfieldImage3.userInteractionEnabled = YES;
    [textfieldImage3 release];
    
    seacchTextfield = [[UITextField alloc] initWithFrame:CGRectMake(50, 55, 250, 25)];
    seacchTextfield.backgroundColor = [UIColor clearColor];
    seacchTextfield.borderStyle = UITextBorderStyleNone;
    seacchTextfield.delegate = self;
    seacchTextfield.text = @"请输入主题名称";
    seacchTextfield.textColor = [UIColor colorWithRed:0.49 green:0.79 blue:0.73 alpha:1];
    seacchTextfield.returnKeyType = UIReturnKeySearch;
    [backgroundView addSubview:seacchTextfield];
    [seacchTextfield release];
    
    cancelbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelbtn setImage:[UIImage imageNamed:@"_0001_取消2--1.png"] forState:UIControlStateNormal];
    cancelbtn.frame = CGRectMake(320, 62, 87/2, 30);
    [cancelbtn addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:cancelbtn];
    
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 123)];
    headView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
   
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 123)];
    _scrollView.delegate = self;
    _scrollView.tag = 2000;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.contentSize = CGSizeMake(320*ADVIEWIMAGENUMBER, 123);
    [headView addSubview:_scrollView];
    [_scrollView release];
    
    
    for (int i=0; i<ADVIEWIMAGENUMBER; i++)
    {
        AsyncImageView *_asyImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0+320*i, 0, 320, 123) ImageState:1];
        _asyImageView.autoImage = YES;
        _asyImageView.defaultImage = 1;
        _asyImageView.image = [UIImage imageNamed:@"adImage.png"];
        _asyImageView.tag = 6000+i;
        [_asyImageView addTarget:self action:@selector(showBanner:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_asyImageView];
        [_asyImageView release];
    }
    
    _control = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    _control.center = CGPointMake(160, 115);
    _control.numberOfPages = ADVIEWIMAGENUMBER;
    _control.currentPage = 0;
    _control.pageIndicatorTintColor = [UIColor grayColor];
    _control.currentPageIndicatorTintColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [headView addSubview:_control];
    [_control release];
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    footView.backgroundColor = [UIColor clearColor];
    
    showMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showMoreBtn.frame = CGRectMake(0, 0, 280, 40);
    [showMoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    [showMoreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [showMoreBtn addTarget:self action:@selector(showMoreThreads:) forControlEvents:UIControlEventTouchUpInside];
    showMoreBtn.center = CGPointMake(160, 30);
    [footView addSubview:showMoreBtn];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(0, 0, 20, 20);
    _activityView.center = CGPointMake(100, 20);
    [showMoreBtn addSubview:_activityView];
    [_activityView release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 320, SCREEN_HEIGHT-90-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 5000;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.tableHeaderView = headView;
    _tableView.tableFooterView = footView;
    [backgroundView addSubview:_tableView];
    [headView release];
    [footView release];
    [_tableView release];
    
    
    distanceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    distanceBtn.frame = CGRectMake(61, 95, 202/2, 54/2);
    [distanceBtn setBackgroundImage:[UIImage imageNamed:@"_0000_图层-1.png"] forState:UIControlStateNormal];
    [distanceBtn addTarget:self action:@selector(changeSearchType:) forControlEvents:UIControlEventTouchUpInside];
    distanceBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [distanceBtn setTitle:@"距 离" forState:UIControlStateNormal];
    [distanceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviView addSubview:distanceBtn];
    distanceBtn.tag = 101;
    
    rewardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rewardBtn.frame = CGRectMake(162, 95, 202/2, 54/2);
    [rewardBtn setBackgroundImage:[UIImage imageNamed:@"_0005__-副本-19.png"] forState:UIControlStateNormal];
    [rewardBtn addTarget:self action:@selector(changeSearchType:) forControlEvents:UIControlEventTouchUpInside];
    rewardBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rewardBtn setTitle:@"悬 赏" forState:UIControlStateNormal];
    [rewardBtn setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [naviView addSubview:rewardBtn];
    rewardBtn.tag = 102;
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.tag = 5001;
    _searchTableView.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:_searchTableView];
    _searchTableView.alpha=0;
    [_searchTableView release];
    
    [self addRefreshHeaderView];
    
    [self requestCollectNum];
    
    [self updateloadUserLocation];
    
    if ([[ALUserEngine defauleEngine] isLoggedIn]==YES)
    {
        [self loginUserChat];
    }
}

- (void)loginUserChat
{
    [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            
        }
    }];
}


#pragma mark 创建广告
- (void)updateAdView
{
    for (int i=0; i<self.adDataList.count; i++)
    {
        NSMutableDictionary *dic = [self.adDataList objectAtIndex:i];
        NSMutableArray *array = [dic objectForKey:@"imageAry"];
        NSString *url = [[array objectAtIndex:0] objectForKey:@"imageUrl"];
    
        AsyncImageView *_asyImageView = (AsyncImageView *)[headView viewWithTag:6000+i];
        _asyImageView.urlString = url;
    }
    
    _scrollView.contentSize = CGSizeMake(320*self.adDataList.count, 123);
    _scrollView.contentOffset = CGPointMake(0, 0);
    _control.numberOfPages = self.adDataList.count;
    _control.currentPage = 0;
    
    [_tableView reloadData];
}

#pragma mark 显示用户信息
- (void)showUserInfo:(AsyncImageView *)sender
{
    User *_user = nil;
    _user = [[self.threadArray objectAtIndex:sender.tag] postUser];
    
    
    BOOL from;
    
    
    if (_user)
    {
        if ([[ALUserEngine defauleEngine].user.objectId isEqualToString:_user.objectId])
        {
            from=YES;
        }
        else
        {
            from=NO;
        }
        
        PersonalDataViewController *personal = [[PersonalDataViewController alloc] initWithUser:_user FromSelf:from SelectFromCenter:YES];
        [self.navigationController pushViewController:personal AnimatedType:MLNavigationAnimationTypeOfScale];
        [personal release];
    }
}

#pragma mark 显示banner信息
- (void)showBanner:(AsyncImageView *)sender
{
    if (self.adDataList.count==0)
    {
        return;
    }
    
    Thread *_temp = nil;
    _temp = [[self.adDataList objectAtIndex:sender.tag-6000] objectForKey:@"thread"];
    
    NSDictionary *_dic = [self.adDataList objectAtIndex:sender.tag-6000];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"主题已被删除" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark 显示更多消息
- (void)showMoreThreads:(UIButton *)sender
{
    if(self.isRequest==YES)
    {
        return;
    }
    
    
    if (self.selectFlag)
    {
        self.isShowMore = YES;
        
        [self requestFlagThreads];
        
        return;
    }
    
    
    self.isRequest = YES;

    __block typeof(self) bself = self;
    
    [_activityView startAnimating];
    [showMoreBtn setTitle:@"加载中" forState:UIControlStateNormal];
    
    [self requestMoreThreadOfForum];
    
//    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
//    {
//        [self requestMoreThreadOfForum];
//        
//        return;
//    }
//    
//    
//    [[ALThreadEngine defauleEngine] getMyFaviconThreadNotContainedIn:nil block:^(NSArray *threads, NSError *error) {
//        
//        
//        if(threads.count>0 && !error)
//        {
//            int count = threads.count;
//            for (int i=0; i<count; i++)
//            {
//                Thread *_thread = [threads objectAtIndex:i];
//                [bself.collectNumArray addObject:_thread.objectId];
//                
//            }
//        }
//        
//        [bself requestMoreThreadOfForum];
//    }];
}

- (void)requestMoreThreadOfForum
{
    self.isShowMore = YES;
    
    __block typeof(self) bself = self;
    
    __block UIButton *__loadbtn = showMoreBtn;
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALThreadEngine defauleEngine] getForumsWithBlock:^(NSArray *forums, NSError *error) {
 
        
        if(!error && forums.count>0)
        {
            int count = forums.count;
            for(int i=0;i<count;i++)
            {
                Forum *_tempforum = [forums objectAtIndex:i];
                NSString *_name = _tempforum.name;
            
                if([_name isEqualToString:@"问答"])
                {
                    
                    [[ALThreadEngine defauleEngine] getThreadsWithForum:_tempforum notContainedIn:bself.threadArray block:^(NSArray *threads, NSError *error) {
                        
                        int counts = threads.count;
                        
                        if(counts>0 && !error)
                        {
                            [bself performSelectorInBackground:@selector(downLoadThreads:) withObject:threads];
                        }
                        
                        
                        if(counts==0 && !error)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有更多" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alert show];
                            [alert release];
                            
                            bself.isRequest = NO;
                            bself.isShowMore = NO;
                            [__activity stopAnimating];
                            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                        }
                        
                        if(error)
                        {
                            bself.isRequest = NO;
                            bself.isShowMore = NO;
                            [__activity stopAnimating];
                            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
                        }
                      
                        
                    }];
                }
     
            }
            
        }
        else
        {
            [bself doneLoadingTableViewData];
            
            bself.isRequest = NO;
            bself.isShowMore = NO;
            [__activity stopAnimating];
            [__loadbtn setTitle:@"显示更多" forState:UIControlStateNormal];
        }
    }];

}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndScrolling
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    int page = _scrollView.contentOffset.x/320+1;//当前显示第几页
    _control.currentPage = page-1;//圆点选中第几个
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(isSearch==NO)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        
        if(scrollView.tag == 2000)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            //enshore that the end of scroll is fired because apple are twats...
            [self performSelector:@selector(scrollViewDidEndScrolling) withObject:nil afterDelay:0];
            
            return;
        }
    }
  
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isSearch==NO)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==5000)
    {
        NSDictionary *tempDic = [self.datalist objectAtIndex:indexPath.row];
        NSString *contentste = [tempDic objectForKey:@"tContents"];
        CGSize Size = [contentste sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        
        return 60+Size.height+40;
    }
    if(tableView.tag==5001)
    {
        return 70;
    }
    if(tableView.tag==5002)
    {
        return 50;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(tableView.tag==5000)
    {
        if (self.datalist.count==0)
        {
            return 0;
        }
        
        return self.datalist.count;
    }
    if(tableView.tag==5001)
    {
        if (self.searchDatalist.count==0)
        {
            return 0;
        }
        
        return self.searchDatalist.count;
    }
    if(tableView.tag==5002)
    {
        if (self.forumArray.count==0)
        {
            return 0;
        }
        
        return self.forumArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //问答列表页
    if(tableView.tag==5000)
    {
        static NSString *Cellidentifier = @"cell1";
        
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
        if(cell==nil)
        {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
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
        
        cell.headImageView.hidden = NO;
        
        cell.headImageView.urlString = [tempDic objectForKey:@"headview"];
        
        
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.headImageView.tag = indexPath.row;
        
        
        
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
        CGSize userNameSize = [cell.userName.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        cell.needText.frame = CGRectMake(70+userNameSize.width+10, 10, 50,20);
        cell.needText.hidden = NO;
        
        cell.title.text = [tempDic objectForKey:@"tTitle"];
        
        cell.content.text = [tempDic objectForKey:@"tContents"];
        CGSize contentSize = [cell.content.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:0];
        cell.content.frame = CGRectMake(70, 60, 240, contentSize.height+10);
        
        cell.timeImage.hidden = NO;
        cell.timeImage.frame = CGRectMake(70, 70+contentSize.height+10, 23/2, 22/2);
        
        cell.sendTime.text = [tempDic objectForKey:@"sendtime"];
        cell.sendTime.frame = CGRectMake(85, 70+contentSize.height+6, 100, 20);
        
        
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
    
    //搜索页
    if(tableView.tag==5001)
    {
        static NSString *Cellidentifier = @"cell1";
        
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
        if(cell==nil)
        {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSDictionary *dic = [self.searchDatalist objectAtIndex:indexPath.row];

        NSString *forunname = [dic objectForKey:@"forumName"];
        
        cell.headImageView.hidden = NO;
        cell.headImageView.urlString = [dic objectForKey:@"userUrl"];
        
        
        int _gender = [[dic objectForKey:@"gender"] intValue];
        
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
            cell.headCoverImage.image = [UIImage imageNamed:@"unfinduser.png.png"];
        }
        cell.headCoverImage.hidden = NO;
        
        
        if ([forunname isEqualToString:@"新闻"])
        {
            cell.userName.text = @"官方发布";
        }
        else
        {
            cell.userName.text = [dic objectForKey:@"userName"];
        }
        cell.userName.frame = CGRectMake(70, 10, 200, 20);
        
        cell.title.text = [NSString stringWithFormat:@"主题：%@",[dic objectForKey:@"title"]];
        cell.title.frame = CGRectMake(70, 35, 220, 20);
        cell.title.font = [UIFont systemFontOfSize:16];
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.frame = CGRectMake(0, 69, 320, 1);
        
        return cell;
    }
    
    //切换分类
    if(tableView.tag==5002)
    {
        static NSString *Cellidentifier = @"cell1";
        
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
//      if(cell==nil)
//      {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
//      }
        cell.backgroundColor = [UIColor clearColor];


        NSString *flagname;
        
        if(indexPath.row==0)
        {
            flagname = @"全部";
        }
        else
        {
            flagname = [[self.forumArray objectAtIndex:indexPath.row] name];
        }
        
        [cell.title setTextAlignment:NSTextAlignmentCenter];
        cell.title.text = flagname;
        cell.title.frame = CGRectMake(0, 17, 170, 20);

        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.image = [UIImage imageNamed:@"_0000_______.png"];
        cell.homeCellLine.frame = CGRectMake(0, 49, 361/2-8, 1);
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //问答页
    if(tableView.tag==5000)
    {
        Thread *_temp = nil;
        _temp = [self.threadArray objectAtIndex:indexPath.row];
        
        NSDictionary *_dic = [self.datalist objectAtIndex:indexPath.row];
        BOOL _collect = [[_dic objectForKey:@"collect"] boolValue];
        int _state = [[_dic objectForKey:@"state"] intValue];
        
        if(_temp)
        {
            InfoViewController *info = [[InfoViewController alloc] initWithThread:_temp Collect:_collect ThreadState:_state];
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
        
        return;
    }
    
    //搜索页
    if(tableView.tag==5001)
    {
        Thread *_temp = nil;
        _temp = [[self.searchDatalist objectAtIndex:indexPath.row] objectForKey:@"threads"];
        
        
        if(_temp)
        {
            int _threadState = _temp.state;
            
            int _collectNum;
            
            NSString *forunname = [[self.searchDatalist objectAtIndex:indexPath.row] objectForKey:@"forumName"];

            
            if([self.collectNumArray containsObject:_temp.objectId])
            {
                _collectNum = 1;
            }
            else
            {
                _collectNum = 0;
            }
            
            if ([forunname isEqualToString:@"新闻"])
            {
                 NewsInfoViewController *info = [[NewsInfoViewController alloc] initWithThread:_temp Collect:_collectNum ThreadState:_threadState Image:[[self.searchDatalist objectAtIndex:indexPath.row] objectForKey:@"imageAry"]];
                [self.navigationController pushViewController:info AnimatedType:MLNavigationAnimationTypeOfScale];
                [info release];
            }
            else
            {
                InfoViewController *info = [[InfoViewController alloc] initWithThread:_temp Collect:_collectNum ThreadState:_threadState];
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
        
        return;
    }
    
    //切换分类页
    if(tableView.tag==5002)
    {
        [self cancelClass];
        
        [self beginPulldownAnimation];
        
        if(indexPath.row==0)
        {
            classLabel.text = @"全部";
            self.selectFlag = nil;
            [self requestCollectNum];
        }
        else
        {
            self.selectFlag = [self.forumArray objectAtIndex:indexPath.row];
            
            classLabel.text = [NSString stringWithFormat:@"%@",self.selectFlag.name];

            [self requestFlagThreadsOfCollectNum];
        }
    }
}

- (void)requestFlagThreads
{
    
    __block typeof(self) bself = self;

    __block NSMutableArray *array;
    
    if (self.isShowMore==NO)
    {
        array = [[NSMutableArray alloc] init];
        
        [self.datalist removeAllObjects];
        [self.threadArray removeAllObjects];
    }
    else
    {
        array = [[NSMutableArray alloc] initWithArray:self.threadArray];
    }
 
    
    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
    [_dic setValue:self.selectFlag forKey:@"flag"];
    
    __block UITableView *__tableview = _tableView;
    
    [[ALThreadEngine defauleEngine] searchThreadsWithSearchInfo:_dic notContainedIn:array block:^(NSArray *objects, NSError *error) {
        
        int counts = objects.count;
       
        if(counts>0 && !error)
        {
            int count = objects.count;
            for(int i=0; i<count; i++)
            {
                Thread *_thread = [objects objectAtIndex:i];
                ThreadContent *_content = _thread.content;
                
                User *_tempuser = (User *)[_thread.postUser fetchIfNeeded];
                
                NSString *_username;
                NSString *_headViewUrl;
                NSNumber *_sex;
                
                if (_tempuser)
                {
                    _username = [NSString stringWithFormat:@"%@",_tempuser.nickName];
                    _headViewUrl = [NSString stringWithFormat:@"%@",_tempuser.headView.url];
                    _sex = [NSNumber numberWithBool:_tempuser.gender];
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
                NSString *_sendTime = [NSString stringWithFormat:@"%@",[self calculateDate:_thread.updatedAt]];
                NSNumber *_clickNum = [NSNumber numberWithInt:_thread.views];
                NSNumber *_threadState = [NSNumber numberWithInt:_thread.state];
                NSNumber *_commentNum = [NSNumber numberWithInt:_thread.numberOfPosts];
                
                NSNumber *_collectNum;
                
                
                if([bself.collectNumArray containsObject:_thread.objectId])
                {
                    _collectNum = [NSNumber numberWithInt:1];
                }
                else
                {
                    _collectNum = [NSNumber numberWithInt:0];
                }
                
                if (_thread)
                {
                    [bself.threadArray addObject:_thread];
                }
                
                NSMutableDictionary *_tempdic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_sex, @"gender",_ttitle,@"tTitle",_tcontent,@"tContents",_clickNum,@"clickNum",_sendTime,@"sendtime",_tid,@"Tid",_collectNum,@"collect", _threadState, @"state",_commentNum, @"commentNum",_username, @"userName", _headViewUrl , @"headview", _tempuser, @"user", nil];
                
                if (_tempdic)
                {
                    [bself.datalist addObject:_tempdic];
                }
                
                [_tempdic release];
                _tempdic = nil;
                
            }
            
            bself.isRequest=NO;
        }
        
        if (counts==0 && !error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询结果" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
            
            bself.isRequest=NO;
        }
        
        if (error)
        {
            [bself hideF3HUDError:nil];
            
            bself.isRequest=NO;
            
            return;
        }
        
        
        [bself hideF3HUDSucceed:nil];
        [__tableview reloadData];
        
        [bself doneLoadingTableViewData];
        
        bself.isRequest=NO;
    }];
}

- (void)requestFlagThreadsOfCollectNum
{
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest=YES;
    
    
    [self showF3HUDLoad:nil];
    
    __block typeof(self) bself = self;


    if (self.isShowMore==NO)
    {
        [self.collectNumArray removeAllObjects];
    }
 
    
    if (![[ALUserEngine defauleEngine] isLoggedIn])
    {
        [self requestFlagThreads];
        
        return;
    }
    
    
    [[ALThreadEngine defauleEngine] getMyFaviconThreadNotContainedIn:nil block:^(NSArray *threads, NSError *error) {
        
        if(threads.count>0 && !error)
        {
            
            int count = threads.count;
            for (int i=0; i<count; i++)
            {
                Thread *_thread = [threads objectAtIndex:i];
                [bself.collectNumArray addObject:_thread.objectId];
                
            }
        }
        
        [bself requestFlagThreads];
        
    }];
}

#pragma mark ChangeClass 切换显示分类

//关闭分类
- (void)cancelClass
{
    isShowClass = NO;

    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _classTableView.alpha = 0;
        classImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_classTableView removeFromSuperview];
        [classImageView removeFromSuperview];
        classImageView=nil;
        _classTableView=nil;
    }];
}



//切换显示标签
- (void)changeLabel:(UIButton *)sender
{
    if (self.forumArray.count<2)
    {
        return;
    }
    
    if(isShowClass==NO)
    {
        isShowClass = YES;
        
        if(_classTableView==nil)
        {
            classImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xialakuang.png"]];
            classImageView.frame = CGRectMake(74, 40+[ViewData defaultManager].versionHeight, 361/2, 421/2);
            [self.view addSubview:classImageView];
            classImageView.alpha = 0;
            [classImageView release];
            
            _classTableView = [[UITableView alloc] initWithFrame:CGRectMake(78, 48+[ViewData defaultManager].versionHeight, 361/2-8, 421/2-13) style:UITableViewStylePlain];
            _classTableView.dataSource = self;
            _classTableView.delegate = self;
            _classTableView.tag = 5002;
            _classTableView.backgroundColor = [UIColor clearColor];
            _classTableView.separatorColor = [UIColor clearColor];
            [self.view addSubview:_classTableView];
            _classTableView.alpha = 0;
            _classTableView.layer.cornerRadius = 8;
            [_classTableView release];
        }
        
        [_classTableView reloadData];
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
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

#pragma mark ShowLeftView/RightView

- (void)showLeftView
{
    [self.sidePanelController showLeftPanelAnimated:YES];
}

- (void)showRightView
{
    [self.sidePanelController showRightPanelAnimated:YES];

}


#pragma mark CollectNews - 收藏信息
- (void)collectNews:(UIButton *)sender
{
    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest= YES;
    
    Thread *_thread = [self.threadArray objectAtIndex:sender.tag];
    __block NSMutableDictionary *_dic = [self.datalist objectAtIndex:sender.tag];
    
    __block typeof(self) bself = self;
    
    if([[_dic objectForKey:@"collect"] intValue]==0)
    {
        [self showF3HUDLoad:nil];
        
        __block UITableView *__tableview = _tableView;
        
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
        
        __block UITableView *__tableview = _tableView;


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

#pragma mark cancelSearch 取消搜索
- (void)cancelSearch:(UIButton *)sender
{
    [self.searchDatalist removeAllObjects];
    [_searchTableView reloadData];
    
    [self.view sendSubviewToBack:_searchTableView];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        textfieldImage1.frame = CGRectMake(10, 50, 90, 34);
        textfieldImage2.frame = CGRectMake(100, 50, 160, 34);
        textfieldImage3.frame = CGRectMake(textfieldImage2.frame.origin.x+textfieldImage2.frame.size.width, 50, 50, 34);
        seacchTextfield.frame = CGRectMake(50, 55, 250, 25);
        cancelbtn.frame = CGRectMake(320, 62, 87/2, 30);
        naviView.frame = CGRectMake(0, 0, 320, 90);
        _searchTableView.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
        _tableView.alpha = 1;
        _searchTableView.alpha = 0;
        
        
    } completion:^(BOOL finished) {
        isSearch = NO;
    }];
    
    seacchTextfield.textColor = [UIColor colorWithRed:0.49 green:0.79 blue:0.73 alpha:1];
    seacchTextfield.text = @"请输入关键字";
    [seacchTextfield resignFirstResponder];

    
}

#pragma mark showSearch 显示搜索页面
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(isSearch==NO)
    {
        seacchTextfield.textColor = [UIColor whiteColor];
        seacchTextfield.text = @"";
        [self.view sendSubviewToBack:_searchTableView];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _tableView.alpha = 0;
            _searchTableView.alpha = 1;
            textfieldImage1.frame = CGRectMake(10, 10, 90, 34);
            textfieldImage2.frame = CGRectMake(100, 10, 110, 34);
            textfieldImage3.frame = CGRectMake(textfieldImage2.frame.origin.x+textfieldImage2.frame.size.width, 10, 50, 34);
            seacchTextfield.frame = CGRectMake(50, 15, 200, 25);
            cancelbtn.frame = CGRectMake(270, 12, 87/2, 30);
            naviView.frame = CGRectMake(0, -40, 320, 130);
            _searchTableView.frame = CGRectMake(0, 50+40, 320, SCREEN_HEIGHT-50-40);
            
        } completion:^(BOOL finished) {
            
            isSearch = YES;
            [seacchTextfield becomeFirstResponder];

        }];
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self requestSearch];

    return YES;
}

- (void)requestSearch
{
    if(seacchTextfield.text.length==0)
    {
        return;
    }
    
    __block typeof(self) bself = self;
    
    [self.searchDatalist removeAllObjects];
    
    [self showF3HUDLoad:nil];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:seacchTextfield.text forKey:@"title[like]"];
    
    
    if (searchDistance==YES)
    {
        [dic setValue:@"location" forKey:@"primaryOrderByAscending"];
    }
    else
    {
        [dic setValue:@"price" forKey:@"primaryOrderByDescending"];
    }
    
    [[ALThreadEngine defauleEngine] searchThreadsWithSearchInfo:dic notContainedIn:nil block:^(NSArray *objects, NSError *error) {
        
        int counts = objects.count;
        
        if(counts==0 && !error)
        {
            [bself hideF3HUDSucceed:nil];
        }
        
        if (error)
        {
            [bself hideF3HUDError:nil];
        }
        
        if (counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(searchThreads:) withObject:objects];
        }
        
    }];
}

- (void)changeSearchType:(UIButton *)sender
{
    [self.searchDatalist removeAllObjects];
    [_searchTableView reloadData];
    
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:101];
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:102];

    [btn1 setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"_0003_图层-2.png"] forState:UIControlStateNormal];
    
    [btn2 setTitleColor:[UIColor colorWithRed:0.08 green:0.6 blue:0.49 alpha:1] forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage imageNamed:@"_0005__-副本-19.png"] forState:UIControlStateNormal];


    if (sender.tag == 101)
    {
        [btn1 setBackgroundImage:[UIImage imageNamed:@"_0000_图层-1.png"] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        searchDistance = YES;
    }
    else
    {
        [btn2 setBackgroundImage:[UIImage imageNamed:@"_0002_形状-6-副本-3.png"] forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        searchDistance = NO;
    }
    
    [self requestSearch];
}

- (void)searchThreads:(NSArray *)objects
{
    int counts = objects.count;
    
    for (int i=0; i<counts; i++)
    {
        Thread *_threads = [objects objectAtIndex:i];
        NSString *forum = [NSString stringWithFormat:@"%@",_threads.forum.name];
        
        User *_user = (User *)[_threads.postUser fetchIfNeeded];
        
        NSString *title = _threads.title;
        
        NSString *username;
        NSString *userurl;
        NSNumber *_sex;
        
        if (_user)
        {
            username = [NSString stringWithFormat:@"%@",_user.nickName];
            userurl = [NSString stringWithFormat:@"%@",_user.headView.url];
            _sex = [NSNumber numberWithBool:_user.gender];
        }
        else
        {
            username = @"该用户已注销";
            userurl = @"0";
            _sex = [NSNumber numberWithInt:2];
        }
        
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc] init];
        
        [_dic setValue:_sex forKey:@"gender"];
        [_dic setValue:username forKey:@"userName"];
        [_dic setValue:userurl forKey:@"userUrl"];
        [_dic setValue:title forKey:@"title"];
        [_dic setValue:_threads forKey:@"threads"];
        [_dic setValue:forum forKey:@"forumName"];

        if ([forum isEqualToString:@"新闻"])
        {
            ThreadContent *_content = (ThreadContent *)[_threads.content fetchIfNeeded];
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

        [self.searchDatalist addObject:_dic];
        [_dic release];
        _dic=nil;
        
    }
    
    [self performSelectorOnMainThread:@selector(refreshSearchThreads) withObject:nil waitUntilDone:NO];
}

- (void)refreshSearchThreads
{
    [_searchTableView reloadData];
    
    [self hideF3HUDSucceed:nil];
}

#pragma mark 请求数据
- (void)requestForum
{
    
    __block typeof(self) bself = self;
    
    __block UITableView *__tableview = _classTableView;
 
    [[ALThreadEngine defauleEngine] getForumsWithBlock:^(NSArray *forums, NSError *error) {
        
        if(!error && forums.count>0)
        {
            int count = forums.count;
            for(int i=0;i<count;i++)
            {
                Forum *_tempforum = [forums objectAtIndex:i];
                NSString *_name = _tempforum.name;

                AVRelation *_pfflag = _tempforum.threadFlag;
               
                [[_pfflag query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if(objects.count>0 && !error)
                    {
                        [bself.forumArray removeAllObjects];
                        
                        [bself.forumArray addObject:@[@"0",@"全部"]];

                        for(int i=0;i<objects.count;i++)
                        {
                            ThreadFlag *_ttype = [objects objectAtIndex:i];
                            [bself.forumArray addObject:_ttype];
                        }
                        
                        [__tableview reloadData];
                    }
                    
                }];
                
                
                if([_name isEqualToString:@"新闻"])
                {
                    
                    [[ALThreadEngine defauleEngine] getThreadsWithForum:_tempforum notContainedIn:nil block:^(NSArray *threads, NSError *error) {
                        
                        if(!error && threads.count>0)
                        {
                            [bself performSelectorInBackground:@selector(downLoadAdImage:) withObject:threads];
                        }
                        
                    }];
                }
//
                if([_name isEqualToString:@"问答"])
                {

                    [[ALThreadEngine defauleEngine] getThreadsWithForum:_tempforum notContainedIn:nil block:^(NSArray *threads, NSError *error) {
                        
                        if(threads.count>0 && !error)
                        {
                            [self performSelectorInBackground:@selector(downLoadThreads:) withObject:threads];
                        }
                        
                    }];
                }
            }
      
        }
        else
        {
            bself.isRequest = NO;
            bself.isPulldown = NO;

            [bself doneLoadingTableViewData];
            [bself hideF3HUDError:nil];
        }
        
       
    }];
    
}

- (void)downLoadThreads:(NSArray *)threads
{
    
    NSMutableArray *ary1 = [[NSMutableArray alloc] init];
    NSMutableArray *ary2 = [[NSMutableArray alloc] init];
    
    for(int i=0; i<threads.count; i++)
    {
        Thread *_thread = [threads objectAtIndex:i];
        ThreadContent *_content = _thread.content;
        
        User *_tempuser = (User *)[_thread.postUser fetchIfNeeded];
        
        NSString *_username;
        NSString *_headViewUrl;
        NSNumber *_sex;
        
        if (_tempuser)
        {
            _username = [NSString stringWithFormat:@"%@",_tempuser.nickName];
            _headViewUrl = [NSString stringWithFormat:@"%@",_tempuser.headView.url];
            _sex = [NSNumber numberWithBool:_tempuser.gender];
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
        NSString *_sendTime = [NSString stringWithFormat:@"%@",[self calculateDate:_thread.updatedAt]];
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
        
        if (_thread)
        {
            [ary1 addObject:_thread];
        }
        
        NSMutableDictionary *_tempdic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_sex, @"gender",_ttitle,@"tTitle",_tcontent,@"tContents",_clickNum,@"clickNum",_sendTime,@"sendtime",_tid,@"Tid",_collectNum,@"collect", _threadState, @"state",_commentNum, @"commentNum",_username, @"userName", _headViewUrl , @"headview", _tempuser, @"user", nil];
        
        if (_tempdic)
        {
            [ary2 addObject:_tempdic];
        }
        
        [_tempdic release];
        _tempdic = nil;
        
    }
    
    if (self.isShowMore==NO)
    {
        [self.datalist removeAllObjects];
        [self.threadArray removeAllObjects];
    }

    [self.datalist addObjectsFromArray:ary2];
    [self.threadArray addObjectsFromArray:ary1];
    
    [ary1 release]; ary1=nil;
    [ary2 release]; ary2=nil;
    
    [self performSelectorOnMainThread:@selector(refreshThreads) withObject:nil waitUntilDone:NO];
}

- (void)refreshThreads
{
    if (self.isShowMore)
    {
        [_activityView stopAnimating];
        [showMoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    }
    else
    {
        [self doneLoadingTableViewData];
    }
    
    [_tableView reloadData];
    
    self.isRequest = NO;
    self.isShowMore = NO;
    
    [self hideF3HUDSucceed:@""];
}

- (void)downLoadAdImage:(NSArray *)threads
{
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    
    int counts = threads.count;

    if (counts<ADVIEWIMAGENUMBER)
    {
        for (int i=0; i<threads.count; i++)
        {
            Thread *_thread = [threads objectAtIndex:i];
            ThreadContent *_content = _thread.content;
            NSArray *imageAry = [[_content.images query] findObjects];
  
            
            if (imageAry.count>0)
            {
                
                NSMutableArray *imageAry = [NSMutableArray arrayWithCapacity:0];
                
                for (int i=0; i<imageAry.count; i++)
                {
                    ThreadImage *_image = [imageAry objectAtIndex:i];
                    
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                    [_dic setValue:_image.image.url forKey:@"imageUrl"];
                    [_dic setValue:_image.imageSize forKey:@"imageSize"];
                    [imageAry addObject:_dic];
                }
                
                NSString *sendtime = [self calculateDate:_thread.createdAt];
                NSString *click = [NSString stringWithFormat:@"%d",_thread.views];
                NSString *comments = [NSString stringWithFormat:@"%d",_thread.numberOfPosts];
                NSString *state = [NSString stringWithFormat:@"%d",_thread.state];
                
                NSNumber *collect;
                
                if([self.collectNumArray containsObject:_thread.objectId])
                {
                    collect = [NSNumber numberWithInt:1];
                }
                else
                {
                    collect = [NSNumber numberWithInt:0];
                }
                
                
                NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                
                [_dic setValue:_thread forKey:@"thread"];
                [_dic setValue:_thread.title forKey:@"title"];
                [_dic setValue:_content.text forKey:@"content"];
                [_dic setValue:sendtime forKey:@"sendTime"];
                [_dic setValue:click forKey:@"click"];
                [_dic setValue:comments forKey:@"comments"];
                [_dic setValue:collect forKey:@"collect"];
                [_dic setValue:state forKey:@"state"];
                [_dic setValue:imageAry forKey:@"imageAry"];
                [_dic setValue:collect forKey:@"collect"];
                
                [ary addObject:_dic];
            }
        }
    }
    else
    {
        for (int i=0; i<ADVIEWIMAGENUMBER; i++)
        {
            Thread *_thread = [threads objectAtIndex:i];
            ThreadContent *_content = _thread.content;
            NSArray *imageAry = [[_content.images query] findObjects];
            
            if (imageAry.count>0)
            {
                
                NSMutableArray *tempary = [NSMutableArray arrayWithCapacity:0];
                
                for (int i=0; i<imageAry.count; i++)
                {
                    ThreadImage *_image = [imageAry objectAtIndex:i];
                    
                    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                    [_dic setValue:_image.image.url forKey:@"imageUrl"];
                    [_dic setValue:_image.imageSize forKey:@"imageSize"];
                    [tempary addObject:_dic];
                }
                
                NSString *sendtime = [self calculateDate:_thread.createdAt];
                NSString *click = [NSString stringWithFormat:@"%d",_thread.views];
                NSString *comments = [NSString stringWithFormat:@"%d",_thread.numberOfPosts];
                NSString *state = [NSString stringWithFormat:@"%d",_thread.state];
                
                NSNumber *collect;
                
                if([self.collectNumArray containsObject:_thread.objectId])
                {
                    collect = [NSNumber numberWithInt:1];
                }
                else
                {
                    collect = [NSNumber numberWithInt:0];
                }
                
                
                NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                
                [_dic setValue:_thread forKey:@"thread"];
                [_dic setValue:_thread.title forKey:@"title"];
                [_dic setValue:_content.text forKey:@"content"];
                [_dic setValue:sendtime forKey:@"sendTime"];
                [_dic setValue:click forKey:@"click"];
                [_dic setValue:comments forKey:@"comments"];
                [_dic setValue:collect forKey:@"collect"];
                [_dic setValue:state forKey:@"state"];
                [_dic setValue:tempary forKey:@"imageAry"];
                [_dic setValue:collect forKey:@"collect"];

                [ary addObject:_dic];
            }

        }
    }
    
    [self.adDataList removeAllObjects];
    
    [self.adDataList addObjectsFromArray:ary];
    
    [ary release]; ary=nil;
    
    [self performSelectorOnMainThread:@selector(backToMainViewUpdate) withObject:nil waitUntilDone:NO];
}

- (void)backToMainViewUpdate
{
    [self updateAdView];
}


- (void)requestCollectNum
{
    [self showF3HUDLoad:@""];
    
    if(self.isRequest==YES)
    {
        return;
        
    }
    
    self.isRequest = YES;

    __block typeof(self) bself = self;
    
    if([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        [self requestForum];
        
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
        
        [bself requestForum];
        
    }];
}

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
    self.isShowMore = NO;

    if(self.selectFlag!=nil)
    {
        
        [self requestFlagThreadsOfCollectNum];
        
        return;
    }
    
    self.isPulldown = YES;
    
	[self requestCollectNum]; //从新读取数据
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


#pragma mark - 自动更新用户坐标
- (void)updateloadUserLocation
{
    if ([ALGPSHelper OpenGPS].latitude!=0 && [ALGPSHelper OpenGPS].longitude!=0)
    {
        [[ALUserEngine defauleEngine] uploadPointWithLatitude:[ALGPSHelper OpenGPS].latitude longitude:[ALGPSHelper OpenGPS].longitude place:[ALGPSHelper OpenGPS].LocationName block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                NSLog(@"定位上传成功！");
                
                [[ALUserEngine defauleEngine].user refreshInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                    if (!error)
                    {
                        NSLog(@"用户刷新成功！");
                    }
                }];
            }
        }];
    }
    else
    {
        NSLog(@"用户定位失败！");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
