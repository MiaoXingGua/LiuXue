//
//  FriendListViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-19.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "FriendListViewController.h"
#import "ViewData.h"
#import "ALUserEngine.h"
#import "CustomCell.h"

@interface FriendListViewController ()

@end

@implementation FriendListViewController
@synthesize friendArray = _friendArray;
@synthesize datalist = _datalist;

- (void)dealloc
{
    [_friendArray release]; _friendArray=nil;
    [_datalist release]; _datalist=nil;
    
    self.datalist=nil;
    
    [super dealloc];
}

- (id)initWithSelectUser:(NSMutableArray *)friendList
{
    if (self = [super init])
    {
        self.friendArray = [NSMutableArray arrayWithArray:friendList];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.datalist = [NSMutableArray arrayWithCapacity:0];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.97 blue:0.96 alpha:1];
    
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
    titleLabel.text = @"@好友";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    

    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(280, 10, 30, 30);
    [doneBtn setImage:[UIImage imageNamed:@"_0035_取消.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneSelect) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:doneBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 6000;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    [backgroundView addSubview:_tableView];
    [_tableView release];
    
    [self showF3HUDLoad:nil];
    
    [self requestFriendList];
}


- (void)doneSelect
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.datalist.count; i++)
    {
        NSMutableDictionary *dic = [self.datalist objectAtIndex:i];
        BOOL _state = [[dic objectForKey:@"state"] boolValue];
        User *_user = [dic objectForKey:@"user"];
        
        if (_state==YES)
        {
            [array addObject:_user];
        }
    }
    
    [self.atDelegate didSelectAtUser:array];
    
    [array release];
    array=nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datalist.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
        cell.headCoverImage.center = CGPointMake(35, 30);
        
        cell.headImageView.hidden = NO;
        cell.headImageView.frame = CGRectMake(0, 0, 46, 46);
        cell.headImageView.center = CGPointMake(35, 30);
        
        cell.title.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
        cell.title.frame = CGRectMake(65, 20, 180, 20);
        
        NSMutableDictionary *dic = [self.datalist objectAtIndex:indexPath.row];
        User *_tempUser = [dic objectForKey:@"user"];
        BOOL _state = [[dic objectForKey:@"state"] boolValue];
        
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
        
        cell.friendImage.hidden = YES;
        
        if (_state==YES)
        {
            cell.friendImage.frame = CGRectMake(280, 15, 30, 30);
            cell.friendImage.image = [UIImage imageNamed:@"selectatuser.png"];
            cell.friendImage.hidden = NO;
        }
        
        
        cell.homeCellLine.hidden = NO;
        cell.homeCellLine.image = [UIImage imageNamed:@"_0004_line-right@2x.png"];
        cell.homeCellLine.frame = CGRectMake(0, 0, 320, 1);
        cell.homeCellLine.center = CGPointMake(160, 60);
        
        return cell;
    }
    
    /*
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
        
        User *_temp = [self.friendArray objectAtIndex:indexPath.row];
        
        
        cell.headImageView.hidden = NO;
        cell.headImageView.frame = CGRectMake(0, 0, 44, 44);
        cell.headImageView.center = CGPointMake(40, 30);
        cell.headImageView.urlString = _temp.headView.url;
        cell.headImageView.userInteractionEnabled = YES;
        [cell.headImageView addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
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
     */
    
    return nil;
}



- (void)requestFriendList
{
    __block typeof(self) bself = self;
    
    __block UITableView *__tabelview = _tableView;

    [[ALUserEngine defauleEngine] refreashRelationWithUser:[ALUserEngine defauleEngine].user block:^(NSDictionary *relationInfo, NSError *error) {
        
        if (relationInfo && !error)
        {
            NSArray *array2 = [relationInfo objectForKey:@"bilaterals"];
            
            int counts2 = array2.count;
            
            for (int i=0; i<counts2; i++)
            {
                User *_friend = [array2 objectAtIndex:i];
                BOOL _state=NO;
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                
                for (int i=0; i<self.friendArray.count; i++)
                {
                    User *temp = [self.friendArray objectAtIndex:i];
                    
                    if ([_friend.objectId isEqualToString:temp.objectId])
                    {
                        _state = YES;
                    }
                }
              
                [dic setValue:_friend forKey:@"user"];
                [dic setValue:[NSNumber numberWithBool:_state] forKey:@"state"];
                
                [bself.datalist addObject:dic];
                [dic release];
                dic = nil;
            }
            
            [__tabelview reloadData];
            [bself hideF3HUDSucceed:nil];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = [self.datalist objectAtIndex:indexPath.row];
    
    BOOL temp = [[dic objectForKey:@"state"] boolValue];
    
    [dic setObject:[NSNumber numberWithBool:!temp] forKey:@"state"];
    
    [_tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
