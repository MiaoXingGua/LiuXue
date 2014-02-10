
//
//  ALXMPPEngine.m
//  XmppDemo
//
//  Created by Jack on 13-6-21.
//  Copyright (c) 2013年 无锡恩梯梯数据有限公司. All rights reserved.
//


#import "ALXMPPEngine.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "GTMBase64.h"
//#import "XMLParser.h"
#import "XMLReader.h"
#import "UserXmppInfo.h"
//#import "DefineAndEnum.h"
//#import "LFCGzipUtillity.h"
#import <CommonCrypto/CommonDigest.h>

//#define USE_MEMORY_STORAGE 0
//#define USE_HYBRID_STORAGE 1

#import "ModelEngineVoip.h"

#import "CommonClass.h"

@class AppDelegate;

//REST服务器
#define VOIP_MAINACCOUNT      @"aaf98f894032b237014047963bb9009d"
#define VOIP_MAINTOKEN      @"bbc381b9a024443da462307cec93ce0b"
#define VOIP_APPID      @"aaf98f894032b2370140482ac6dc00a8"
//#define VOIP_APPID          @"aaf98f894032b2370140479684b0009f"
#define CONFIG_KEY_SID        @"aaf98f894032b237014047963bb9009d"

#define TEST_ROOM_ID            @"conf400100386360002984"

#define CHECH_MESSAGE       @"AUDHIQUWHDQILUWDGHAETWW8DRTKUYWVAKLWEUYGD"

static ALXMPPEngine *engine = nil;

@interface ALXMPPEngine ()

@property (nonatomic, retain) ModelEngineVoip *modelEngineVoip;
//@property (nonatomic, readonly) IMMsgDBAccess *imDBAccess;

@property (nonatomic, retain) NSString *curTalkUserVoip;
@property (nonatomic, retain) NSString *curTalkGroupVoip;

@property (nonatomic, retain) NSMutableArray *onlineFirends;

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, assign) BOOL isAutoLogIn;
@property (nonatomic, retain) NSDictionary *errorCode;

@property (nonatomic, retain) IMTextMsg *imMsg;

@property (nonatomic, retain) NSString *checkMsgId;
@property (nonatomic, assign) int checkCount;

//用户
//@property (nonatomic, copy) PFBooleanResultBlock signUpResultBlock;  //注册
@property (nonatomic, copy) PFBooleanResultBlock logInResultBlock;      //登录

//发消息
@property (nonatomic, copy) PFStringResultBlock postMessageResultBlock;//


//群
//创建群
@property (nonatomic, copy) void(^createdGroupResultBlock)(NSString *groupId, NSError *error) ;
//删除群
@property (nonatomic, copy) ALBooleanResultBlock deletedGroupResultBlock;

//获取所有公共群组
@property (nonatomic, copy) ALArrayResultBlock queryPublicGroupsResultBlock;

@property (nonatomic, copy) void(^groupsResultBlock)(IMGroupInfo *group, NSError *error);

//查询群成员
@property (nonatomic, copy) ALArrayResultBlock queryUserGroupsResultBlock;

//进入群
@property (nonatomic, copy) ALBooleanResultBlock enterGroupResultBlock;

//退出群
@property (nonatomic, copy) ALBooleanResultBlock exitGroupResultBlock;

//查询聊天记录
//@property (nonatomic, copy) ALArrayResultBlock queryUserGroupsResultBlock;

//查询聊天记录数
//@property (nonatomic, copy) ALArrayResultBlock queryUserGroupsResultBlock;

//管理员邀请加入群组

//管理员删除成员群组

@property (nonatomic, copy) ALArrayResultBlock roomListResultBlock;
@property (nonatomic, copy) ALBooleanResultBlock enterRoomResultBlock;
@property (nonatomic, copy) ALBooleanResultBlock exitRoomResultBlock;
@property (nonatomic, copy) ALBooleanResultBlock inviteEnterResultBlock;

//群消息
@property (nonatomic, copy) ALBooleanResultBlock postShoutMessageToRoomResultBlock;
//    ALDictionaryResultBlock _postBigMessageToRoomResultBlock;

@end

@implementation ALXMPPEngine
{
    BOOL currentUsersIsOffline;
}
- (void)dealloc
{
    [_modelEngineVoip release];
    
    [_imMsg release];
//    [_xmlParser release];
    
    [_xmppInfo release];
    
    [_curTalkUser release];
    
    [_curTalkUserVoip release];
    
    [_curTalkGroupVoip release];
    
//    [self removeNotification];
//    
//    [self removeBlock];
    
    [super dealloc];
}

- (void)removeBlock
{
    [_logInResultBlock release];
}

//- (void)setXmlParser:(XMLParser *)xmlParser
//{
//    [_xmlParser release];
//    _xmlParser  = [xmlParser retain];
//}

- (void)setCurTalkUser:(User *)curTalkUser
{
    [_curTalkUser release];
    _curTalkUser = [curTalkUser retain];
}

- (ALIMMsgDB *)imMsgDB
{
    return [ALIMMsgDB defaultIMMsgDBWithVoip:self.xmppInfo.voipAccount];
}

//- (IMMsgDBAccess *)imDBAccess
//{
//    return self.modelEngineVoip.imDBAccess;
//}

#pragma mark - 初始化
+(ALXMPPEngine *)defauleEngine
{
    if (!engine) {
        
        engine = [[ALXMPPEngine alloc] init];
        
        engine.modelEngineVoip = [ModelEngineVoip getInstance];

        engine.modelEngineVoip.UIDelegate = engine;
        
        engine.xmppInfo = [[[UserXmppInfo alloc] init] autorelease];

        engine.imMsg = [[[IMTextMsg alloc] init] autorelease];
        
        engine.errorCode = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ErrorCode" ofType:@"plist"]] valueForKey:@"cloopen"];
        
        [engine addNotification];
    }
    
    return engine;
}


#pragma mark - 通知
- (void)addNotification
{

}

- (void)removeNotification
{

}

#pragma mark - 系统基本方法
//取得当前程序的委托
-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


NSString* getCurrentTimeString()
{
    NSDateFormatter *dateformat=[[NSDateFormatter alloc] init];//???
    [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *timeDesc = [dateformat stringFromDate:[NSDate date]];
    [dateformat release];
    return timeDesc;
}

//生成字符串
NSString* getRandomStringGenerator(int len)
{
    const NSArray *arr = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:len];
    
    for (int i=0; i<len; i++) [str appendString:arr[arc4random()%arr.count]];
    
    return str;
}

NSString *getMID()
{
    return [NSString stringWithFormat:@"%@%@",getCurrentTimeString(),getRandomStringGenerator(0)];
}


