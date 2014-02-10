//
//  ALXMPPEngine.h
//  XmppDemo
//
//  Created by Jack on 13-6-21.
//  Copyright (c) 2013年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ALXMPPConstant.h"//一些静态属性

//#import "XMLParser.h"

#import "User.h"

#import "UserXmppInfo.h"

#import "ModelEngineVoip.h"

//#import "CCPCallService.h"
//#import "CCPCallEvent.h"
//#import "DefineAndEnum.h"
//#import "IMCommon.h"
//#import "AsyncUdpSocket.h"

#import "ALXMPPHelper.h"

#import "ALIMMsgDB.h"

//#define APP_ID  @"aaf98f894032b2370140479684b0009f"

#define VERIFIED_IS_NECESSARY YES



@interface ALXMPPEngine : NSObject <ModelEngineUIDelegate>

@property (nonatomic, retain) CCPCallService *VoipCallService;

@property (nonatomic, readonly) UserXmppInfo *xmppInfo;

@property (nonatomic, readonly) NSDictionary *errorCode;

@property (nonatomic, readonly) User *curTalkUser;

@property (nonatomic, readonly) ALIMMsgDB *imMsgDB;

#pragma mark - 初始化

+(ALXMPPEngine *)defauleEngine;

#pragma mark - 注册登录
/*
 *登陆注册
*/

//注册
- (BOOL)signUpWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock;

//登陆
- (BOOL)logInWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock;

//登出
- (BOOL)logOut;

//是否已登录
- (BOOL)isLoggedIn;

#pragma mark - 聊天
//与某人开始聊天
- (void)beganToChatWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock;

//是否正在与此用户聊天中
- (BOOL)isTalkingToUser:(User *)theUser;

#pragma mark - 群组
//创建群聊室
//
/**
 * @param name          NSString		群组名字
 * @param type          NSString		群组类型 0：临时组(上限100人)  1：普通组(上限300人)  2：VIP组 (上限500人)
 * @param declared      NSString		群组公告
 * @param permission	NSInteger     	申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
 */
- (void)createGroupWithName:(NSString *)theName
                    andType:(ALGroupType)theType
                   declared:(NSString *)theDeclared
                 permission:(ALGroupPermission)thepermission
                      block:(void(^)(NSString *groupId, NSError *error))resultBlock;

//修改群组
/**
 * @param groupId       NSString		群组ID
 * @param name          NSString		群组名字
 * @param declared      NSString		群组公告
 * @param permission	NSInteger     	申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
 */
- (void)updateGroup:(NSString *)theGroupId
               name:(NSString *)theName
           declared:(NSString *)theDeclared
         permission:(ALGroupPermission)thepermission
              block:(ALBooleanResultBlock)resultBlock;

//解散聊天室
- (void)destroyGroup:(NSString *)theGroupId
               block:(ALBooleanResultBlock)resultBlock;

//获得群
- (void)getGroup:(NSString *)theGroupId
           block:(void(^)(IMGroupInfo *group, NSError *error))resultBlock;

- (void)getGroupListWithBlock:(ALArrayResultBlock)resultBlock;

- (void)getGroupListWithUser:(User *)theUser
                       block:(ALArrayResultBlock)resultBlock;

//- (void)getGroupListWithGroupId:(NSString *)theGroupId
//                         orName:(NSString *)theGroupName
//                          block:(ALArrayResultBlock)resultBlock;

//进入群
- (void)enterGroup:(NSString *)theGroupId
       andDeclared:(NSString *)theDeclared
             block:(ALBooleanResultBlock)resultBlock;

//退出群
- (void)exitGroup:(NSString *)theGroupId
            block:(ALBooleanResultBlock)resultBlock;

//邀请好友进入房间
- (void)inviteUsers:(NSArray *)theUsers
            toGroup:(NSString *)theGroupId
           declared:(NSString *)theDeclared
              block:(ALBooleanResultBlock)resultBlock;

//踢出聊天室成员
- (void)removeUsers:(NSArray *)theUsers
          fromGroup:(NSString *)theGroupId
              block:(ALBooleanResultBlock)resultBlock;

//获得群成员
- (void)getMemberWithGroup:(NSString *)theGroupId
                     block:(ALArrayResultBlock)resultBlock;

#pragma mark - 发消息
//发消息(文字)
- (void)postMessageWithText:(NSString *)theText
                      block:(PFStringResultBlock)resultBlock;

//发消息(声音)
- (void)postMessageWithVoice:(NSData *)theVoice
                   extension:(NSString *)theExtension
                       block:(PFStringResultBlock)resultBlock;

