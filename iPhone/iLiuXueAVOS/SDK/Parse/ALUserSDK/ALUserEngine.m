//
//  ALUserEngine.m
//  LiveRoom
//
//  Created by Jack on 13-6-14.
//  Copyright (c) 2013年 Albert. All rights reserved.
//


#import "ALUserEngine.h"
//#import "BrithedayTransfrom.h"
//#import "ASIHTTPRequest.h"

@class Photo;
//#import "Photo.h"

#define NSLOG_SUCCESS NSLog(@"success")
#define NSLOG_FAILE NSLog(@"faile")
#define NSLOG_ERRER NSLog(@"Error: %@ %@", error, [error userInfo])

const NSString * userProperty = @"nickName headView gender signature credits experience creditsTitleSeries numberOfRemind location userCount userFavicon QQWeibo SinaWeibo RenRen WeChat";

@interface ALUserEngine()
@property (nonatomic, retain) NSMutableArray *follows;//粉丝
@property (nonatomic, retain) NSMutableArray *friends;//关注
@property (nonatomic, retain) NSMutableArray *bilaterals;//互粉
@property (nonatomic, retain) NSMutableArray *banList;//黑名单
@property (nonatomic, retain) NSDictionary *errorCode;
@end

static ALUserEngine *engine = nil;

@implementation ALUserEngine

@synthesize user=_user;

#pragma mark - 初始化
- (void)dealloc
{
    [_friends release];
    [_follows release];
    [_bilaterals release];
    [_banList release];
    [super dealloc];
}

+ (ALUserEngine *)defauleEngine
{
    if (!engine)
    {
        engine = [[ALUserEngine alloc] init];
        engine.friends = [NSMutableArray array];
        engine.follows = [NSMutableArray array];
        engine.bilaterals = [NSMutableArray array];
        engine.banList = [NSMutableArray array];
        
        engine.errorCode = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ErrorCode" ofType:@"plist"]] valueForKey:ERROR_CODE_KEY];
    }
    return engine;
}

- (void)setFriends:(NSMutableArray *)friends
{
    [_friends release];
    _friends = [friends retain];
}

- (void)setFollows:(NSMutableArray *)follows
{
    [_follows release];
    _follows = [follows retain];
}

- (void)setBilaterals:(NSMutableArray *)bilaterals
{
    [_bilaterals release];
    _bilaterals = [bilaterals retain];
}

- (void)setBanList:(NSMutableArray *)banList
{
    [_banList release];
    _banList = [banList retain];
}

#pragma mark - 用户
- (User *)user
{
    _user = (User *)[User currentUser];
    
    return _user;
}


#pragma mark - 注册登录
- (void)signUpWithUserName:(NSString *)theUserName
               andPassword:(NSString *)thePassword
                  andEmail:(NSString *)theEmail
                     block:(PFBooleanResultBlock)resultBlock
{
//    [resultBlock copy];
    
    __block typeof (self) bself = self;
    
    __block User *user = (User *)[User user];
    user.username = [theUserName lowercaseString];
    user.password = thePassword;
    user.email = theEmail;
    user.userKey = thePassword;
    
    user.userInfo = (UserInfo *)[UserInfo object];
    
    user.userCount = (UserCount *)[UserCount object];
    
    user.userFavicon = (UserFavicon *)[UserFavicon object];
//    user.userRelation = (UserRelation *)[UserRelation object];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLOG_ERRER;
        
        if (!error)
        {
            [bself bindingUser];
            
            [[User currentUser] refresh];
            
            UserRelation * userR = (UserRelation *)[UserRelation object];
            userR.user = bself.user;
            [userR saveEventually];
            
            //通知积分中心
            POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfSignUp, user, 0);
        }
        
        if (resultBlock)
        {
            resultBlock(succeeded,error);
        }
    }];
    
//    [resultBlock release];
}

