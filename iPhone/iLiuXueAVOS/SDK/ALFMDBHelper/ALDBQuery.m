//
//  ALDBQuery.m
//  FMDB_DEMO
//
//  Created by Albert on 13-8-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALDBQuery.h"
#import "ALFMDBHelper.h"


@interface ALDBQuery ()

//约束
//@{@"key":约束关键字  ,  @"value":约束值    ,@"type":约束方式（大于、等于、小于、like等）}
//[self.basicConstraints addObject:@{@"key":@"",@"value":@"",@"type":@""}];
@property (nonatomic, retain) NSMutableArray *basicConstraints;

@property (nonatomic, assign) BOOL isLimitOne;
//排序
@property (nonatomic, retain) NSMutableArray *orders;

@end

const static NSString *compareStr = @"<>=<=";

@implementation ALDBQuery

- (void)dealloc
{
    [_basicConstraints release];
    [_orders release];
    [_className release];
    [super dealloc];
}

- (void)setClassName:(NSString *)className
{
    [_className release];
    _className = [className retain];
}

+ (ALDBQuery *)queryWithClassName:(NSString *)className
{
    ALDBQuery *query = [[[ALDBQuery alloc] init] autorelease];
    query.basicConstraints = [NSMutableArray array];
    query.orders = [NSMutableArray array];
    query.className = className;

    return query;
}

#pragma mark - 基本约束
//select * from table1

- (id)_objectFromObject:(id)object
{
    if ([object isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"'%@'",object];
    }
    
    return object;
}

//where colum1 is not null
- (void)whereKeyExists:(NSString *)key
{
    if (key)
    {
        key = [self _objectFromObject:key];
        [self.basicConstraints addObject:@{@"key":key,@"value":@"NOT NULL",@"type":@"IS"}];
    }
}

//where colum1 is null
- (void)whereKeyDoesNotExist:(NSString *)key
{
    if (key)
    {
        key = [self _objectFromObject:key];
        [self.basicConstraints addObject:@{@"key":key,@"value":@"NULL",@"type":@"IS"}];
    }
}

//where colum1 is null and objectid=11
- (void)whereKey:(NSString *)key equalTo:(id)object
{
    if (key && object)
    {
        object = [self _objectFromObject:object];
        [self.basicConstraints addObject:@{@"key":key,@"value":object,@"type":@"="}];
    }
}

//where objectid<11
- (void)whereKey:(NSString *)key lessThan:(id)object
{
    if (key && object)
    {
        object = [self _objectFromObject:object];
        [self.basicConstraints addObject:@{@"key":key,@"value":object,@"type":@"<"}];
    }
}

//where objectid<=11
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object
{
    if (key && object)
    {
        object = [self _objectFromObject:object];
        [self.basicConstraints addObject:@{@"key":key,@"value":object,@"type":@"<="}];
    }
}

//where objectid>11
- (void)whereKey:(NSString *)key greaterThan:(id)object
{
    if (key && object)
    {
        object = [self _objectFromObject:object];
        [self.basicConstraints addObject:@{@"key":key,@"value":object,@"type":@">"}];
    }
}

//where objectid>=11
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object
{
    if (key && object)
    {
        object = [self _objectFromObject:object];
        [self.basicConstraints addObject:@{@"key":key,@"value":object,@"type":@">="}];
    }
}

//where objectid<>11
- (void)whereKey:(NSString *)key notEqualTo:(id)object
{
    if (key && object)
    {
        object = [self _objectFromObject:object];
        [self.basicConstraints addObject:@{@"key":key,@"value":object,@"type":@"<>"}];
    }
}

//where objectid = 11 OR objectid = 10
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array
{
    if (key && array.count)
        [self.basicConstraints addObject:@{@"key":key,@"value":array,@"type":@"=OR"}];
}

//where objectid <> 11 AND objectid <> 10
- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array
{
    if (key && array.count)
        [self.basicConstraints addObject:@{@"key":key,@"value":array,@"type":@"<>AND"}];
}

//SELECT * FROM student where objectid = 1 AND name = 'liujia'
//字符串要加''
- (void)whereKey:(NSString *)key containsAllObjectsInArray:(NSArray *)array
{
    if (key && array.count)
        [self.basicConstraints addObject:@{@"key":key,@"value":array,@"type":@"=AND"}];
}

#pragma mark - 排序

//FROM Orders ORDER BY Company DESC, OrderNumber ASC
- (void)orderByAscending:(NSString *)key
{
    if (key)
        [self.orders addObject:@{@"key":key,@"value":[NSNull null],@"type":@"Master_ASC"}];
}

/*!
 按key升序排序结果
 */
- (void)addAscendingOrder:(NSString *)key
{
    if (key)
        [self.orders addObject:@{@"key":key,@"value":[NSNull null],@"type":@"ASC"}];
}

/*!
 按key降序排序结果(优先级最高)
 */
- (void)orderByDescending:(NSString *)key
{
    if (key)
        [self.orders addObject:@{@"key":key,@"value":[NSNull null],@"type":@"Master_DESC"}];
}
/*!
 按key降序排序结果
 */
- (void)addDescendingOrder:(NSString *)key
{
    if (key)
        [self.orders addObject:@{@"key":key,@"value":[NSNull null],@"type":@"DESC"}];
}

/*!
 按sortDescriptor排序结果
 */
- (void)orderBySortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    
}

/*!
 
 */
