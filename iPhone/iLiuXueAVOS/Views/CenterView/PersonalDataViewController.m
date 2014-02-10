//
//  PersonalDataViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "PersonalDataViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "PersonalCustomCell.h"
#import "AsyncImageView.h"
#import "ALUserEngine.h"
#import "ALXMPPEngine.h"
#import "ViewData.h"
#import "CollectViewController.h"
#import "ShowMyThreadsViewController.h"
#import "EditViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MessageCenter.h"
#import "ChatViewController.h"

@interface PersonalDataViewController ()

@end

@implementation PersonalDataViewController
@synthesize user = _user;
@synthesize userName = _userName;
@synthesize datalist = _datalist;
@synthesize gradute = _gradute;
@synthesize study = _study;
@synthesize interest = _interest;
@synthesize signature = _signature;
@synthesize userImageArray = _userImageArray;
@synthesize userPointArray = _userPointArray;
@synthesize userPhotosArray = _userPhotosArray;
@synthesize photos = _photos;
@synthesize userImg = _userImg;

- (void)dealloc
{
    [self.userImageArray removeAllObjects];
    [self.userPointArray removeAllObjects];
    [self.userPhotosArray removeAllObjects];
    [self.datalist removeAllObjects];
    
    [_userImg release]; _userImg=nil;
    [_photos release]; _photos=nil;
    [_userPhotosArray release]; _userPhotosArray=nil;
    [_userPointArray release]; _userPointArray=nil;
    [_userImageArray release]; _userImageArray=nil;
    [_gradute release]; _gradute=nil;
    [_study release]; _study=nil;
    [_interest release]; _interest=nil;
    [_signature release]; _signature=nil;
    [_datalist release]; _datalist=nil;
    [_userName release]; _userName=nil;
    [_user release]; _user=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeImageView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEUSERINFO object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEUSERRELATIONLIST object:nil];

    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (id)initWithUser:(User *)user FromSelf:(BOOL)from SelectFromCenter:(BOOL)fromcenter
{
    if(self=[super init])
    {
        self.user = user;
        _from = from;
        _fromcenter = fromcenter;
        self.userName=nil;
    }
    
    return self;
}