//登录
- (void)logInWithUserName:(NSString *)theUserName
              andPassword:(NSString *)thePassword
              isAutoLogin:(BOOL)isAutlogin
                 latitude:(CGFloat)theLatitude
                longitude:(CGFloat)theLongitude
                    place:(NSString *)thePlace
                    block:(PFBooleanResultBlock)resultBlock
{
//    [resultBlock copy];
    
    __block typeof (self) bself = self;

    [User logInWithUsernameInBackground:theUserName password:thePassword block:^(AVUser *__user, NSError *error) {
        
        if (!error && __user)
        {
            [bself bindingUser];
            
            if (resultBlock)
            {
                resultBlock(YES,error);
            }
            
            User *user = (User *)__user;
            
//            NSLog(@"location=%@,%@",[AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude],thePlace);
            
            if (theLatitude>0 && theLongitude>0)
            {
                user.location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
            }
            if (thePlace.length>0)
            {
                user.place = thePlace;
            }
            
//            user.location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
//            user.place = thePlace;
//            user.location = [AVGeoPoint geoPointWithLatitude:31 longitude:44];
//            user.place = @"永乐小区";
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                NSLOG_ERRER;
                
                if (!error)
                {
                    [bself bindingUser];
                    //通知积分中心
                    POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfLogin, user, 0);
                }
                
                [user.userInfo fetchIfNeededInBackgroundWithBlock:nil];
                [user.userCount fetchIfNeededInBackgroundWithBlock:nil];
                [user.userFavicon fetchIfNeededInBackgroundWithBlock:nil];
//                [_user.userRelation fetchIfNeededInBackgroundWithBlock:nil];
            }];
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(NO,error);
            }
        }
    }];
    
//    [resultBlock release];
}

//登出
- (void)logOut
{
    [User logOut];
}

//是否已登录
- (BOOL)isLoggedIn
{
    return [User currentUser].isAuthenticated && self.user;
}

- (BOOL)_checkLoggedIn
{
    if (![self isLoggedIn])
    {
        NSLog(@"请先登录！！！");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PARSE_IS_NEED_LOGIN object:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}


- (void)uploadPointWithLatitude:(CGFloat)theLatitude
                      longitude:(CGFloat)theLongitude
                          place:(NSString *)thePlace
                          block:(PFBooleanResultBlock)resultBlock
{
//    [resultBlock copy];
    self.user.location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
    self.user.place = thePlace;
    [self.user saveInBackgroundWithBlock:resultBlock];
//    [resultBlock release];
}

#pragma mark - 绑定设备
//添加设备绑定
- (void)bindingUser
{
    [[AVInstallation currentInstallation] setObject:self.user forKey:@"owner"];
    [[AVInstallation currentInstallation] saveEventually];
}

//解除设备绑定
- (void)unbindingUser
{
    [[AVInstallation currentInstallation] removeObjectForKey:@"owner"];
    [[AVInstallation currentInstallation] saveEventually];
}

#pragma mark - 绑定第三方帐号
//绑定已有帐号
- (void)bindingOldAccountsWithAccessToken:(NSString *)theToken
                       andAccessTokenType:(ALDZAccessTokenType)theTokenType
                                    block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    switch (theTokenType) {
        case ALDZAccessTokenTypeOfSinaWeiBo:
            
            self.user.SinaWeibo = theToken;
            break;
        case ALDZAccessTokenTypeOfQQWeiBo:
            self.user.QQWeibo = theToken;
            break;
        case ALDZAccessTokenTypeOfRenren:
            self.user.RenRen = theToken;
            break;
        case ALDZAccessTokenTypeOfWeChat:
            self.user.WeChat = theToken;
            break;
        default:
            break;
    }
    
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (resultBlock) {
            resultBlock(succeeded,error);
        }
    }];
    
//    [resultBlock release];
}

//绑定新账号
- (void)bindingNewAccountsWithUserName:(NSString *)theUserName
                           andPassword:(NSString *)thePassword
                              andEmail:(NSString *)theEmail
                        andAccessToken:(NSString *)theToken
                    andAccessTokenType:(ALDZAccessTokenType)theTokenType
                                 block:(PFBooleanResultBlock)resultBlock
{
    
//    [resultBlock copy];
    
    __block BOOL isExsitToken = NO;
    __block typeof (self) bself = self;
    [self _accessTokenToUserWithToken:theToken block:^(AVUser *user, NSError *error) {
       
        if (user && !error)
        {
            isExsitToken = YES;
            
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_TOKEN_IS_EXIST]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_TOKEN_IS_EXIST, errorInfo));
            }
        }
    }];
    
    if (isExsitToken)
    {
        return;
    }
    
    __block User *user = (User *)[User user];
    user.username = theUserName;
    user.password = thePassword;
        
    UserInfo *userInfo = (UserInfo *)[UserInfo object];
    user.userInfo = userInfo;//不用先saveuserInfo
    
    switch (theTokenType) {
        case ALDZAccessTokenTypeOfSinaWeiBo:
            
            user.SinaWeibo = theToken;
            break;
        case ALDZAccessTokenTypeOfQQWeiBo:
            user.QQWeibo = theToken;
            break;
        case ALDZAccessTokenTypeOfRenren:
            user.RenRen = theToken;
            break;
        case ALDZAccessTokenTypeOfWeChat:
            user.WeChat = theToken;
            break;
        default:
            break;
        }
    
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error)
            {
                //通知积分中心
                POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfSignUp, user, 0);
            }
            
            if (resultBlock)
            {
                resultBlock(succeeded,error);
            }
        }];
        
    
