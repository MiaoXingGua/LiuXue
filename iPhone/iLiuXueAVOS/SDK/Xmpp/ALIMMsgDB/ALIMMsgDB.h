//
//  ALIMMsgDB.h
//  Cloopen_DEMO
//
//  Created by Albert on 13-10-24.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseQueue.h"
#import "IMCommon.h"


#define PERPAGE_OF_MESSAGE 5

@class User;

@interface ALIMMsgDB : NSObject

+ (instancetype)defaultIMMsgDBWithVoip:(NSString *)theVoip;

#pragma mark - add
//添加聊天消息
- (void)insertIMMessage:(IMMessageObj*)imMsg block:(void(^)(BOOL success))block;

#pragma mark - del

#pragma mark - change
//更改会话中未读状态为已读
- (void)updateUnreadStateOfUserVoip:(NSString *)theVoip
                               user:(User *)theUser
                              block:(void (^)(BOOL succeeded, NSError *error))resultBlock;

#pragma mark - search
//判断消息是否存在
- (void)isMessageExistOfMsgid:(NSString*)msgid block:(void(^)(BOOL success))block;

//获得全部聊天记录
- (void)getALLMessageWithUserVoip:(NSString *)theVoip
                   notContainedIn:(NSArray *)theMsgsId
                            block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock;
//获得全部聊天记录数

//获得全部未读的聊天记录
- (void)getALLUnreadMessageWithUserVoip:(NSString *)theVoip
                         notContainedIn:(NSArray *)theMsgsId
                                  block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock;

//获得全部未读的聊天记录数
- (void)getALLUnreadMessageCountWithUserVoip:(NSString *)theVoip
                                       block:(void(^)(NSInteger messagesCount, NSError *error))resultBlock;

//获取与某用户的聊天记录
- (void)getUserMessageWithUserVoip:(NSString *)theVoip
                              user:(User *)theUser
                    notContainedIn:(NSArray *)theMsgsId
                             block:(void (^)(NSDictionary *messages, NSError *error))resultBlock;

//获取与某用户的未读聊天记录数
- (void)getUserUnreadMessageCountWithUserVoip:(NSString *)theVoip
                                         user:(User *)theUser
                                        block:(void (^)(NSInteger messagesCount, NSError *error))resultBlock;

- (void)getALLUnreadMessageCount2WithUserVoip:(NSString *)theVoip
                                        block:(void(^)(NSDictionary *messages, NSError *error))resultBlock;

//获取与某用户的未读聊天记录
- (void)getUserUnreadMessageWithUserVoip:(NSString *)theVoip
                                    user:(User *)theUser
                          notContainedIn:(NSArray *)theMsgsId
                                   block:(void (^)(NSDictionary *messages, NSError *error))resultBlock;

//获取最近联系人列表
- (void)getLinkerOfRecentWithUserVoip:(NSString *)theVoip
                                block:(void (^)(NSArray *likers, NSError *error))resultBlock;

//删除最近联系人
- (void)delLinkerOfRecentWithUserVoip:(NSString *)theVoip
                        andLinkerVoip:(NSString *)theLinkerVoip
                                block:(void(^)(BOOL success))block;

@end
