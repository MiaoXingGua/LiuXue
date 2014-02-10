//
//  CSqlite.h
//  WXS
//
//  Created by zili zhu on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "sqlite3.h"

@interface CSqlite  : NSObject
{
    sqlite3 *database;
}

-(void)openSqlite;

-(sqlite3_stmt*)runSql:(char*)sql;

-(sqlite3_stmt*)NSRunSql:(NSString*)sql;

-(BOOL)NSSendSql:(NSString*)sql;

@end