//    [resultBlock release];
}

//解除绑定
- (void)unbindingWithAccessToken:(NSString *)theToken
              andAccessTokenType:(ALDZAccessTokenType)theTokenType
                           block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    __block typeof (self) bself = self;
    [self.user fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
//        NSLog(@"renren=%@ theToken=%@",self.user.RenRen,theToken);
        
        switch (theTokenType)
        {
            case ALDZAccessTokenTypeOfSinaWeiBo:
                
                if ([bself.user.SinaWeibo isEqualToString:theToken])
                    bself.user.SinaWeibo = @"";
                break;
                
            case ALDZAccessTokenTypeOfQQWeiBo:
                if ([bself.user.QQWeibo isEqualToString:theToken])
                    bself.user.QQWeibo = @"";
                break;
                
            case ALDZAccessTokenTypeOfRenren:
                if ([bself.user.RenRen isEqualToString:theToken])
                    bself.user.RenRen = @"";
                break;
                
            case ALDZAccessTokenTypeOfWeChat:
                if ([bself.user.WeChat isEqualToString:theToken])
                    bself.user.WeChat = @"";
                break;
                
            default:
                break;
        }
        
        [bself.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (resultBlock)
            {
                resultBlock(succeeded,error);
            }
        }];
    }];
}

//第三方登录
- (void)logInWithAccessToken:(NSString *)theToken
          andAccessTokenType:(ALDZAccessTokenType)theTokenType
                       block:(PFUserResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
    [self _accessTokenToUserWithToken:theToken block:^(AVUser *user, NSError *error) {
       
        User *_user = (User*)user;
        if (_user && !error)
        {
            [User logInWithUsernameInBackground:_user.username password:_user.userKey block:resultBlock];
        }
    }];
}

- (void)_accessTokenToUserWithToken:(NSString *)theToken block:(PFUserResultBlock)resultBlock
{
    AVQuery *Q1 = [User query];
    [Q1 whereKey:@"SinaWeibo" equalTo:theToken];
    
    AVQuery *Q2 = [User query];
    [Q2 whereKey:@"QQWeibo" equalTo:theToken];
    
    AVQuery *Q3 = [User query];
    [Q3 whereKey:@"RenRen" equalTo:theToken];
    
    
    AVQuery *Q4 = [User query];
    [Q4 whereKey:@"WeChat" equalTo:theToken];
    
    AVQuery *uQ = [AVQuery orQueryWithSubqueries:@[Q1,Q2,Q3,Q4]];
    
    [uQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (resultBlock)
        {
            resultBlock(object,error);
        }
    }];
}


#pragma mark - 用户资料
//更新我的用户资料
- (void)updateMyCardWithUserInfo:(NSDictionary *)theUserInfo
                           block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];

    if ([theUserInfo valueForKey:@"nickName"])
    {
        self.user.nickName = [theUserInfo valueForKey:@"nickName"];
    }
    
    if ([theUserInfo valueForKey:@"headView"])
    {
        self.user.headView = [theUserInfo valueForKey:@"headView"];
    }
    
    if ([theUserInfo valueForKey:@"location"])
    {
        self.user.location = [theUserInfo valueForKey:@"location"];
    }
    
    if ([theUserInfo valueForKey:@"gender"])
    {
        self.user.gender = [[theUserInfo valueForKey:@"gender"] boolValue];
    }
    
    if ([theUserInfo valueForKey:@"signature"])
    {
        self.user.signature = [theUserInfo valueForKey:@"signature"];
    }
    
    if ([theUserInfo valueForKey:@"interest"])
    {
        self.user.userInfo.interest = [theUserInfo valueForKey:@"interest"];
    }
    
    if ([theUserInfo valueForKey:@"affectiveState"])
    {
        self.user.userInfo.affectiveState = [theUserInfo valueForKey:@"affectiveState"];
    }
    
    if ([theUserInfo valueForKey:@"brithday"])
    {
        self.user.userInfo.brithday = [theUserInfo valueForKey:@"brithday"];
    }
    
    if ([theUserInfo valueForKey:@"telephone"])
    {
        self.user.userInfo.telephone = [theUserInfo valueForKey:@"telephone"];
    }
    
    if ([theUserInfo valueForKey:@"mobile"])
    {
        self.user.userInfo.mobile = [theUserInfo valueForKey:@"mobile"];
    }
    
    if ([theUserInfo valueForKey:@"address"])
    {
        self.user.userInfo.address = [theUserInfo valueForKey:@"address"];
    }
    
    if ([theUserInfo valueForKey:@"zipcode"])
    {
        self.user.userInfo.zipcode = [theUserInfo valueForKey:@"zipcode"];
    }
    
    if ([theUserInfo valueForKey:@"nationality"])
    {
        self.user.userInfo.nationality = [theUserInfo valueForKey:@"nationality"];
    }
    
    if ([theUserInfo valueForKey:@"brithProvince"])
    {
        self.user.userInfo.brithProvince = [theUserInfo valueForKey:@"brithProvince"];
    }
    
    if ([theUserInfo valueForKey:@"graduateSchool"])
    {
        self.user.userInfo.graduateSchool = [theUserInfo valueForKey:@"graduateSchool"];
    }
    
    if ([theUserInfo valueForKey:@"company"])
    {
        self.user.userInfo.company = [theUserInfo valueForKey:@"company"];
    }
    
    if ([theUserInfo valueForKey:@"education"])
    {
        self.user.userInfo.education = [theUserInfo valueForKey:@"education"];
    }
    
    if ([theUserInfo valueForKey:@"bloodType"])
    {
        self.user.userInfo.bloodType = [theUserInfo valueForKey:@"bloodType"];
    }
    
    if ([theUserInfo valueForKey:@"QQ"])
    {
        self.user.userInfo.QQ = [theUserInfo valueForKey:@"QQ"];
    }
    
    if ([theUserInfo valueForKey:@"MSN"])
    {
        self.user.userInfo.MSN = [theUserInfo valueForKey:@"MSN"];
    }
    
