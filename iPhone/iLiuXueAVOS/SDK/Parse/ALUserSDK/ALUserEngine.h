//
//  ALUserEngine.h
//  LiveRoom
//
//  Created by Jack on 13-6-14.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

#import "User.h"
#import "UserInfo.h"
#import "UserCount.h"
#import "ALUserConfig.h"
#import "UserRelation.h"
#import "UserFavicon.h"
#import "AVRelation+AddUniqueObject.h"

typedef NS_ENUM(NSUInteger, ALDZAccessTokenType) {
    ALDZAccessTokenTypeOfUndefined = 0,
    ALDZAccessTokenTypeOfSinaWeiBo,
    ALDZAccessTokenTypeOfQQWeiBo,
    ALDZAccessTokenTypeOfRenren,
    ALDZAccessTokenTypeOfWeChat,
};

@class UserRelation;
@class UserBanList;

@interface ALUserEngine : NSObject
         
@property (nonatomic, readonly) User *user;

+ (instancetype)defauleEngine;

//注册
- (void)signUpWithUserName:(NSString *)theUserName
               andPassword:(NSString *)thePassword
                  andEmail:(NSString *)theEmail
                     block:(PFBooleanResultBlock)resultBlock;

//补充用户资料
//- (void)updateUserInfoWithDisplayName:(NSString *)theDisplayName email:(NSString *)theEmail profilePic:(NSData *)theImageData block:(PFBooleanResultBlock)block;

//登陆
- (void)logInWithUserName:(NSString *)theUserName
              andPassword:(NSString *)thePassword
              isAutoLogin:(BOOL)isAutlogin
                 latitude:(CGFloat)theLatitude
                longitude:(CGFloat)theLongitude
                    place:(NSString *)thePlace
                    block:(PFBooleanResultBlock)resultBlock;

//登出
- (void)logOut;

//是否已登录
- (BOOL)isLoggedIn;


//
- (void)uploadPointWithLatitude:(CGFloat)theLatitude
                      longitude:(CGFloat)theLongitude
                          place:(NSString *)thePlace
                          block:(PFBooleanResultBlock)resultBlock;

//更新我的用户资料
/*

brithday(NSDAte),constellation,zodiac,telephone,mobile,address,zipcode,nationality,brithProvince,graduateSchool,company,education,bloodType,QQ,MSN,interest,abums(图片AVFile数组)

nickName,headView,location(AVGeoPoint)
 
 */
- (void)updateMyCardWithUserInfo:(NSDictionary *)theUserInfo
                           block:(PFBooleanResultBlock)resultBlock;

//上传照片到相册
- (void)updateMyAlbumWithPhotos:(NSArray *)thePhotos
                          block:(PFBooleanResultBlock)resultBlock;

//删除照片到相册
- (void)deleteMyAlbumWithPhotos:(NSArray *)thePhotos
                          block:(PFBooleanResultBlock)resultBlock;

//添加设备绑定
- (void)bindingUser;

//解除设备绑定
- (void)unbindingUser;

//绑定第三方帐号
//绑定已有帐号
- (void)bindingOldAccountsWithAccessToken:(NSString *)theToken
                       andAccessTokenType:(ALDZAccessTokenType)theTokenType
                                    block:(PFBooleanResultBlock)resultBlock;

//绑定新账号
- (void)bindingNewAccountsWithUserName:(NSString *)theUserName
                           andPassword:(NSString *)thePassword
                              andEmail:(NSString *)theEmail
                        andAccessToken:(NSString *)theToken
                    andAccessTokenType:(ALDZAccessTokenType)theTokenType
                                 block:(PFBooleanResultBlock)resultBlock;

//解除绑定
- (void)unbindingWithAccessToken:(NSString *)theToken
              andAccessTokenType:(ALDZAccessTokenType)theTokenType
                           block:(PFBooleanResultBlock)resultBlock;
//第三方登录
- (void)logInWithAccessToken:(NSString *)theToken
          andAccessTokenType:(ALDZAccessTokenType)theTokenType
                       block:(PFUserResultBlock)resultBlock;

//取得用户资料
- (void)getMyCardWithBlock:(void(^)(User *user, NSError *error))resultBlock;

