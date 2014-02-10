//
//  ALIMMsgDB.m
//  Cloopen_DEMO
//
//  Created by Albert on 13-10-24.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALIMMsgDB.h"
#import "ALXMPPHelper.h"
#import "JSONKit.h"


#define TABEL_NAME_OF_SESSION @"session"

static ALIMMsgDB *defaultIMMsgDB = nil;

@interface ALIMMsgDB()
//@property (nonatomic, retain) FMDatabase *db;
@property (nonatomic, assign) FMDatabaseQueue *queue;
@property (nonatomic, retain) NSMutableArray *queueList;
@property (nonatomic, retain) NSMutableArray *temp;
@end

@implementation ALIMMsgDB

- (void)dealloc
{
//    [_db release];
    [_temp release];
    [_queueList release];
    [super dealloc];
}

+ (instancetype)defaultIMMsgDBWithVoip:(NSString *)theVoip
{
    if (!theVoip)
    {
        return defaultIMMsgDB;
    }
    
    if (!defaultIMMsgDB)
    {
        defaultIMMsgDB = [[ALIMMsgDB alloc] init];
        defaultIMMsgDB.queueList = [NSMutableArray array];
        defaultIMMsgDB.temp = [NSMutableArray array];
    }
    
    [defaultIMMsgDB openDBName:theVoip];
    
    return defaultIMMsgDB;
}

//打开数据库
- (BOOL)openDBName:(NSString *)dbName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:dbName];
//    NSLog(@"dbPath=%@",dbPath);
//    self.db = [FMDatabase databaseWithPath:dbPath] ;

    BOOL isExistQueue = NO;
    
    for (FMDatabaseQueue *temQueue in self.queueList)
    {
        if ([temQueue.path isEqualToString:dbPath])
        {
            isExistQueue = YES;
            self.queue = temQueue;
        }
    }
    
    if (!isExistQueue)
    {
        self.queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [self.queueList addObject:self.queue];
    }

    return [self.queue.path isEqualToString:dbPath];
}

//打开表
- (void)createTableName:(NSString *)tbName block:(void(^)(BOOL success))block
{
    if ([tbName isEqualToString:TABEL_NAME_OF_SESSION])
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (voip TEXT, updateAt DATETIME)",tbName];
        [self.queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:sql];
            if (block) block(success);
        }];
    }
    
    if (tbName.length>0)
    {
        //发给群的消息
        if (![self isChatMessage:tbName])
        {
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (msgid text, sender text, isRead bool, isSender bool, dateCreated text, curDate text, userData text, content text)",tbName];
            [self.queue inDatabase:^(FMDatabase *db) {
                BOOL success = [db executeUpdate:sql];
                if (block) block(success);
            }];
        }
        //发给个人的消息
        else
        {
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (msgid text, isRead bool, isSender bool, dateCreated text, curDate text, userData text, content text)",tbName];
            [self.queue inDatabase:^(FMDatabase *db) {
                BOOL success = [db executeUpdate:sql];
                if (block) block(success);
            }];
        }
    }
    else
    {
        NSLog(@"数据库表名不能为空!!!!!");
        if (block) block(NO);
    }
}

//搜索表名
- (void)getTablesName:(void(^)(NSArray *tablesNames))block
{
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray * tablesName = [NSMutableArray array];
        
        FMResultSet *rs = [db executeQuery:@"SELECT name FROM sqlite_master"];
        
        while ([rs next])
        {
            NSString *name = [rs stringForColumn:@"name"];
            if (![name isEqualToString:TABEL_NAME_OF_SESSION])
            {
                [tablesName addObject:name];
            } 
        }
        
        if (block) block(tablesName);
    }];
    
}

- (BOOL)isChatMessage:(NSString *)voip
{
    return ![[voip substringToIndex:1] isEqualToString:@"g"];
}

//判断消息是否存在
- (void)isMessageExistOfMsgid:(NSString*)msgid block:(void(^)(BOOL success))block
{
    if (!block) return;
    
    __block NSMutableArray *tbsName = [NSMutableArray array];
    
    [self getTablesName:^(NSArray *tablesName) {
            
        [tbsName addObjectsFromArray:tablesName];
    }];
    
    [self.queue inDatabase:^(FMDatabase *db) {
       
        BOOL isExist = NO;
        for (NSString *tbName in tbsName)
        {
            NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as count FROM '%@' WHERE msgid='%@'",tbName,msgid];
            
            int count = [db boolForQuery:sql];
            
            if (count != 0) isExist = YES;
        }
        
        block(isExist);
        
    }];
}