//    NSLog(@"%@--%d---%@---%@---%@---%@",self.user.userInfo.company,self.user.gender,self.user.userInfo.graduateSchool,self.user.userInfo.interest,self.user.nickName,self.user.signature);
    
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (resultBlock)
        {
            resultBlock(succeeded,error);
        }
    }];
    
    [resultBlock release];
}

//上传相册
- (void)updateMyAlbumWithPhotos:(NSArray *)thePhotos
                          block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    if ([thePhotos isKindOfClass:[NSArray class]])
    {
        [AVObject saveAllInBackground:thePhotos block:^(BOOL succeeded, NSError *error) {
            for (id photo in thePhotos)
            {
                if ([photo isKindOfClass:[Photo class]])
                {
                    if ([photo objectId])
                    {
                        [bself.user.userInfo.album addObject:photo];
                    }
                }
            }
            [self.user.userInfo saveEventually:resultBlock];
        }];
    }
    
    [resultBlock release];
}

//删除照片到相册
- (void)deleteMyAlbumWithPhotos:(NSArray *)thePhotos
                          block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    if ([thePhotos isKindOfClass:[NSArray class]])
    {
        [AVObject deleteAllInBackground:thePhotos block:resultBlock];
    }
    
//    [resultBlock release];
}

//取得用户资料
- (void)getMyCardWithBlock:(void(^)(User *user, NSError *error))resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    __block User *bUser = self.user;
    [self.user.userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (resultBlock) {
                resultBlock(bUser,error);
            }
    }];
//    [resultBlock release];
}

- (void)getUserCardWithUserName:(NSString *)theUserName
                          block:(void(^)(User *user, NSError *error))resultBlock
{
//    [resultBlock copy];
    AVQuery *userQ = [User query];
    [userQ includeKey:@"userInfo"];//同时下载userInfo的数据
    [userQ whereKey:@"username" equalTo:theUserName];//
    
    [userQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        User *user = (User *)object;
        if (resultBlock) {
            resultBlock(user,error);
        }
    }];
//    [resultBlock release];
}

//查看相册album
- (void)getMyAlbumWithBlock:(void(^)(NSArray *photos, NSError *error))resultBlock
{
//    [resultBlock copy];
    [self getUserAlbumWithUser:self.user block:resultBlock];
//    [resultBlock release];
}

- (void)getUserAlbumWithUser:(User *)theUser
                       block:(void(^)(NSArray *photos, NSError *error))resultBlock
{
//    [resultBlock copy];
    
    [theUser.userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        UserInfo *userInfo = (UserInfo *)object;
        AVQuery *query = [userInfo.album query];
        query.limit = 8;
        [query orderByAscending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (resultBlock) {
                resultBlock(objects,error);
            }
        }];
    }];
    
//    [resultBlock release];
}

#pragma mark - 用户关系
//关注用户
#pragma mark - 好友
- (void)addFriendWithUser:(User *)theUser
                 orBkName:(NSString *)theBkName
                    block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    [self _friendRequestWithToUser:theUser isAdd:YES block:resultBlock];
    