- (NSString *)getMainSig:(NSString *)timestamp
{
    NSString *sigString = [NSString stringWithFormat:@"%@%@%@", VOIP_MAINACCOUNT, VOIP_MAINTOKEN, timestamp];
    const char *cStr = [sigString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}


- (void)addVCService
{
    if (!self.modelEngineVoip.VoipCallService)
    {
        [self removeVCService];
        self.modelEngineVoip.VoipCallService = [[[CCPCallService alloc] init] autorelease];
        [self.modelEngineVoip.VoipCallService setDelegate:self.modelEngineVoip];
    }
}

- (void)removeVCService
{
    
//    CCPCallService *call = self.modelEngineVoip.VoipCallService;
//    NSLog(@"count=%d",call.retainCount);
//    [call release];
//        NSLog(@"count=%d",call.retainCount);
    self.modelEngineVoip.VoipCallService = nil;
//    NSLog(@"%@",call);
//    NSLog(@"count=%d",call.retainCount);
}

- (void)setXmppInfo:(UserXmppInfo *)xmppInfo
{
    [_xmppInfo release];
    _xmppInfo = [xmppInfo retain];
}

#pragma mark - 注册登录
//注册
- (BOOL)signUpWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock
{
    if (![theUser isAuthenticated])
    {
        if (resultBlock)
        {
            resultBlock(NO,nil);
        }
        return NO;
    }
    
    BOOL isEmailVerified = [[theUser objectForKey:@"emailVerified"] boolValue];
    if (!isEmailVerified && !VERIFIED_IS_NECESSARY)
    {
        if (resultBlock)
        {
            resultBlock(NO,nil);
        }
        return NO;
    }
    
    [resultBlock copy];
    
    NSString *theEmail = theUser.email;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *fomater=[[NSDateFormatter alloc] init];
    [fomater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeString = [fomater stringFromDate:dat];
    [fomater release];
    
    
    NSString *urlstr = [NSString stringWithFormat:@"https://%@:%@/2013-03-22/Accounts/%@/SubAccounts?sig=%@",VOIP_SERVICEIP,VOIP_SERVICEPORT,VOIP_MAINACCOUNT,[self getMainSig:timeString]];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    
    
    NSString *xmlbody = [NSString stringWithFormat:
                         @"<SubAccount>"
                         @"<appId>%@</appId>"
                         @"<friendlyName>%@</friendlyName>"
                         @"</SubAccount>",VOIP_APPID,theEmail];
    
    NSMutableData *xmlData =[NSMutableData dataWithData:[xmlbody dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestMethod:@"POST"];
    
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    
    NSString *authstr = [NSString stringWithFormat:@"%@:%@",VOIP_MAINACCOUNT,timeString];
    
//    NSLog(@"%@:%@",authstr,[ASIHTTPRequest base64forData:[authstr dataUsingEncoding:NSUTF8StringEncoding]]);
    
    [request addRequestHeader:@"Authorization" value:[ASIHTTPRequest base64forData:[authstr dataUsingEncoding:NSUTF8StringEncoding]]];
    
    [request appendPostData:xmlData];
    
    [request setCompletionBlock:^{
        
        if (!request.error)
        {
//            NSString *response = request.responseString;
            NSError *error = nil;
            NSData *responseData = request.responseData;
            
            NSDictionary *dict = [XMLReader dictionaryForXMLData:responseData error:&error];
            
            NSInteger reason = [[dict valueForKeyPath:@"Response.statusCode.text"] integerValue];
            
            if (reason == 0)
            {
                NSString *subAccountSid = [dict valueForKeyPath:@"Response.SubAccount.subAccountSid.text"];
                NSString *subToken = [dict valueForKeyPath:@"Response.SubAccount.subToken.text"];
                NSString *voipAccount = [dict valueForKeyPath:@"Response.SubAccount.voipAccount.text"];
                NSString *voipPwd = [dict valueForKeyPath:@"Response.SubAccount.voipPwd.text"];
                                     
                UserXmppInfo * userXI = [UserXmppInfo object];
                userXI.user = theUser;
                userXI.subAccountSid = subAccountSid;
                userXI.subToken = subToken;
                userXI.voipAccount = voipAccount;
                userXI.voipPwd = voipPwd;
                
                [userXI saveEventually:resultBlock];
            }
            else
            {
                NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
                
                if (resultBlock)
                {
                    resultBlock(NO,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
                }
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(NO,nil);
            }
        }
    }];
    
    [request setFailedBlock:^{
      
        if (resultBlock)
        {
            resultBlock(NO,nil);
        }
    }];
    
    [request startAsynchronous];
    
    [resultBlock release];
    
    return YES;
}

//登录
- (BOOL)logInWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock
{
    if (![theUser isAuthenticated])
    {
        if (resultBlock)
        {
            resultBlock(NO,nil);
        }
        return NO;
    }

    BOOL isEmailVerified = [[theUser objectForKey:@"emailVerified"] boolValue];
    if (!isEmailVerified && !VERIFIED_IS_NECESSARY)
    {
        if (resultBlock)
        {
            resultBlock(NO,nil);
        }
        return NO;
    }
    
//    if (self.logInResultBlock)
//    {
//        return NO;
//    }
    
    self.logInResultBlock = resultBlock;
    
    [self addVCService];
    
    __block typeof (self) bself = self;
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        if (!error && userXmppDB)
        {
            NSString *subAccountSid = userXmppDB.subAccountSid;
            NSString *subToken = userXmppDB.subToken;
            NSString *voipAccount = userXmppDB.voipAccount;
            NSString *voipPwd = userXmppDB.voipPwd;
            
            bself.xmppInfo.user = theUser;
            bself.xmppInfo.subAccountSid = subAccountSid;
            bself.xmppInfo.subToken = subToken;
            bself.xmppInfo.voipAccount = voipAccount;
            bself.xmppInfo.voipPwd = voipPwd;
            
            [self.modelEngineVoip connectToCCP:VOIP_SERVICEIP onPort:8883 withAccount:voipAccount withPsw:voipPwd withAccountSid:subAccountSid withAuthToken:subToken];
        }
        else if (error)
        {
            if (resultBlock)
            {
                resultBlock(YES, error);
            }
        }
    }];
    
    return YES;
}


//登出
- (BOOL)logOut
{
    [self removeVCService];
    
    return self.modelEngineVoip.VoipCallService == nil;
}

//是否已登录
- (BOOL)isLoggedIn
{
    if (self.modelEngineVoip.VoipCallService == nil)
    {
        return NO;
    }

    return [self.modelEngineVoip.VoipCallService isOnline];
}

#pragma mark - 聊天
//与某人开始聊天
- (void)beganToChatWithUser:(User *)theUser block:(PFBooleanResultBlock)resultBlock
{
    [resultBlock copy];
    
    typeof (self) bself = self;
    
    self.curTalkUser = theUser;
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        if (!error && userXmppDB)
        {
            self.curTalkUserVoip = userXmppDB.voipAccount;
            
            [self.modelEngineVoip sendInstanceMessage:self.curTalkUserVoip andText:CHECH_MESSAGE andAttached:nil andUserdata:theUser.objectId];
            self.imMsg.userData = theUser.objectId;
            
            self.checkCount = 2;
            
            if (resultBlock)
            {
                resultBlock(YES,nil);
            }
            
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(NO,error);
            }
        }
    }];
    
    [resultBlock release];
}

//是否正在与此用户聊天中
- (BOOL)isTalkingToUser:(User *)theUser
{
    return [self.curTalkUser.objectId isEqualToString:theUser.objectId];
}


#pragma mark - 群
//创建群聊室
//
- (void)createGroupWithName:(NSString *)theName
                    andType:(ALGroupType)theType
                   declared:(NSString *)theDeclared
                 permission:(ALGroupPermission)thepermission
                      block:(void(^)(NSString *groupId, NSError *error))resultBlock
{
    self.createdGroupResultBlock = resultBlock;
    [self.modelEngineVoip createGroupWithName:theName andType:theType andDeclared:theDeclared andPermission:thepermission];
}

//修改群组
- (void)updateGroup:(NSString*) groupId
               name:(NSString *)theName
           declared:(NSString *)theDeclared
         permission:(ALGroupPermission)thepermission
              block:(ALBooleanResultBlock)resultBlock
{
    [self.modelEngineVoip modifyGroupWithGroupId:groupId andName:theName andDeclared:theDeclared andPermission:thepermission];
}

//解散聊天室
- (void)destroyGroup:(NSString *)theGroupId
               block:(ALBooleanResultBlock)resultBlock
{
    self.deletedGroupResultBlock = resultBlock;
    [self.modelEngineVoip deleteGroupWithGroupId:theGroupId];
}

//获得群
- (void)getGroup:(NSString *)theGroupId
           block:(void(^)(IMGroupInfo *group, NSError *error))resultBlock
{
    self.groupsResultBlock = resultBlock;
    [self.modelEngineVoip queryGroupDetailWithGroupId:theGroupId];
    //onGroupQueryGroupWithReason
}

//roomListResultBlock
- (void)getGroupListWithBlock:(ALArrayResultBlock)resultBlock
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%lld", (long long)tmp];//转为字符型
    
    //查询公共群组
    self.queryPublicGroupsResultBlock = resultBlock;
    [self.modelEngineVoip queryPublicGroupsWithLastUpdateTime:timeString];
    //onGroupQueryPublicGroupsWithReason
}

