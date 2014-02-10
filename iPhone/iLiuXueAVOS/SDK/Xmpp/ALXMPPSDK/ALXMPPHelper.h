//
//  XMPPHelper.h
//  Cloopen_DEMO
//
//  Created by Albert on 13-10-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import "User.h"
#import "UserXmppInfo.h"
#import "UserXmppDB.h"

//key:      user.objectId
//value:    voip

@interface ALXMPPHelper : NSObject

//user to voip
+ (void)getVoipFromUser:(User *)theUser
                  block:(void(^)(UserXmppDB *userXmppDB, NSError *error))resultBlock;

//批量 User to UserXmppInfo
+ (void)getVoipFromUsers:(NSArray *)theUsers//User
                    block:(void(^)(NSArray *userXmppDBs, NSError *error))resultBlock;


//UserXmppInfo to User
+ (void)getUserFromVoip:(NSString *)voip
                   block:(void(^)(UserXmppDB *userXmppDB, NSError *error))resultBlock;

//批量 UserXmppInfo to User
+ (void)getUsersFromVoips:(NSArray *)voips
                     block:(void(^)(NSArray *userXmppDBs, NSError *error))resultBlock;




@end