//发消息(图片)
- (void)postMessageWithImage:(NSData *)theImage
                   extension:(NSString *)theExtension
                     preview:(NSData *)thePreview
                        size:(CGSize)theSize
                       block:(PFStringResultBlock)resultBlock
               progressBlock:(ALProgressBlock)progressBlock;

- (void)postMessageWithImagePath:(NSString *)theImagePath
                         preview:(NSData *)thePreview
                            size:(CGSize)theSize
                           block:(PFStringResultBlock)resultBlock
                   progressBlock:(ALProgressBlock)progressBlock;

//发消息(视频)
- (void)postMessageWithVideo:(NSData *)theVideo
                   extension:(NSString *)theExtension
                     preview:(NSData *)thePreview
                       block:(PFStringResultBlock)resultBlock
               progressBlock:(ALProgressBlock)progressBlock;

- (void)postMessageWithVideoPath:(NSString *)theVideoPath
                         preview:(NSData *)thePreview
                           block:(PFStringResultBlock)resultBlock
                   progressBlock:(ALProgressBlock)progressBlock;

//发消息(文字)
- (void)postMessageToGroupWithText:(NSString *)theText
                             block:(PFStringResultBlock)resultBlock;

//发消息(声音)
- (void)postMessageToGroupWithVoice:(NSData *)theVoice
                          extension:(NSString *)theExtension
                              block:(PFStringResultBlock)resultBlock;

//发消息(图片)
- (void)postMessageToGroupWithImage:(NSData *)theImage
                          extension:(NSString *)theExtension
                            preview:(NSData *)thePreview
                               size:(CGSize)theSize
                              block:(PFStringResultBlock)resultBlock
                      progressBlock:(ALProgressBlock)progressBlock;

- (void)postMessageToGroupWithImagePath:(NSString *)theImagePath
                                preview:(NSData *)thePreview
                                   size:(CGSize)theSize
                                  block:(PFStringResultBlock)resultBlock
                          progressBlock:(ALProgressBlock)progressBlock;

//发消息(视频)
- (void)postMessageToGroupWithVideo:(NSData *)theVideo
                          extension:(NSString *)theExtension
                            preview:(NSData *)thePreview
                              block:(PFStringResultBlock)resultBlock
                      progressBlock:(ALProgressBlock)progressBlock;

- (void)postMessageToGroupWithVideoPath:(NSString *)theVideoPath
                                preview:(NSData *)thePreview
                                  block:(PFStringResultBlock)resultBlock
                          progressBlock:(ALProgressBlock)progressBlock;


#pragma mark - 消息记录
//更改会话中未读状态为已读
- (void)updateUnreadStateOfUser:(User *)theUser
                              block:(void (^)(BOOL succeeded, NSError *error))resultBlock;

//判断消息是否存在
- (void)isMessageExistOfMsgid:(NSString*)msgid
                        block:(void(^)(BOOL success))block;

//获得全部聊天记录
- (void)getALLMessageWithNotContainedIn:(NSArray *)theMsgsId
                                  block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock;

//获得全部未读的聊天记录
- (void)getALLUnreadMessageWithNotContainedIn:(NSArray *)theMsgsId
                                        block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock;

//获取与某用户的聊天记录
- (void)getUserMessageWithUser:(User *)theUser
                notContainedIn:(NSArray *)theMsgsId
                         block:(void (^)(NSDictionary *messages, NSError *error))resultBlock;

//获取与某用户的未读聊天记录数
- (void)getUserUnreadMessageCountWithUser:(User *)theUser
                                        block:(void (^)(NSInteger messagesCount, NSError *error))resultBlock;

//获取与某用户的未读聊天记录
- (void)getUserUnreadMessageWithUser:(User *)theUser
                      notContainedIn:(NSArray *)theMsgsId
                               block:(void (^)(NSDictionary *messages, NSError *error))resultBlock;

//获得全部未读的聊天记录数
- (void)getALLUnreadMessageCountWithBlock:(void(^)(NSInteger messagesCount, NSError *error))resultBlock;

//获得全部未读的聊天记录
- (void)getALLUnreadMessageWithBlock:(void(^)(NSDictionary *messages, NSError *error))resultBlock;

#pragma mark - 联系人记录
//获取最近联系人列表
- (void)getLinkerOfRecentWithBlock:(void (^)(NSArray *likers, NSError *error))resultBlock;

//删除最近联系人
- (void)delLinkerOfRecentWithLinker:(User *)theUser
                              block:(void(^)(BOOL success))resultBlock;

#pragma mark - 通知记录

#pragma mark - 群组消息记录



@end
