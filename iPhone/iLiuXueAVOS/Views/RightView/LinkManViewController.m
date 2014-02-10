//
//  LinkManViewController.m
//  NightTalk
//
//  Created by superhomeliu on 13-6-9.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import "LinkManViewController.h"
#import "CustomCell.h"
#import "ViewData.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "CHDraggableView.h"
#import "ViewPointManager.h"
#import "MLNavigationController.h"
#import "ALXMPPEngine.h"
#import "PersonalDataViewController.h"
#import "ViewData.h"
#import "ALXMPPEngine.h"
#import "ALUserEngine.h"
#import "ChatViewController.h"
#import "AppDelegate.h"
#import "GroupViewController.h"
#import "VideoViewController.h"
#import "MessageCenter.h"
#import "UnReadMessageListViewController.h"

@interface LinkManViewController ()

@end

@implementation LinkManViewController
@synthesize grouplist = _grouplist;
@synthesize searchlist = _searchlist;
@synthesize personlist = _personlist;
@synthesize linktypeAry = _linktypeAry;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_linktypeAry release]; _linktypeAry=nil;
    [_personlist release]; _personlist=nil;
    [_grouplist release]; _grouplist=nil;
    [_searchlist release]; _searchlist=nil;
    
    [super dealloc];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (![[ALUserEngine defauleEngine] isLoggedIn])
    {
        if([ViewData defaultManager].homeVc!=nil)
        {
            MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].homeVc] autorelease];
            self.sidePanelController.centerPanel = n;
            
            return;
        }
        
        HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
        self.sidePanelController.centerPanel = n;
        [ViewData defaultManager].homeVc = home;
        
        return;
    }
    
    if (self.sidePanelController.centerPanelHidden==YES)
    {
        if (isEditing)
        {
            [self cancelSearchView];
        }
        
        [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2];
    }
    
    if ([[ALXMPPEngine defauleEngine] isLoggedIn])
    {
        [self readUnReadMessageNum];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)readUnReadMessageNum
{
  //  __block typeof(self) bself = self;
    
    __block UILabel *__unlabel = _unreadLabel;

    [[ALXMPPEngine defauleEngine] getALLUnreadMessageCountWithBlock:^(NSInteger messagesCount, NSError *error) {
        
        if (messagesCount>0 && !error)
        {
            __unlabel.hidden = NO;
            
            NSString *unReadStr = [NSString stringWithFormat:@"%d",messagesCount];
            
            if (unReadStr.length>2)
            {
                __unlabel.text = @"99+";
                
            }
            else
            {
                __unlabel.text = unReadStr;
            }
            
            __unlabel.frame = CGRectMake(0, 0, 12+unReadStr.length*6, 17);
            __unlabel.center = CGPointMake(212, 15);
        }
        else
        {
            __unlabel.hidden=YES;
        }
    }];
}

- (void)requestGroupList
{
    self.isRequest = YES;
    
    __block typeof(self) bself = self;
    
    __block UITableView *__tableview = _tableView;

    [[ALXMPPEngine defauleEngine] getGroupListWithBlock:^(NSArray *array, NSError *error) {
        
        int counts = array.count;
        
        if (counts>0 && !error)
        {
            [bself.grouplist removeAllObjects];

            for (int i=0; i<counts; i++)
            {
                IMGroupInfo *_group = [array objectAtIndex:i];
                
                NSString *_gid = _group.groupId;
                NSString *_gname = _group.name;
                NSString *_declared = _group.declared;
                NSString *_creattime = _group.created;
                NSNumber *_gNum = [NSNumber numberWithInteger:_group.count];
                NSNumber *_gtype = [NSNumber numberWithInteger:_group.type];
                NSString *_guser = _group.owner;
                
                NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
                
                [_dic setValue:_gid forKey:@"gId"];
                [_dic setValue:_gname forKey:@"gName"];
                [_dic setValue:_declared forKey:@"gDeclared"];
                [_dic setValue:_creattime forKey:@"gCreatTime"];
                [_dic setValue:_gNum forKey:@"gCount"];
                [_dic setValue:_gtype forKey:@"gType"];
                [_dic setValue:_guser forKey:@"gUser"];
                [_dic setValue:@"default" forKey:@"imageUrl"];
                [bself.grouplist addObject:_dic];

                [__tableview reloadData];
                
                bself.isRequest = NO;
                
                
                if (_group.groupId!=nil && _group.name!=nil)
                {
                    [[ALGroupEngine defauleEngine] getGroupImageWithGroupId:_gid block:^(AVFile *imageFile, NSError *error) {
                        
                        if (imageFile && !error)
                        {
                            NSString *url = [NSString stringWithFormat:@"%@",imageFile.url];
                            
                            for (NSMutableDictionary *dic in bself.grouplist)
                            {
                                if ([[dic objectForKey:@"gId"] isEqualToString:_gid])
                                {
                                    [dic setObject:url forKey:@"imageUrl"];
                                }
                            }
                            
                            
                            [__tableview reloadData];
                        }
                        
                    }];
                }
                
            }
            
            
        }
        
        if (counts==0 && !error)
        {
            bself.isRequest = NO;
            
        }
        
        if (error)
        {
            bself.isRequest = NO;
            NSLog(@"error=%@",[error userInfo]);
        }
    }];
}


