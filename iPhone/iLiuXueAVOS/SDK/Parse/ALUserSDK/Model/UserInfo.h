//
//  userInfo.h
//  AVOS_DEMO
//
//  Created by Albert on 13-9-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//


//#import "AVSubclassing.h"

#import <AVOSCloud/AVOSCloud.h>
//@class User;

@interface UserInfo : AVObject <AVSubclassing>

//@property (nonatomic, retain) User *user;
+ (NSString *)parseClassName;

@property (nonatomic, retain) NSDate *brithday;//生日

@property (nonatomic, readonly) int age; //年龄

@property (nonatomic, assign) NSString *affectiveState; //情感状态

@property (nonatomic, readonly) NSString *constellation;//星座

@property (nonatomic, readonly) NSString *zodiac;//生肖

@property (nonatomic, retain) NSString *telephone;//固定电话

@property (nonatomic, retain) NSString *mobile;//手机

@property (nonatomic, retain) NSString *address;//地址

@property (nonatomic, retain) NSString *zipcode;//邮编

@property (nonatomic, retain) NSString *nationality;//国籍

@property (nonatomic, retain) NSString *brithProvince;//出生地

@property (nonatomic, retain) NSString *graduateSchool;//毕业校

@property (nonatomic, retain) NSString *company;//公司

@property (nonatomic, retain) NSString *education;//学历

@property (nonatomic, retain) NSString *bloodType;//血型

@property (nonatomic, retain) NSString *QQ;//qq

@property (nonatomic, retain) NSString *MSN;//msn

@property (nonatomic, retain) NSString *interest;//兴趣

@property (nonatomic, readonly) AVRelation *album;//相册


@end