//    [resultBlock release];
}

//解除关注
//2次请求
- (void)removeFriendWithUser:(User *)theUser
                       block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    [self _friendRequestWithToUser:theUser isAdd:NO block:resultBlock];
    
//    [resultBlock release];
}

- (void)_friendRequestWithToUser:(User *)theUser
                           isAdd:(BOOL)isAdd
                           block:(PFBooleanResultBlock)resultBlock
{
//    [resultBlock copy];
    
    __block typeof (self) bself = self;
    
    __block int __count = 2;
    
    //我的关系
    __block AVQuery *userR = [UserRelation query];
    [userR whereKey:@"user" equalTo:self.user];
    [userR getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        if (object && !error)
        {
            UserRelation *userR = (UserRelation *)object;
            
            //添加好友
            if (isAdd)
            {
                [userR.friends addUniqueObject:theUser block:^{
                    [userR saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                        if (!succeeded || error)
                        {
                            if (resultBlock)
                            {
                                resultBlock(succeeded,error);
                            }
                            __count = -1;
                        }
                        
                        if (--__count==0)
                        {
                            if (resultBlock)
                            {
                                resultBlock(succeeded,error);
                            }
                        }
                    }];
                }];
            }
            //移除好友
            else
            {
                [userR.friends removeObject:theUser];
                [userR saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (!succeeded || error)
                    {
                        if (resultBlock)
                        {
                            resultBlock(succeeded,error);
                        }
                        __count = -1;
                    }
                    
                    if (--__count==0)
                    {
                        //发通知给通知中心
                        POST_NOTIFICATION_FRIEND_NOTIFICATION(ALFriendNotificationTypeOfNewFollower,bself.user,userR);
                        
                        if (resultBlock)
                        {
                            resultBlock(succeeded,error);
                        }
                    }
                }];
            }
        }
    }];
    
    //对方的关系
    userR = [UserRelation query];
    [userR whereKey:@"user" equalTo:theUser];
    [userR getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        if (object && !error)
        {
            UserRelation *userR = (UserRelation *)object;
            
            //添加粉丝
            if (isAdd)
            {
                
                [userR.follows addUniqueObject:bself.user block:^{
                    [userR saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (!succeeded || error)
                        {
                            if (resultBlock)
                            {
                                resultBlock(succeeded,error);
                            }
                            __count = -1;
                        }
                        
                        if (--__count==0)
                        {
                            //发通知给通知中心
                            POST_NOTIFICATION_FRIEND_NOTIFICATION(ALFriendNotificationTypeOfNewFollower,bself.user,userR);
                            
                            if (resultBlock)
                            {
                                resultBlock(succeeded,error);
                            }
                        }
                    }];
                }];
            }
            //移除粉丝
            else
            {
                [userR.follows removeObject:bself.user];
                [userR saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (!succeeded || error)
                    {
                        if (resultBlock)
                        {
                            resultBlock(succeeded,error);
                        }
                        __count = -1;
                    }
                    
                    if (--__count==0)
                    {
                        if (resultBlock)
                        {
                            resultBlock(succeeded,error);
                        }
                    }
                }];
            }
        }
    }];
    
//    [resultBlock release];
}



#pragma mark - 黑名单
//拉黑用户
//2次请求
- (void)addBanListWithUser:(User *)theUser
             orDescription:(NSString *)theDescription
                     block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    __block typeof (self) bself = self;
    
    //获取我的关系
    __block AVQuery *ARQ = [UserRelation query];
    [ARQ whereKey:@"user" equalTo:self.user];
    [ARQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        //我的关系
        UserRelation *userR = (UserRelation *)object;
        
        //加黑名单
        [userR.banList addUniqueObject:theUser block:^{
            [userR saveEventually:nil];
        }];
        
        //获取我的黑名单
//        [[userR.banList query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//            BOOL isExsit = [self isExsitTheUser:theUser inUsers:objects];
//            
//            //黑名单中还没有他
//            if (!isExsit)
//            {
//                [userR.banList addObject:theUser];
//                [userR saveEventually:nil];
//            }
//            else
//            {
//                
//            }
//        }];
    }];
    
    
    //获取他的关系
    __block AVQuery *BRQ = [UserRelation query];
    [BRQ whereKey:@"user" equalTo:theUser];
    [BRQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        //他的关系
        UserRelation *userR = (UserRelation *)object;
        
        [userR.friends removeObject:self.user];
        [userR.follows removeObject:self.user];
        
        [userR saveEventually:nil];
    }];
    
    
//    [resultBlock release];
}