- (id)initWithUserName:(NSString *)userName FromSelf:(BOOL)from SelectFromCenter:(BOOL)fromcenter
{
    if (self = [super init])
    {
        self.userName = userName;
    }
    
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)refreshPersonalData:(NSArray *)array
{
    UserInfo *_userinfo = [array objectAtIndex:0];
    UserCount *_usercontent = [array objectAtIndex:1];
    
    
    NSString *_age = [NSString stringWithFormat:@"%d",_userinfo.age];
    NSString *_emotion = _userinfo.affectiveState;
    NSString *_star = _userinfo.constellation;
    
    int _gender = self.user.gender;
    
    if (_userinfo.graduateSchool.length==0)
    {
        self.gradute = @"暂无";
    }
    else
    {
        self.gradute = _userinfo.graduateSchool;
    }
    
    if (_userinfo.interest.length==0)
    {
        self.interest = @"暂无";
    }
    else
    {
        self.interest = _userinfo.interest;
    }
    
    if (_userinfo.company.length==0)
    {
        self.study = @"暂无";
    }
    else
    {
        self.study = _userinfo.company;
    }
    
    if (self.user.signature.length==0)
    {
        self.signature = @"暂无";
    }
    else
    {
        self.signature = self.user.signature;
    }
    
    CGSize userNameSize = [username.text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:0];
    
    
    sexImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0003_♂.png"]];
    sexImage.frame = CGRectMake(115+userNameSize.width+10, 23, 17/2, 28/2);
    [headView addSubview:sexImage];
    [sexImage release];
    
    if (_gender==0)
    {
        sexImage.image = [UIImage imageNamed:@"_0000_♀-.png"];
    }
    
    UIImageView *jifenImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"积分.png"]];
    jifenImage.frame = CGRectMake(115, 48, 35/2, 9);
    [headView addSubview:jifenImage];
    [jifenImage release];
    
    UILabel *jifenLabel = [[UILabel alloc] initWithFrame:CGRectMake(115+22, 42, 100, 20)];
    jifenLabel.textColor = [UIColor whiteColor];
    jifenLabel.font = [UIFont systemFontOfSize:12];
    jifenLabel.backgroundColor = [UIColor clearColor];
    jifenLabel.text = [NSString stringWithFormat:@"%d",self.user.credits];
    [headView addSubview:jifenLabel];
    [jifenLabel release];
    
    
    AVGeoPoint *_pfpointself=nil;
    AVGeoPoint *_pfpointfriend=nil;
    float disdance=0;
    
    if ([ALUserEngine defauleEngine].user.location.latitude!=0 && [ALUserEngine defauleEngine].user.location.longitude!=0)
    {
        _pfpointself = [ALUserEngine defauleEngine].user.location;
    }
    
    if (self.user.location.latitude!=0 && self.user.location.longitude!=0)
    {
        _pfpointfriend = self.user.location;
    }
    
    if (_pfpointfriend!=nil && _pfpointself!=nil)
    {
        disdance = [_pfpointfriend distanceInKilometersTo:_pfpointself];
    }
    
    disdanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 42, 100, 20)];
    disdanceLabel.textColor = [UIColor whiteColor];
    disdanceLabel.font = [UIFont systemFontOfSize:12];
    disdanceLabel.backgroundColor = [UIColor clearColor];
    disdanceLabel.text = [NSString stringWithFormat:@"距离: %.2fkm",disdance];
    [headView addSubview:disdanceLabel];
    [disdanceLabel release];
    
    
    if (_pfpointself==nil || _pfpointfriend==nil || disdance<0)
    {
        disdanceLabel.text = @"距离: 未知";
    }
    
    if (_from==YES)
    {
        disdanceLabel.text = @"距离: 0.00km";
    }
    
    UIImageView *locationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0001_location.png"]];
    locationImage.frame = CGRectMake(115, 90, 21/2, 25/2);
    [headView addSubview:locationImage];
    [locationImage release];
    
    locationLabel = [[UILabel alloc] init];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.numberOfLines = 0;
    [locationLabel setTextAlignment:NSTextAlignmentLeft];
    locationLabel.font = [UIFont systemFontOfSize:12];
    locationLabel.backgroundColor = [UIColor clearColor];
    [headView addSubview:locationLabel];
    [locationLabel release];
    
    if (self.user.place.length==0)
    {
        locationLabel.text = @"暂无";
    }
    else
    {
        locationLabel.text = self.user.place;
    }
    
    CGSize placeSize = [locationLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(110, 1000) lineBreakMode:0];
    
    locationLabel.frame = CGRectMake(130, 89, 110, placeSize.height);
    
    ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 65, 80, 20)];
    ageLabel.text = _age;
    ageLabel.textColor = [UIColor whiteColor];
    [ageLabel setTextAlignment:NSTextAlignmentLeft];
    ageLabel.font = [UIFont systemFontOfSize:12];
    ageLabel.backgroundColor = [UIColor clearColor];
    [headView addSubview:ageLabel];
    [ageLabel release];
    
    if (_age.length==0)
    {
        ageLabel.text = @"暂无";
    }
    
    starLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 65, 80, 20)];
    starLabel.text = [NSString stringWithFormat:@"%@座",_star];
    starLabel.textColor = [UIColor whiteColor];
    [starLabel setTextAlignment:NSTextAlignmentLeft];
    starLabel.font = [UIFont systemFontOfSize:12];
    starLabel.backgroundColor = [UIColor clearColor];
    [headView addSubview:starLabel];
    [starLabel release];
    
    if (_star.length==0)
    {
        starLabel.text = @"暂无";
    }
    
    marryLabel = [[UILabel alloc] initWithFrame:CGRectMake(207, 65, 80, 20)];
    marryLabel.text = _emotion;
    marryLabel.textColor = [UIColor whiteColor];
    [marryLabel setTextAlignment:NSTextAlignmentLeft];
    marryLabel.font = [UIFont systemFontOfSize:12];
    marryLabel.backgroundColor = [UIColor clearColor];
    [headView addSubview:marryLabel];
    [marryLabel release];
    
    if (_emotion.length==0)
    {
        marryLabel.text = @"暂无";
    }
    
    attentioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [attentioBtn setImage:[UIImage imageNamed:@"关注.png"] forState:UIControlStateNormal];
    attentioBtn.frame = CGRectMake(55, 80, 40, 59/2);
    attentioBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [attentioBtn addTarget:self action:@selector(attention:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:attentioBtn];
    attentioBtn.hidden = YES;
    
    cancelAttentioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelAttentioBtn setImage:[UIImage imageNamed:@"取消关注.png"] forState:UIControlStateNormal];
    cancelAttentioBtn.frame = CGRectMake(55, 80, 40, 59/2);
    cancelAttentioBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [cancelAttentioBtn addTarget:self action:@selector(cancelAttention:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:cancelAttentioBtn];
    cancelAttentioBtn.hidden = YES;
    
    if (_from==NO)
    {
        UIButton *beginchatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        beginchatBtn.frame = CGRectMake(270, 10, 40, 40);
        [beginchatBtn setTitle:@"聊天" forState:UIControlStateNormal];
        [beginchatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        beginchatBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [beginchatBtn addTarget:self action:@selector(beginChatWithUser) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:beginchatBtn];
    }

    
    __block typeof(self) bself = self;

    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        attentioBtn.hidden = YES;
        cancelAttentioBtn.hidden = YES;
        
        __block UITableView *__tableview = _tableView;
        
        [[ALUserEngine defauleEngine] refreashRelationWithUser:self.user block:^(NSDictionary *relationInfo, NSError *error) {
            
            NSString *numberOfThreads = [NSString stringWithFormat:@"%d",_usercontent.numberOfThreads];
            NSString *numberOfPosts = [NSString stringWithFormat:@"%d",_usercontent.numberOfPosts];
            NSString *numberOfBest = [NSString stringWithFormat:@"%d",_usercontent.numberOfBestPosts];
            NSString *numberOfCollents = [NSString stringWithFormat:@"%d",_usercontent.numberOfFavicon];
            NSString *numberOfComments = [NSString stringWithFormat:@"%d",_usercontent.numberOfComments];
            
            NSString *numberOfFans = [NSString stringWithFormat:@"%d",_usercontent.numberOfFollows];
            NSString *numberOfFriends = [NSString stringWithFormat:@"%d",_usercontent.numberOfFriends];
            NSString *numberOfBilaterals = [NSString stringWithFormat:@"%d",_usercontent.numberOfBilaterals];
            NSString *numberOfBanList = [NSString stringWithFormat:@"%d",_usercontent.numberOfBanList];
            
            [bself.datalist setValue:numberOfFans forKey:@"fans"];
            [bself.datalist setValue:numberOfFriends forKey:@"friends"];
            [bself.datalist setValue:numberOfThreads forKey:@"threads"];
            [bself.datalist setValue:numberOfPosts forKey:@"posts"];
            [bself.datalist setValue:numberOfBest forKey:@"bestAnswers"];
            [bself.datalist setValue:numberOfCollents forKey:@"collects"];
            [bself.datalist setValue:numberOfComments forKey:@"comments"];
            [bself.datalist setValue:numberOfBilaterals forKey:@"bilaterals"];
            [bself.datalist setValue:numberOfBanList forKey:@"ban"];
            
            [__tableview reloadData];
            
            [bself hideF3HUDSucceed:nil];
            
            bself.isRequest = NO;
        }];
    }
    else
    {
        __block UITableView *__tableview = _tableView;

        [[ALUserEngine defauleEngine] refreashRelationWithUser:self.user block:^(NSDictionary *relationInfo, NSError *error) {
            
            NSString *numberOfThreads = [NSString stringWithFormat:@"%d",_usercontent.numberOfThreads];
            NSString *numberOfPosts = [NSString stringWithFormat:@"%d",_usercontent.numberOfPosts];
            NSString *numberOfBest = [NSString stringWithFormat:@"%d",_usercontent.numberOfBestPosts];
            NSString *numberOfCollents = [NSString stringWithFormat:@"%d",_usercontent.numberOfFavicon];
            NSString *numberOfComments = [NSString stringWithFormat:@"%d",_usercontent.numberOfComments];
            
            NSString *numberOfFans = [NSString stringWithFormat:@"%d",_usercontent.numberOfFollows];
            NSString *numberOfFriends = [NSString stringWithFormat:@"%d",_usercontent.numberOfFriends];
            NSString *numberOfBilaterals = [NSString stringWithFormat:@"%d",_usercontent.numberOfBilaterals];
            NSString *numberOfBanList = [NSString stringWithFormat:@"%d",_usercontent.numberOfBanList];
            
            bself.datalist = [NSMutableDictionary dictionaryWithObjectsAndKeys:numberOfFans, @"fans", numberOfFriends, @"friends", numberOfThreads, @"threads", numberOfPosts, @"posts", numberOfBest, @"bestAnswers", numberOfCollents, @"collects", numberOfComments, @"comments", numberOfBilaterals, @"bilaterals", numberOfBanList, @"ban", nil];
            
            [__tableview reloadData];
            
            [bself hideF3HUDSucceed:nil];
            
            bself.isRequest = NO;
        }];
        
        if(_from==NO)
        {
            __block UIButton *__btn1 = attentioBtn;
            __block UIButton *__btn2 = cancelAttentioBtn;
            __block UITableView *__tableview = _tableView;
            
            [[ALUserEngine defauleEngine] refreashMyRelationWithBlock:^(NSDictionary *relationInfo, NSError *error) {
                
                if (relationInfo && !error)
                {
                    NSArray *array = (NSArray *)[relationInfo objectForKey:@"friends"];
                    NSArray *array2 = [relationInfo objectForKey:@"bilaterals"];
                    int counts = array.count;
                    int counts2 = array2.count;
                    
                    bself.isAttention = NO;
                    
                    for (int i=0; i<counts; i++)
                    {
                        User *_friend = [array objectAtIndex:i];
                        
                        if ([_friend.objectId isEqualToString:self.user.objectId])
                        {
                            bself.isAttention = YES;
                        }
                    }
                    
                    for (int i=0; i<counts2; i++)
                    {
                        User *_friend = [array2 objectAtIndex:i];
                        
                        if ([_friend.objectId isEqualToString:self.user.objectId])
                        {
                            bself.isAttention = YES;
                        }
                        
                    }
                }
                else
                {
                    bself.isAttention = NO;
                }
                
                
                if(bself.isAttention==YES)
                {
                    __btn1.hidden = YES;
                    __btn2.hidden = NO;
                }
                else
                {
                    __btn1.hidden = NO;
                    __btn2.hidden = YES;
                }
                
                [__tableview reloadData];
                
                bself.isRequest = NO;
                
            }];
        }
        else
        {
            updateData = [UIButton buttonWithType:UIButtonTypeCustom];
            [updateData setImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];
            [updateData addTarget:self action:@selector(updateData) forControlEvents:UIControlEventTouchUpInside];
            updateData.frame = CGRectMake(270, 10, 75/2, 75/2);
            [headView addSubview:updateData];
            
            addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addImageBtn.frame = CGRectMake(0, 0, 75, 75);
            [addImageBtn setImage:[UIImage imageNamed:@"添加照片.png"] forState:UIControlStateNormal];
            [addImageBtn addTarget:self action:@selector(addUserImage) forControlEvents:UIControlEventTouchUpInside];
            [_userImageView addSubview:addImageBtn];
            addImageBtn.hidden = YES;
            
            [_tableView reloadData];
            
            self.isRequest = NO;
            _edit = NO;
        }
    }
}