//添加聊天消息
- (void)insertIMMessage:(IMMessageObj*)imMsg block:(void(^)(BOOL success))block
{
    [self.temp removeAllObjects];
    [self.temp addObject:imMsg];
    
    if (![self openDBName:imMsg.my])
    {
        if (block) block(NO);
        return;
    }
    
    __block BOOL isExsit = YES;
    
    [self isMessageExistOfMsgid:imMsg.msgId block:^(BOOL success) {

        if (success)
        {
            if (block) block(NO);
        }
        else
        {
            isExsit = NO;
        }

    }];
    
    if (isExsit)
    {
        return;
    }

    NSString *tabelName = nil;
    
//    NSArray *alternativeTableName = @[imMsg.sender,imMsg.receiver];
    
    //是否是群组消息
    if (![self isChatMessage:imMsg.receiver])
    {
        tabelName = imMsg.receiver;
    }
    else
    {
        if (!imMsg.isSender)//也可以是 ：[imMsg.my isEqualToString:imMsg.receiver]
        {
            tabelName = imMsg.sender;
        }
        else
        {
            tabelName = imMsg.receiver;
            imMsg.isRead = YES;
        }
    }
    
    
    [self createTableName:tabelName block:^(BOOL success) {
        
        if (!success)
        {
            NSLog(@"BUG!!!!! 创建表失败!!!!");
            if (block) block(NO);
            return;
        }
        
     }];
    
    __block BOOL __success = NO;

     [self.queue inDatabase:^(FMDatabase *db) {
         
        NSString *insertSql = nil;

        NSMutableArray *arguments = [NSMutableArray array];
        //群组消息
        if (![self isChatMessage:tabelName])
        {
            insertSql = [NSString stringWithFormat:@"INSERT INTO '%@' (msgid, sender, isRead, isSender, dateCreated, curDate, userData, content) VALUES (?,?,?,?,?,?,?,?)",tabelName];
            
            if (imMsg.msgId) [arguments addObject:imMsg.msgId];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.sender) [arguments addObject:imMsg.sender];
            else [arguments addObject:[NSNull null]];
            
            [arguments addObject:[NSNumber numberWithBool:imMsg.isRead]];
            
            [arguments addObject:[NSNumber numberWithBool:imMsg.isSender]];
            
            if (imMsg.dateCreated) [arguments addObject:imMsg.dateCreated];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.curDate) [arguments addObject:imMsg.curDate];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.userData) [arguments addObject:imMsg.userData];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.content) [arguments addObject:imMsg.content];
            else [arguments addObject:[NSNull null]];
            
//            arguments = @[imMsg.msgId,imMsg.sender,[NSNumber numberWithBool:imMsg.isRead],imMsg.dateCreated,imMsg.curDate,imMsg.userData,imMsg.content];
            //                if (!arguments) return NO;
            
            __success = [db executeUpdate:insertSql withArgumentsInArray:arguments];
            
            if (block) block(__success);
        }
        //单人聊天
        else
        {
            insertSql = [NSString stringWithFormat:@"INSERT INTO '%@' (msgid, isRead, isSender, dateCreated, curDate, userData, content) VALUES (?,?,?,?,?,?,?)",tabelName];

            if (imMsg.msgId) [arguments addObject:imMsg.msgId];
            else [arguments addObject:[NSNull null]];
            
            [arguments addObject:[NSNumber numberWithBool:imMsg.isRead]];
            
            [arguments addObject:[NSNumber numberWithBool:imMsg.isSender]];
            
            if (imMsg.dateCreated) [arguments addObject:imMsg.dateCreated];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.curDate) [arguments addObject:imMsg.curDate];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.userData) [arguments addObject:imMsg.userData];
            else [arguments addObject:[NSNull null]];
            
            if (imMsg.content) [arguments addObject:imMsg.content];
            else [arguments addObject:[NSNull null]];
            