- (void)requestFriendList
{
    __block typeof(self) bself = self;
    
    __block UITableView *__tableview = _tableView;
    
    self.isRequest = YES;
    
    [[ALUserEngine defauleEngine] refreashRelationWithUser:[ALUserEngine defauleEngine].user block:^(NSDictionary *relationInfo, NSError *error) {
        
        if (relationInfo && !error)
        {
            [bself.personlist removeAllObjects];
            
            NSArray *array = (NSArray *)[relationInfo objectForKey:@"friends"];
            NSArray *array2 = [relationInfo objectForKey:@"bilaterals"];

            int counts1 = array.count;
            int counts2 = array2.count;

            NSMutableArray *temp1 = [NSMutableArray array];
            NSMutableArray *temp2 = [NSMutableArray array];

            for (int i=0; i<counts1; i++)
            {
                User *_friend = [array objectAtIndex:i];
                
                [temp1 addObject:_friend];
            }
            
            [bself.personlist addObject:temp1];

            
            for (int i=0; i<counts2; i++)
            {
                User *_friend = [array2 objectAtIndex:i];
                
                [temp2 addObject:_friend];
            }
            
            [bself.personlist addObject:temp2];
            
            [__tableview reloadData];
            [bself hideF3HUDSucceed:nil];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        
        [bself doneLoadingTableViewData];
        bself.isRequest = NO;
    }];
    
}

- (void)showRightPanelView
{
    if ([ALUserEngine defauleEngine].isLoggedIn==NO)
    {
        [self showLogOutView];
    }
    
    
    if ([ALUserEngine defauleEngine].isLoggedIn==YES && [[ALXMPPEngine defauleEngine] isLoggedIn]==YES)
    {
//        [self requestFriendList];
//        [self requestGroupList];
        if (self.personlist.count==0)
        {
            [self requestFriendList];
        }
        
        if (self.grouplist.count==0)
        {
            [self requestGroupList];
        }
        
        [self hidenLogOutView];
        [self readUnReadMessageNum];
    }
    
    if ([ALUserEngine defauleEngine].isLoggedIn==YES && [[ALXMPPEngine defauleEngine] isLoggedIn]==NO)
    {
        [self beginLoginChat];
    }
    
    
    self.isBeginChat = NO;
    self.isRequest = NO;
    
    NSLog(@"open");
}

- (void)userLogOut_LinkView
{
    self.isBeginChat = NO;
    self.isRequest = NO;
    [self.grouplist removeAllObjects];
    [self.personlist removeAllObjects];
    [_tableView reloadData];
    
    if (isEditing==YES)
    {
        [self cancelSearchView];
    }
    
    [self showLogOutView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的账号已下线" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    alert=nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self creatView];
}

- (void)showLogOutView
{

    if(_logOutView!=nil)
    {
        [_logOutView removeFromSuperview];
        _logOutView=nil;
    }
    
    _logOutView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004_bg.png"]];
    _logOutView.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
    _logOutView.backgroundColor = [UIColor greenColor];
    _logOutView.userInteractionEnabled = YES;
    [self.view addSubview:_logOutView];
    [_logOutView release];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 130, 100, 30)];
    textLabel.text = @"开始聊天";
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:18];
    [_logOutView addSubview:textLabel];
    [textLabel release];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(200, 300, 274/2, 276/2);
    loginBtn.center = CGPointMake(200, SCREEN_HEIGHT/2);
    [loginBtn setImage:[UIImage imageNamed:@"_0014_开通-.png"] forState:UIControlStateNormal];
    [loginBtn setImage:[UIImage imageNamed:@"_0000_开通-点击.png"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(beginLoginChat) forControlEvents:UIControlEventTouchUpInside];
    [_logOutView addSubview:loginBtn];
    
    [self.view bringSubviewToFront:_logOutView];
}

- (void)hidenLogOutView
{
    if(_logOutView!=nil)
    {
        [UIView animateWithDuration:0.2 animations:^{
            _logOutView.alpha = 0;
        } completion:^(BOOL finished) {
            _logOutView.hidden = YES;

        }];
    }
}

- (void)loginChat
{
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        [self showLogOutView];
        
        return;
    }
    
    __block typeof(self) bself = self;
    
    
    [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hidenLogOutView];
            [bself requestFriendList];
            
            [ViewData defaultManager].autoLogin=YES;
            [[ViewData defaultManager] setNSTimer];
            
            bself.isRequest = NO;
            [bself hideF3HUDSucceed:nil];
        }
        else
        {
            [bself hideF3HUDError:nil];
            [bself showLogOutView];
            
            [ViewData defaultManager].autoLogin=NO;
            [[ViewData defaultManager] stopNSTimer];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请重新尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
        }
        
    }];

}