#pragma mark - 开始聊天
- (void)beginChatWithUser
{
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if (self.isAttention==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先关注该用户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if ([[ALXMPPEngine defauleEngine] isLoggedIn]==NO)
    {
        [self checkUserState];
    }
    else
    {
        [self openChatView];
    }
}

- (void)checkUserState
{
    if (self.isRequest==YES)
    {
        return;
    }
    
    self.isRequest=YES;
    
    __block typeof(self) bself = self;
    
    [self showF3HUDLoad:nil];
    
    NSLog(@"登录！！！！！！");
    
    [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hideF3HUDSucceed:nil];
            
            [ViewData defaultManager].autoLogin=YES;
            [[ViewData defaultManager] setNSTimer];
            
            [ViewData defaultManager].logOut = NO;
            bself.isRequest = NO;
            
            [bself openChatView];
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
                        [ViewData defaultManager].autoLogin=NO;
                        [[ViewData defaultManager] stopNSTimer];

                        [bself hideF3HUDError:nil];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请重新尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                        [alert release];
                        alert=nil;
                        
                        bself.isRequest = NO;
                    }
                }];
            }
            else
            {
                [bself hideF3HUDError:nil];

                bself.isRequest = NO;
                [ViewData defaultManager].autoLogin=NO;
                [[ViewData defaultManager] stopNSTimer];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请重新尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                alert=nil;
            }
        }
        
    }];

}

- (void)loginChat
{
    __block typeof(self) bself = self;

    [[ALXMPPEngine defauleEngine] logInWithUser:[ALUserEngine defauleEngine].user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [ViewData defaultManager].autoLogin=YES;
            [[ViewData defaultManager] setNSTimer];
            
            [ViewData defaultManager].logOut = NO;
            bself.isRequest = NO;
            
            [bself openChatView];
        }
        else
        {
            [bself hideF3HUDError:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请重新尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            alert=nil;
        }
    }];
}

- (void)openChatView
{
    if (self.isBeginChat==YES)
    {
        return;
    }
    
    self.isBeginChat=YES;
    
    [self showF3HUDLoad:nil];
    
    __block typeof(self) bself = self;
    
    [[ALXMPPEngine defauleEngine] beganToChatWithUser:self.user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hideF3HUDSucceed:nil];
            
            ChatViewController *chatView = [[ChatViewController alloc] initWithUser:bself.user];
            [bself.navigationController pushViewController:chatView AnimatedType:MLNavigationAnimationTypeOfNone];
            [chatView release];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
        
        bself.isBeginChat=NO;
    }];
}


