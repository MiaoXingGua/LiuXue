//
//  UserFollow.h
//  AVOS_DEMO
//
//  Created by Albert on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
//#import "AVSubclassing.h"
//#import "Subclassing.h"

     
@class User;

@interface UserRelation : AVObject <AVSubclassing>

+ (NSString *)parseClassName;

//@property (nonatomic, retain) User *fromUser;
//
//@property (nonatomic, retain) User *toUser;
//
//@property (nonatomic, retain) NSString *bkName;//备注名
//
//@property (nonatomic, assign) ALUserFollowState state;

@property (nonatomic, retain) User *user;

//用户关系
@property (nonatomic, retain) AVRelation *friends;//Friend

@property (nonatomic, retain) AVRelation *follows;//Follow

@property (nonatomic, retain) AVRelation *banList;//BanList

@end