//            arguments = @[imMsg.msgId,[NSNumber numberWithBool:imMsg.isRead],imMsg.dateCreated,imMsg.curDate,imMsg.userData,imMsg.content];
            //                if (!arguments) return NO;
            
            __success =  [db executeUpdate:insertSql withArgumentsInArray:arguments];
            
            if (block) block(__success);
        }
     }];
    
    if ([self isChatMessage:tabelName] && __success)
    {
        [self _insertSession:tabelName];
    }
}

- (void)_insertSession:(NSString *)theVoip
{

    if (!theVoip || theVoip.length == 0) return;
    
    [self createTableName:TABEL_NAME_OF_SESSION block:^(BOOL success) {
        
        if (!success)
        {
            NSLog(@"BUG!!!!! 创建表失败!!!!");
            return;
        }
    }];
    
    
    BOOL isExist = [self isSessionExistOfVoip:theVoip];
    
    
        [self.queue inDatabase:^(FMDatabase *db) {
            
            NSString *insertSql = nil;
            
            if (!isExist)
            {
                insertSql = [NSString stringWithFormat:@"INSERT INTO '%@' (voip, updateAt) VALUES (?,?)",TABEL_NAME_OF_SESSION];
                
                [db executeUpdate:insertSql withArgumentsInArray:@[theVoip,[NSDate date]]];
            }
            else
            {
                insertSql = [NSString stringWithFormat:@"UPDATE '%@' SET updateAt=? WHERE voip=?",TABEL_NAME_OF_SESSION];
                
                [db executeUpdate:insertSql withArgumentsInArray:@[[NSDate date],theVoip]];
            }
            
        }];
    
}

//判断session是否存在
- (BOOL)isSessionExistOfVoip:(NSString *)theVoip
{
    __block BOOL __isExist = NO;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        
        NSString *tbName = @"session";
        
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as count FROM '%@' WHERE voip='%@'",tbName,theVoip];
        
        int count = [db boolForQuery:sql];
        
        if (count != 0) __isExist = YES;

    }];
    
    return __isExist;
}

//获取最近联系人列表
- (void)getLinkerOfRecentWithUserVoip:(NSString *)theVoip
                                block:(void (^)(NSArray *likers, NSError *error))resultBlock
{
    
    if (![self openDBName:theVoip])
    {
        if (resultBlock) resultBlock(nil,nil);
        return ;
    }
    
    NSString *orderSql = [NSString stringWithFormat:@"ORDER BY 'update' DESC"];
    
    NSString *unit = [NSString stringWithFormat:@"rowid IN (SELECT MIN(rowid) FROM '%@' GROUP BY voip)",TABEL_NAME_OF_SESSION];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT voip FROM '%@' WHERE %@ %@",TABEL_NAME_OF_SESSION,unit,orderSql];
    
    [self.queue inDatabase:^(FMDatabase *db) {
       
        NSMutableArray *likers = [NSMutableArray array];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        NSMutableArray *voips = [NSMutableArray array];
        
        while ([rs next])
        {
            NSString *voip = [rs stringForColumn:@"voip"];
            [voips addObject:voip];
        }
        
        [ALXMPPHelper getUsersFromVoips:voips block:^(NSArray *userXmppDBs, NSError *error) {
            
            if (!error)
            {
                for (int i=0; i<voips.count; i++)
                {
                    for (UserXmppDB *xmppDB in userXmppDBs)
                    {
                        if ([xmppDB.voipAccount isEqualToString:voips[i]])
                        {
                            [likers addObject:[User objectWithoutDataWithObjectId:xmppDB.userId]];
                        }
                    }
                }
                
                if (resultBlock)
                {
                    resultBlock(likers,nil);
                }
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(likers,error);
                }
            }
        }];
    }];
}

//删除最近联系人
- (void)delLinkerOfRecentWithUserVoip:(NSString *)theVoip
                        andLinkerVoip:(NSString *)theLinkerVoip
                                block:(void(^)(BOOL success))resultBlock
{
    if (![self openDBName:theVoip])
    {
        if (resultBlock) resultBlock(NO);
        return ;
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE voip = %@",TABEL_NAME_OF_SESSION,theLinkerVoip];
        
        BOOL success = [db executeUpdate:sql];
        if (resultBlock) resultBlock(success);
        
    }];
}