#pragma mark  请求个人资料
- (void)requestPersonalData
{
    [self.user fetchIfNeeded];
    
    if (_from==NO)
    {
        [[ALUserEngine defauleEngine].user refresh];
    }
    
    UserInfo *_userinfo = (UserInfo *)[self.user.userInfo fetchIfNeeded];
    UserCount *_usercontent = (UserCount *)[self.user.userCount fetchIfNeeded];

    [self performSelectorOnMainThread:@selector(refreshPersonalData:) withObject:[NSArray arrayWithObjects:_userinfo,_usercontent, nil] waitUntilDone:NO];
}

- (void)editUserInfo:(UIButton *)sender
{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //编辑相册
    if (actionSheet.tag==5000)
    {
        if (self.completeDownLoadImage==NO)
        {
            return;
        }
        if (buttonIndex==0)
        {
            if (addImageBtn && self.userImageArray.count<8)
            {
                CGRect rect = CGRectFromString([self.userPointArray objectAtIndex:self.userImageArray.count]);
                addImageBtn.frame = rect;
                addImageBtn.hidden=NO;
            }
            else
            {
                addImageBtn.hidden=YES;
            }
            
            _editphotoalbum=YES;
            [updateData setImage:[UIImage imageNamed:@"完成.png"] forState:UIControlStateNormal];
        }
        if (buttonIndex==1)
        {
            if (self.user)
            {
                NSArray *array = [NSArray arrayWithObjects:self.gradute,self.study,self.interest,self.signature, username.text, self.user.headView.url, ageLabel.text, marryLabel.text, [NSNumber numberWithBool:self.user.gender], nil];
                
                EditViewController *editview = [[EditViewController alloc] initWithUser:self.user UserInfo:array];
                [self.navigationController pushViewController:editview animated:YES];
                [editview release];
            }
        }
    }
    //删除照片
    if (actionSheet.tag==5001)
    {
        if (buttonIndex==0)
        {
            [self deleteUserImage:nil];
        }
    }
    //上传照片
    if (actionSheet.tag==5002)
    {
        if(buttonIndex == 0)
        {
            UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
            imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePiker.delegate = self;
            imagePiker.allowsEditing = YES;
            [self presentViewController:imagePiker
                               animated:YES
                             completion:NULL];
            [imagePiker release];
        }
        if (buttonIndex == 1)
        {
            
            UIImagePickerController *imagPickerC = [[UIImagePickerController alloc] init];//图像选取器
            imagPickerC.delegate = self;
            imagPickerC.allowsEditing = YES;
            imagPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
            imagPickerC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
            [self presentViewController:imagPickerC animated:YES completion:nil];
            [imagPickerC release];
            
        }
    }
 
}

