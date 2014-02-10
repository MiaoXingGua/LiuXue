//
//  User.h
//  ParseTest
//
//  Created by Jack on 13-5-30.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class UserInfo;
@class UserCount;
//@class UserRelation;
@class UserFavicon;

//@class Friend;
//@class Follow;
//@class BanList;

@interface User : AVUser <AVSubclassing>

//+ (NSString *)parseClassName;

@property (nonatomic, retain) NSString *nickName;//昵称

@property (nonatomic, retain) AVFile *headView;//头像

//@property (nonatomic, retain) NSString *registerIp;//注册ip

@property (nonatomic, assign) BOOL gender;//性别

//@property (nonatomic, assign) BOOL isAdmin;//是否是管理员

@property (nonatomic, retain) NSString *signature;//个性签名

@property (nonatomic, readonly) int credits;//积分

@property (nonatomic, readonly) int experience;//经验

@property (nonatomic, retain) NSString *creditsTitleSeries;//头衔系列

@property (nonatomic, readonly) int numberOfRemind;//新提醒数

@property (nonatomic, retain) AVGeoPoint *location;

@property (nonatomic, retain) NSString *place;

@property (nonatomic, retain) UserInfo *userInfo;

@property (nonatomic, retain) UserCount *userCount;

@property (nonatomic, retain) UserFavicon *userFavicon;

@property (nonatomic, retain) NSString *QQWeibo;

@property (nonatomic, retain) NSString *SinaWeibo;

@property (nonatomic, retain) NSString *RenRen;

@property (nonatomic, retain) NSString *WeChat;

@property (nonatomic,retain) NSString *userKey;

//@property (nonatomic, retain) UserRelation *userRelation;
//里面有user可能会引起循环引用

@end