- (void)_getMessageCountWithUserVoip:(NSString *)theVoip
                                 SQL:(NSArray *)sqlArr
                               block:(void(^)(NSInteger messagesCount, NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(0, nil);
        return;
    }
    
    if (![self openDBName:theVoip])
    {
        if (resultBlock) resultBlock(0,nil);
        return ;
    }
    
    [self.queue inDatabase:^(FMDatabase *db){
        
        int msgCount = 0;
        
        for (NSString *sql in sqlArr)
        {
            FMResultSet *rs = [db executeQuery:sql];
            
            while ([rs next])
            {
                msgCount += [rs intForColumn:@"count"];
            }
            
            if (resultBlock) resultBlock(msgCount,nil);
        }
        
    }];
}

- (void)_getMessageWithUserVoip:(NSString *)theVoip
                            SQL:(NSArray *)sqlArr
                    isOnlyCount:(BOOL)isOnlyCount
                          block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(nil, nil);
        return;
    }
    
    if (![self openDBName:theVoip])
    {
        if (resultBlock) resultBlock(nil,nil);
        return ;
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *chatMessages = [NSMutableArray array];
        NSMutableArray *groupMessages = [NSMutableArray array];
        
        for (NSDictionary *sqlDic in sqlArr)
        {
            NSString *sql = sqlDic[@"sql"];
            
            FMResultSet *rs = [db executeQuery:sql];
            
            NSMutableArray *messages = [NSMutableArray array];
            
            while ([rs next])
            {
                //                    NSMutableDictionary * mess = [NSMutableDictionary dictionary];
                //                    for (int i=0; i<[rs columnCount]; i++)
                //                    {
                //                        [mess setValue:[rs stringForColumn:[rs columnNameForIndex:i]] forKey:[rs columnNameForIndex:i]];
                //                    }
                if (!isOnlyCount)
                {
                    NSString *msgid = [rs stringForColumn:@"msgid"];
                    BOOL isRead = [rs boolForColumn:@"isRead"];
                    NSString *dateCreadted = [rs stringForColumn:@"dateCreadted"];
                    NSString *curDate = [rs stringForColumn:@"curDate"];
                    NSDictionary *userData = [[rs stringForColumn:@"userData"] objectFromJSONString];
                    NSDictionary *content = [[rs stringForColumn:@"content"] objectFromJSONString];
                    BOOL isSender = [rs boolForColumn:@"isSender"];
                    NSString *sender = [rs stringForColumn:@"sender"];
                    
                    NSMutableDictionary * mess = [NSMutableDictionary dictionary];
                    [mess setValue:msgid forKey:@"msgid"];
                    [mess setValue:[NSNumber numberWithBool:isRead] forKey:@"isRead"];
                    [mess setValue:dateCreadted forKey:@"dateCreadted"];
                    [mess setValue:curDate forKey:@"curDate"];
                    
                    for (NSString *key in userData.allKeys)
                    {
                        [mess setValue:userData[key] forKey:key];
                    }
                    
                    for (NSString *key in content.allKeys)
                    {
                        [mess setValue:content[key] forKey:key];
                    }
                    
                    [mess setValue:sender forKey:@"sender"];
                    [mess setValue:[NSNumber numberWithBool:isSender] forKey:@"isSender"];
                    
                    [messages addObject:mess];
                }
                else
                {
                    int count = [rs intForColumn:@"count"];
//                    NSString *sender = [rs stringForColumn:@"sender"];
                    
                    NSMutableDictionary * countDic = [NSMutableDictionary dictionary];
                    [countDic setValue:[NSNumber numberWithInt:count] forKey:@"count"];
//                    [countDic setValue:sender forKey:@"sender"];
                    [messages addObject:countDic];
                    
                }
                
                
            }
            
            if (messages.count == 0)
            {
                continue;
            }
            
            NSString *tbName = sqlDic[@"tableName"];
            
            //group
            if (![self isChatMessage:tbName])
            {
                [groupMessages addObject:@{@"user":tbName,@"message":messages}];
            }
            //chat
            else
            {
                [ALXMPPHelper getUserFromVoip:tbName block:^(UserXmppDB *userXmppDB, NSError *error) {
                    
                    User *user = [User objectWithoutDataWithObjectId:userXmppDB.userId];
                    
                    [chatMessages addObject:@{@"user":user,@"message":messages}];
                    
                }];
            }
        }
        
        if (resultBlock)
        {
            resultBlock(@{@"chat":chatMessages,@"group":groupMessages},nil);
        }
    }];
}

