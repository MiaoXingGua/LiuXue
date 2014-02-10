//
//  UserXmppDB.h
//  Cloopen_DEMO
//
//  Created by Albert on 13-10-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALDBObject.h"

@interface UserXmppDB : ALDBObject

@property (nonatomic, retain) NSString *userId;

@property (nonatomic, retain) NSString *subAccountSid;

@property (nonatomic, retain) NSString *subToken;

@property (nonatomic, retain) NSString *voipAccount;

@property (nonatomic, retain) NSString *voipPwd;

@end