- (void)updateData
{
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    
    if (_editphotoalbum==YES)
    {
        if (addImageBtn)
        {
            addImageBtn.hidden=YES;
        }
        _editphotoalbum=NO;
        
        [updateData setImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];

        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑相册",@"编辑个人资料", nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 5000;
    [actionSheet release];
    actionSheet=nil;
}

- (void)refreashUserInfo:(NSNotification *)info
{
    [self showF3HUDLoad:nil];
    
    [self performSelectorInBackground:@selector(requestUserInfo) withObject:nil];
}

- (void)requestUserInfo
{
    [self.user refresh];
    
    UserInfo *_userinfo = (UserInfo *)[self.user.userInfo fetchIfNeeded];
    
    [self performSelectorOnMainThread:@selector(refreshUserInfo:) withObject:_userinfo waitUntilDone:NO];
    
}

- (void)refreshUserInfo:(UserInfo *)_userinfo
{
    int _gender = self.user.gender;
    
    headImageAsy.urlString = self.user.headView.url;
    username.text = self.user.nickName;
    ageLabel.text = [NSString stringWithFormat:@"%d",_userinfo.age];
    starLabel.text = [NSString stringWithFormat:@"%@座",_userinfo.constellation];
    marryLabel.text = _userinfo.affectiveState;
    
    CGSize userNameSize = [username.text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:0];
    
    sexImage.frame = CGRectMake(115+userNameSize.width+10, 23, 17/2, 28/2);
    
    //女
    if (_gender==0)
    {
        touxiang.image = [UIImage imageNamed:@"nv.png"];
        
        sexImage.image = [UIImage imageNamed:@"_0000_♀-.png"];
    }
    //男
    if (_gender==1)
    {
        touxiang.image = [UIImage imageNamed:@"nan.png"];
        
        sexImage.image = [UIImage imageNamed:@"_0003_♂.png"];
    }
    //删除
    if (_gender==2)
    {
        touxiang.image = [UIImage imageNamed:@"图层-20.png"];
    }
    
    if (_userinfo.graduateSchool.length==0)
    {
        self.gradute = @"暂无";
    }
    else
    {
        self.gradute = _userinfo.graduateSchool;
    }
    
    if (_userinfo.interest.length==0)
    {
        self.interest = @"暂无";
    }
    else
    {
        self.interest = _userinfo.interest;
    }
    
    if (_userinfo.company.length==0)
    {
        self.study = @"暂无";
    }
    else
    {
        self.study = _userinfo.company;
    }
    
    if (self.user.signature.length==0)
    {
        self.signature = @"暂无";
    }
    else
    {
        self.signature = self.user.signature;
    }
    
    
    [_tableView reloadData];
    
    [self hideF3HUDSucceed:nil];

}

- (void)updataUserRelationList
{
    [self.user refresh];
    
    UserCount *_usercontent = (UserCount *)[self.user.userCount fetchIfNeeded];

    __block typeof(self) bself = self;
    
    __block UITableView *__tableview = _tableView;
    
    [[ALUserEngine defauleEngine] refreashRelationWithUser:self.user block:^(NSDictionary *relationInfo, NSError *error) {
        
        NSString *numberOfFans = [NSString stringWithFormat:@"%d",_usercontent.numberOfFollows];
        NSString *numberOfFriends = [NSString stringWithFormat:@"%d",_usercontent.numberOfFriends];
        NSString *numberOfBilaterals = [NSString stringWithFormat:@"%d",_usercontent.numberOfBilaterals];
        NSString *numberOfBanList = [NSString stringWithFormat:@"%d",_usercontent.numberOfBanList];
        
        [bself.datalist setValue:numberOfFans forKey:@"fans"];
        [bself.datalist setValue:numberOfFriends forKey:@"friends"];
        [bself.datalist setValue:numberOfBilaterals forKey:@"bilaterals"];
        [bself.datalist setValue:numberOfBanList forKey:@"ban"];

        [__tableview reloadData];
        
        bself.isRequest = NO;
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalImageView:) name:@"removeImageView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreashUserInfo:) name:UPDATEUSERINFO object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataUserRelationList) name:UPDATEUSERRELATIONLIST object:nil];
    
    self.userImageArray = [NSMutableArray arrayWithCapacity:0];
    self.userPhotosArray = [NSMutableArray arrayWithCapacity:0];
    self.userPointArray = [NSMutableArray arrayWithCapacity:0];
    self.datalist = [NSMutableDictionary dictionary];
    
    for (int j=0; j<2; j++)
    {
        for (int i=0; i<4; i++)
        {
            CGRect rect = CGRectMake(5+i*78, 7+j*78, 75, 75);
            
            [self.userPointArray addObject:NSStringFromCGRect(rect)];
        }
    }
    
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
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    
    tabelViewHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 164+122)];
    tabelViewHeadView.image = [UIImage imageNamed:@"照片bg.png"];
    tabelViewHeadView.userInteractionEnabled = YES;
    
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 164, 320, 122)];
    headView.backgroundColor = [UIColor clearColor];
    [tabelViewHeadView addSubview:headView];
    [headView release];
    
    
    UIImageView *headImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0002_personal_bg.png"]];
    headImage.userInteractionEnabled = YES;
    headImage.frame = CGRectMake(0, 0, 320, 122);
    [headView addSubview:headImage];
    [headImage release];
    
    
    touxiang = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004_头像_default.png"]];
    touxiang.frame = CGRectMake(0, 0, 78, 78);
    touxiang.center = CGPointMake(60, 122/2);
    
    int _gender = self.user.gender;
    //女
    if (_gender==0)
    {
        touxiang.image = [UIImage imageNamed:@"nv.png"];
    }
    //男
    if (_gender==1)
    {
        touxiang.image = [UIImage imageNamed:@"nan.png"];
    }
    //删除
    if (_gender==2)
    {
        touxiang.image = [UIImage imageNamed:@"图层-20.png"];
    }
    
    [headView addSubview:touxiang];
    [touxiang release];
    
    headImageAsy = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70) ImageState:0];
    headImageAsy.center = CGPointMake(60, 122/2);
    headImageAsy.defaultImage = 0;
    headImageAsy.urlString = self.user.headView.url;
    [headImageAsy addTarget:self action:@selector(showOriginalImage:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:headImageAsy];
    [headImageAsy release];
    
    username = [[UILabel alloc] initWithFrame:CGRectMake(115, 20, 200, 20)];
    username.text = self.user.nickName;
    username.textColor = [UIColor whiteColor];
    [username setTextAlignment:NSTextAlignmentLeft];
    username.font = [UIFont systemFontOfSize:18];
    username.backgroundColor = [UIColor clearColor];
    [headView addSubview:username];
    [username release];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT-45-[ViewData defaultManager].versionHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tag = 5000;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.tableHeaderView = tabelViewHeadView;
    [backgroundView addSubview:_tableView];
    
    [tabelViewHeadView release];
    [_tableView release];
    
    
    naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    if (_fromcenter)
    {
        UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
        [showLeftViewBtn setImage:[UIImage imageNamed:@"_0010_chat_返回.png"] forState:UIControlStateNormal];
        [showLeftViewBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [naviView addSubview:showLeftViewBtn];
    }
    else
    {
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
    }
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"个人资料";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];

    
    //[self showF3HUDLoad:nil];

    //增加照片墙
    [self addUserImageView];
    [self downLoadUserImage];

    if (self.userName==nil)
    {
        [self performSelectorInBackground:@selector(requestPersonalData) withObject:nil];
    }
   
}

- (void)addUserImageToUserView:(NSArray *)photos
{
    self.completeDownLoadImage=YES;
    
    int counts = photos.count;
    
    if (counts<=4)
    {
        for (int i=0; i<counts; i++)
        {
            Photo *temp = [photos objectAtIndex:i];
            
            AsyncImageView *asyView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5+i*78, 7, 75, 75) ImageState:1];
            [asyView.layer setMasksToBounds:YES];
            [asyView.layer setCornerRadius:3.0];//设置矩形四个圆角半径
            asyView.urlString = temp.image.url;
            [asyView addTarget:self action:@selector(showUserImage:) forControlEvents:UIControlEventTouchUpInside];
            [_userImageView addSubview:asyView];
            asyView.tag = i+1000;
            
            [self.userImageArray addObject:temp.image.url];
            [self.userPhotosArray addObject:temp];
            [asyView release];
        }
    }
    else
    {
        for (int j=0; j<2; j++)
        {
            for (int i=0; i<4; i++)
            {
                if (j==1)
                {
                    if (i==counts-4)
                    {
                        return;
                    }
                }
                
                Photo *temp = [photos objectAtIndex:i+j*4];
                
                AsyncImageView *asyView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5+i*78, 7+j*78, 75, 75) ImageState:1];
                [asyView.layer setMasksToBounds:YES];
                [asyView.layer setCornerRadius:3.0];//设置矩形四个圆角半径
                asyView.urlString = temp.image.url;
                [asyView addTarget:self action:@selector(showUserImage:) forControlEvents:UIControlEventTouchUpInside];
                [_userImageView addSubview:asyView];
                asyView.tag = i+j*4+1000;
                
                [self.userImageArray addObject:temp.image.url];
                [self.userPhotosArray addObject:temp];
                
                [asyView release];
                
            }
        }
    }
    
    
    if (counts<8)
    {
        CGRect rect = CGRectFromString([self.userPointArray objectAtIndex:counts]);
        addImageBtn.frame = rect;
    }
}