- (void)getUserCardWithUserName:(NSString *)theUserName
                          block:(void(^)(User *user, NSError *error))resultBlock;

//查看相册album
- (void)getMyAlbumWithBlock:(void(^)(NSArray *photos, NSError *error))resultBlock;

- (void)getUserAlbumWithUser:(User *)theUser
                       block:(void(^)(NSArray *photos, NSError *error))resultBlock;



//用户关系:
//关注用户
- (void)addFriendWithUser:(User *)theUser
                 orBkName:(NSString *)theBkName
                    block:(PFBooleanResultBlock)resultBlock;

//解除关注
- (void)removeFriendWithUser:(User *)theUser
                       block:(PFBooleanResultBlock)resultBlock;

//拉黑用户
- (void)addBanListWithUser:(User *)theUser
             orDescription:(NSString *)theDescription
                     block:(PFBooleanResultBlock)resultBlock;

//解除拉黑
- (void)removeBanListWithUser:(User *)theUser
                        block:(PFBooleanResultBlock)resultBlock;

//取得用户的关注+粉丝+互粉+黑名单
//NSDictionary key : friends follows bilaterals banList -- 数组
//刷新了用户关系+userCount的关系数
- (void)refreashMyRelationWithBlock:(void(^)(NSDictionary *relationInfo ,NSError *error))resultBlock;

- (void)refreashRelationWithUser:(User *)theUser block:(void(^)(NSDictionary *relationInfo ,NSError *error))resultBlock;

- (void)refreashMyCountWithBlock:(PFBooleanResultBlock)resultBlock;

- (void)refreashCountWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock;

////我的关注
//- (void)getMyFrinendsWithBlock:(void(^)(NSArray *friends, NSError *error))resultBlock;
//
//- (void)getUserFrinendsWithUser:(User *)theUser
//                          block:(void(^)(NSArray *friends, NSError *error))resultBlock;
//
////我的粉丝
//- (void)getMyFollowsWithBlock:(void(^)(NSArray *follows, NSError *error))resultBlock;
//
//- (void)getUserFollowsWithUser:(User *)theUser
//                         block:(void(^)(NSArray *follows, NSError *error))resultBlock;
//
////我的互粉
//- (void)getMyBilateralsWithBlock:(void(^)(NSArray *bilaterals, NSError *error))resultBlock;
//
//- (void)getUserBilateralsWithUser:(User *)theUser
//                         block:(void(^)(NSArray *bilaterals, NSError *error))resultBlock;
//
////我的黑名单
//- (void)getMyBanListWithBlock:(void(^)(NSArray *banList, NSError *error))resultBlock;
//
//- (void)getUserBanListWithUser:(User *)theUser
//                         block:(void(^)(NSArray *banList, NSError *error))resultBlock;
//
//user.user.userCount有延迟
//更新服务器上的userCount数据，并获得及时的userCount，
//- (void)getMyCountWithBlock:(void(^)(UserCount *userCount, NSError *error))resultBlock;
//
//- (void)getUserCountWithUser:(User *)theUser
//                       block:(void(^)(UserCount *userCount, NSError *error))resultBlock;

//查找用户
//附近用户
- (void)getUserCardNotContainedIn:(NSArray *)theUsers
                  nearForLatitude:(CGFloat)theLatitude
                     andLongitude:(CGFloat)theLongitude
                         distance:(CGFloat)theDistance  //半径：公里
                            block:(void(^)(NSArray *userList, NSError *error))resultBlock;

//用户名查找
//- (void)getUserCardWithUserName:(NSString *)theUserName
//                          block:(void(^)(NSArray *userList, NSError *error))resultBlock;

//昵称查找
- (void)getUserCardWithUserNickName:(NSString *)theNickName
                              block:(void(^)(NSArray *userList, NSError *error))resultBlock;

//@{@"realname[like]":@[@"123",@"456",@"789"]}
//@{@"score[min]":@"100",@"score[max]":@"10000"}
//复合查找用户
- (void)getUserCardWithSearchInfo:(NSDictionary *)searchInfo
                            block:(void(^)(NSArray *userList, NSError *error))resultBlock;


//刷新userCount


@end