- (void)orderBySortDescriptors:(NSArray *)sortDescriptors
{
    
}

#pragma mark - 查询
- (NSString *)getQuerySQLString
{
    NSMutableString *sqlStr = [NSMutableString string];
    
    [sqlStr appendFormat:@"SELECT * FROM %@ ",self.className];

    
    //排序
    if (self.orders.count)
    {
        
        [sqlStr appendFormat:@"ORDER BY "];
        
        int i = 0;
        for (NSDictionary *sql in self.orders)
        {
            NSString *sqlType = sql[@"type"];
            NSString *column = sql[@"key"];
            
            if ([sqlType isEqualToString:@"Master_ASC"])
            {
                [sqlStr appendFormat:@"%@ ASC ,",column];
            }
            else if ([sqlType isEqualToString:@"Master_DESC"])
            {
                [sqlStr appendFormat:@"%@ DESC ,",column];
            }
        }
        
        for (NSDictionary *sql in self.orders)
        {
            NSString *sqlType = sql[@"type"];
            NSString *column = sql[@"key"];
            
            if ([sqlType isEqualToString:@"ASC"])
            {
                [sqlStr appendFormat:@"%@ ASC ,",column];
            }
            else if ([sqlType isEqualToString:@"DESC"])
            {
                [sqlStr appendFormat:@"%@ DESC ,",column];
            }
        }
        
        if (self.orders.count) [sqlStr deleteCharactersInRange:NSMakeRange(sqlStr.length - 1, 1)];//删,
    }
    
    
    //约束
    if (self.basicConstraints.count)
    {
        [sqlStr appendFormat:@"WHERE "];
        
        int i = 0;
        for (NSDictionary *sql in self.basicConstraints)
        {
            
            NSString *sqlType = sql[@"type"];
            
            NSLog(@"###=%@",NSStringFromRange([sqlType rangeOfString:@"<>=<="]));
            
            if ([sqlType isEqualToString:@"IS"])
            {
                NSString *column = sql[@"key"];
                NSString *value = sql[@"value"];
                
                [sqlStr appendFormat:@"%@ IS %@ ",column,value];
            }
            else if ([compareStr rangeOfString:sqlType].location != NSNotFound)
            {
                NSString *column = sql[@"key"];
                NSString *value = sql[@"value"];
                
                [sqlStr appendFormat:@"%@ %@ %@ ",column,sqlType,value];
            }
            else if ([sqlType isEqualToString:@"=OR"])
            {
                NSArray *values = sql[@"value"];
                NSString *column = sql[@"key"];
                
                int j = 0;
                for (id value in values)
                {
                    [sqlStr appendFormat:@"%@ = %@ ",column,value];
                    
                    if (++j < values.count-1)
                    {
                        [sqlStr appendFormat:@"OR "];
                    }
                }
            }
            else if ([sqlType isEqualToString:@"<>AND"])
            {
                NSArray *values = sql[@"value"];
                NSString *column = sql[@"key"];
                
                int j = 0;
                for (id value in values)
                {
                    [sqlStr appendFormat:@"%@ <> %@ ",column,value];
                    
                    if (++j < values.count-1)
                    {
                        [sqlStr appendFormat:@"AND "];
                    }
                }
            }
            else if ([sqlType isEqualToString:@"=AND"])
            {
                NSArray *values = sql[@"value"];
                NSString *column = sql[@"key"];
                
                int j = 0;
                for (id value in values)
                {
                    [sqlStr appendFormat:@"%@ = %@ ",column,value];
                    
                    if (++j < values.count-1)
                    {
                        [sqlStr appendFormat:@"AND "];
                    }
                }
            }
            
            if (++i < self.basicConstraints.count-1)
            {
                [sqlStr appendFormat:@"AND "];
            }
            
        }
    }
    
    //返回数据条数
    if (self.isLimitOne)
    {
        [sqlStr appendFormat:@"LIMIT 1"];
    }
    else if (self.limit > 0)
    {
        [sqlStr appendFormat:@"LIMIT %d",self.limit];
    }

    
    return sqlStr;
}

- (NSArray *)findObjects
{
    NSMutableArray *objs = [NSMutableArray array];
    
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;
    if ([db open])
    {
        //  NSLog(@"querySQLStr == %@",[self getQuerySQLString]);
        FMResultSet *rs = [db executeQuery:[self getQuerySQLString]];
        
        Class myClass = NSClassFromString(self.className);
        
        while ([rs next])
        {
            ALDBObject *obj = [myClass objectWithClassName:self.className];
            [obj getSelfWithRS:rs];
            [objs addObject:obj];
        }
        [rs close];
    }
    
    return objs;
}

- (ALDBObject *)getFirstObject
{
    NSMutableArray *objs = [NSMutableArray array];
    
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;
    if ([db open])
    {
        //  NSLog(@"querySQLStr == %@",[self getQuerySQLString]);
        
        self.isLimitOne = YES;
        
        NSString *sql = [self getQuerySQLString];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        Class myClass = NSClassFromString(self.className);
        
        while ([rs next])
        {
            ALDBObject *obj = [myClass objectWithClassName:self.className];
            [obj getSelfWithRS:rs];
            [objs addObject:obj];
        }
        
        [rs close];
    }
    
    self.isLimitOne = NO;
    
    if (objs.count)
    {
        return objs[0];
    }
    else
    {
        return nil;
    }
    
}

- (NSInteger)countObjects
{
    return -111111;
}

@end