//解除拉黑
- (void)removeBanListWithUser:(User *)theUser
                        block:(PFBooleanResultBlock)resultBlock
{
    if (![self _checkLoggedIn]) return;
    
//    [resultBlock copy];
    
    __block typeof (self) bself = self;
    
    //获取我的关系
    __block AVQuery *ARQ = [UserRelation query];
    [ARQ whereKey:@"user" equalTo:self.user];
    [ARQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
    
        //我的关系
        __block UserRelation *AR = (UserRelation *)object;
        
        //1.解除拉黑
        [AR.banList removeObject:theUser];
        [AR saveEventually:nil];
        
        AVQuery *BRQ = [UserRelation query];
        [BRQ whereKey:@"user" equalTo:theUser];
        
        //2.她是否在我的好友中
        [AR.friends isExsitObject:theUser block:^(BOOL isExsit) {
            //如果在我的好友中
            if (isExsit)
            {
                [BRQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                    
                    //对方的关系
                    UserRelation *BR = (UserRelation *)object;
                    [BR.follows addUniqueObject:bself.user block:^{
                        [BR saveEventually:nil];
                    }];
                }];
                
            }
        }];
        
        //3.她是否在我的粉丝中
        [AR.follows isExsitObject:theUser block:^(BOOL isExsit) {
            //如果在我的好友中
            if (isExsit)
            {
                [BRQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                    
                    //对方的关系
                    UserRelation *BR = (UserRelation *)object;
                    [BR.friends addUniqueObject:bself.user block:^{
                        [BR saveEventually:nil];
                    }];
                }];
            }
        }];
        
    }];
    
    
//    [resultBlock release];
}



//#pragma mark - 获得好友
//获的好友的Query
- (NSDictionary *)_refreashRelationCompleteWithUser:(User *)theUser block:(void(^)(NSDictionary *relationInfo ,NSError *error))resultBlock
{
//    self.friends;
//    self.follows;
//    self.bilaterals;
//    self.banList;
    
    NSLog(@"%d--%d--%d--%d",self.friends.count,self.follows.count,self.bilaterals.count,self.banList.count);
    
    //好友列表中去除在我黑名单中的
    NSMutableArray *tmpFriends = [NSMutableArray array];
    for (User *friend in self.friends)
    {
        if ([AVRelation isExsitTheObject:friend inObjects:self.banList])
        {
            [tmpFriends addObject:friend];
            
        }
    }
    for (User *friend in tmpFriends)
    {
        [self.friends removeObject:friend];
    }
    
    //粉丝列表中去除在我黑名单中的
    NSMutableArray *tmpFollows = [NSMutableArray array];
    for (User *follows in self.follows)
    {
        if ([AVRelation isExsitTheObject:follows inObjects:self.banList])
        {
            [tmpFollows addObject:follows];
        }
    }
    for (User *follows in tmpFollows)
    {
        [self.follows removeObject:follows];
    }
    
    //计算互粉
    for (User *friend in self.friends)
    {
        for (User *follow in self.follows)
        {
            if ([friend.objectId isEqualToString:follow.objectId])
            {
                if (![self.bilaterals containsObject:friend])
                [self.bilaterals addObject:friend];
            }
        }
    }
    
    
    //互粉列表中去除在我黑名单中的
//    NSMutableArray *tmpBilaterals = [NSMutableArray array];
//    for (User *bilaterals in self.bilaterals)
//    {
//        if ([AVRelation isExsitTheObject:bilaterals inObjects:self.banList])
//        {
//            [tmpBilaterals addObject:bilaterals];
//        }
//    }
//    for (User *bilaterals in tmpBilaterals)
//    {
//        [self.bilaterals removeObject:bilaterals];
//    }

    NSLog(@"%d--%d--%d--%d",self.friends.count,self.follows.count,self.bilaterals.count,self.banList.count);
    
    NSDictionary *resultInfo = @{@"friends":self.friends,@"follows":self.follows,@"bilaterals":self.bilaterals,@"banList":self.banList};
    
    if (resultBlock)
    {
        resultBlock(resultInfo,nil);
    }
    
    theUser.userCount.numberOfFriends = self.friends.count;
    theUser.userCount.numberOfFollows = self.follows.count;
    theUser.userCount.numberOfBilaterals = self.bilaterals.count;
    theUser.userCount.numberOfBanList = self.banList.count;
    
    [theUser saveEventually];
    
    return resultInfo;
}

- (void)refreashMyRelationWithBlock:(void(^)(NSDictionary *relationInfo ,NSError *error))resultBlock
{
//    [resultBlock copy];
    [self refreashRelationWithUser:self.user block:resultBlock];
//    [resultBlock release];
}

