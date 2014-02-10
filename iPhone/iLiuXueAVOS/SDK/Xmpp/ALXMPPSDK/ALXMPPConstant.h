//
//  ALXMPPConstant.h
//  ALXMPPDemo
//
//  Created by Jack on 13-6-27.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#ifndef ALXMPPDemo_ALXMPPConstant_h
#define ALXMPPDemo_ALXMPPConstant_h

#define ALERROR(_domain,_code,_error) !_error ? ([NSError errorWithDomain:_domain code:_code userInfo:@{@"code":[NSNumber numberWithInteger:_code],@"error":[NSNull null]}]) : ([NSError errorWithDomain:_domain code:_code userInfo:@{@"code":[NSNumber numberWithInteger:_code],@"error":_error}])

#define NOTIFICATION__

typedef void (^ALBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^ALBooleanErrorResultBlock)(BOOL succeeded,NSError *error);
typedef void (^ALProgressBlock)(float percentDone);
typedef void (^ALDataResultBlock)(NSData *data, BOOL success);
typedef void (^ALDictionaryResultBlock)(NSDictionary *result, BOOL success);
typedef void (^ALArrayResultBlock)(NSArray* array, NSError *error);
//typedef void (^ALNetwokStatuseChangeBlock)(NetworkStatus status);

typedef NS_ENUM(NSInteger, ALFileType)
{
    ALFileTypeOfNone = 0,
    ALFileTypeText,
    ALFileTypeVoice,
    ALFileTypeImage,
    ALFileTypeVideo
};

//群组类型
typedef NS_ENUM(NSInteger, ALGroupType)
{
    ALGroupTypeOfTemp   = 0,    //临时组(上限100人)
    ALGroupTypeOfNomal  = 1,    //普通组(上限300人)
    ALGroupTypeOfVip    = 2,    //VIP组 (上限500人)
};

//申请加入模式
typedef NS_ENUM(NSInteger, ALGroupPermission)
{
    ALGroupPermissionOfNone     = 0,    //直接加入
    ALGroupPermissionOfVerify   = 1,    //身份验证
    ALGroupPermissionOfPrivate  = 2     //私有
};

//下线提示
#define NOTIFICATION_XMPP_LOG_OUT @"KUSYDGFKSDUFGLISUDGFSJDBVKUZSIFKSUE"

//当得到一条新消息 @"type" @"url" @"sender" @"msgId" @"dateCreated"
//@"preview" @"size"
#define NOTIFICATION_NEW_MESSAGE @"27983RHR2F9R832Q98HG9103247Y8EHTGRUYi"

//群解散通知
//@"groupId"
#define NOTIFICATION_GROUP_MESSAGE_OF_DESTROY @"GIER7FT874W3KUYQFI8SDJWEKRI374RWQJGH"

//来自群的邀请
//@"groupId" @"admin" @"declared"  @"confirm"
#define NOTIFICATION_GROUP_MESSAGE_OF_INVITER @"LAISRTFIW74FILRUWQFI8WFLGIASDTOAIRTFI"

//来自用户入群申请
//@"groupId" @"proposer" @"declared" @"dateCreated"
#define NOTIFICATION_GROUP_MESSAGE_OF_PROPOSER @"ASKRUGFAWILRFJARYGI74RFKYUFA478RFI4UFRF7"

//有用户退出群
#define NOTIFICATION_GROUP_MESSAGE_OF_QUIT_GROUP @"VIIER784RGKYDUFTGI65TGKW3YU4FI6R3W4UYFR6384"

//有用户被踢出群RemoveMember
#define NOTIFICATION_GROUP_MESSAGE_OF_REMOVE_MEMBER @"KYWF764QHJ34CR346IRQ34TCRYQI2674Q3J4CR"

//申请加入群组消息回复ReplyJoinGroup
#define NOTIFICATION_GROUP_MESSAGE_OF_REPLY_JOIN_GROUP @"KEWUJFSZJTSKEYUFRUWYAEVFURATWKUAFVYU4URZ"

#define NOTIFICATION_XMPP_TALKER_IS_OFFLINE  @"KU7S4RIAFW47RAL48GI8FGAWE48TFRLIAGEL47"

#endif