#pragma mark 登录聊天
- (void)beginLoginChat
{
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        [self showLogOutView];
        
        return;
    }
    
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest = YES;
    
    __block typeof(self) bself = self;
    

    [self showF3HUDLoad:nil];
    
    NSLog(@"登录！！！！！！");
    

    [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hidenLogOutView];
            [bself requestFriendList];
            [bself requestGroupList];
            [bself readUnReadMessageNum];
            
            [ViewData defaultManager].autoLogin=YES;
            [[ViewData defaultManager] setNSTimer];
            
            [ViewData defaultManager].logOut = NO;
            bself.isRequest = NO;
        }
        else
        {            
            NSLog(@"%@",[error userInfo]);
            int code = [[[error userInfo] objectForKey:@"code"] intValue];
            
            if (code==101)
            {
                NSLog(@"%d",code);
                
                [[ALXMPPEngine defauleEngine] signUpWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded && !error)
                    {
                        [bself loginChat];
                    }
                    else
                    {
                        NSLog(@"%@",error);
                        [bself hideF3HUDError:nil];
                        [bself showLogOutView];
                    }
                    
                    bself.isRequest = NO;
                }];
            }
            else
            {
                bself.isRequest = NO;
                [bself showLogOutView];
                [ViewData defaultManager].autoLogin=NO;
                [[ViewData defaultManager] stopNSTimer];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请重新尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
        }
        
        
        [bself doneLoadingTableViewData];
    }];
}

#pragma mark -检测未读消息数量变化-
- (void)addUnReadNum:(NSNotification *)info
{
//    int num = [_unreadLabel.text intValue];
//    
//    NSString *unReadStr = [NSString stringWithFormat:@"%d",num+1];
//    
//    if (unReadStr.length>2)
//    {
//        _unreadLabel.text = @"99+";
//        
//    }
//    else
//    {
//        _unreadLabel.text = unReadStr;
//    }
//    
//    _unreadLabel.frame = CGRectMake(0, 0, 12+unReadStr.length*6, 17);
//    _unreadLabel.center = CGPointMake(212, 15);
    
//    _unreadLabel.hidden=NO;
    
    [self performSelector:@selector(readUnReadMessageNum) withObject:nil afterDelay:1];
    
  //  [self readUnReadMessageNum];
    
}

#pragma mark 创建页面
- (void)creatView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRightPanelView) name:NOTIFICATION_JASIDE_LOAD_RIGHT_PANEL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut_LinkView) name:NOTIFICATION_XMPP_LOG_OUT object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUnReadNum:) name:@"addUnReadNum" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFriendList) name:REFRESHLINKLIST object:nil];

    
    
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

    
    viewWidth = [ViewData defaultManager].rightVisibleWidth;
    isEditing = NO;
    isAnimation = NO;
    
    self.personlist = [NSMutableArray arrayWithCapacity:0];
    self.grouplist = [NSMutableArray arrayWithCapacity:0];
    self.searchlist = [NSMutableArray arrayWithCapacity:0];
    self.linktypeAry = [NSMutableArray arrayWithCapacity:0];
    
    [self.linktypeAry addObject:[NSNumber numberWithBool:1]];
    [self.linktypeAry addObject:[NSNumber numberWithBool:1]];
    [self.linktypeAry addObject:[NSNumber numberWithBool:1]];
    
    textfieldImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0011_search-Right.png"]];
    textfieldImage.frame = CGRectMake(320-viewWidth+10, 5, 240, 35);
    textfieldImage.userInteractionEnabled = YES;
    [backgroundView addSubview:textfieldImage];
    [textfieldImage release];
    
    UIButton *searchTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchTypeBtn.frame = CGRectMake(5, 5, 35, 30);
    [searchTypeBtn addTarget:self action:@selector(showSearchType) forControlEvents:UIControlEventTouchUpInside];
    [textfieldImage addSubview:searchTypeBtn];
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(320-viewWidth, 0, viewWidth, 55)];
    headView.backgroundColor = [UIColor clearColor];
    
    UIButton *unreadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unreadBtn.frame = CGRectMake(0, 0, 230, 30);
    unreadBtn.layer.cornerRadius = 5;
    unreadBtn.layer.borderColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1].CGColor;
    unreadBtn.layer.borderWidth = 1;
    [unreadBtn setTitle:@"消息列表" forState:UIControlStateNormal];
    [unreadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    unreadBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    unreadBtn.center = CGPointMake(viewWidth/2, 25);
    [unreadBtn addTarget:self action:@selector(pushToUnReadView) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:unreadBtn];
    
    
    _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_unreadLabel setTextAlignment:NSTextAlignmentCenter];
    _unreadLabel.font = [UIFont systemFontOfSize:13];
    _unreadLabel.layer.cornerRadius = 8;
    _unreadLabel.layer.borderWidth = 1.5;
    _unreadLabel.center = CGPointMake(212, 15);
    _unreadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _unreadLabel.font = [UIFont boldSystemFontOfSize:13];
    _unreadLabel.backgroundColor = [UIColor redColor];
    _unreadLabel.textColor = [UIColor whiteColor];
    _unreadLabel.hidden=YES;
    [unreadBtn addSubview:_unreadLabel];
    [_unreadLabel release];
    
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(45, 7, 180, 20)];
    _textfield.backgroundColor = [UIColor clearColor];
    _textfield.borderStyle = UITextBorderStyleNone;
    _textfield.delegate = self;
    _textfield.placeholder = @"请输入昵称";
    _textfield.returnKeyType = UIReturnKeySearch;
    _textfield.textColor = [UIColor whiteColor];
    [textfieldImage addSubview:_textfield];
    [_textfield release];
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_下拉三角.png"]];
    arrow.frame = CGRectMake(28, 15, 17/2, 15/2);
    arrow.userInteractionEnabled = YES;
    [textfieldImage addSubview:arrow];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(320-viewWidth, 45, viewWidth, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 6000;
    _tableView.tableHeaderView = headView;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [headView release];
    [_tableView release];
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.tag = 6001;
    _searchTableView.backgroundColor = [UIColor clearColor];
    _searchTableView.separatorColor = [UIColor clearColor];
    _searchTableView.hidden = YES;
    [backgroundView addSubview:_searchTableView];
    [_searchTableView release];
 
    
    self.searchTypeStr = @"昵称";
    
    [self addRefreshHeaderView];

    if ([[ALUserEngine defauleEngine] isLoggedIn]==YES)
    {
        if ([[ALXMPPEngine defauleEngine] isLoggedIn]==NO)
        {
            
            [self beginLoginChat];
        }
        else
        {
            [self showF3HUDLoad:nil];
            
            [self requestFriendList];
            [self requestGroupList];
        }
    }
    else
    {
        [self showLogOutView];
    }
  
}