- (void)refreashRelationWithUser:(User *)theUser block:(void(^)(NSDictionary *relationInfo ,NSError *error))resultBlock
{
//    [resultBlock copy];
    
    __block typeof(self) bself = self;
    
    //获取我的关系表
    AVQuery *uFriendQ = [UserRelation query];
    [uFriendQ whereKey:@"user" equalTo:theUser];
    
    [uFriendQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
       
        if (object)
        {
            //我的关系表
            UserRelation *userRelation = (UserRelation *)object;
            
            __block int count = 3;
            
            //1 搜索我的关注（包含我ban，不包含我的粉丝）
            AVQuery *friendQ = [userRelation.friends query];
//            [friendQ whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:[userRelation.follows query]];
            [friendQ orderByAscending:@"nickname"];
            [friendQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

                for (User *user in objects)
                {
                    NSLog(@"关注:%@",user.nickName);
                }
                [bself.friends removeAllObjects];
                [bself.friends addObjectsFromArray:objects];
                
                if (--count==0)
                {
                    [bself _refreashRelationCompleteWithUser:theUser block:resultBlock];
                }
            }];
            
            //2 搜索我的粉丝（包含我ban，不包含我的好友）
            AVQuery *followQ = [userRelation.follows query];
//            [followQ whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:[userRelation.friends query]];
            [followQ orderByAscending:@"nickname"];
            [followQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for (User *user in objects)
                {
                    NSLog(@"粉丝:%@",user.nickName);
                }
                
                [bself.follows removeAllObjects];
                [bself.follows addObjectsFromArray:objects];
                
                if (--count==0)
                {
                    [bself _refreashRelationCompleteWithUser:theUser block:resultBlock];
                }
            }];
            
//            //3 搜索我的互粉（包含我ban）
//            AVQuery *bilateralsQ = [userRelation.friends query];
//            
//            //不对这样是所有人(AVOS bug)
////            [bilateralsQ whereKey:@"objectId" matchesKey:@"objectId" inQuery:[userRelation.follows query]];
//            [bilateralsQ whereKey:@"objectId" matchesQuery:[userRelation.follows query]];
//            [bilateralsQ orderByAscending:@"nickname"];
//            [bilateralsQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                
//                for (User *user in objects)
//                {
//                    NSLog(@"互粉:%@",user.nickName);
//                }
//                
//                [bself.bilaterals removeAllObjects];
//                [bself.bilaterals addObjectsFromArray:objects];
//                
//                if (--count==0)
//                {
//                    [bself _refreashRelationCompleteWithUser:theUser block:resultBlock];
//                }
//            }];
            
            //4 搜索我的黑名单
            [[userRelation.banList query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for (User *user in objects)
                {
                    NSLog(@"黑名单:%@",user.nickName);
                }
                
                [bself.banList removeAllObjects];
                [bself.banList addObjectsFromArray:objects];
                
                if (--count==0)
                {
                    [bself _refreashRelationCompleteWithUser:theUser block:resultBlock];
                }
            }];
        }
    }];
    
//    [resultBlock release];
}

- (void)refreashMyCountWithBlock:(PFBooleanResultBlock)resultBlock
{
//    [resultBlock copy];
    [self refreashCountWithUser:self.user block:resultBlock];
//    [resultBlock release];
}

- (void)refreashCountWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock
{
//    [resultBlock copy];
    
    __block int __count = 6;
    __block typeof (self) bself = self;
    
    //1
    AVQuery *threadQ = [AVQuery queryWithClassName:@"Thread"];
    [threadQ whereKey:@"postUser" equalTo:self.user];
    
    [threadQ countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        bself.user.userCount.numberOfThreads = number;
        if (--__count==0)
        {
            [bself.user.userCount saveEventually:resultBlock];
        }
    }];
    
    //2
    AVQuery *postQ = [AVQuery queryWithClassName:@"Post"];
    [postQ whereKey:@"postUser" equalTo:self.user];
    
    [postQ countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        bself.user.userCount.numberOfPosts = number;
        if (--__count==0)
        {
            [bself.user.userCount saveEventually:resultBlock];
        }
    }];
    
    //3
    AVQuery *commentQ = [AVQuery queryWithClassName:@"Comment"];
    [commentQ whereKey:@"postUser" equalTo:self.user];
    
    [commentQ countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        bself.user.userCount.numberOfComments = number;
        if (--__count==0)
        {
            [bself.user.userCount saveEventually:resultBlock];
        }
    }];
    
    //4
    [postQ whereKey:@"state" equalTo:@1];
    [postQ countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        bself.user.userCount.numberOfBestPosts = number;
        if (--__count==0)
        {
            [bself.user.userCount saveEventually:resultBlock];
        }
    }];
    
    
    //5
    [[self.user.userFavicon.threads query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        bself.user.userCount.numberOfFavicon = number;
        if (--__count==0)
        {
            [bself.user.userCount saveEventually:resultBlock];
        }
    }];
    
    //6
    [[self.user.userFavicon.supports query] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        bself.user.userCount.numberOfSupports = number;
        if (--__count==0)
        {
            [bself.user.userCount saveEventually:resultBlock];
        }
    }];

