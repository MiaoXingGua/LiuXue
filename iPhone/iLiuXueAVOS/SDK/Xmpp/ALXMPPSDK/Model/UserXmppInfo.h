//
//  UserXmppInfo.h
//  PARSE_DEMO
//
//  Created by Albert on 13-10-4.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class User;

@interface UserXmppInfo : AVObject <AVSubclassing>

@property (nonatomic, retain) User *user;

@property (nonatomic, retain) NSString *subAccountSid;
@property (nonatomic, retain) NSString *subToken;
@property (nonatomic, retain) NSString *voipAccount;
@property (nonatomic, retain) NSString *voipPwd;

@end