- (void)pushToUnReadView
{
    UnReadMessageListViewController *unreadview = [[UnReadMessageListViewController alloc] init];
    [self.navigationController pushViewController:unreadview AnimatedType:MLNavigationAnimationTypeOfNone];
    [unreadview release];
    
    [[MessageCenter defauleCenter] removeChatView:nil];
    
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.3];
}


- (void)showSearchType
{
    if (isEditing==NO)
    {
        return;
    }
    
    if (searchImage==nil)
    {
        searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xialakuang_search.png"]];
        searchImage.frame = CGRectMake(5, 45, 361/3, 421/3);
        searchImage.userInteractionEnabled = YES;
        [self.view addSubview:searchImage];
        [searchImage release];
        
        
        for (int i=0; i<3; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(10, 13+i*43, 100, 35);
            btn.titleLabel.font = [UIFont systemFontOfSize:18];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
            if (i==0)
            {
                [btn setTitle:@"昵 称" forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
            if (i==1)
            {
                [btn setTitle:@"距 离" forState:UIControlStateNormal];
            }
            if (i==2)
            {
                [btn setTitle:@"学 校" forState:UIControlStateNormal];
            }
            
            [btn addTarget:self action:@selector(selectSearchType:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 3000+i;
            [searchImage addSubview:btn];
            
        }
        
        UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004_line-right@2x.png"]];
        line1.frame = CGRectMake(3, 50, 361/3-5, 1);
        line1.userInteractionEnabled = YES;
        [searchImage addSubview:line1];
        [line1 release];
        
        UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004_line-right@2x.png"]];
        line2.frame = CGRectMake(3, 95, 361/3-5, 1);
        line2.userInteractionEnabled = YES;
        [searchImage addSubview:line2];
        [line2 release];
    }
    else
    {
        [self showSearchTypeView];
    }
    
}

- (void)selectSearchType:(UIButton *)sender
{
    UIButton *temp1 = (UIButton *)[self.view viewWithTag:3000];
    UIButton *temp2 = (UIButton *)[self.view viewWithTag:3001];
    UIButton *temp3 = (UIButton *)[self.view viewWithTag:3002];

    [temp1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [temp2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [temp3 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

    [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];

    [self hideSearchTypeView];
    
    if (sender.tag-3000==0)
    {
        self.searchTypeStr = @"昵称";
        _textfield.placeholder = @"请输入昵称";
        _textfield.keyboardType = UIKeyboardTypeDefault;
        [_textfield resignFirstResponder];
        [_textfield becomeFirstResponder];

    }
    if (sender.tag-3000==1)
    {
        _textfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [_textfield resignFirstResponder];
        [_textfield becomeFirstResponder];
        
        self.searchTypeStr = @"距离";
        _textfield.placeholder = @"请输入距离";
    }
    if (sender.tag-3000==2)
    {
        self.searchTypeStr = @"学校";
        _textfield.placeholder = @"请输入学校";
        _textfield.keyboardType = UIKeyboardTypeDefault;
        [_textfield resignFirstResponder];
        [_textfield becomeFirstResponder];
    }
}

- (void)showSearchTypeView
{
    searchImage.hidden = NO;
    [self.view bringSubviewToFront:searchImage];
}

- (void)hideSearchTypeView
{
    searchImage.hidden = YES;
}


#pragma mark 增加分组
- (void)addGroup:(UIButton *)sender
{
    
}

#pragma mark 编辑好友
- (void)editFriend:(UIButton *)sender
{
    
}

- (void)changeLinkType:(UIButton *)sender
{
    int num = sender.tag-5000;
    
    NSNumber *number = [NSNumber numberWithBool:![[self.linktypeAry objectAtIndex:num] boolValue]];
    
    [self.linktypeAry replaceObjectAtIndex:num withObject:number];
    
    //section动画
    NSIndexSet *inset = [NSIndexSet indexSetWithIndex:num];
    [_tableView reloadSections:inset withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark UItableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView.tag==6000)
    {
        return 30;
    }
    
    if(tableView.tag==6001)
    {
        return 0;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView.tag==6000)
    {
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 30)];
        headView.image = [UIImage imageNamed:@"_0010_分类栏.png"];
        headView.userInteractionEnabled = YES;
        
        UIImageView *classImage = [[UIImageView alloc] init];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(46, 6, viewWidth-50, 20)];
        [title setText:NSTextAlignmentLeft];
        title.font = [UIFont systemFontOfSize:14];
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor whiteColor];
        [headView addSubview:title];
        
        
        if(section==0)
        {
            title.text = @"群组聊天";
            title.textColor = [UIColor colorWithRed:0.55 green:0.78 blue:0.2 alpha:1];
            classImage.image = [UIImage imageNamed:@"_0005_friend.png"];
            classImage.frame = CGRectMake(20, 10, 32/2, 26/2);
            [headView addSubview:classImage];
        }
        if(section==1)
        {
            title.text = @"关注好友";
            title.textColor = [UIColor colorWithRed:0.97 green:0.70 blue:0.31 alpha:1];
            classImage.image = [UIImage imageNamed:@"_0006_friend是、.png"];
            classImage.frame = CGRectMake(20, 10, 24/2, 26/2);
            [headView addSubview:classImage];
        }
        if (section==2)
        {
            title.text = @"互粉好友";
            title.textColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
            classImage.image = [UIImage imageNamed:@"_0004_互粉.png"];
            classImage.frame = CGRectMake(20, 10, 28/2, 24/2);
            [headView addSubview:classImage];
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, viewWidth, 30);
        btn.tag = 5000+section;
        [btn addTarget:self action:@selector(changeLinkType:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:btn];
        
        [title release];
        [classImage release];
        
        return [headView autorelease];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag==6000)
    {
        if(section==0)
        {
            if ([[self.linktypeAry objectAtIndex:0] boolValue]==NO)
            {
                return 0;
            }
            
            return self.grouplist.count;
        }
        if (section==1)
        {
            if ([[self.linktypeAry objectAtIndex:1] boolValue]==NO)
            {
                return 0;
            }
            
            if (self.personlist.count==0)
            {
                return 0;
            }
            
            
            NSArray *array = [self.personlist objectAtIndex:0];
            NSLog(@"关注好友：%d",array.count);
            if (array.count>0)
            {
                return array.count;
            }
            else
            {
                return 0;
            }
        }
        if (section==2)
        {
            if ([[self.linktypeAry objectAtIndex:2] boolValue]==NO)
            {
                return 0;
            }
            
            if (self.personlist.count==0)
            {
                return 0;
            }
            
            NSArray *array = [self.personlist objectAtIndex:1];
             NSLog(@"互粉好友：%d",array.count);
            if (array.count>0)
            {
                return array.count;
            }
            else
            {
                return 0;
            }
        }
  
        return 0;
    }
    
   if(tableView.tag==6001)
   {
       return self.searchlist.count;

   }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView.tag==6000)
    {
        return 3;
    }
    if(tableView.tag==6001)
    {
        return 1;

    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Celldentifier1 = @"Cell1";
    static NSString *Celldentifier2 = @"Cell2";

    
    //好友列表
    if(tableView.tag==6000)
    {
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier1];
        if(cell==nil)
        {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier1] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundColor = [UIColor clearColor];
        }
        
 
        cell.headCoverImage.hidden = NO;
        cell.headCoverImage.frame = CGRectMake(0, 0, 50, 50);
        cell.headCoverImage.center = CGPointMake(40, 30);
        
        cell.headImageView.hidden = NO;
        cell.headImageView.frame = CGRectMake(0, 0, 44, 44);
        cell.headImageView.center = CGPointMake(40, 30);
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.headImageView.indexPath = indexPath;
        
        cell.title.textColor = [UIColor whiteColor];
        cell.title.frame = CGRectMake(70, 20, 180, 20);
        
        //群组列表
        if(indexPath.section==0)
        {
            NSMutableDictionary *_dic = [self.grouplist objectAtIndex:indexPath.row];

            cell.headCoverImage.image = [UIImage imageNamed:@"图层-20.png"];
            cell.title.text = [NSString stringWithFormat:@"%@群",[_dic objectForKey:@"gName"]];
            cell.collectImage.hidden = YES;
            cell.headImageView.urlString = [_dic objectForKey:@"imageUrl"];
        }
        else
        {
            NSArray *array = [self.personlist objectAtIndex:indexPath.section-1];
            User *_tempUser = [array objectAtIndex:indexPath.row];
            
            cell.headImageView.urlString = _tempUser.headView.url;
            
            int _gender = _tempUser.gender;
            
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
            
            cell.title.text = _tempUser.nickName;
        }
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.image = [UIImage imageNamed:@"_0004_line-right@2x.png"];
        cell.homeCellLine.frame = CGRectMake(0, 0, 270, 1);
        cell.homeCellLine.center = CGPointMake(120, 60);
        
        return cell;
    }
    
    //搜索好友
    if(tableView.tag==6001)
    {
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Celldentifier2];
        if(cell==nil)
        {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Celldentifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundColor = [UIColor clearColor];
        }
        
        User *_temp = [self.searchlist objectAtIndex:indexPath.row];
        
        
        cell.headImageView.hidden = NO;
        cell.headImageView.frame = CGRectMake(0, 0, 44, 44);
        cell.headImageView.center = CGPointMake(40, 30);
        cell.headImageView.urlString = _temp.headView.url;
        cell.headImageView.userInteractionEnabled = YES;
        [cell.headImageView addTarget:self action:@selector(showSearchUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.headImageView.tag = indexPath.row;
        
        BOOL gender = _temp.gender;
        
        if (gender==0)
        {
            cell.headCoverImage.image = [UIImage imageNamed:@"nv.png"];
        }
        else
        {
            cell.headCoverImage.image = [UIImage imageNamed:@"nan.png"];
        }
        
        cell.headCoverImage.hidden = NO;
        cell.headCoverImage.frame = CGRectMake(0, 0, 50, 50);
        cell.headCoverImage.center = CGPointMake(40, 30);
        
       

        cell.title.textColor = [UIColor whiteColor];
        cell.title.frame = CGRectMake(70, 20, 180, 20);
        cell.title.text = _temp.nickName;
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.image = [UIImage imageNamed:@"_0004_line-right@2x.png"];
        cell.homeCellLine.frame = CGRectMake(0, 0, 320, 1);
        cell.homeCellLine.center = CGPointMake(160, 60);
        
        return cell;
    }
    return nil;
}

- (void)showSearchUserInfo:(AsyncImageView *)sender
{
    User *_tempuser = nil;
    
    _tempuser = [self.searchlist objectAtIndex:sender.tag];

    
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

- (void)showUserInfo:(AsyncImageView *)sender
{
    User *_tempuser = nil;
    
    //显示群组信息
    if (sender.indexPath.section==0)
    {
        
    }
    //显示用户信息
    else
    {
        NSArray *array = [self.personlist objectAtIndex:sender.indexPath.section-1];
        
        _tempuser = [array objectAtIndex:sender.indexPath.row];
        
        if (!_tempuser)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已注销" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
            
            return;
        }
        
        PersonalDataViewController *person = [[[PersonalDataViewController alloc] initWithUser:_tempuser FromSelf:NO SelectFromCenter:NO] autorelease];
        MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:person] autorelease];
        self.sidePanelController.centerPanel = n;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isRequest)
    {
        return;
    }
    
    //进入搜索聊天室
    if(tableView.tag==6001)
    {

        __block typeof(self) bself = self;
        
        User *_friend=nil;
        
        _friend = [self.searchlist objectAtIndex:indexPath.row];
        
        if (_friend)
        {
            if (self.isBeginChat==YES)
            {
                return;
            }
            
            self.isBeginChat = YES;
            
            [self showF3HUDLoad:nil];
            
            __block UITextField *__textfield = _textfield;
            
            [[ALXMPPEngine defauleEngine] beganToChatWithUser:_friend block:^(BOOL succeeded, NSError *error) {
                
                
                if (succeeded && !error)
                {
                    [_friend fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                        
                        
                        if (object && !error)
                        {
                            [[MessageCenter defauleCenter] removeChatView:nil];
                            [bself hideF3HUDSucceed:nil];
                            
                            User *_temp = (User *)object;
                            
                            ChatViewController *chatView = [[ChatViewController alloc] initWithUser:_temp];
                            [bself.navigationController pushViewController:chatView AnimatedType:MLNavigationAnimationTypeOfNone];
                            [chatView release];
                            
                            __textfield.text = @"";
                        }
                        else
                        {
                            [bself hideF3HUDError:nil];
                        }
                        
                        bself.isBeginChat = NO;
                        
                    }];
                }
                else
                {
                    bself.isBeginChat = NO;
                    
                    [bself hideF3HUDError:nil];
                }
            }];
        }
        
        return;
    }
    
    if(tableView.tag==6000)
    {
        //进入群聊室
        if (indexPath.section==0)
        {
            NSString *_gId = [[self.grouplist objectAtIndex:indexPath.row] objectForKey:@"gId"];
            NSString *_gName = [[self.grouplist objectAtIndex:indexPath.row] objectForKey:@"gName"];
            
            if (_gId)
            {
                [ViewData defaultManager].groupId = _gId;
                
                if (self.isBeginChat==YES)
                {
                    return;
                }
                
                self.isBeginChat = YES;
                
                __block typeof(self) bself = self;
                
                [self showF3HUDLoad:nil];
                
                [[ALXMPPEngine defauleEngine] enterGroup:_gId andDeclared:nil block:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded && !error)
                    {
                        [[MessageCenter defauleCenter] removeChatView:nil];

                        [bself hideF3HUDSucceed:nil];
                        
                        GroupViewController *group = [[GroupViewController alloc] initWithGroupId:_gId GroupName:_gName];
                        [bself.navigationController pushViewController:group AnimatedType:MLNavigationAnimationTypeOfNone];
                        [group release];
                        
                        [bself.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.3];
                        
                        bself.isBeginChat=NO;
                    }
                    else
                    {
                        [bself hideF3HUDError:nil];
                        bself.isBeginChat=NO;
                    }
                }];
            }
        }
        else
        {
            __block typeof(self) bself = self;
            
            User *_friend=nil;
            
            NSArray *array = [self.personlist objectAtIndex:indexPath.section-1];
            _friend = [array objectAtIndex:indexPath.row];
            
            if (_friend)
            {
                if (self.isBeginChat==YES)
                {
                    return;
                }
                
                self.isBeginChat = YES;
                
                [self showF3HUDLoad:nil];
                                
                [[ALXMPPEngine defauleEngine] beganToChatWithUser:_friend block:^(BOOL succeeded, NSError *error) {
                    
                    
                    if (succeeded && !error)
                    {
                        [_friend fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                            
                            
                            if (object && !error)
                            {
                                [[MessageCenter defauleCenter] removeChatView:nil];

                                [bself hideF3HUDSucceed:nil];
                                
                                User *_temp = (User *)object;
                                
                                
                                ChatViewController *chatView = [[ChatViewController alloc] initWithUser:_temp];
                                [bself.navigationController pushViewController:chatView AnimatedType:MLNavigationAnimationTypeOfNone];
                                [chatView release];
                                
                                [bself.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.3];
                                
                            }
                            else
                            {
                                [bself hideF3HUDError:nil];
                            }
                            
                            bself.isBeginChat = NO;
                            
                        }];
                    }
                    else
                    {
                        bself.isBeginChat = NO;
                        
                        [bself hideF3HUDError:nil];
                    }
                }];
            }
        }
    }
}