- (void)downLoadUserImage
{
    __block typeof(self) bself = self;
    
    __block UIActivityIndicatorView *__activity = _activityView;

    [[ALUserEngine defauleEngine] getUserAlbumWithUser:self.user block:^(NSArray *photos, NSError *error) {
        
        [__activity stopAnimating];
        
        if (!error)
        {
            [bself addUserImageToUserView:photos];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户相册加载错误" delegate:bself cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        
    }];
}

- (void)addUserImageView
{
    _userImageView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,164)];
    _userImageView.backgroundColor = [UIColor clearColor];
    [tabelViewHeadView addSubview:_userImageView];
    [_userImageView release];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.center = CGPointMake(160, 82);
    [_userImageView addSubview:_activityView];
    [_activityView release];
    [_activityView startAnimating];
}

- (void)showUserImage:(AsyncImageView *)sender
{
    int _tag = sender.tag-1000;
    deleteImageTag = _tag;
    
    if (_editphotoalbum==YES)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除照片", nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = 5001;
        [actionSheet release];
        actionSheet=nil;
    }
    else
    {
        MWPhoto *photo;
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        
        for (int i=0; i<self.userImageArray.count; i++)
        {
            id content = [self.userImageArray objectAtIndex:i];
            
            if ([content isKindOfClass:[NSString class]])
            {
                NSString *str = [self.userImageArray objectAtIndex:i];
                [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:str]]];
            }
            else
            {
                photo = [MWPhoto photoWithImage:[self.userImageArray objectAtIndex:i]];
                [photos addObject:photo];
            }
        }
        
        self.photos = [NSArray arrayWithArray:photos];
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        //browser.wantsFullScreenLayout = NO;
        [browser setInitialPageIndex:_tag];
        [self presentViewController:browser animated:YES completion:nil];
        [browser release];
        [photos release];
    }
    
   
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)deleteUserImage:(UIButton *)sender
{
    int _tag = deleteImageTag;
    
    id content = [self.userImageArray objectAtIndex:_tag];
    
    if ([content isKindOfClass:[NSString class]])
    {
        Photo *_temp = [self.userPhotosArray objectAtIndex:_tag];
        [[ALUserEngine defauleEngine] deleteMyAlbumWithPhotos:[NSArray arrayWithObjects:_temp, nil] block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded && !error)
            {
                NSLog(@"删除照片成功");
            }
            
        }];
        
    }

    
    [_userImageView removeFromSuperview];
    _userImageView=nil;
    [self addUserImageView];
    [_activityView stopAnimating];
    
    [self.userImageArray removeObjectAtIndex:_tag];

    int counts = self.userImageArray.count;
    
    for (int i=0; i<counts; i++)
    {
        id temp = [self.userImageArray objectAtIndex:i];
        CGRect _frame = CGRectFromString([self.userPointArray objectAtIndex:i]);
        
        if ([temp isKindOfClass:[NSString class]])
        {
            AsyncImageView *asyView = [[AsyncImageView alloc] initWithFrame:_frame ImageState:1];
            asyView.urlString = temp;
            [asyView addTarget:self action:@selector(showUserImage:) forControlEvents:UIControlEventTouchUpInside];
            [_userImageView addSubview:asyView];
            asyView.tag = i+1000;
            
            [asyView release];
        }
        else
        {
            UIButton *_btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_btn setImage:temp forState:UIControlStateNormal];
            [_btn addTarget:self action:@selector(deleteUserImage:) forControlEvents:UIControlEventTouchUpInside];
            _btn.frame = _frame;
            _btn.tag = i+1000;
            [_userImageView addSubview:_btn];
  
        }
    }

    if (self.userImageArray.count<8)
    {
        addImageBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect rect = CGRectFromString([self.userPointArray objectAtIndex:self.userImageArray.count]);
        addImageBtn.frame = rect;
        [addImageBtn setImage:[UIImage imageNamed:@"添加照片.png"] forState:UIControlStateNormal];
        [addImageBtn addTarget:self action:@selector(addUserImage) forControlEvents:UIControlEventTouchUpInside];
        [_userImageView addSubview:addImageBtn];
    }
    else
    {
        addImageBtn.hidden=YES;
    }

}

- (void)addUserImage
{
    if (self.userImageArray.count==8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"只能上传8张照片" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 5002;
    [actionSheet release];
    actionSheet=nil;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.userImageArray.count>=8)
    {
        return;
    }

    self.userImg = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    
    [self updateUserImage];
  //  [self performSelectorInBackground:@selector(updateUserImage) withObject:nil];
}

- (void)updateUserImage
{
    
    [_activityView startAnimating];
    
    Photo *_userPhotos = [Photo object];
    
    AVFile *_file = [AVFile fileWithName:[NSString stringWithFormat:@"%d.jpg",(int)[[NSDate date] timeIntervalSince1970]] data:UIImageJPEGRepresentation(self.userImg, 0.1)];
    [_file save];
    _userPhotos.image = _file;
    
    NSArray *array = [NSArray arrayWithObjects:_userPhotos, nil];
    
    int counts = self.userImageArray.count;
    
    if (counts<=3)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5+self.userImageArray.count*78, 7, 75, 75);
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:3.0];//设置矩形四个圆角半径
        [btn addTarget:self action:@selector(showUserImage:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:self.userImg forState:UIControlStateNormal];
        btn.tag = self.userImageArray.count+1000;
        [_userImageView addSubview:btn];
        
        [self.userImageArray addObject:self.userImg];

    }
    else
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5+(self.userImageArray.count-4)*78, 85, 75, 75);
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:3.0];//设置矩形四个圆角半径
        [btn addTarget:self action:@selector(showUserImage:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:self.userImg forState:UIControlStateNormal];
        btn.tag = self.userImageArray.count+1000;
        [_userImageView addSubview:btn];
        

        [self.userImageArray addObject:self.userImg];

    }
    
    if (self.userImageArray.count<8)
    {
        CGRect rect = CGRectFromString([self.userPointArray objectAtIndex:self.userImageArray.count]);
        addImageBtn.frame = rect;
    }
    else
    {
        addImageBtn.hidden=YES;
    }
    
    __block UIActivityIndicatorView *__activity = _activityView;
    
    [[ALUserEngine defauleEngine] updateMyAlbumWithPhotos:array block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            NSLog(@"succeed");
        }
        else
        {
            NSLog(@"error=%@",error);
        }
        
        [__activity stopAnimating];
    }];
}