- (NSString *)_notContainedMsgSQL:(NSArray *)theMsgsId
{
    NSMutableString *notCsql = [NSMutableString string];
    
    if (theMsgsId && theMsgsId.count)
    {
        [notCsql appendFormat:@" WHERE msgid NOT IN ("];
        
        for (int i = 0; i < theMsgsId.count; ++i)
        {
            NSString *msgid = theMsgsId[i];
            [notCsql appendFormat:@"'%@'",msgid];
            
            if (i == theMsgsId.count-1)
            {
                [notCsql appendFormat:@") "];
            }
            else
            {
                [notCsql appendFormat:@", "];
            }
        }
    }
    
    return notCsql;
}

- (NSString *)_orderBySql
{
    return [NSString stringWithFormat:@"ORDER BY rowid DESC limit 0,%d",PERPAGE_OF_MESSAGE];
}

//获得全部聊天记录数
- (void)getALLMessageWithUserVoip:(NSString *)theVoip
                   notContainedIn:(NSArray *)theMsgsId
                            block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(nil, nil);
        return;
    }
    
    __block NSMutableArray *tbsName = [NSMutableArray array];
    
    [self getTablesName:^(NSArray *tablesName){
        
        [tbsName addObjectsFromArray:tablesName];
        
    }];
    
    NSString *notCsql = [self _notContainedMsgSQL:theMsgsId];
    
    NSString *orderSql = [self _orderBySql];
    
    NSMutableArray *sqlArr = [NSMutableArray arrayWithCapacity:tbsName.count];
    
    for (NSString *tbName in tbsName)
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' %@ %@",tbName,notCsql,orderSql];
        
        [sqlArr addObject:@{@"sql":sql,@"tableName":tbName}];
    }
    [self _getMessageWithUserVoip:theVoip SQL:sqlArr isOnlyCount:NO block:resultBlock];
}

//获得全部未读的聊天记录数
- (void)getALLUnreadMessageWithUserVoip:(NSString *)theVoip
                         notContainedIn:(NSArray *)theMsgsId
                                  block:(void(^)(NSDictionary *messages ,NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(nil, nil);
        return;
    }
    
    __block NSMutableArray *tbsName = [NSMutableArray array];
    
    [self getTablesName:^(NSArray *tablesNames){
        
        [tbsName addObjectsFromArray:tablesNames];
        
    }];
    
    NSString * notCsql = [self _notContainedMsgSQL:theMsgsId];
    NSString *orderSql = [self _orderBySql];

    NSMutableArray *sqlArr = [NSMutableArray arrayWithCapacity:tbsName.count];
    
    for (NSString *tbName in tbsName)
    {
        NSString *sql = @"";

        if (notCsql.length > 0)
        {
            sql = [NSString stringWithFormat:@"SELECT * FROM '%@' %@ isRead=%@ %@",tbName,notCsql,@0,orderSql];
        }
        else
        {
            sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE isRead=%@ %@",tbName,@0,orderSql];
        }
        
        [sqlArr addObject:@{@"sql":sql,@"tableName":tbName}];
    }
    
    [self _getMessageWithUserVoip:theVoip SQL:sqlArr isOnlyCount:NO block:resultBlock];
}

//获得全部未读的聊天记录数
- (void)getALLUnreadMessageCountWithUserVoip:(NSString *)theVoip
                                       block:(void(^)(NSInteger messagesCount, NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(0, nil);
        return;
    }
    
    __block NSMutableArray *tbsName = [NSMutableArray array];
    
    [self getTablesName:^(NSArray *tablesNames){
        
//        [tbsName addObjectsFromArray:tablesName];
        //只读取个人聊天未读消息数，不读取群组的
        for (NSString *tbName in tablesNames) {
            if ([self isChatMessage:tbName])
                [tbsName addObject:tbName];
        }
        
    }];
    
    NSMutableArray *sqlArr = [NSMutableArray arrayWithCapacity:tbsName.count];
    
    for (NSString *tbName in tbsName)
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as count FROM '%@' WHERE isRead=%@",tbName,@0];
        
        [sqlArr addObject:sql];
    }
    
    [self _getMessageCountWithUserVoip:theVoip SQL:sqlArr block:resultBlock];
}