//onMemberQueryGroupWithReason
- (void)getGroupListWithUser:(User *)theUser
                       block:(ALArrayResultBlock)resultBlock
{
    self.queryUserGroupsResultBlock = resultBlock;
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        [self.modelEngineVoip queryGroupWithAsker:userXmppDB.voipAccount];
    }];

}


//进入群
//enterRoomResultBlock
- (void)enterGroup:(NSString *)theGroupId
       andDeclared:(NSString *)theDeclared
             block:(ALBooleanResultBlock)resultBlock
{
    if (self.enterGroupResultBlock)
    {
        return ;
    }
    
    self.curTalkGroupVoip = theGroupId;
    
    self.enterGroupResultBlock = resultBlock;
    
    [self.modelEngineVoip joinGroupWithGroupId:theGroupId andDeclared:theDeclared];
}

//退出群
//exitRoomResultBlock
- (void)exitGroup:(NSString *)theGroupId
            block:(ALBooleanResultBlock)resultBlock
{
    if (self.exitGroupResultBlock)
    {
        return ;
    }
    
    self.curTalkGroupVoip = nil;
    self.exitGroupResultBlock = resultBlock;
    
    [self.modelEngineVoip logoutGroupWithGroupId:theGroupId];
}

//邀请好友进入房间
//inviteEnterResultBlock
- (void)inviteUsers:(NSArray *)theUsers
            toGroup:(NSString *)theGroupId
           declared:(NSString *)theDeclared
              block:(ALBooleanResultBlock)resultBlock
{
    
    [ALXMPPHelper getVoipFromUsers:theUsers block:^(NSArray *userXmppInfos, NSError *error) {
        
        if (userXmppInfos.count > 0 && !error)
        {
            NSMutableArray *voips = [NSMutableArray arrayWithCapacity:userXmppInfos.count];
            for (UserXmppInfo *xmppInfo in userXmppInfos)
            {
                [voips addObject:xmppInfo.voipAccount];
            }
            [self.modelEngineVoip inviteJoinGroupWithGroupId:theGroupId andMembers:voips andDeclared:theDeclared andConfirm:0];
            //需要被邀请人确认
        }
    }];
}

//踢出聊天室成员
//
- (void)removeUsers:(NSArray *)theUsers
          fromGroup:(NSString *)theGroupId
              block:(ALBooleanResultBlock)resultBlock
{
    
    [ALXMPPHelper getVoipFromUsers:theUsers block:^(NSArray *userXmppInfos, NSError *error) {
        
        if (userXmppInfos.count > 0 && !error)
        {
            NSMutableArray *voips = [NSMutableArray arrayWithCapacity:userXmppInfos.count];
            for (UserXmppInfo *xmppInfo in userXmppInfos)
            {
                [voips addObject:xmppInfo.voipAccount];
            }
            [self.modelEngineVoip deleteGroupMemberWithGroupId:theGroupId andMembers:theUsers];
        }
    }];
}

//获得群成员
- (void)getMemberWithGroup:(NSString *)theGroupId
                     block:(ALArrayResultBlock)resultBlock
{
    if (self.queryUserGroupsResultBlock)
    {
        return;
    }
    
    self.queryUserGroupsResultBlock = resultBlock;
    [self.modelEngineVoip queryMemberWithGroupId:theGroupId];
}

#pragma mark - 发消息
- (void)postMessageWithText:(NSString *)theText
                      block:(PFStringResultBlock)resultBlock
{
    [self _postMessageWithText:theText
                       isGroup:NO
                         block:resultBlock];
}

- (void)postMessageToGroupWithText:(NSString *)theText
                             block:(PFStringResultBlock)resultBlock
{
    [self _postMessageWithText:theText
                       isGroup:YES
                         block:resultBlock];
}

- (void)_postMessageWithText:(NSString *)theText
                     isGroup:(BOOL)isGroup
                       block:(PFStringResultBlock)resultBlock
{
    if (theText.length > 0)
    {
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        
        if (isGroup)
        {
            [content setValue:@"group" forKey:@"type"];
        }
        else
        {
            [content setValue:@"chat" forKey:@"type"];
        }
        
        [content setValue:@"text" forKey:@"subType"];
//        [dic setValue:theText forKey:@"url"];
        
        [self __postMessageWithContent:[content JSONString]
                              userData:[@{@"url":theText} JSONString]
                               isGroup:isGroup
                                  type:ALFileTypeText
                                 block:resultBlock];
        
    }
}

- (void)postMessageWithVoice:(NSData *)theVoice
                   extension:(NSString *)theExtension
                       block:(PFStringResultBlock)resultBlock
{
    AVFile *voiceFile = [AVFile fileWithName:[NSString stringWithFormat:@"voice.%@",theExtension] data:theVoice];
    
    [self _postMessageWithVoice:voiceFile
                        isGroup:NO
                          block:resultBlock
                  progressBlock:nil];
}

- (void)postMessageToGroupWithVoice:(NSData *)theVoice
                          extension:(NSString *)theExtension
                              block:(PFStringResultBlock)resultBlock
{
    AVFile *voiceFile = [AVFile fileWithName:[NSString stringWithFormat:@"voice.%@",theExtension] data:theVoice];
    
    [self _postMessageWithVoice:voiceFile
                        isGroup:YES
                          block:resultBlock
                  progressBlock:nil];
}

- (void)_postMessageWithVoice:(AVFile *)theVoiceFile
                      isGroup:(BOOL)isGroup
                        block:(PFStringResultBlock)resultBlock
                progressBlock:(ALProgressBlock)progressBlock
{
    if (theVoiceFile)
    {
        //        NSString *mesB64 = [theVoice base64Encoded];
        //        NSString *mesB64 = [GTMBase64 stringByEncodingData:theVoice];
        __block NSMutableDictionary *content = [[NSMutableDictionary dictionary] retain];
        
        if (isGroup)
        {
            [content setValue:@"group" forKey:@"type"];
        }
        else
        {
            [content setValue:@"chat" forKey:@"type"];
        }
        
        [content setValue:@"voice" forKey:@"subType"];

        [theVoiceFile retain];
        
        [theVoiceFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error && succeeded)
            {
//                [dic setValue:voiceFile.url forKey:@"url"];
                [self __postMessageWithContent:[content JSONString]
                                      userData:[@{@"url":theVoiceFile.url} JSONString]
                                       isGroup:isGroup
                                          type:ALFileTypeVoice
                                         block:resultBlock];
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(succeeded,error);
                }
            }
            
            [theVoiceFile release];
            [content release];
            
        } progressBlock:^(int percentDone) {
            
            if (progressBlock)
            {
                progressBlock(percentDone/100.0);
            }
            
        }];
    }
}