#pragma mark ChangeCenterView Show Or Hide
- (void)hideTapped:(id)sender
{
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
}

- (void)showTapped:(id)sender
{
    [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2f];
}

#pragma mark 好友搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self hideSearchTypeView];
    
    __block typeof(self) bself = self;
    
    if(_textfield.text.length==0)
    {
        return YES;
    }
    
    [self showF3HUDLoad:nil];
    
    __block UITableView *__searchtableview = _searchTableView;
    __block UITableView *__tableview = _tableView;
    __block UIButton *__cover = coverView;
    
    if ([self.searchTypeStr isEqualToString:@"昵称"])
    {
        [[ALUserEngine defauleEngine] getUserCardWithUserNickName:_textfield.text block:^(NSArray *userList, NSError *error) {
            
            int counts = userList.count;
            
            if (counts>0 && !error)
            {
                [bself.searchlist removeAllObjects];
                
                for (int i=0; i<counts; i++)
                {
                    User *_temp = [userList objectAtIndex:i];
                    
                    if (![_temp.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
                    {
                        [bself.searchlist addObject:_temp];
                    }
                    
                    __searchtableview.hidden = NO;
                    __tableview.hidden = YES;
                    __cover.hidden = YES;
                    [bself.view bringSubviewToFront:__searchtableview];
                    [__searchtableview reloadData];
                }
                
                [bself hideF3HUDSucceed:nil];
            }
            
            if (counts==0 && !error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询结果" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
                
                [bself hideF3HUDSucceed:nil];
            }
            
            if (error)
            {
                [bself hideF3HUDError:nil];
            }
            
            bself.isRequest=NO;
        }];
    }
    
    if ([self.searchTypeStr isEqualToString:@"距离"])
    {
        [[ALUserEngine defauleEngine] getUserCardNotContainedIn:nil nearForLatitude:[ALUserEngine defauleEngine].user.location.latitude andLongitude:[ALUserEngine defauleEngine].user.location.longitude distance:[_textfield.text intValue] block:^(NSArray *userList, NSError *error) {
            
            int counts = userList.count;
            
            if (counts>0 && !error)
            {
                [bself.searchlist removeAllObjects];
                
                for (int i=0; i<counts; i++)
                {
                    User *_temp = [userList objectAtIndex:i];
                    
                    if (![_temp.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
                    {
                        [bself.searchlist addObject:_temp];
                    }
                    
                    __searchtableview.hidden = NO;
                    __tableview.hidden = YES;
                    __cover.hidden = YES;
                    [bself.view bringSubviewToFront:__searchtableview];
                    [__searchtableview reloadData];
                }
                
                [bself hideF3HUDSucceed:nil];
            }
            
            if (counts==0 && !error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询结果" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
                
                [bself hideF3HUDSucceed:nil];
            }
            
            if (error)
            {
                [bself hideF3HUDError:nil];
            }
            
            bself.isRequest=NO;

        }];
    }
    
    if ([self.searchTypeStr isEqualToString:@"学校"])
    {
        
        NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
        [_dic setValue:_textfield.text forKey:@"graduateSchool[like]"];
        
        [[ALUserEngine defauleEngine] getUserCardWithSearchInfo:_dic block:^(NSArray *userList, NSError *error) {
            
            int counts = userList.count;
            
            if (counts>0 && !error)
            {
                [bself.searchlist removeAllObjects];
                
                for (int i=0; i<counts; i++)
                {
                    User *_temp = [userList objectAtIndex:i];
                    
                    if (![_temp.objectId isEqualToString:[ALUserEngine defauleEngine].user.objectId])
                    {
                        [bself.searchlist addObject:_temp];
                    }
                    
                    __searchtableview.hidden = NO;
                    __tableview.hidden = YES;
                    __cover.hidden = YES;
                    [bself.view bringSubviewToFront:__searchtableview];
                    [__searchtableview reloadData];
                }
                
                [bself hideF3HUDSucceed:nil];
            }
            
            if (counts==0 && !error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询结果" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                alertView=nil;
                
                [bself hideF3HUDSucceed:nil];
            }
            
            if (error)
            {
                [bself hideF3HUDError:nil];
            }
            
            bself.isRequest=NO;
            
        }];

    }


    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(isEditing==NO)
    {
        [self hideTapped:nil];
        
        viewWidth=320;
        _textfield.text = @"";
        
        coverView = [UIButton buttonWithType:UIButtonTypeCustom];
        coverView.frame = CGRectMake(0, 45+[ViewData defaultManager].versionHeight, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight);
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0;
        [coverView addTarget:self action:@selector(cancelSearchView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:coverView];
        
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(320, 8+[ViewData defaultManager].versionHeight, 87/2, 30);
        [cancelBtn setImage:[UIImage imageNamed:@"_0002_取消1-1.png"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelSearchView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelBtn];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            cancelBtn.frame = CGRectMake(265, 8+[ViewData defaultManager].versionHeight, 87/2, 30);
            textfieldImage.frame = CGRectMake(10, 5, 240, 35);
            _tableView.frame = CGRectMake(0, 45+[ViewData defaultManager].versionHeight, viewWidth, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight);
            coverView.alpha = 0.8;
            
        } completion:^(BOOL finished) {
            isEditing = YES;
        }];
    }
    
    return YES;
}

- (void)cancelSearchView
{
    [self hideSearchTypeView];
    
    [self showTapped:nil];
    
    _textfield.text = @"";
    [_textfield resignFirstResponder];
    
    _searchTableView.hidden = YES;
    coverView.hidden = NO;
    viewWidth = [ViewData defaultManager].rightVisibleWidth;
    
    [self.searchlist removeAllObjects];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        cancelBtn.frame = CGRectMake(320, 8+[ViewData defaultManager].versionHeight, 87/2, 30);
        textfieldImage.frame = CGRectMake(320-viewWidth+10, 5, 240, 35);
        _tableView.frame = CGRectMake(320-viewWidth, 45+[ViewData defaultManager].versionHeight, viewWidth, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight);
        coverView.alpha = 0;
        _tableView.hidden = NO;
    } completion:^(BOOL finished) {
        
        [coverView removeFromSuperview];
        [cancelBtn removeFromSuperview];
        
        isEditing = NO;
    }];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isEditing)
    {
        return;
    }
    
    if (scrollView.contentOffset.y <= -70)
    {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -70);
    }
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isEditing)
    {
        return;
    }
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - addHeader&addFooter
- (void)addRefreshHeaderView
{
    if (_refreshHeaderView == nil)
    {
        _reloading = NO;
        
        _refreshHeaderView=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(-30.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height) textColor:[UIColor whiteColor] beginStr:@"下拉刷新" stateStr:@"松开即可刷新" endStr:@"加载中" haveArrow:NO];
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
    isFriendOpen = NO;
    
    if (self.isRequest)
    {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.4];
        
        return;
    }
    
    [self requestGroupList];
    [self requestFriendList];
    [self readUnReadMessageNum];
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

@end