- (void)showUserImageView:(UIScrollView *)scrollView
{
    
    [UIView animateWithDuration:0.3 animations:^{


        _tableView.contentOffset = CGPointMake(0, -200);
        
        } completion:^(BOOL finished) {
           
           
    }];
}

- (void)hideUserImageView:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    } completion:^(BOOL finished) {
        
        
    }];
}

#pragma mark 显示用户头像
- (void)showOriginalImage:(AsyncImageView *)sender
{
    if(self.user.headView.url)
    {
        if(showImageView==nil)
        {
            [self addImageView:sender.downimage Url:nil];
        }
    }
}

- (void)addImageView:(UIImage *)img Url:(NSString *)url
{
    showImageView = [[ShowImageViewController alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) ImageUrl:url Image:img];
    [self.view addSubview:showImageView.view];
}

- (void)removeOriginalImageView:(NSNotification *)info
{
    [showImageView release];
    showImageView=nil;
}



#pragma mark 关注/取消
- (void)attention:(UIButton *)btn
{
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if (!self.user)
    {
        return;
    }
    
    __block typeof(self) bself = self;

    [self showF3HUDLoad:nil];
    
    __block UIButton *__attentionbtn = attentioBtn;
    __block UIButton *__cancelbtn = cancelAttentioBtn;
    
    [[ALUserEngine defauleEngine] addFriendWithUser:self.user orBkName:nil block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            __attentionbtn.hidden = YES;
            __cancelbtn.hidden = NO;
            [bself hideF3HUDSucceed:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHLINKLIST object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEUSERRELATIONLIST object:nil];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
    }];

}

- (void)cancelAttention:(UIButton *)btn
{
    if ([[ALUserEngine defauleEngine] isLoggedIn]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    __block typeof(self) bself = self;

    if (!self.user)
    {
        return;
    }
    
    [self showF3HUDLoad:nil];
    
    __block UIButton *__attentionbtn = attentioBtn;
    __block UIButton *__cancelbtn = cancelAttentioBtn;

    [[ALUserEngine defauleEngine] removeFriendWithUser:self.user block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            __attentionbtn.hidden = NO;
            __cancelbtn.hidden = YES;
            [bself hideF3HUDSucceed:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESHLINKLIST object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEUSERRELATIONLIST object:nil];

        }
        else
        {
            [bself hideF3HUDError:nil];
        }
    }];
}