- (void)postMessageWithImage:(NSData *)theImage
                   extension:(NSString *)theExtension
                     preview:(NSData *)thePreview
                        size:(CGSize)theSize
                       block:(PFStringResultBlock)resultBlock
               progressBlock:(ALProgressBlock)progressBlock
{
    AVFile *imageFile = [AVFile fileWithName:[NSString stringWithFormat:@"image.%@",theExtension] data:theImage];
    AVFile *preview = [AVFile fileWithName:[NSString stringWithFormat:@"preview.jpg"] data:thePreview];
    
    [self _postMessageWithImage:imageFile
                        preview:preview
                           size:theSize
                        isGroup:NO
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)postMessageToGroupWithImage:(NSData *)theImage
                          extension:(NSString *)theExtension
                            preview:(NSData *)thePreview
                               size:(CGSize)theSize
                              block:(PFStringResultBlock)resultBlock
                      progressBlock:(ALProgressBlock)progressBlock
{
    AVFile *imageFile = [AVFile fileWithName:[NSString stringWithFormat:@"image.%@",theExtension] data:theImage];
    AVFile *preview = [AVFile fileWithName:[NSString stringWithFormat:@"preview.jpg"] data:thePreview];
    
    [self _postMessageWithImage:imageFile
                        preview:preview
                           size:theSize
                        isGroup:YES
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)postMessageWithImagePath:(NSString *)theImagePath
                         preview:(NSData *)thePreview
                            size:(CGSize)theSize
                           block:(PFStringResultBlock)resultBlock
                   progressBlock:(ALProgressBlock)progressBlock
{
    NSString *fileLastName = [[theImagePath substringFromIndex:theImagePath.length-3] lowercaseString];
    
    if (![fileLastName rangeOfString:@"jpg jpeg gif png bmp"].location == NSNotFound)
    {
        fileLastName = @"png";
    }
    
    AVFile *imageFile = [AVFile fileWithName:[NSString stringWithFormat:@"image.%@",fileLastName] contentsAtPath:theImagePath];
    AVFile *preview = [AVFile fileWithName:[NSString stringWithFormat:@"preview.jpg"] data:thePreview];
    
    [self _postMessageWithImage:imageFile
                        preview:preview
                           size:theSize
                        isGroup:NO
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)postMessageToGroupWithImagePath:(NSString *)theImagePath
                         preview:(NSData *)thePreview
                            size:(CGSize)theSize
                           block:(PFStringResultBlock)resultBlock
                   progressBlock:(ALProgressBlock)progressBlock
{
    NSString *fileLastName = [[theImagePath substringFromIndex:theImagePath.length-3] lowercaseString];
    
    if (![fileLastName rangeOfString:@"jpg jpeg gif png bmp"].location == NSNotFound)
    {
        fileLastName = @"png";
    }
    
    AVFile *imageFile = [AVFile fileWithName:[NSString stringWithFormat:@"image.%@",fileLastName] contentsAtPath:theImagePath];
    AVFile *preview = [AVFile fileWithName:[NSString stringWithFormat:@"preview.png"] data:thePreview];
    
    [self _postMessageWithImage:imageFile
                        preview:preview
                           size:theSize
                        isGroup:YES
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)_postMessageWithImage:(AVFile *)imageFile
                      preview:(AVFile *)previewFile
                         size:(CGSize)theSize
                      isGroup:(BOOL)isGroup
                        block:(PFStringResultBlock)resultBlock
                progressBlock:(ALProgressBlock)progressBlock
{
    [imageFile retain];
    [previewFile retain];
    
    if (imageFile)
    {
        __block int __count = 2;
        
        __block NSMutableDictionary *content = [[NSMutableDictionary dictionary] retain];
        __block NSMutableDictionary *userData = [[NSMutableDictionary dictionary] retain];
        
        if (isGroup)
        {
            [content setValue:@"group" forKey:@"type"];
        }
        else
        {
            [content setValue:@"chat" forKey:@"type"];
        }
        
        [content setValue:@"image" forKey:@"subType"];
        [content setValue:NSStringFromCGSize(theSize) forKey:@"size"];
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error && succeeded)
            {
                [userData setValue:imageFile.url forKey:@"url"];
                
                if (--__count <=0)
                {
                    [self __postMessageWithContent:[content JSONString]
                                          userData:[userData JSONString]
                                           isGroup:isGroup
                                              type:ALFileTypeImage
                                             block:resultBlock];
                    
                    [content release];
                    [userData release];
                }
                
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(succeeded,error);
                }
                
                [content release];
                [userData release];
                
                __count = 10;
            }
            
        } progressBlock:^(int percentDone) {
            
            if (progressBlock)
            {
                progressBlock(percentDone/100.0);
            }
            
        }];

        if (previewFile)
        {
            [previewFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (__count != 10)
                {
                    if (succeeded && !error)
                    {
                        [userData setValue:previewFile.url forKey:@"preview"];
                    }
                    else
                    {
                        [userData setValue:[NSNull null] forKey:@"preview"];
                    }
                    
                    if (--__count <=0)
                    {
                        [self __postMessageWithContent:[content JSONString]
                                              userData:[userData JSONString]
                                               isGroup:isGroup
                                                  type:ALFileTypeImage
                                                 block:resultBlock];
                        [content release];
                        [userData release];
                    }
                }
            }];
        }
        else
        {
            [userData setValue:[NSNull null] forKey:@"preview"];
        }
    }
    else
    {
        if (resultBlock)
        {
            resultBlock(NO,nil);
        }
    }
    
    [previewFile release];
    [imageFile release];
}

- (void)postMessageWithVideo:(NSData *)theVideo
                   extension:(NSString *)theExtension
                     preview:(NSData *)thePreview
                       block:(PFStringResultBlock)resultBlock
               progressBlock:(ALProgressBlock)progressBlock
{
    AVFile *videoFile = [AVFile fileWithName:[NSString stringWithFormat:@"video.%@",theExtension] data:theVideo];
    AVFile *previewFile = [AVFile fileWithData:thePreview];
    
    [self _postMessageWithVideo:videoFile
                        preview:previewFile
                        isGroup:NO
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)postMessageWithVideoPath:(NSString *)theVideoPath
                         preview:(NSData *)thePreview
                           block:(PFStringResultBlock)resultBlock
                   progressBlock:(ALProgressBlock)progressBlock
{
    NSString *fileLastName = [[theVideoPath substringFromIndex:theVideoPath.length-3] lowercaseString];
    
    if (![@"mov mp4 avi wmv 3gp" rangeOfString:fileLastName].location == NSNotFound)
    {
        fileLastName = @"mp4";
    }
    
    AVFile *videoFile = [AVFile fileWithName:[NSString stringWithFormat:@"video.%@",fileLastName] contentsAtPath:theVideoPath];
    AVFile *previewFile = [AVFile fileWithData:thePreview];
    
    [self _postMessageWithVideo:videoFile
                        preview:previewFile
                        isGroup:NO
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)postMessageToGroupWithVideo:(NSData *)theVideo
                          extension:(NSString *)theExtension
                            preview:(NSData *)thePreview
                              block:(PFStringResultBlock)resultBlock
                      progressBlock:(ALProgressBlock)progressBlock
{
    AVFile *videoFile = [AVFile fileWithName:[NSString stringWithFormat:@"video.%@",theExtension] data:theVideo];
    AVFile *previewFile = [AVFile fileWithData:thePreview];
    
    [self _postMessageWithVideo:videoFile
                        preview:previewFile
                        isGroup:YES
                          block:resultBlock
                  progressBlock:progressBlock];
}

- (void)postMessageToGroupWithVideoPath:(NSString *)theVideoPath
                                preview:(NSData *)thePreview
                                  block:(PFStringResultBlock)resultBlock
                          progressBlock:(ALProgressBlock)progressBlock
{
    NSString *fileLastName = [[theVideoPath substringFromIndex:theVideoPath.length-3] lowercaseString];
    
    if (![@"mov mp4 avi wmv 3gp" rangeOfString:fileLastName].location == NSNotFound)
    {
        fileLastName = @"mp4";
    }
    
    AVFile *videoFile = [AVFile fileWithName:[NSString stringWithFormat:@"video.%@",fileLastName] contentsAtPath:theVideoPath];
    AVFile *previewFile = [AVFile fileWithData:thePreview];
    
    [self _postMessageWithVideo:videoFile
                        preview:previewFile
                        isGroup:YES
                          block:resultBlock
                  progressBlock:progressBlock];
}


- (void)_postMessageWithVideo:(AVFile *)videoFile
                      preview:(AVFile *)previewFile
                      isGroup:(BOOL)isGroup
                        block:(PFStringResultBlock)resultBlock
                progressBlock:(ALProgressBlock)progressBlock
{
    if (videoFile)
    {
        __block int __count = 2;
        
        __block NSMutableDictionary *content = [[NSMutableDictionary dictionary] retain];
        __block NSMutableDictionary *userData = [[NSMutableDictionary dictionary] retain];
        
        if (isGroup)
        {
            [content setValue:@"group" forKey:@"type"];
        }
        else
        {
            [content setValue:@"chat" forKey:@"type"];
        }
        
        [content setValue:@"video" forKey:@"subType"];
        
        [previewFile retain];
        
        [previewFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error && succeeded)
            {
//                [dic setValue:previewFile.url forKey:@"preview"];
                [userData setValue:previewFile.url forKey:@"preview"];
                
            }
            else
            {
                [userData setValue:[NSNull null] forKey:@"preview"];
            }
            
            [previewFile release];
            
            if (--__count <=0)
            {
                [self __postMessageWithContent:[content JSONString]
                                      userData:[userData JSONString]
                                       isGroup:isGroup
                                          type:ALFileTypeImage
                                         block:resultBlock];
                [content release];
                [userData release];
            }
            
        }];
        

        [videoFile retain];
        [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error && succeeded)
            {
                [userData setValue:videoFile.url forKey:@"url"];
                
                if (--__count <=0)
                {
                    [self __postMessageWithContent:[content JSONString]
                                          userData:[userData JSONString]
                                           isGroup:isGroup
                                              type:ALFileTypeImage
                                             block:resultBlock];
                    
                    [content release];
                    [userData release];
                }
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(succeeded,error);
                }
                
                __count = 10;
            }
            
            [videoFile release];
            
        } progressBlock:^(int percentDone) {
            
            if (progressBlock)
            {
                progressBlock(percentDone/100.0);
            }
        }];
    }
}

