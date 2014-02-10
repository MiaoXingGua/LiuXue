//
//  UnReadMessageListViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-27.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "UnReadMessageListViewController.h"
#import "ViewData.h"
#import "CustomCell.h"
#import "ALXMPPEngine.h"
#import "ALUserEngine.h"
#import "ChatViewController.h"
#import "MessageCenter.h"


#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@interface UnReadMessageListViewController ()

@end

@implementation UnReadMessageListViewController
@synthesize userlist = _userlist;

- (void)dealloc
{

    [_userlist release]; _userlist=nil;
    [_faceMap release]; _faceMap=nil;
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [ViewData defaultManager].isShowUnReadView=YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self beginPulldownAnimation];
}

- (void)readChatUserList
{
    if (self.isRefresh==YES)
    {
        return;
    }
    
    self.isRefresh=YES;
    
    __block typeof(self) bself = self;
    

    [[ALXMPPEngine defauleEngine] getLinkerOfRecentWithBlock:^(NSArray *likers, NSError *error) {
        
        int counts = likers.count;
        
        if (counts>0 && !error)
        {
            [bself performSelectorInBackground:@selector(downLoadUser:) withObject:likers];
        }
        if (counts==0 && !error)
        {
            [bself performSelector:@selector(refreshUI) withObject:nil afterDelay:1];
        }
        if (error)
        {
            [bself performSelector:@selector(refreshUI) withObject:nil afterDelay:1];
        }
 
    }];
}

- (void)downLoadUser:(NSArray *)array
{
    [self.userlist removeAllObjects];

    for (int i=0; i<array.count; i++)
    {
        User *_tempuser = (User *)[[array objectAtIndex:i] fetchIfNeeded];
        NSLog(@"%@,%@,%@",_tempuser.nickName,_tempuser.headView.url,_tempuser.userKey);
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_tempuser,@"user",@"0",@"unreadnum", nil];
        [self.userlist addObject:dic];
    }
    
    [self readAllUnReadMessages];
}

- (void)addUnReadNum:(NSNotification *)info
{
    User *_user = [info object];
    BOOL haveUser=NO;
    int indexofarray;
    
    for (int i=0; i<self.userlist.count; i++)
    {
        NSMutableDictionary *dic = [self.userlist objectAtIndex:i];
        User *user = [dic objectForKey:@"user"];
        
        if ([user.objectId isEqualToString:_user.objectId])
        {
            indexofarray = i;
            haveUser=YES;
        }
    }
    
    if (haveUser==YES)
    {
        NSMutableDictionary *dic = [self.userlist objectAtIndex:indexofarray];

        int num = [[dic objectForKey:@"unreadnum"] intValue];
        [dic setObject:[NSString stringWithFormat:@"%d",num+1] forKey:@"unreadnum"];
        [self.userlist exchangeObjectAtIndex:indexofarray withObjectAtIndex:0];
        
        [_tableView reloadData];
    }
    else
    {
        [self performSelectorInBackground:@selector(downLoadUserTwo:) withObject:_user];
    }
}

- (void)downLoadUserTwo:(User *)user
{
    User *_tempuser = (User *)[user fetchIfNeeded];
    
    __block NSMutableDictionary *tempdic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_tempuser,@"user",@"0",@"unreadnum", nil];
    
    
    __block typeof(self) bself = self;

    __block UITableView *__tableview = _tableView;
    
    [[ALXMPPEngine defauleEngine] getALLUnreadMessageWithBlock:^(NSDictionary *messages, NSError *error) {
        
        if (!error)
        {
            NSArray *array = [messages objectForKey:@"chat"];
            
            for (int i=0; i<array.count; i++)
            {
                NSDictionary *dic = [array objectAtIndex:i];
                
                User *_user = [dic objectForKey:@"user"];
                
                int num = [[[[dic objectForKey:@"message"] objectAtIndex:0] objectForKey:@"count"] intValue];
                
                if ([_tempuser.objectId isEqualToString:_user.objectId])
                {
                    [tempdic setObject:[NSString stringWithFormat:@"%d",num] forKey:@"unreadnum"];
                    [bself.userlist insertObject:tempdic atIndex:0];
                }
            }
        }
        
        [__tableview reloadData];
        [bself doneLoadingTableViewData];
    }];
}