#pragma mark UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==3)
    {
        NSString *_school = @"北京大学";
        CGSize userNameSize = [_school sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:0];
        return userNameSize.height+50;
        
    }
    if(indexPath.row==4)
    {
        NSString *_school = @"哈佛大学";
        CGSize userNameSize = [_school sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(160, 1000) lineBreakMode:0];
        return userNameSize.height+50;
        
    }
    if(indexPath.row==5)
    {
        NSString *_school = @"篮球、足球、游泳";
        CGSize userNameSize = [_school sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:0];
        return userNameSize.height+50;
        
    }
    if(indexPath.row==6)
    {
        NSString *_school;
        
        if (self.user.signature.length>0)
        {
            _school = self.user.signature;
        }
        else
        {
            _school = @"暂无";
        }
        
        CGSize userNameSize = [_school sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:0];
        
        return userNameSize.height+50;
        
    }
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cellidentifier = @"cell1";
    
    PersonalCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    
    if (cell==nil)
    {
        cell = [[[PersonalCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }

  
    if(indexPath.row==0)
    {
        cell.label1.hidden = NO;
        cell.label2.hidden = NO;
        cell.label3.hidden = NO;
        
        cell.label1.text = @"问题数";
        cell.label2.text = @"回答数";
        cell.label3.text = @"评论数";
        
        cell.question.text = [self.datalist objectForKey:@"threads"];
        cell.answer.text = [self.datalist objectForKey:@"posts"];
        cell.bestAnswer.text = [self.datalist objectForKey:@"comments"];
        
        cell.conBtn1.frame = CGRectMake(1, 5, 90, 60);
        cell.conBtn1.tag = 1000;
        [cell.conBtn1 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.conBtn2.frame = CGRectMake(1+110, 5, 90, 60);
        cell.conBtn2.tag = 1001;
        [cell.conBtn2 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.conBtn3.frame = CGRectMake(1+110*2, 5, 90, 60);
        cell.conBtn3.tag = 1002;
        [cell.conBtn3 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        

        cell.shuxian1.frame = CGRectMake(106, 0, 1, 70);
        cell.shuxian1.image = [UIImage imageNamed:@"_0007__.png"];
   
        cell.shuxian2.frame = CGRectMake(212, 0, 1, 70);
        cell.shuxian2.image = [UIImage imageNamed:@"_0007__.png"];
        
        cell.hengxian1.frame = CGRectMake(0, 69, 320, 1);
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
        
    }
    if(indexPath.row==1)
    {
        cell.label1.hidden = NO;
        cell.label2.hidden = NO;
        cell.label3.hidden = NO;
        
        cell.label1.text = @"粉丝";
        cell.label2.text = @"关注";
        cell.label3.text = @"互粉";
        
        cell.fans.text = [self.datalist objectForKey:@"fans"];
        cell.attention.text = [self.datalist objectForKey:@"friends"];
        cell.level.text = [self.datalist objectForKey:@"bilaterals"];
        
        cell.conBtn1.frame = CGRectMake(1, 5, 90, 60);
        cell.conBtn1.tag = 2000;
        [cell.conBtn1 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.conBtn2.frame = CGRectMake(1+110, 5, 90, 60);
        cell.conBtn2.tag = 2001;
        [cell.conBtn2 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.conBtn3.frame = CGRectMake(1+110*2, 5, 90, 60);
        cell.conBtn3.tag = 2002;
        [cell.conBtn3 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.shuxian1.frame = CGRectMake(106, 0, 1, 70);
        cell.shuxian1.image = [UIImage imageNamed:@"_0007__.png"];
        
        cell.shuxian2.frame = CGRectMake(212, 0, 1, 70);
        cell.shuxian2.image = [UIImage imageNamed:@"_0007__.png"];
        
        cell.hengxian1.frame = CGRectMake(0, 69, 320, 1);
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
    }
    
    if(indexPath.row==2)
    {
        cell.label1.hidden = NO;
        cell.label2.hidden = NO;
        cell.label3.hidden = NO;
        
        cell.label1.text = @"收藏";
        cell.label2.text = @"最佳答案";
        cell.label3.text = @"黑名单";
        
        cell.fans.text = [self.datalist objectForKey:@"collects"];
        cell.attention.text = [self.datalist objectForKey:@"bestAnswers"];
        cell.level.text = [self.datalist objectForKey:@"ban"];
        
        cell.conBtn1.frame = CGRectMake(1, 5, 90, 60);
        cell.conBtn1.tag = 3000;
        [cell.conBtn1 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.conBtn2.frame = CGRectMake(1+110, 5, 90, 60);
        cell.conBtn2.tag = 3001;
        [cell.conBtn2 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.conBtn3.frame = CGRectMake(1+110*2, 5, 90, 60);
        cell.conBtn3.tag = 3002;
        [cell.conBtn3 addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.shuxian1.frame = CGRectMake(106, 0, 1, 70);
        cell.shuxian1.image = [UIImage imageNamed:@"_0007__.png"];
        
        cell.shuxian2.frame = CGRectMake(212, 0, 1, 70);
        cell.shuxian2.image = [UIImage imageNamed:@"_0007__.png"];
        
        cell.hengxian1.frame = CGRectMake(0, 69, 320, 1);
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
    }

    
    if(indexPath.row==3)
    {
        cell.graduateSchool.text = self.gradute;

        CGSize userNameSize = [cell.graduateSchool.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:0];
        cell.label4.hidden = NO;
        cell.label4.text = @"毕业学校：";
        cell.graduateSchool.frame = CGRectMake(110, 26, 190, userNameSize.height);
        
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
        cell.hengxian1.frame = CGRectMake(0, 0, 280, 1);
        cell.hengxian1.center = CGPointMake(160, userNameSize.height+50);
    }
    
    if(indexPath.row==4)
    {
        cell.label4.hidden = NO;
        cell.label4.text = @"留学意向学校：";
        
        cell.studyAbroadSchool.text = self.study;
        
        CGSize userNameSize = [cell.studyAbroadSchool.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(160, 1000) lineBreakMode:0];
        cell.studyAbroadSchool.frame = CGRectMake(140, 26, 160, userNameSize.height);
        
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
        cell.hengxian1.frame = CGRectMake(0, 0, 280, 1);
        cell.hengxian1.center = CGPointMake(160, userNameSize.height+50);
    }
    if(indexPath.row==5)
    {
        cell.label4.hidden = NO;
        cell.label4.text = @"兴趣爱好：";
 
        cell.interest.text = self.interest;
        
        CGSize userNameSize = [cell.interest.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:0];
        cell.interest.frame = CGRectMake(110, 26, 190, userNameSize.height);
        
        
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
        cell.hengxian1.frame = CGRectMake(0, 0, 280, 1);
        cell.hengxian1.center = CGPointMake(160, userNameSize.height+50);
      
    }
    if(indexPath.row==6)
    {
        cell.label4.hidden = NO;
        cell.label4.text = @"个性签名：";
        
        cell.introduce.text = self.signature;
        
        CGSize userNameSize = [cell.introduce.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:0];
        cell.introduce.frame = CGRectMake(110, 26, 190, userNameSize.height);
        
        cell.hengxian1.image = [UIImage imageNamed:@"_0007__line.png"];
        cell.hengxian1.frame = CGRectMake(0, 0, 280, 1);
        cell.hengxian1.center = CGPointMake(160, userNameSize.height+50);
    }
    
    return cell;
}

- (void)showMoreInfo:(UIButton *)sender
{
    int row = sender.tag;
    
    if (!self.user)
    {
        return;
    }
    
    //发布主题
    if (row==1000)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"发布主题" User:self.user Tag:1 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];
        
        return;
    }
    
    //回复列表
    if (row==1001)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"回复" User:self.user Tag:2 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];
        
        return;
    }
    
    //评论列表
    if (row==1002)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"评论" User:self.user Tag:3 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];
        
        return;
    }
    
    //粉丝
    if (row==2000)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"粉丝" User:self.user Tag:4 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];
        
        return;
    }
    
    //关注
    if (row==2001)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"关注" User:self.user Tag:5 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];

        return;
    }
    
    //互粉列表
    if (row==2002)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"互粉" User:self.user Tag:6 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];
        
        return;
    }
    
    //收藏列表
    if (row==3000)
    {
        if (self.user)
        {
            
            ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"收藏" User:self.user Tag:7 FromSelf:_from];
            [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
            [threas release];
        }
        
        
        return;
    }
    
    //最佳答案
    if (row==3001)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"最佳答案" User:self.user Tag:8 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];

        return;
    }
    
    //黑名单
    if (row==3002)
    {
        ShowMyThreadsViewController *threas = [[ShowMyThreadsViewController alloc] initWithTitle:@"黑名单" User:self.user Tag:9 FromSelf:_from];
        [self.navigationController pushViewController:threas AnimatedType:MLNavigationAnimationTypeOfScale];
        [threas release];
        
        return;
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

#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    

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
    isShowMore = NO;
    
    [self requestPersonalData];
}

- (void)doneLoadingTableViewData
{
    isShowMore = NO;
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


- (void)back
{
    [self.navigationController popViewControllerAnimated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