- (void)__postMessageWithContent:(NSString *)theContent
                        userData:(NSString *)theUserData
                         isGroup:(BOOL)isGroup
                            type:(ALFileType)theType
                           block:(PFStringResultBlock)resultBlock
{

    self.postMessageResultBlock = resultBlock;

    if (self.curTalkUserVoip && !isGroup)
    {
        if (theContent.length > 0)
        {
//        [self.xmppRoster sendMessage:theContent toUser:self.currentTalkUserId type:theType];
            
            self.imMsg.sender = self.xmppInfo.voipAccount;
            self.imMsg.receiver = self.curTalkUserVoip;
            self.imMsg.message = theContent;
            self.imMsg.userData = theUserData;
            self.imMsg.status = 0;
            
//            IMTextMsg * immmm = self.imMsg;
            
            [self.modelEngineVoip sendInstanceMessage:self.curTalkUserVoip andText:theContent andAttached:nil andUserdata:theUserData];
            
            [self push];
            
            if (currentUsersIsOffline)
            {
                
            }
        }
    }
    //发群消息
    else if (self.curTalkGroupVoip && isGroup)
    {
        if (theContent.length > 0)
        {
            //        [self.xmppRoster sendMessage:theContent toUser:self.currentTalkUserId type:theType];
            self.imMsg.sender = self.xmppInfo.voipAccount;
            self.imMsg.receiver = self.curTalkGroupVoip;
            self.imMsg.message = theContent;
            self.imMsg.userData = theUserData;
            self.imMsg.status = 0;
            [self.modelEngineVoip sendInstanceMessage:self.curTalkGroupVoip andText:theContent andAttached:nil andUserdata:theUserData];
        }
    }
    else
    {
        if (resultBlock)
        {
            if (isGroup)
            {
                resultBlock(NO,ALERROR(VOIP_SERVICEIP, -1, @"你当前没有进入任何群组"));
            }
            else
            {
                resultBlock(NO,ALERROR(VOIP_SERVICEIP, -1, @"你当前没有和任何人在聊天"));
            }
        }
    }
}

- (void)push
{
    if (!self.curTalkUser) return;
    
    //发通知
    AVQuery *installationQ = [AVInstallation query];
    [installationQ whereKey:@"owner" equalTo:self.curTalkUser];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setValue:@"message.wav" forKey:@"sound"];
    
    [dic setValue:@"Increment" forKey:@"badge"];
    
    if (self.curTalkUser.nickName)
    {
        [dic setValue:[NSString stringWithFormat:@"%@给你发了一条新消息",self.curTalkUser.nickName] forKey:@"alert"];
    }
    else
    {
        [dic setValue:@"您收到了一条新消息" forKey:@"alert"];
    }
    [dic setValue:nil forKey:@"chatUser"];
    [dic setValue:[NSNumber numberWithBool:YES] forKey:@"isFromChatUser"];
    
    
    [AVPush sendPushDataToQueryInBackground:installationQ withData:dic];
    
}



#pragma mark - 消息记录
//更改会话中未读状态为已读
- (void)updateUnreadStateOfUser:(User *)theUser
                          block:(void (^)(BOOL succeeded, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB updateUnreadStateOfUserVoip:self.xmppInfo.voipAccount user:theUser block:resultBlock];
}

//判断消息是否存在
- (void)isMessageExistOfMsgid:(NSString*)msgid block:(void(^)(BOOL success))block
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB isMessageExistOfMsgid:msgid block:block];
}

//获得全部聊天记录
- (void)getALLMessageWithNotContainedIn:(NSArray *)theMsgsId
                                  block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getALLMessageWithUserVoip:self.xmppInfo.voipAccount notContainedIn:theMsgsId block:resultBlock];
}

//获得全部未读的聊天记录数
- (void)getALLUnreadMessageWithNotContainedIn:(NSArray *)theMsgsId
                                        block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getALLUnreadMessageWithUserVoip:self.xmppInfo.voipAccount notContainedIn:theMsgsId block:resultBlock];
}

//获取与某用户的聊天记录
- (void)getUserMessageWithUser:(User *)theUser
                notContainedIn:(NSArray *)theMsgsId
                         block:(void (^)(NSDictionary *messages, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getUserMessageWithUserVoip:self.xmppInfo.voipAccount  user:theUser notContainedIn:theMsgsId block:resultBlock];
}

//获取与某用户的未读聊天记录数
- (void)getUserUnreadMessageCountWithUser:(User *)theUser
                                    block:(void (^)(NSInteger messagesCount, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getUserUnreadMessageCountWithUserVoip:self.xmppInfo.voipAccount user:theUser block:resultBlock];
}

//获取与某用户的未读聊天记录
- (void)getUserUnreadMessageWithUser:(User *)theUser
                      notContainedIn:(NSArray *)theMsgsId
                               block:(void (^)(NSDictionary *messages, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getUserUnreadMessageWithUserVoip:self.xmppInfo.voipAccount user:theUser notContainedIn:theMsgsId block:resultBlock];
}

//获得全部未读的聊天记录数
- (void)getALLUnreadMessageCountWithBlock:(void(^)(NSInteger messagesCount, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getALLUnreadMessageCountWithUserVoip:self.xmppInfo.voipAccount block:resultBlock];
}

- (void)getALLUnreadMessageWithBlock:(void(^)(NSDictionary *messages, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getALLUnreadMessageWithUserVoip:self.xmppInfo.voipAccount block:resultBlock];
}


#pragma mark - 联系人记录
//获取最近联系人列表
- (void)getLinkerOfRecentWithBlock:(void (^)(NSArray *likers, NSError *error))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    [self.imMsgDB getLinkerOfRecentWithUserVoip:self.xmppInfo.voipAccount block:resultBlock];
}

