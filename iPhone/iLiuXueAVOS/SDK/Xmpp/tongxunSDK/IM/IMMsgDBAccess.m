/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "IMMsgDBAccess.h"
#import <AVOSCloud/AVOSCloud.h>

@interface IMMsgDBAccess()

@end

@implementation IMMsgDBAccess
- (IMMsgDBAccess *)init
{
    if (self=[super init]) {
        shareDB = [DBConnection getSharedDatabase];
        [self IMMessageTableCreate];
        [self IMGroupNoticeTableCreate];
        [self IMGroupInfoTableCreate];
        return self;
    }
    return nil;
}

- (BOOL)IMMessageTableCreate {
    const char * createTable = "create table if not exists im_message(msgId text primary key, sessionId text, msgType integer, sender text, isRead integer, imState integer, createDate text, curDate text, userData text, msgContent text, fileUrl text, filePath text, fileExt text, duration double)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or im_message!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

- (BOOL)IMGroupNoticeTableCreate {
    const char * createTable = "create table if not exists im_groupnotice(id integer primary key, verifyMsg text, msgType integer, state integer, isRead integer, groupId text, who text, curDate text)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or im_groupnotice!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

- (BOOL)IMGroupInfoTableCreate {
    const char * createTable = "create table if not exists im_groupinfo(groupId text primary key, name text, owner text, type integer, declared text, createDate text, count integer, permission integer)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or im_groupinfo!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

- (void)deleteAllIMMsg
{
    [self deleteAllMessage];
    [self deleteAllGroupNotice];
}

- (BOOL)deleteAllMessage
{
    @try {
        char * errmsg;
        int flag = 0;
        BOOL returnFlag = YES;
        const char * deleteRelatedInfo = "delete from im_message";
        flag = sqlite3_exec(shareDB, deleteRelatedInfo, NULL, NULL, &errmsg);
        if (SQLITE_OK!=flag) {
            sqlite3_free(errmsg);
            NSLog(@"ERROR: Failed to delete table im_message!");
            returnFlag = FALSE;
        }
        
        return returnFlag;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)deleteAllGroupNotice
{
    @try {
        char * errmsg;
        int flag = 0;
        BOOL returnFlag = YES;
        const char * deleteRelatedInfo = "delete from im_groupnotice";
        flag = sqlite3_exec(shareDB, deleteRelatedInfo, NULL, NULL, &errmsg);
        if (SQLITE_OK!=flag) {
            sqlite3_free(errmsg);
            NSLog(@"ERROR: Failed to delete table im_groupnotice!");
            returnFlag = FALSE;
        }
        
        return returnFlag;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)deleteAllGroupInfo
{
    @try {
        char * errmsg;
        int flag = 0;
        BOOL returnFlag = YES;
        const char * deleteRelatedInfo = "delete from im_groupinfo";
        flag = sqlite3_exec(shareDB, deleteRelatedInfo, NULL, NULL, &errmsg);
        if (SQLITE_OK!=flag) {
            sqlite3_free(errmsg);
            NSLog(@"ERROR: Failed to delete table im_groupinfo!");
            returnFlag = FALSE;
        }
        
        return returnFlag;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

//删除会话消息
- (BOOL)deleteMessageOfSessionId:(NSString *)sessionId
{
    @try {
        const char * deleteRelatedInfo = "delete from im_message where sessionId = ?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:deleteRelatedInfo];
            [stmt retain];
        }
        [stmt bindString:sessionId forIndex:1];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to delete table im_message!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (NSArray *)getIMListArray
{
    @try {
        [DBConnection beginTransaction];
        
        const char * getMsgSql = "SELECT msgId, sessionId, curDate, msgType, msgContent, max(curDate) from im_message group by sessionId order by curDate desc";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:getMsgSql];
            [stmt retain];
        }
        NSMutableArray * IMArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            IMConversation *msg = [[IMConversation alloc] init];
            msg.conversationId = [stmt getString:0];
            msg.contact = [stmt getString:1];
            msg.date = [stmt getString:2];
            
            EMessageType msgtype = [stmt getInt32:3];
            if (msgtype == EMessageType_Text)
            {
                msg.content = [stmt getString:4];
            }
            else if (msgtype == EMessageType_File)
            {
                msg.content = @"文件";
            }
            else if (msgtype == EMessageType_Voice)
            {
                msg.content = @"语音";
            }
            
            msg.type = EConverType_Message;
            
            [IMArray addObject:msg];
            [msg release];
        }
        [stmt reset];
        
        const char * getLastNotice = "select id, curDate, msgType from im_groupnotice order by curDate desc limit 1";
        static Statement * stmt2 = nil;
        if (nil == stmt2)
        {
            stmt2 = [DBConnection statementWithQuery:getLastNotice];
            [stmt2 retain];
        }
        while (SQLITE_ROW == [stmt2 step]) {
            IMConversation *msg = [[IMConversation alloc] init];
            msg.conversationId = [NSString stringWithFormat:@"%d",[stmt2 getInt32:0]];
            msg.contact = @"系统通知";
            msg.date = [stmt2 getString:1];
            
            EGroupNoticeType noticeType = [stmt2 getInt32:2];
            if (noticeType == EGroupNoticeType_ApplyJoin){
                msg.content = @"有人申请加入群组";
            }else if(noticeType == EGroupNoticeType_DismissGroup){
                msg.content = @"有群组解散";
            }else if(noticeType == EGroupNoticeType_InviteJoin){
                msg.content = @"有人邀请您加入群组";
            }else if(noticeType == EGroupNoticeType_JoinedGroup){
                msg.content = @"有人加入群组";
            }else if(noticeType == EGroupNoticeType_QuitGroup){
                msg.content = @"有人退出群组";
            }else if(noticeType == EGroupNoticeType_RemoveMember){
                msg.content = @"您被一个群组踢出";
            }else if(noticeType == EGroupNoticeType_ReplyJoin){
                msg.content = @"有申请加入群组的回复";
            }
            
            msg.type = EConverType_Notice;
            
            [IMArray insertObject:msg atIndex:0];
            [msg release];
        }
        [stmt2 reset];
        
        
        [DBConnection commitTransaction];
        return [IMArray autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

- (NSArray *)getUnreadIMListArray
{
    @try {
        [DBConnection beginTransaction];
        
        const char * getMsgSql = "SELECT msgId, sessionId, curDate, msgType, msgContent, max(curDate) from im_message group by sessionId order by curDate desc";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:getMsgSql];
            [stmt retain];
        }
        NSMutableArray * IMArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            IMConversation *msg = [[IMConversation alloc] init];
            msg.conversationId = [stmt getString:0];
            msg.contact = [stmt getString:1];
            msg.date = [stmt getString:2];
            
            EMessageType msgtype = [stmt getInt32:3];
            if (msgtype == EMessageType_Text)
            {
                msg.content = [stmt getString:4];
            }
            else if (msgtype == EMessageType_File)
            {
                msg.content = @"文件";
            }
            else if (msgtype == EMessageType_Voice)
            {
                msg.content = @"语音";
            }
            
            msg.type = EConverType_Message;
            
            [IMArray addObject:msg];
            [msg release];
        }
        [stmt reset];
        
        const char * getLastNotice = "select id, curDate, msgType from im_groupnotice order by curDate desc limit 1";
        static Statement * stmt2 = nil;
        if (nil == stmt2)
        {
            stmt2 = [DBConnection statementWithQuery:getLastNotice];
            [stmt2 retain];
        }
        while (SQLITE_ROW == [stmt2 step]) {
            IMConversation *msg = [[IMConversation alloc] init];
            msg.conversationId = [NSString stringWithFormat:@"%d",[stmt2 getInt32:0]];
            msg.contact = @"系统通知";
            msg.date = [stmt2 getString:1];
            
            EGroupNoticeType noticeType = [stmt2 getInt32:2];
            if (noticeType == EGroupNoticeType_ApplyJoin){
                msg.content = @"有人申请加入群组";
            }else if(noticeType == EGroupNoticeType_DismissGroup){
                msg.content = @"有群组解散";
            }else if(noticeType == EGroupNoticeType_InviteJoin){
                msg.content = @"有人邀请您加入群组";
            }else if(noticeType == EGroupNoticeType_JoinedGroup){
                msg.content = @"有人加入群组";
            }else if(noticeType == EGroupNoticeType_QuitGroup){
                msg.content = @"有人退出群组";
            }else if(noticeType == EGroupNoticeType_RemoveMember){
                msg.content = @"您被一个群组踢出";
            }else if(noticeType == EGroupNoticeType_ReplyJoin){
                msg.content = @"有申请加入群组的回复";
            }
            
            msg.type = EConverType_Notice;
            
            [IMArray insertObject:msg atIndex:0];
            [msg release];
        }
        [stmt2 reset];
        
        
        [DBConnection commitTransaction];
        return [IMArray autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

- (NSArray*)getAllFilePath{
    @try
    {
        const char* sqlString = "select filePath from im_message where filePath is not null";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        NSMutableArray * fileArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            [fileArray addObject:[stmt getString:0]];
        }
        
        [stmt reset];
        return [fileArray autorelease];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    }
    return nil;
}

- (NSArray*)getAllFilePathOfSessionId:(NSString*)sessionId{
    @try
    {
        const char* sqlString = "select filePath from im_message where sessionId = ? and filePath is not null";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindString:sessionId forIndex:1];
        NSMutableArray * fileArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            [fileArray addObject:[stmt getString:0]];
        }
        
        [stmt reset];
        return [fileArray autorelease];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    }
    return nil;
}

//获取会话内容
- (NSArray *)getMessageOfSessionId:(NSString *)sessionId
{
    @try
    {
        const char* sqlString = "select msgid,sessionId,msgType,sender,isRead,imState,createDate,curDate,userData,msgContent,fileUrl,filePath,fileExt,duration from im_message where sessionId = ? order by curDate";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindString:sessionId forIndex:1];
        NSMutableArray * IMArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            IMMessageObj *msg = [[IMMessageObj alloc] init];
            
            int columnIndex = 0;
//            msg.msgid = [stmt getString:columnIndex]; columnIndex++;
//            msg.sessionId = [stmt getString:columnIndex]; columnIndex++;
//            msg.msgtype = [stmt getInt32:columnIndex]; columnIndex++;
//            msg.sender = [stmt getString:columnIndex]; columnIndex++;
//            msg.isRead = [stmt getInt32:columnIndex]; columnIndex++;
//            msg.imState = [stmt getInt32:columnIndex]; columnIndex++;
//            msg.dateCreated = [stmt getString:columnIndex]; columnIndex++;
//            msg.curDate = [stmt getString:columnIndex]; columnIndex++;
//            msg.userData = [stmt getString:columnIndex]; columnIndex++;
//            msg.content = [stmt getString:columnIndex]; columnIndex++;
//            msg.fileUrl = [stmt getString:columnIndex]; columnIndex++;
//            msg.filePath = [stmt getString:columnIndex]; columnIndex++;
//            msg.fileExt = [stmt getString:columnIndex]; columnIndex++;
//            msg.duration = [stmt getDouble:columnIndex];
//            
//            if ([msg.sessionId isEqualToString:msg.sender]) {
//                NSLog(@"一样的");
//            }
//            else
//            {
//                NSLog(@"不一样");
//            }
            
            [IMArray addObject:msg];
            [msg release];
        }
        
        [stmt reset];
        return [IMArray autorelease];        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    }
    return nil;
}

- (BOOL)isMessageExistOfMsgid:(NSString*)msgid
{
    BOOL isExist = NO;
    @try
    {
        const char * sqlString = "select count(*) from im_message where msgid = ?";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindString:msgid forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            NSInteger count = [stmt getInt32:0];
            if (count > 0)
            {
                isExist = YES;
            }
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
        return isExist;
    }
}



- (BOOL)insertIMMessage:(IMMessageObj*)im
{
    @try {
        const char * add = "insert into im_message(msgid,sessionId,msgType,sender,isRead,imState,createDate,curDate,userData,msgContent,fileUrl,filePath,fileExt,duration) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        static Statement * stmt = nil;
        if (stmt == nil) {
            stmt = [DBConnection statementWithQuery:add];
            [stmt retain];
        }
        int index = 1;
//        [stmt bindString:im.msgid forIndex:index]; index++;
//        [stmt bindString:im.sessionId forIndex:index]; index++;
//        [stmt bindInt32:im.msgtype forIndex:index]; index++;
//        [stmt bindString:im.sender forIndex:index]; index++;
//        [stmt bindInt32:im.isRead forIndex:index]; index++;
//        [stmt bindInt32:im.imState forIndex:index]; index++;
//        [stmt bindString:im.dateCreated forIndex:index]; index++;
//        [stmt bindString:im.curDate forIndex:index]; index++;
//        [stmt bindString:im.userData forIndex:index]; index++;
//        [stmt bindString:im.content forIndex:index]; index++;
//        [stmt bindString:im.fileUrl forIndex:index]; index++;
//        [stmt bindString:im.filePath forIndex:index]; index++;
//        [stmt bindString:im.fileExt forIndex:index]; index++;
//        [stmt bindDouble:im.duration forIndex:index];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to add new message into im_message!ret=%d,%s",ret,__func__);
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)insertNoticeMessage:(IMGroupNotice *)notice
{
    @try {
        const char * add = "insert into im_groupnotice(verifyMsg,msgType,state,isRead,groupId,who,curDate) values (?,?,?,?,?,?,?)";
        static Statement * stmt = nil;
        if (stmt == nil) {
            stmt = [DBConnection statementWithQuery:add];
            [stmt retain];
        }
        int index = 1;
        [stmt bindString:notice.verifyMsg forIndex:index]; index++;
        [stmt bindInt32:notice.msgType forIndex:index]; index++;
        [stmt bindInt32:notice.state forIndex:index]; index++;
        [stmt bindInt32:notice.isRead forIndex:index]; index++;
        [stmt bindString:notice.groupId forIndex:index]; index++;
        [stmt bindString:notice.who forIndex:index]; index++;
        [stmt bindString:notice.curDate forIndex:index]; 
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to add new message into im_message!ret=%d,%s",ret,__func__);
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;

}

- (NSArray *)getAllGroupNotices
{
    @try {
        const char* sqlString = "select id,verifyMsg,msgType,state,isRead,groupId,who,curDate from im_groupnotice order by curDate";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        NSMutableArray * noticesArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            IMGroupNotice *notice = [[IMGroupNotice alloc] init];
            
            int columnIndex = 0;
            notice.messageId = [stmt getInt32:columnIndex]; columnIndex++;
            notice.verifyMsg = [stmt getString:columnIndex]; columnIndex++;
            notice.msgType = [stmt getInt32:columnIndex]; columnIndex++;
            notice.state = [stmt getInt32:columnIndex]; columnIndex++;
            notice.isRead = [stmt getInt32:columnIndex]; columnIndex++;
            notice.groupId = [stmt getString:columnIndex]; columnIndex++;
            notice.who = [stmt getString:columnIndex]; columnIndex++;
            notice.curDate = [stmt getString:columnIndex];
            [noticesArray addObject:notice];
            [notice release];
        }
        
        [stmt reset];
        return [noticesArray autorelease];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    }
    return nil;
}

- (BOOL)insertNoticeMessage:(InstanceMsg *)msg withType:(EGroupNoticeType)type
{
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
    [dateformatter release];
    
    NSString *verifyMsg = @"";
    NSString *groupId = @"";
    NSString *who = @"";
    EGroupNoticeOperation state = EGroupNoticeOperation_UnneedAuth;
    if (EGroupNoticeType_ApplyJoin == type)
    {
        IMProposerMsg *instanceMsg = (IMProposerMsg*)msg;
        groupId = instanceMsg.groupId;
        state = EGroupNoticeOperation_NeedAuth;
        verifyMsg = instanceMsg.declared;
        who = instanceMsg.proposer;
    }
    else if (EGroupNoticeType_DismissGroup == type)
    {
        IMDismissGroupMsg *instanceMsg = (IMDismissGroupMsg*)msg;
        groupId = instanceMsg.groupId;
        verifyMsg = @"群组被解散";
    }
    else if (EGroupNoticeType_InviteJoin == type)
    {
        IMInviterMsg *instanceMsg = (IMInviterMsg*)msg;
        groupId = instanceMsg.groupId;
        
        who = instanceMsg.admin;
        verifyMsg = instanceMsg.declared;
        NSInteger confirm = [instanceMsg.confirm integerValue];
        if (confirm == 0)
        {
            state = EGroupNoticeOperation_NeedAuth;
        }
    }
    else if (EGroupNoticeType_JoinedGroup == type)
    {
        IMJoinGroupMsg *instanceMsg = (IMJoinGroupMsg*)msg;
        groupId = instanceMsg.groupId;
        verifyMsg = instanceMsg.declared;
        who = instanceMsg.proposer;
    }
    else if (EGroupNoticeType_QuitGroup == type)
    {
        IMQuitGroupMsg *instanceMsg = (IMQuitGroupMsg*)msg;
        groupId = instanceMsg.groupId;
        who = instanceMsg.member;
        verifyMsg = @"退出群组";
    }
    else if (EGroupNoticeType_RemoveMember == type)
    {
        IMRemoveMemberMsg *instanceMsg = (IMRemoveMemberMsg*)msg;
        groupId = instanceMsg.groupId;
        verifyMsg = @"你被管理员移除群组";
    }
    else if (EGroupNoticeType_ReplyJoin == type)
    {
        IMReplyJoinGroupMsg *instanceMsg = (IMReplyJoinGroupMsg*)msg;
        groupId = instanceMsg.groupId;
        
        if (instanceMsg.confirm == 0)
        {
            verifyMsg = @"通过你加入群组";
            state = EGroupNoticeOperation_Access;
        }
        else
        {
            verifyMsg = @"拒绝你加入群组";
            state = EGroupNoticeOperation_Reject;
        }
        who = instanceMsg.admin;
    }
    
    IMGroupNotice *groupNotice = [[IMGroupNotice alloc] init];
    groupNotice.verifyMsg = verifyMsg;
    groupNotice.msgType = type;
    groupNotice.state = state;
    groupNotice.isRead = EReadState_Unread;
    groupNotice.groupId = groupId;
    groupNotice.who = who;
    groupNotice.curDate = curTimeStr;
    BOOL ret = [self insertNoticeMessage:groupNotice];
    [groupNotice release];

    return ret;
}

- (void)insertOrUpdateGroupInfos:(NSArray*)groupInfos{
    @try
    {
        [DBConnection beginTransaction];
        for (IMGroupInfo *info in groupInfos)
        {
            if ([self isGroupExistOfGroupId:info.groupId])
            {
                [self updateGroupInfo:info];
            }
            else
            {
                [self insertGroupInfo:info];
            }
        }
        [DBConnection commitTransaction];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@", exception.name);
        NSLog(@"Exception reason=%@", exception.reason);
    }
    @finally
    {
    }
}

- (BOOL)insertGroupInfo:(IMGroupInfo *)groupInfo
{
    @try {
        const char * add = "insert into im_groupinfo(groupId,name,owner,type,declared,createDate,count,permission) values (?,?,?,?,?,?,?,?)";
        static Statement * stmt = nil;
        if (stmt == nil) {
            stmt = [DBConnection statementWithQuery:add];
            [stmt retain];
        }
        
        int index = 1;
        [stmt bindString:groupInfo.groupId forIndex:index]; index++;
        [stmt bindString:groupInfo.name forIndex:index]; index++;
        [stmt bindString:groupInfo.owner forIndex:index]; index++;
        [stmt bindInt32:groupInfo.type forIndex:index]; index++;
        [stmt bindString:groupInfo.declared forIndex:index]; index++;
        [stmt bindString:groupInfo.created forIndex:index]; index++;
        [stmt bindInt32:groupInfo.count forIndex:index]; index++;
        [stmt bindInt32:groupInfo.permission forIndex:index];

        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to add new message into im_message!ret=%d,%s",ret,__func__);
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (void)insertGroupInfos:(NSArray*)groupInfoArr
{
    @try
    {
        [DBConnection beginTransaction];
        for (IMGroupInfo *info in groupInfoArr)
        {
            [self insertGroupInfo:info];
        }
        [DBConnection commitTransaction];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    }
}

- (BOOL)isGroupExistOfGroupId:(NSString*)groupId{
    BOOL isExist = NO;
    @try
    {
        const char * sqlString = "select count(*) from im_groupinfo where groupId = ?";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindString:groupId forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            NSInteger count = [stmt getInt32:0];
            if (count > 0)
            {
                isExist = YES;
            }
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
        return isExist;
    }
}

- (BOOL)updateGroupInfo:(IMGroupInfo*)groupinfo
{
    @try {
        const char * updateInfo = "update im_groupinfo set name=?,owner=?,type=?,declared=?,createDate=?,count=?,permission=? where groupId=?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        int index = 1;
        [stmt bindString:groupinfo.name forIndex:index]; index++;
        [stmt bindString:groupinfo.owner forIndex:index]; index++;
        [stmt bindInt32:groupinfo.type forIndex:index]; index++;
        [stmt bindString:groupinfo.declared forIndex:index]; index++;
        [stmt bindString:groupinfo.created forIndex:index]; index++;
        [stmt bindInt32:groupinfo.count forIndex:index]; index++;
        [stmt bindInt32:groupinfo.permission forIndex:index]; index++;
        [stmt bindString:groupinfo.groupId forIndex:index];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_groupinfo!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (void)updateGroupInfos:(NSArray*)groupInfos{
    @try
    {
        [DBConnection beginTransaction];
        
        for (IMGroupInfo *group in groupInfos)
        {
            [self updateGroupInfo:group];
        }
        
        [DBConnection commitTransaction];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@", exception.name);
        NSLog(@"Exception reason=%@", exception.reason);
    }
    @finally
    {
    }
}

- (NSString*)queryNameOfGroupId:(NSString*)groupId
{
    NSString *name = nil;
    @try
    {
        const char *sqlStr = "select name from im_groupinfo where groupId=?";
        static Statement *stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlStr];
            [stmt retain];
        }
        [stmt bindString:groupId forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            name = [stmt getString:0];
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@", exception.name);
        NSLog(@"Exception reasong=%@", exception.reason);
    }
    @finally
    {
        return name;
    }
}



//获取某个会话中全部消息数
- (NSInteger)getCountOfSessionId:(NSString *)sessionId
{
    NSInteger count = 0;
    @try
    {
        const char * sqlString = "select count(*) from im_message where sessionId = ?";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindString:sessionId forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            count = [stmt getInt32:0];
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
        return count;
    }
}

- (NSInteger)getUnreadCountOfSessionId:(NSString *)sessionId
{
    NSInteger count = 0;
    @try
    {
        const char * sqlString = "select count(*) from im_message where isRead = ? and sessionId = ?";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindInt32:EReadState_Unread forIndex:1];
        [stmt bindString:sessionId forIndex:2];
        if (SQLITE_ROW == [stmt step])
        {
            count = [stmt getInt32:0];
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
        return count;
    }
}

- (BOOL)__addMessage:(NSString *)sessionId intoMessages:(NSDictionary *)messageInfo
{
    NSString *g = [sessionId substringToIndex:1];
    //g8039079698908
    if ([g isEqualToString:@"g"])
    {
        NSMutableArray * groupArray = messageInfo[@"group"];
        for (NSMutableDictionary *group in groupArray)
        {
            if ([group[@"groupId"] isEqualToString:sessionId])
            {
                
//                [groupArray replaceObjectAtIndex:[groupArray indexOfObject:group] withObject:@{@"groupId":sessionId,@"count":[NSNumber numberWithInt:[group[@"count"] intValue]+1]}];
                
                [group setValue:[NSNumber numberWithInt:[group[@"count"] intValue]+1] forKey:@"count"];
                
                return YES;
            }
        }
        
        NSMutableDictionary * groupDic = [NSMutableDictionary dictionaryWithCapacity:2];
        [groupDic setValue:sessionId forKey:@"groupId"];
        [groupDic setValue:@1 forKey:@"count"];
        
        [groupArray addObject:groupDic];
        
        return NO;
    }
    else
    {
        NSMutableArray * userArray = messageInfo[@"user"];
        for (NSMutableDictionary *user in userArray)
        {
            if ([user[@"userId"] isEqualToString:sessionId])
            {
//                [userArray replaceObjectAtIndex:[userArray indexOfObject:user] withObject:@{@"userId":sessionId,@"count":[NSNumber numberWithInt:[user[@"count"] intValue]+1]}];
                
                [user setValue:[NSNumber numberWithInt:[user[@"count"] intValue]+1] forKey:@"count"];
                
                return YES;
            }
        }
        
        NSMutableDictionary * userDic = [NSMutableDictionary dictionaryWithCapacity:2];
        [userDic setValue:sessionId forKey:@"userId"];
        [userDic setValue:@1 forKey:@"count"];
        
        [userArray addObject:userDic];
        
        return NO;
    }
}

//获取某个会话的全部聊天记录
- (void)getALLMessageCountWithBlock:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    [self _getALLMessageCountIsUnread:NO block:resultBlock];
}

//获取某个会话的全部未读聊天记录
- (void)getALLUnreadMessageCountWithBlock:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    [self _getALLMessageCountIsUnread:YES block:resultBlock];
}

- (void)_getALLMessageCountIsUnread:(BOOL)isUnread
                              block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    NSMutableArray * userArray = [NSMutableArray array];
    NSMutableArray * groupArray = [NSMutableArray array];
    
    NSMutableDictionary *messagesInfo = [NSMutableDictionary dictionary];
    [messagesInfo setValue:userArray forKey:@"user"];
    [messagesInfo setValue:groupArray forKey:@"group"];
    
    @try
    {
        char * sqlString = NULL;
        
        static Statement * stmt = nil;

        if (isUnread)
        {
            sqlString = "select sessionId from im_message where isRead = ?";
            [stmt bindInt32:EReadState_Unread forIndex:1];
        }
        else
        {
            sqlString = "select sessionId from im_message";
        }
        
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        
        while (SQLITE_ROW == [stmt step])
        {
            //会话的分组，群消息保存groupid 点对点保存对方voip
            NSString *sessionId = [stmt getString:0];
            
            [self __addMessage:sessionId intoMessages:messagesInfo];
        }
        [stmt reset];
        
        
        /*
         messagesInfo={
             group =     (
                     {
                         count = 11;
                         groupId = g8039074045376;
                     }
                 );
             user =     (
                            {
                             count = 15;
                             userId = 80390700000001;
                            },
                             {
                             count = 10;
                             userId = 80390700000002;
                             }
                        );
         }
         */

        NSMutableArray *userIdList = [NSMutableArray arrayWithCapacity:userArray.count];
        
        for (NSDictionary *userInfo in userArray)
        {
            [userIdList addObject:userInfo[@"userId"]];
        }
        
        [ALXMPPHelper getUsersFromVoips:userIdList block:^(NSArray *userXmppDBs, NSError *error) {
           
            if (userXmppDBs.count && userXmppDBs && !error)
            {
                for (UserXmppDB *xmppDB in userXmppDBs)
                {
                    for (NSMutableDictionary *user in userArray)
                    {
                        if ([user[@"userId"] isEqualToString:xmppDB.voipAccount])
                        {
                            [user setValue:[User objectWithoutDataWithObjectId:xmppDB.userId] forKey:@"user"];
                        }
                    }
                }
                
                NSLog(@"messagesInfo=%@",messagesInfo);
                
                if (resultBlock)
                {
                    resultBlock(messagesInfo,nil);
                }
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(nil,error);
                }
            }
            
        }];
        
        
//        return messagesInfo;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {

    }
}


- (NSArray *)getUnreadMessageOfSessionId:(NSString *)sessionId
{
    @try
    {
        const char* sqlString = "select msgid,sessionId,msgType,sender,isRead,imState,createDate,curDate,userData,msgContent,fileUrl,filePath,fileExt,duration from im_message where isRead = ? and sessionId = ? order by curDate";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindInt32:EReadState_Unread forIndex:1];
        [stmt bindString:sessionId forIndex:2];
        NSMutableArray * IMArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            IMMessageObj *msg = [[IMMessageObj alloc] init];
            
            int columnIndex = 0;
//            msg.msgid = [stmt getString:columnIndex]; columnIndex++;
//            msg.sessionId = [stmt getString:columnIndex]; columnIndex++;
//            msg.msgtype = [stmt getInt32:columnIndex]; columnIndex++;
//            msg.sender = [stmt getString:columnIndex]; columnIndex++;
//            msg.isRead = [stmt getInt32:columnIndex]; columnIndex++;
//            msg.imState = [stmt getInt32:columnIndex]; columnIndex++;
//            msg.dateCreated = [stmt getString:columnIndex]; columnIndex++;
//            msg.curDate = [stmt getString:columnIndex]; columnIndex++;
//            msg.userData = [stmt getString:columnIndex]; columnIndex++;
//            msg.content = [stmt getString:columnIndex]; columnIndex++;
//            msg.fileUrl = [stmt getString:columnIndex]; columnIndex++;
//            msg.filePath = [stmt getString:columnIndex]; columnIndex++;
//            msg.fileExt = [stmt getString:columnIndex]; columnIndex++;
//            msg.duration = [stmt getDouble:columnIndex];
 
            [IMArray addObject:msg];
            [msg release];
        }
        
        [stmt reset];
        return [IMArray autorelease];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    }
    return nil;
}

- (BOOL)updateUnreadStateOfSessionId:(NSString *)sessionId
{
    @try {
        const char * updateInfo = "update im_message set isRead = ? where sessionId = ?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        [stmt bindInt32:EReadState_IsRead forIndex:1];
        [stmt bindString:sessionId forIndex:2];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_message!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)updateFilePath:(NSString*)path andMsgid:(NSString*)msgid
{
    @try
    {
        const char * updateInfo = "update im_message set filePath = ? where msgid = ?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        [stmt bindString:path forIndex:1];
        [stmt bindString:msgid forIndex:2];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_message!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@", exception.name);
        NSLog(@"Exception reason=%@", exception.reason);
    }
    @finally 
    {
    }
    return NO;
}

- (BOOL)updateimState:(EMessageState)status OfmsgId:(NSString *)msgId
{
    @try {
        const char * updateInfo = "update im_message set imState = ? where msgid = ?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        [stmt bindInt32:status forIndex:1];
        [stmt bindString:msgId forIndex:2];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_message!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)updateGroupNoticeState:(EGroupNoticeOperation)state OfGroupId:(NSString *)groupid andPushMsgType:(EGroupNoticeType)msgType andWho:(NSString*)who
{
    @try {
        const char * updateInfo = "update im_groupnotice set state = ? where groupId=? and msgType=? and who=?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        [stmt bindInt32:state forIndex:1];
        [stmt bindString:groupid forIndex:2];
        [stmt bindInt32:msgType forIndex:3];
        [stmt bindString:who forIndex:4];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_groupnotice!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)updateUnreadGroupNotice
{
    @try {
        const char * updateInfo = "update im_groupnotice set isRead=? where isRead=?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        [stmt bindInt32:EReadState_IsRead forIndex:1];
        [stmt bindInt32:EReadState_Unread forIndex:2];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_message!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (NSInteger)getUnreadCountOfGroupNotice
{
    NSInteger count = 0;
    @try
    {
        const char * sqlString = "select count(*) from im_groupnotice where isRead = ?";
        static Statement * stmt = nil;
        if (nil == stmt)
        {
            stmt = [DBConnection statementWithQuery:sqlString];
            [stmt retain];
        }
        [stmt bindInt32:EReadState_Unread forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            count = [stmt getInt32:0];
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
        return count;
    }
}

- (BOOL)updateAllSendingToFailed
{
    @try {
        const char * updateInfo = "update im_message set imState=? where imState=?";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:updateInfo];
            [stmt retain];
        }
        [stmt bindInt32:EMessageState_SendFailed forIndex:1];
        [stmt bindInt32:EMessageState_Sending forIndex:2];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to update table im_message!");
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}
@end
