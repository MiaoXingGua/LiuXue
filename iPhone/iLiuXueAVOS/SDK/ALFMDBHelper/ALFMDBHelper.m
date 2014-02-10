//
//  ALFMDBHelper.m
//  FMDB_DEMO
//
//  Created by Albert on 13-8-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALFMDBHelper.h"

static ALFMDBHelper *helper = nil;

@implementation ALFMDBHelper

- (void)dealloc
{
    [_db release];
    [_databasePath release];
    [super dealloc];
}

+ (ALFMDBHelper *)shareDBHelper
{
    if (!helper) {
        helper = [[ALFMDBHelper alloc] init];
    }
    return helper;
}

+ (NSString *)databaseFilePath:(NSString *)theDBName
{
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [filePath objectAtIndex:0];
    NSString *databasePath = [documentPath stringByAppendingPathComponent:theDBName];
    
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
	}
    return databasePath;
}


- (BOOL)setApplicationDataBaseName:(NSString *)theDBName
{
    NSString *databasePath = [ALFMDBHelper databaseFilePath:theDBName];
    [ALFMDBHelper shareDBHelper].databasePath = databasePath;
    [ALFMDBHelper shareDBHelper].db = [FMDatabase databaseWithPath:databasePath];
    return databasePath ? YES: NO;
}

//技巧：：readonly + set方法
- (void)setDatabasePath:(NSString *)databasePath
{
    [_databasePath release];
    _databasePath = [databasePath retain];
}

- (void)setDb:(FMDatabase *)db
{
    [_db release];
    _db = [db retain];
}

-(void)dropAllTable
{
    FMResultSet* set = [self.db executeQuery:@"SELECT NAME FROME SQLITE_MASTER WHERE TYPE='table'"];
    NSMutableArray* dropTables = [NSMutableArray arrayWithCapacity:0];
    while ([set next]) {
        [dropTables addObject:[set stringForColumnIndex:0]];
    }
    [set close];

    for (NSString* tableName in dropTables) {
        NSString* dropTable = [NSString stringWithFormat:@"drop table %@",tableName];
        [self.db executeUpdate:dropTable];
    }
    
    
//    [self.tableManager clearTableInfos];
}
@end