#pragma mark - 被迫下线
- (void)userLogOut
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的账号已下线" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    alert=nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self back];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUnReadNum:) name:@"addUnReadNum" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:NOTIFICATION_XMPP_LOG_OUT object:nil];

    
    self.view.backgroundColor = [UIColor whiteColor];

    self.userlist = [NSMutableArray arrayWithCapacity:0];
    
    UIImageView *stateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0011111111_bg.png"]];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    [self.view addSubview:stateView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIImageView *bgImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0029_Background.png"]];
    bgImageview.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    [backgroundView addSubview:bgImageview];
    [bgImageview release];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-49-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    UIImageView *navigationBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0011111111_bg.png"]];
    navigationBarView.frame = CGRectMake(0, 0, 320, 45);
    [backgroundView addSubview:navigationBarView];
    navigationBarView.userInteractionEnabled = YES;
    [navigationBarView release];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    title.center = CGPointMake(160, 23);
    title.text = @"消息";
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
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editBtn.frame = CGRectMake(270, 10, 40, 25);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:editBtn];
    
    self.isEditing=NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    if ([[languages objectAtIndex:0] hasPrefix:@"zh"])
    {
        _faceMap = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceMap_ch" ofType:@"plist"]] retain];
    } else
    {
        _faceMap = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceMap_en" ofType:@"plist"]] retain];
    }
    
    [self addRefreshHeaderView];
}

- (void)beginPulldownAnimation
{
    [_tableView setContentOffset:CGPointMake(0, -75) animated:YES];
    [_refreshHeaderView performSelector:@selector(egoRefreshScrollViewDidEndDragging:) withObject:_tableView afterDelay:0.5];
}