//    [resultBlock release];
}
- (void)_includeKeyWithUser:(AVQuery *)userQ
{
    [userQ includeKey:@"headView"];
    [userQ includeKey:@"userInfo"];
    [userQ includeKey:@"userCount"];
    [userQ includeKey:@"userFavicon"];
}

//#pragma mark - 搜索用户
//附近用户
- (void)getUserCardNotContainedIn:(NSArray *)theUsers
                  nearForLatitude:(CGFloat)theLatitude
                     andLongitude:(CGFloat)theLongitude
                         distance:(CGFloat)theDistance  //半径：公里
                            block:(void(^)(NSArray *userList, NSError *error))resultBlock
{
    AVGeoPoint *location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
    
    AVQuery *uQ = [User query];
    [uQ whereKey:@"location" nearGeoPoint:location withinKilometers:theDistance];
    [uQ orderByAscending:@"location"];
    
//    [self _includeKeyWithUser:uQ];
    
    [uQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects && !error)
        {
            if (resultBlock)
            {
                resultBlock(objects,error);
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(nil,error);
            }
        }
        
    }];
}

//昵称查找
- (void)getUserCardWithUserNickName:(NSString *)theNickName
                              block:(void(^)(NSArray *userList, NSError *error))resultBlock
{
    AVQuery *uQ = [User query];
    [uQ whereKey:@"nickName" matchesRegex:[NSString stringWithFormat:@".*%@.*",theNickName]];
    [uQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects && !error)
        {
            if (resultBlock)
            {
                resultBlock(objects,error);
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(nil,error);
            }
        }
        
    }];
}

//@{@"realname[like]":@[@"123",@"456",@"789"]}
//@{@"score[min]":@"100",@"score[max]":@"10000"}
//复合查找用户
- (void)getUserCardWithSearchInfo:(NSDictionary *)searchInfo
                            block:(void(^)(NSArray *userList, NSError *error))resultBlock
{
    AVQuery *uQ = [User query];
    AVQuery *uIQ = [UserInfo query];
    
    [uQ whereKey:@"userInfo" matchesQuery:uIQ];
    
    for (NSString *key in searchInfo.allKeys)
    {

        if ([key rangeOfString:@"[like]"].location != NSNotFound)
        {
            NSString *temKey = [key substringToIndex:[key rangeOfString:@"[like]"].location];
            
            if ([userProperty rangeOfString:temKey].location != NSNotFound)
            {
                [uQ whereKey:temKey matchesRegex:[NSString stringWithFormat:@".*%@.*",searchInfo[key]]];
            }
            else
            {
                [uIQ whereKey:temKey matchesRegex:[NSString stringWithFormat:@".*%@.*",searchInfo[key]]];
            }
        }
        else if ([key rangeOfString:@"[min]"].location != NSNotFound)
        {
            NSString *temKey = [key substringToIndex:[key rangeOfString:@"[min]"].location];
            
            if ([userProperty rangeOfString:temKey].location != NSNotFound)
            {
                [uQ whereKey:temKey lessThan:searchInfo[key]];
            }
            else
            {
                [uIQ whereKey:temKey lessThan:searchInfo[key]];
            }
        }
        else if ([key rangeOfString:@"[max]"].location != NSNotFound)
        {
            NSString *temKey = [key substringToIndex:[key rangeOfString:@"[max]"].location];
            
            if ([userProperty rangeOfString:temKey].location != NSNotFound)
            {
                [uQ whereKey:temKey greaterThan:searchInfo[key]];
            }
            else
            {
                [uIQ whereKey:temKey greaterThan:searchInfo[key]];
            }
        }
        else
        {
            if ([userProperty rangeOfString:key].location != NSNotFound)
            {
                [uQ whereKey:key equalTo:searchInfo[key]];
            }
            else
            {
                [uIQ whereKey:key equalTo:searchInfo[key]];
            }
        }
    }
    
    
    [uQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects && !error)
        {
            if (resultBlock)
            {
                resultBlock(objects,error);
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(nil,error);
            }
        }
    }];
}


@end


