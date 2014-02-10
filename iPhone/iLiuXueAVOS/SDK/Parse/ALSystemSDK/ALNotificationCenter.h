//
//  ALNotificationEngine.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-18.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationOfThread.h"
#import "NotificationOfFriend.h"
#import "ALNotificationConfig.h"

@interface ALNotificationCenter : NSObject

+ (instancetype)defauleCenter;

//+ (void)refreashNotificaitionWithBlock:(void(^)(NSDictionary *resultDictionary))block;

//获取帖子通知
- (void)getNotificationsOfThreadNotContainedIn:(NSArray *)theNotifications
                                          type:(ALThreadNotificationType)type
                                      isUnread:(BOOL)isUnread
                                         block:(void(^)(NSArray *notifications, NSError *error))resultBlock;

//获取用户通知
- (void)getNotificationsOfFriendNotContainedIn:(NSArray *)theNotifications
                                          type:(ALFriendNotificationType)type
                                      isUnread:(BOOL)isUnread
                                         block:(void(^)(NSArray *notifications, NSError *error))resultBlock;

//获取帖子通知数
- (void)getNotificationsOfThreadCountWithType:(ALThreadNotificationType)type
                                     isUnread:(BOOL)isUnread
                                        block:(void(^)(int count, NSError *error))resultBlock;

//获取用户通知数
- (void)getNotificationsOfFriendCountWithType:(ALFriendNotificationType)type
                                     isUnread:(BOOL)isUnread
                                        block:(void(^)(int count, NSError *error))resultBlock;
//更改通知未读状态为已读
- (void)updateUnreadStateOfNotification:(AVObject *)notification
                                  block:(PFBooleanResultBlock)resultBlock;

//删除通知
- (void)deleteStateOfNotification:(AVObject *)notification
                            block:(PFBooleanResultBlock)resultBlock;

@end