//删除最近联系人
- (void)delLinkerOfRecentWithLinker:(User *)theUser
                              block:(void(^)(BOOL success))resultBlock
{
    if (!self.xmppInfo.voipAccount) return;
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        [self.imMsgDB delLinkerOfRecentWithUserVoip:self.xmppInfo.voipAccount andLinkerVoip:userXmppDB.voipAccount block:resultBlock];
        
    }];
    
    
}
//- (void)getMessages
//{
//  [self.imMsgDB getALLMessageWithBlock:^(NSDictionary *messages, NSError *error) {
//      
//  }];
//}
//- (void)getMessages
//{
//    //1
//    //一个会话是指：toUser的所有消息
//    //获取会话列表(IMConversation)
//    NSArray *arr = [self.modelEngineVoip.imDBAccess getIMListArray];
//    
//    for (IMConversation *coversation in arr)
//    {
//        NSLog(@"==========会话：========");
//        NSLog(@"消息id=%@",coversation.conversationId);
//        NSLog(@"联系人=%@",coversation.contact);
//        NSLog(@"时间=%@",coversation.date);
//        NSLog(@"内容=%@",coversation.content);
//    }
//    
//    //TEST1
////    NSArray *ARR1 = [self.imDBAccess getUnreadOfSessionId:@"80390700000001"];
////    NSLog(@"ARR1.count=%d",ARR1.count);
//    
//    //2
//    //获取某个会话的聊天记录(IMMessageObj)
//    NSArray *arr1 = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:@"80390700000001"];
//    NSLog(@"count=%d",arr1.count);
//    for (IMMessageObj *message in arr1)
//    {
//        NSLog(@"消息：");
//        NSLog(@"消息id=%@",message.msgId);
////        NSLog(@"会话分组=%@",message.sessionId);
//        NSLog(@"sender=%@",message.sender);
//        NSLog(@"内容=%@",message.content);
//    }
//    
//    //3
//    //获取某个会话中未读消息数
//    int arr2 = [self.modelEngineVoip.imDBAccess getUnreadCountOfSessionId:@"80390700000001"];
//    NSLog(@"count=%d",arr2);
//    
//    
//    //4
//    //更改会话中未读状态为已读
//    [self.imDBAccess updateUnreadStateOfSessionId:@"80390700000001"];
//    
//    //获取所有通知消息
//    //申请入群消息
//    NSArray *groupNotices = [self.modelEngineVoip.imDBAccess getAllGroupNotices];
//    
//    for (IMGroupNotice *msg in groupNotices)
//    {
//         //0 申请加入   1 回复加入  2邀请加入  3移除成员 4退出 5解散 6有人加入
//        if (msg.msgType == EGroupNoticeType_ApplyJoin || msg.msgType == EGroupNoticeType_InviteJoin)
//        {
//            if (msg.state == EGroupNoticeOperation_NeedAuth)
//            {
////                UIButton* yesBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////                [yesBtn setTitle:@"同意" forState:UIControlStateNormal];
////                yesBtn.frame = CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 20.0f);
////                yesBtn.tag = 2000+indexPath.row;
////                [yesBtn addTarget:self action:@selector(inviteOrJoinYesBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
////                [cell addSubview:yesBtn];
////                
////                UIButton* noBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////                [noBtn setTitle:@"拒绝" forState:UIControlStateNormal];
////                noBtn.frame = CGRectMake(210.0f, yesBtn.frame.origin.y+yesBtn.frame.size.height+5.0f, 100.0f, 20.0f);
////                noBtn.tag = 2000+indexPath.row;
////                [noBtn addTarget:self action:@selector(inviteOrJoinNoBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
////                [cell addSubview:noBtn];
//            }
//            else if (msg.state==EGroupNoticeOperation_UnneedAuth)
//            {
////                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 40.0f)];
////                label.textColor = [UIColor grayColor];
////                label.textAlignment = NSTextAlignmentCenter;
////                label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
////                label.text = @"已在群组";
////                label.tag = 2000;
////                [cell addSubview:label];
////                [label release];
//            }
//            else if (msg.state == EGroupNoticeOperation_Access)
//            {
////                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 40.0f)];
////                label.textColor = [UIColor grayColor];
////                label.textAlignment = NSTextAlignmentCenter;
////                label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
////                label.text = @"已通过";
////                label.tag = 2000;
////                [cell addSubview:label];
////                [label release];
//            }
//            else if (msg.state == EGroupNoticeOperation_Reject)
//            {
////                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 40.0f)];
////                label.textColor = [UIColor grayColor];
////                label.textAlignment = NSTextAlignmentCenter;
////                label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
////                label.text = @"已拒绝";
////                label.tag = 2000;
////                [cell addSubview:label];
////                [label release];
//            }
//        }
//    }
//}

#pragma mark - voip代理
#pragma mark - 接收
//通知客户端收到新的IM信息
//个人和群组都走这个代理
- (void)onReceiveInstanceMessage:(InstanceMsg*) msg
{
    //如果是IM
    if ([msg isKindOfClass:[IMTextMsg class]])
    {
        //如果是check消息
        if ([[msg message] rangeOfString:CHECH_MESSAGE].location != NSNotFound || ![msg message])
        {
            return;
        }
        
        IMTextMsg *textMsg = (IMTextMsg*)msg;
        
        if ([textMsg.sender isEqualToString:@"registrar"])
        {
            return;
        }
        
        //接收消息通知
        [self _receiveTextMessage:textMsg];
        
        //插入数据库
        [self _insertIMMessage:textMsg isSend:NO];
        
    }
    //附件消息
    else if ([msg isKindOfClass:[IMAttachedMsg class]])
    {
        IMAttachedMsg* attachmsg = (IMAttachedMsg*)msg;

//        if([self.imDBAccess isMessageExistOfMsgid:attachmsg.msgId])
//            return;
    }
    //解散群组消息
    else if([msg isKindOfClass:[IMDismissGroupMsg class]])
    {
        IMDismissGroupMsg *instanceMsg = (IMDismissGroupMsg*)msg;
        NSString *groupId = instanceMsg.groupId;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP_MESSAGE_OF_DESTROY object:self userInfo:@{@"groupId":groupId}];
    }
    //群组邀请加入
    else if([msg isKindOfClass:[IMInviterMsg class]])//
    {
        IMInviterMsg *instanceMsg = (IMInviterMsg*)msg;
        NSString *groupId = instanceMsg.groupId;
        NSString *admin = instanceMsg.admin;
        NSString *declared = instanceMsg.declared;
        NSString *confirm = instanceMsg.confirm;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP_MESSAGE_OF_INVITER object:self userInfo:@{@"groupId":groupId, @"admin":admin, @"declared":declared, @"confirm":confirm}];
    }
    //有人申请加入群组
    else if([msg isKindOfClass:[IMProposerMsg class]])
    {
        IMProposerMsg *instanceMsg = (IMProposerMsg*)msg;
        NSString *groupId = instanceMsg.groupId;
        NSString *proposer = instanceMsg.proposer;
        NSString *declared = instanceMsg.declared;
        NSString *dateCreated = instanceMsg.dateCreated;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP_MESSAGE_OF_INVITER object:self userInfo:@{@"groupId":groupId, @"proposer":proposer, @"declared":declared, @"dateCreated":dateCreated}];
    }
    //有人退出群组
    else if([msg isKindOfClass:[IMQuitGroupMsg class]])
    {
        IMQuitGroupMsg *instanceMsg = (IMQuitGroupMsg*)msg;//
        NSString *groupId = instanceMsg.groupId;
        NSString *member = instanceMsg.member;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP_MESSAGE_OF_QUIT_GROUP object:self userInfo:@{@"groupId":groupId, @"member":member}];
    }
    //有成员被移除群组
    else if([msg isKindOfClass:[IMRemoveMemberMsg class]])
    {
        IMRemoveMemberMsg *instanceMsg = (IMRemoveMemberMsg*)msg;
        //NOTIFICATION_GROUP_MESSAGE_OF_REMOVE_MEMBER
        NSString *groupId = instanceMsg.groupId;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP_MESSAGE_OF_REMOVE_MEMBER object:self userInfo:@{@"groupId":groupId}];
    }
    //申请加入群组消息回复
    else if([msg isKindOfClass:[IMReplyJoinGroupMsg class]])
    {
        IMReplyJoinGroupMsg *instanceMsg = (IMReplyJoinGroupMsg*)msg;
        NSString *groupId = instanceMsg.groupId;
        NSString *admin = instanceMsg.admin;
        NSString *confirm = instanceMsg.confirm;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GROUP_MESSAGE_OF_REPLY_JOIN_GROUP object:self userInfo:@{@"groupId":groupId, @"admin":admin,  @"confirm":confirm}];
    }
    //有人加入群组
    else if([msg isKindOfClass:[IMJoinGroupMsg class]])
    {
        IMJoinGroupMsg *instanceMsg = (IMJoinGroupMsg*)msg;
    }
}