- (void)getALLUnreadMessageWithUserVoip:(NSString *)theVoip
                                        block:(void(^)(NSDictionary *messages, NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(nil, nil);
        return;
    }
    
    __block NSMutableArray *tbsName = [NSMutableArray array];
    
    [self getTablesName:^(NSArray *tablesName){
        
        [tbsName addObjectsFromArray:tablesName];
        
    }];
    
    NSMutableArray *sqlArr = [NSMutableArray arrayWithCapacity:tbsName.count];
    
    for (NSString *tbName in tbsName)
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as count FROM '%@' WHERE isRead=%@",tbName,@0];
        
        [sqlArr addObject:@{@"sql":sql,@"tableName":tbName}];
    }
    
    [self _getMessageWithUserVoip:theVoip SQL:sqlArr isOnlyCount:YES block:resultBlock];
}

//获取与某用户的聊天记录
- (void)getUserMessageWithUserVoip:(NSString *)theVoip
                              user:(User *)theUser
                    notContainedIn:(NSArray *)theMsgsId
                             block:(void (^)(NSDictionary *messages, NSError *error))resultBlock
{
    NSString *notCsql = [self _notContainedMsgSQL:theMsgsId];
    NSString *orderSql = [self _orderBySql];
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        NSString *tbName = userXmppDB.voipAccount;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' %@ %@",tbName,notCsql,orderSql];
        
        [self _getMessageWithUserVoip:theVoip SQL:@[@{@"sql":sql,@"tableName":tbName}] isOnlyCount:NO block:resultBlock];
    }];
}

//获取与某用户的未读聊天记录数
- (void)getUserUnreadMessageCountWithUserVoip:(NSString *)theVoip
                                         user:(User *)theUser
                                        block:(void (^)(NSInteger messagesCount, NSError *error))resultBlock
{
    if (!theVoip)
    {
        if (resultBlock) resultBlock(0, nil);
        return;
    }
    
    __block NSMutableArray *tbsName = [NSMutableArray array];
    
    [self getTablesName:^(NSArray *tablesName){
        
        [tbsName addObjectsFromArray:tablesName];
        
    }];
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        NSString *tbName = userXmppDB.voipAccount;
        
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as count FROM '%@' WHERE isRead=%@",tbName,@0];
    
        [self _getMessageCountWithUserVoip:theVoip SQL:@[sql] block:resultBlock];
    }];
}

//获取与某用户的未读聊天记录
- (void)getUserUnreadMessageWithUserVoip:(NSString *)theVoip
                                    user:(User *)theUser
                          notContainedIn:(NSArray *)theMsgsId
                                   block:(void (^)(NSDictionary *messages, NSError *error))resultBlock
{
    NSString *notCsql = [self _notContainedMsgSQL:theMsgsId];
    NSString *orderSql = [self _orderBySql];
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        NSString *tbName = userXmppDB.voipAccount;
        
        NSString *sql = @"";
        
        if (notCsql.length > 0)
        {
            sql = [NSString stringWithFormat:@"SELECT * FROM '%@' %@ isRead=%@ %@",tbName,notCsql,@0,orderSql];
        }
        else
        {
            sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE isRead=%@ %@",tbName,@0,orderSql];
        }
        
        
        [self _getMessageWithUserVoip:theVoip SQL:@[@{@"sql":sql,@"tableName":tbName}] isOnlyCount:NO block:resultBlock];
    }];
}

//更改会话中未读状态为已读
- (void)updateUnreadStateOfUserVoip:(NSString *)theVoip
                               user:(User *)theUser
                              block:(void (^)(BOOL succeeded, NSError *error))resultBlock
{
    if (![self openDBName:theVoip])
    {
        if (resultBlock) resultBlock(NO,nil);
        return ;
    }
    
    [ALXMPPHelper getVoipFromUser:theUser block:^(UserXmppDB *userXmppDB, NSError *error) {
        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            NSString *tbName = userXmppDB.voipAccount;
            NSString *sql = [NSString stringWithFormat:@"UPDATE '%@' SET isRead = %@",tbName,@1];
            [db executeUpdate:sql];
            
           if (resultBlock) resultBlock(YES,error);
        }];
    }];
}
@end