- (void)readAllUnReadMessages
{
    __block typeof(self) bself = self;
    
    [[ALXMPPEngine defauleEngine] getALLUnreadMessageWithBlock:^(NSDictionary *messages, NSError *error) {
        
        if (!error)
        {
            NSArray *array = [messages objectForKey:@"chat"];

            for (int i=0; i<array.count; i++)
            {
                NSDictionary *dic = [array objectAtIndex:i];
                
                User *_user = [dic objectForKey:@"user"];
                
                int num = [[[[dic objectForKey:@"message"] objectAtIndex:0] objectForKey:@"count"] intValue];
                
                for (int i=0; i<self.userlist.count; i++)
                {
                    NSMutableDictionary *temp = [self.userlist objectAtIndex:i];
                    User *_listuser = [temp objectForKey:@"user"];
                    
                    if ([_listuser.objectId isEqualToString:_user.objectId])
                    {
                        [temp setObject:[NSString stringWithFormat:@"%d",num] forKey:@"unreadnum"];
                    }
                    
                }
            }
        }
        
        [bself performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
        
    }];
    
}

- (void)refreshUI
{
    [_tableView reloadData];
    [self doneLoadingTableViewData];
    self.isRefresh=NO;
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
    return self.userlist.count;
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
    
    NSDictionary *_dic = [self.userlist objectAtIndex:indexPath.row];
    
    User *_user = [_dic objectForKey:@"user"];
    
    int unreadNums = [[_dic objectForKey:@"unreadnum"] intValue];
    
    int _gender = _user.gender;
    
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
    cell.headImageView.urlString = _user.headView.url;
    cell.headImageView.center = CGPointMake(30, 35);
    
    cell.userName.hidden = NO;
    cell.userName.text = _user.nickName;
    cell.userName.frame = CGRectMake(65, 20, 240, 20);
    cell.userName.font = [UIFont systemFontOfSize:16];
    cell.userName.textColor = [UIColor whiteColor];
    
//    cell.content.frame = CGRectMake(65, 35, 220, 20);
//    cell.content.font = [UIFont systemFontOfSize:16];
//    cell.content.numberOfLines=0;
    
//    if ([_type isEqualToString:@"text"])
//    {
//        NSString *_text = [_messageDic objectForKey:@"url"];
//                
//        if (cell.content.subviews.count>0)
//        {
//            UIView *subview = [cell.content.subviews objectAtIndex:0];
//            [subview removeFromSuperview];
//        }
//        
//        UIView *view = [self assembleMessageAtIndex:_text from:NO];
//        [cell.content addSubview:view];;
//        
//    }
//    if ([_type isEqualToString:@"image"])
//    {
//        cell.content.text = @"收到一张图片";
//    }
//    if ([_type isEqualToString:@"voice"])
//    {
//        cell.content.text = @"收到一条语音";
//    }
//    if ([_type isEqualToString:@"video"])
//    {
//        cell.content.text = @"收到一段视频";
//    }
    
    
    NSString *unReadStr = [NSString stringWithFormat:@"%d",unreadNums];

    
    if (unReadStr.length>2)
    {
        cell.title.text = @"99+";
        cell.title.frame = CGRectMake(0, 0, 12+3*7, 17);

    }
    else
    {
        cell.title.text = unReadStr;
        cell.title.frame = CGRectMake(0, 0, 12+unReadStr.length*6, 17);

    }
    
    [cell.title setTextAlignment:NSTextAlignmentCenter];
    cell.title.font = [UIFont systemFontOfSize:13];
    cell.title.layer.cornerRadius = 8;
    cell.title.layer.borderWidth = 1.5;
    cell.title.center = CGPointMake(50, 20);
    cell.title.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.title.font = [UIFont boldSystemFontOfSize:13];
    cell.title.backgroundColor = [UIColor redColor];
    cell.title.textColor = [UIColor whiteColor];
    
    if (unreadNums==0)
    {
        cell.title.hidden=YES;
    }
//    cell.voiceBtn.hidden = NO;
//    cell.voiceBtn.frame = CGRectMake(0, 0, 50, 25);
//    cell.voiceBtn.center = CGPointMake(270, 35);
//    [cell.voiceBtn setTitle:@"聊天" forState:UIControlStateNormal];
//    [cell.voiceBtn addTarget:self action:@selector(attentionUser:) forControlEvents:UIControlEventTouchUpInside];
//    cell.voiceBtn.tag = indexPath.row;
    
    cell.homeCellLine.hidden = NO;
    cell.homeCellLine.center = CGPointMake(160, 70);
    cell.homeCellLine.image = [UIImage imageNamed:@"_0004_line-right@2x.png"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_dic = [self.userlist objectAtIndex:indexPath.row];
    
    User *_user=nil;
    _user = [_dic objectForKey:@"user"];
    
    if (_user)
    {
        
        [[MessageCenter defauleCenter] removeChatView:nil];

        ChatViewController *chatView = [[ChatViewController alloc] initWithUser:_user fromNotifition:nil IsFromNotifition:YES];
        [self.navigationController pushViewController:chatView AnimatedType:MLNavigationAnimationTypeOfNone];
        [chatView release];
        
//        [[ALXMPPEngine defauleEngine] updateUnreadStateOfUser:_user block:^(BOOL succeeded, NSError *error) {
//            
//            if (succeeded && !error)
//            {
//                NSLog(@"修改未读状态成功！！");
//            }
//            else
//            {
//                NSLog(@"修改未读状态失败！！");
//            }
//        }];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableDictionary *dic = [self.userlist objectAtIndex:indexPath.row];
        User *_user = [dic objectForKey:@"user"];
        
        if (_user)
        {
            __block typeof(self) bself = self;

            __block UITableView *__tableview = _tableView;
            
            //修改用户未读消息状态
            [[ALXMPPEngine defauleEngine] updateUnreadStateOfUser:_user block:^(BOOL succeeded, NSError *error) {
                
            }];
            
            //移除联系人
            [[ALXMPPEngine defauleEngine] delLinkerOfRecentWithLinker:_user block:^(BOOL success) {
                
                if (success)
                {
                    [bself.userlist removeObjectAtIndex:indexPath.row];
                    [__tableview reloadData];
                }
            }];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


#define KFacialSizeWidth  20
#define KFacialSizeHeight 20
#define MAX_WIDTH 200

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}


-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = [array retain];
    [array release];
    UIFont *fon = [UIFont systemFontOfSize:14.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++)
        {
            NSString *str=[data objectAtIndex:i];
            NSLog(@"str--->%@",str);
            
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                NSLog(@"str(image)---->%@",str);
                
                
                NSString *name = [NSString stringWithFormat:@"[%@]",[str substringWithRange:NSMakeRange(1, str.length - 2)]];
                NSLog(@"%@",_faceMap);
                
                NSString *imageNameKey;
                
                NSArray *array = [_faceMap allKeys];
                for (int i=0; i<array.count; i++)
                {
                    NSString *_value = [_faceMap objectForKey:[array objectAtIndex:i]];
                    
                    if ([_value isEqualToString:name])
                    {
                        imageNameKey = [array objectAtIndex:i];
                        
                        NSLog(@"%@",imageNameKey);
                        
                    }
                }
                
                
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageNameKey]]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                upX=KFacialSizeWidth+upX;
                if (X<200) X = upX;
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 200;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(200, 40)];
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X<200) {
                        X = upX;
                    }
                }
            }
        }
    }
    [data release];
    returnView.frame = CGRectMake(0,0, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    // NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}

- (void)edit
{
    if (self.isEditing==YES)
    {
        [UIView animateWithDuration:0.2 animations:^{
            _tableView.editing=NO;

        } completion:^(BOOL finished) {
            [_tableView reloadData];
            self.isEditing=NO;
        }];
        
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            _tableView.editing=YES;
            
        } completion:^(BOOL finished) {
            [_tableView reloadData];
            self.isEditing=YES;
        }];
    }
}


- (void)back
{
    [ViewData defaultManager].isShowUnReadView=NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addUnReadNum" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_XMPP_LOG_OUT object:nil];
    
    [self.navigationController popViewControllerAnimated];
}


#pragma mark - addHeader&addFooter
- (void)addRefreshHeaderView
{
    if (_refreshHeaderView == nil)
    {
        _reloading = NO;
        
        _refreshHeaderView=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height) textColor:[UIColor whiteColor] beginStr:@"拉取历史记录" stateStr:@"松开加载" endStr:@"加载中" haveArrow:NO];
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
	[self readChatUserList]; //从新读取数据
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

@end
