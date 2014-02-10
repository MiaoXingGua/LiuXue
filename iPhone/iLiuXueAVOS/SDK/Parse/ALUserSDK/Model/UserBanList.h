//
//  UserBanList.h
//  AVOS_DEMO
//
//  Created by Albert on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class User;

@interface UserBanList : AVObject <AVSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) User *fromUser;

@property (nonatomic, retain) User *toUser;

@property (nonatomic, retain) NSString *description;//拉黑原因

@end