- (void)_insertIMMessage:(IMTextMsg *)textMsg isSend:(BOOL)isSend
{
//    if([self.imMsgDB isMessageExistOfMsgid:textMsg.msgId])
//        return;
    
    if (!textMsg.message || !textMsg.userData) return;
    
    IMMessageObj *imMsg = [[IMMessageObj alloc] init];
    imMsg.msgId = textMsg.msgId;
    imMsg.content = textMsg.message;
    imMsg.userData = textMsg.userData;
    imMsg.my = self.xmppInfo.voipAccount;
    
//    UserXmppInfo *info = self.xmppInfo;

//    if (![textMsg.sender isEqualToString:self.xmppInfo.voipAccount])
//    {
//        imMsg.talker = textMsg.sender;
//    }
//    else if (![textMsg.receiver isEqualToString:self.xmppInfo.voipAccount])
//    {
//        imMsg.talker = textMsg.receiver;
//    }
    
    imMsg.isRead = NO;
    imMsg.isSender = isSend;
    imMsg.dateCreated = textMsg.dateCreated;
    imMsg.userData =textMsg.userData;
    imMsg.imState = EMessageState_Received;

    imMsg.sender = textMsg.sender;
    imMsg.receiver = textMsg.receiver;
    
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
    [dateformatter release];
    
    imMsg.curDate = curTimeStr;

    //加入消息盒子
    [self.imMsgDB insertIMMessage:imMsg block:^(BOOL success) {
        if (success) NSLog(@"加入聊天盒子");
        [imMsg release];
    }];
    
}

//处理接收到的文字IM
-(void)_receiveTextMessage:(IMTextMsg *)textMsg
{
    
    NSString *msgId = textMsg.msgId;
    NSString *dateCreated = textMsg.dateCreated;
    NSString *senderId = textMsg.sender;
//    NSString *receiverId = textMsg.receiver;
    NSString *message = textMsg.message;
    NSString *userData = textMsg.userData;
    
    NSString *g = [senderId substringToIndex:1];
    //来自群组的
    if ([g isEqualToString:@"g"])
    {
        
        NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:[message objectFromJSONString]];
        [messageInfo addEntriesFromDictionary:[userData objectFromJSONString]];
        [messageInfo setValue:senderId forKey:@"sender"];
        [messageInfo setValue:msgId forKey:@"msgId"];
        [messageInfo setValue:dateCreated forKey:@"dateCreated"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_MESSAGE object:self userInfo:messageInfo];
    }
    //来自用户的
    else
    {
//        __block User *sender = [[NSUserDefaults standardUserDefaults] objectForKey:senderId];
        
        [ALXMPPHelper getUserFromVoip:senderId block:^(UserXmppDB *userXmppDB, NSError *error) {
           
            NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:[message objectFromJSONString]];

            [messageInfo addEntriesFromDictionary:[userData objectFromJSONString]];
            [messageInfo setValue:[User objectWithoutDataWithObjectId:userXmppDB.userId] forKey:@"sender"];
            [messageInfo setValue:msgId forKey:@"msgId"];
            [messageInfo setValue:dateCreated forKey:@"dateCreated"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_MESSAGE object:self userInfo:messageInfo];
        }];
        
    }
}

- (void)responseKickedOff
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下线提示" message:@"该账号在其他设备登录，你已经下线。" delegate:nil cancelButtonTitle:@"退出" otherButtonTitles: nil,nil];
//    alertView.delegate = self;
//    [alertView show];
//    [alertView release];
    NSLog(@"发送掉线通知！！！");
    [self removeVCService];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_LOG_OUT object:self];
}


#pragma mark - 回调
//11 17 10
/*
 ERegisterResult
 
 ERegisterNot=0,         //没有注册
 ERegistering,           //注册中
 ERegisterSuccess,       //注册成功
 ERegisterFail,          //注册失败
 ERegisterLogout         //注销
 */
//注册的信息
- (void)responseVoipRegister:(ERegisterResult)event data:(NSString *)data
{
    switch (event)
    {
        case ERegisterSuccess:
        {
            if (self.logInResultBlock)
            {
                self.logInResultBlock(YES,nil);
                self.logInResultBlock = nil;
            }
        }
            break;
        case ERegisterFail:
        {
            if (self.logInResultBlock)
            {
                self.logInResultBlock(NO,nil);
                self.logInResultBlock = nil;
            }

            self.xmppInfo.subAccountSid = nil;
            self.xmppInfo.subToken = nil;
            self.xmppInfo.voipAccount = nil;
            self.xmppInfo.voipPwd = nil;
        }
        case ERegisterLogout:
        {
            //登出
        }
        
            break;
        default:
            break;
    }
}

//通知客户端发出了新的IM信息
- (void)onSendInstanceMessageWithReason:(NSInteger)reason andMsg:(InstanceMsg*) data
{
    if (reason == 0)
    {
        NSLog(@"发送消息成功 mess=%@",self.imMsg.message);
        
        //发得检测消息
        if (self.checkCount==2)
        {
            self.checkMsgId = [data msgId];
            --self.checkCount;
        }
        else if (self.checkCount == 1 && [self.checkMsgId isEqualToString:[data msgId]])
        {
            --self.checkCount;
        
            //对方不在线
            if ([[data status] isEqualToString:@"0"])
            {
                NSLog(@"%@,%@",self.curTalkUser.objectId,self.imMsg.userData);
                if ([self.curTalkUser.objectId isEqualToString:self.imMsg.userData])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_XMPP_TALKER_IS_OFFLINE object:nil];
                    
                    NSLog(@"用户不在线！！！！！！！！！");
                    currentUsersIsOffline = YES;
                }
            }
            else
            {
                currentUsersIsOffline = NO;
            }
        }
        else
        {
            if ([[data status] isEqualToString:@"0"] && [data dateCreated])
            {
                self.imMsg.msgId = [data msgId];
                self.imMsg.dateCreated = [data dateCreated];
                
                [self _insertIMMessage:self.imMsg isSend:YES];
            }
            
            if (self.postMessageResultBlock)
            {
                self.postMessageResultBlock([data msgId],nil);
                self.postMessageResultBlock = nil;
            }
        }
    }
    else
    {
        NSLog(@"发送消息失败，请稍后再试! 原因：%d",reason);
        
        self.imMsg.sender = nil;
        self.imMsg.receiver = nil;
        self.imMsg.message = nil;
        self.imMsg.userData = nil;
        self.imMsg.status = 0;
        
        self.imMsg.msgId = nil;
        self.imMsg.dateCreated = nil;
        
        if (self.postMessageResultBlock)
        {
            NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
            
            self.postMessageResultBlock(nil,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.postMessageResultBlock = nil;
        }
    }
}

/********************多媒体IM群组的方法********************/
//创建群组回调
- (void)onGroupCreateGroupWithReason:(NSInteger)reason andGroupId:(NSString*)groupId
{
    if (reason == 0)
    {
        NSLog(@"创建群成功 groupId=%@",groupId);
        if (self.createdGroupResultBlock)
        {
            self.createdGroupResultBlock(groupId,nil);
            self.createdGroupResultBlock = nil;
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"创建群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.createdGroupResultBlock)
        {
            self.createdGroupResultBlock(NO,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.createdGroupResultBlock = nil;
        }
    }
}

//修改群组回调
- (void)onGroupModifyGroupWithReason:(NSInteger)reason
{
    if (reason == 0)
    {
        NSLog(@"修改群成功");
        
    }
    else
    {
        NSLog(@"修改群组失败，请稍后再试! 原因：%d",reason);
        
    }
}

//删除群组回调 deletedGroupResultBlock
- (void)onGroupDeleteGroupWithReason:(NSInteger)reason
{
    if (reason == 0)
    {
        NSLog(@"删除群成功");
        if (self.deletedGroupResultBlock)
        {
            self.deletedGroupResultBlock(YES,nil);
            self.deletedGroupResultBlock = nil;
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"删除群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.deletedGroupResultBlock)
        {
            self.deletedGroupResultBlock(NO,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.deletedGroupResultBlock = nil;
        }
    }
}

//获取公共群组回调 queryPublicGroupsResultBlock
//queryPublicGroupsWithGroupId 用不了？
- (void)onGroupQueryPublicGroupsWithReason:(NSInteger)reason andGroups:(NSArray*)groups
{
    if (reason == 0)
    {
        NSLog(@"获取公共群组成功 groups.count=%d",groups.count);
//        for (IMGroupInfo *group in groups)
//        {
//            NSLog(@"group=%@",group.name);
//            NSLog(@"group=%@",group.groupId);
//        }
        if (self.queryPublicGroupsResultBlock)
        {
            self.queryPublicGroupsResultBlock(groups,nil);
            self.queryPublicGroupsResultBlock = nil;
        }
        /*
         好听符合规范1
         g8039076738341
         
         测试3
         g8039071794180
         
         测试2
         g8039073039518
         
         测试1
         g8039073414829
         
         g8039079698908
         */
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"获取公共群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.queryPublicGroupsResultBlock)
        {
            self.queryPublicGroupsResultBlock(nil,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.queryPublicGroupsResultBlock = nil;
        }
    }
}

//搜索公共群组回调 //有什么用？
- (void)onGroupSearchPublicGroupsWithReason:(NSInteger)reason andGroups:(NSArray*)groups
{
    if (reason == 0)
    {
        NSLog(@"获取公共群组成功 groups=%@",groups);
    }
    else
    {
        NSLog(@"删除群组失败，请稍后再试! 原因：%d",reason);
    }
}

//查询群组回调 groupsResultBlock
- (void)onGroupQueryGroupWithReason:(NSInteger)reason andGroup:(IMGroupInfo*)group
{
    if (reason == 0)
    {
        NSLog(@"获取公共群组成功 groupName=%@",group.name);
        if (self.groupsResultBlock)
        {
            self.groupsResultBlock(group,nil);
            self.groupsResultBlock = nil;
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"获取公共群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.groupsResultBlock)
        {
            self.groupsResultBlock(nil,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.groupsResultBlock = nil;
        }
    }
}

//申请加入群组回调
- (void)onGroupJoinGroupWithReason:(NSInteger)reason
{
    if (reason == 0)
    {
        NSLog(@"申请加入群组成功");//enterGroupResultBlock
        if (self.enterGroupResultBlock)
        {
            self.enterGroupResultBlock(YES,nil);
            self.enterGroupResultBlock = nil;
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"申请加入群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.enterGroupResultBlock)
        {
            self.enterGroupResultBlock(NO,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.enterGroupResultBlock = nil;
        }
    }
}

//成员主动退出群组回调
- (void)onGroupLogoutGroupWithReason: (NSInteger) reason
{
    if (reason == 0)
    {
        NSLog(@"成员退出群组成功");//exitGroupResultBlock
        if (self.exitGroupResultBlock)
        {
            self.exitGroupResultBlock(YES,nil);
            self.exitGroupResultBlock = nil;
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"成员退出群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.exitGroupResultBlock)
        {
            self.exitGroupResultBlock(NO,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.exitGroupResultBlock = nil;
        }
    }
}

//管理员邀请加入群组回调
- (void)onGroupInviteJoinGroupWithReason:(NSInteger)reason
{
    if (reason == 0)
    {
        NSLog(@"管理员邀请加入群组成功");
    }
    else
    {
        NSLog(@"管理员邀请加入群组失败，请稍后再试! 原因：%d",reason);
    }
}

//群组管理员删除成员回调
- (void) onGroupDeleteGroupMemberWithReason: (NSInteger) reason
{
    if (reason == 0)
    {
        NSLog(@"管理员邀请加入群组成功");
    }
    else
    {
        NSLog(@"管理员邀请加入群组失败，请稍后再试! 原因：%d",reason);
    }
}



/********************多媒体IM群组成员的方法********************/
//添加成员回调
- (void) onMemberAddMemberWithReason: (NSInteger) reason
{
    
}

//修改成员回调
- (void) onMemberModifyMemberWithReason: (NSInteger) reason
{
    
}

//删除成员回调
- (void) onMemberDeleteMemberWithReason: (NSInteger) reason
{
    
}

//查询成员
- (void) onMemberQueryMemberWithReason: (NSInteger) reason andMembers:(NSArray*)members
{
    if (reason == 0)
    {
        NSLog(@"获取群成员成功 members.count=%d",members.count);
        if (self.queryUserGroupsResultBlock)
        {
            NSMutableArray *membersId = [NSMutableArray arrayWithCapacity:members.count];
            
            //@"80390700000001|&|IOS-VoIP\U80fd\U529bDEMO;&;0"
            for (NSString *memberInfo in members)
            {
                NSString *memberId = [memberInfo substringWithRange:NSMakeRange(0, [memberInfo rangeOfString:@"|&|"].location)];
                
                [membersId addObject:memberId];
            }
            
            [ALXMPPHelper getUsersFromVoips:membersId block:^(NSArray *users, NSError *error) {
                
                NSMutableArray *userList = [NSMutableArray array];
                for (UserXmppDB *userXmpp in users)
                {
                    [userList addObject:[User objectWithoutDataWithObjectId:userXmpp.userId]];
                }
                self.queryUserGroupsResultBlock(userList,error);
                self.queryUserGroupsResultBlock = nil;
            }];
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"获取群成员失败，请稍后再试! 原因：%@",errorInfo);
        if (self.queryUserGroupsResultBlock)
        {
            self.queryUserGroupsResultBlock(nil,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.queryUserGroupsResultBlock = nil;
        }
    }
    
    NSLog(@"%@",members [0]);
}

//查询成员加入的群组 //queryUserGroupsResultBlock
- (void)onMemberQueryGroupWithReason:(NSInteger)reason andGroups:(NSArray*)groups
{
    if (reason == 0)
    {
        NSLog(@"获取公共群组成功 group.count=%d",groups.count);
//        for (IMGroupInfo *group in groups)
//        {
//            NSLog(@"群组ID:%@",group.groupId);
//            NSLog(@"群组名字:%@",group.name);
//            NSLog(@"管理员:%@",group.owner);
//            NSLog(@"人数:%d",group.count);
//        }
        if (self.queryUserGroupsResultBlock)
        {
            self.queryUserGroupsResultBlock(groups,nil);
            self.queryUserGroupsResultBlock = nil;
        }
    }
    else
    {
        NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",reason]];
        NSLog(@"获取公共群组失败，请稍后再试! 原因：%@",errorInfo);
        if (self.queryUserGroupsResultBlock)
        {
            self.queryUserGroupsResultBlock(nil,ALERROR(VOIP_SERVICEIP, reason, errorInfo));
            self.queryUserGroupsResultBlock = nil;
        }
    }
}

//管理员对用户禁言回调
- (void)onForbidSpeakWithReason: (NSInteger) reason
{
    
}

//管理员验证用户申请加入群组回调
- (void) onMemberAskJoinWithReason: (NSInteger) reason
{
    
}

//用户验证邀请加入群组回调
- (void) onMemberInviteGroupWithReason: (NSInteger) reason
{
    
}

//修改群名片回调
-(void) onModifyGroupCardWithReason:(NSInteger) reason
{
    
}

//查询群名片回调
-(void) onQueryCardWithReason:(NSInteger) reason andGroupCard:(IMGruopCard*) groupCard
{
    
}

//下载文件状态返回
-(void)responseDownLoadMediaMessageStatus:(NSInteger)event
{
    
}

//im群组消息通知
-(void)responseIMGroupNotice:(NSString*)groupId data:(NSString *)data
{
    //有人申请加入群组
    NSLog(@"来着群组%@ 的消息:%@ ",groupId, data);
    
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	//使用这个方法来释放共享资源,保存用户数据,无效计时器
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	//
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
//			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}
@end