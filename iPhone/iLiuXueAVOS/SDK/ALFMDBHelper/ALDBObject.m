 //
//  ALDBObject.m
//  FMDB_DEMO
//
//  Created by Albert on 13-8-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALDBObject.h"
#import "ALFMDBHelper.h"
#import <objc/runtime.h> 

#define LKSQLText @"text"
#define LKSQLInt @"integer"
#define LKSQLDouble @"float"
#define LKSQLBlob @"blob"
#define LKSQLBool @"bool"
#define LKSQLDatetime @"DATETIME"
#define LKSQLNull @"null"
#define LKSQLIntPrimaryKey(a) [NSString stringWithFormat:@"PRIMARY KEY (%@)",a]

//子类化支持的所有数据类型
const static NSString *normaltypestring = @"floatdoublelongcharshort";
const static NSString *blobtypestring = @"NSDataUIImageNSArrayNSDictionary";
const static NSString *datetypestring = @"NSDate";
const static NSString *privateProperty = @"propertys KVCs className updatedAt createdAt";


@interface ALDBObject ()

//属性
@property (nonatomic ,retain) NSMutableArray *propertys;


//KVC
@property (nonatomic ,retain) NSMutableArray *KVCs;
//@property (nonatomic, retain) NSMutableString *parameterStr;
//@property (nonatomic, retain) NSMutableDictionary *propertys;  //绑定的model属性集合
//@property (nonatomic, retain) NSMutableArray* columeNames;  //列名
//@property (nonatomic, retain) NSMutableArray* columeTypes;  //列类型
//@property (nonatomic, retain) NSMutableArray* columeValues; //列的值

//KVC
//@property(retain,nonatomic)NSMutableArray* keys;
//@property(retain,nonatomic)NSMutableArray* values;
//@property(retain,nonatomic)NSMutableArray* keyTypes;
@end

@implementation ALDBObject
{
    NSDate *lastUpdateTime;
}

@synthesize className=_className;

#pragma mark - 初始化

- (void)dealloc
{
    [_propertys release];
    [_KVCs release];
    [_className release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.propertys = [NSMutableArray array];
        self.KVCs = [NSMutableArray array];
    }
    return self;
}

+ (ALDBObject *)objectWithClassName:(NSString *)className
{
    return [self.class objectWithoutDataWithClassName:className objectId:0];
}

+ (ALDBObject *)objectWithoutDataWithClassName:(NSString *)className
                                      objectId:(unsigned int)objectId
{
    ALDBObject *bself = [[[self.class alloc] init] autorelease];
    bself.className = className;
    bself.objectId = objectId;
    
    [bself createTableWithCallback:nil];
    
    return bself;
}

#pragma mark - 属性
- (void)setObjectId:(int)objectId
{
    _objectId = objectId;
}

- (void)setCreatedAt:(NSDate *)createdAt
{
    _createdAt = createdAt;
}

- (void)setUpdatedAt:(NSDate *)updatedAt
{
    _updatedAt = updatedAt;
}

- (void)setClassName:(NSString *)className
{
    [_className release];
    _className = [className retain];
}

- (NSString *)className
{
    return _className;
}


#pragma mark - KVC设置字段
- (void)setValue:(id)value forKey:(NSString *)key
{
    NSString *temValueType = NSStringFromClass([value class]);
    NSString *temName = key;

    id temValue = [value retain];

    
    id oldValue = [self valueForKey:key];
    
    if (oldValue)
    {    
        [self updateValue:value forKey:key];
        return;
    }
    
    if (temName && temValue && temValueType)
    {
        NSMutableDictionary *prop = [NSMutableDictionary dictionaryWithCapacity:3];
        [prop setValue:temName forKey:@"name"];
        [prop setValue:temValue forKey:@"value"];
        [prop setValue:temValueType forKey:@"type"];
        [self.KVCs addObject:prop];
    }
    
    [temValue release];
}

- (id)valueForKey:(NSString *)key
{
    for (NSDictionary *com in self.KVCs)
    {
        NSString *name = com[@"name"];
        if ([name isEqualToString:key]) return com[@"value"];
    }
    return nil;
}

- (void)updateValue:(id)value forKey:(NSString *)key
{
    for (NSMutableDictionary *com in self.KVCs)
    {
        NSString *name = com[@"name"];
        if ([name isEqualToString:key])
        {
            [com setValue:value forKey:@"value"];
        }
    }
}


#pragma mark - 数据库
//数据库 与 oc 数据类型转换
#pragma mark -- SQL语句
- (NSString *)toDBType:(NSString *)type
{
    if([type isEqualToString:@"int"])
    {
        return LKSQLInt;
    }
    //BUG!!!
    if ([type isEqualToString:@"char"])
    {
        return LKSQLBool;
    }
    
    if ([normaltypestring rangeOfString:type].location != NSNotFound)
    {
        return LKSQLDouble;
    }
    
    if ([datetypestring rangeOfString:type].location != NSNotFound)
    {
        return LKSQLDatetime;
    }
    
    if ([blobtypestring rangeOfString:type].location != NSNotFound)
    {
        return LKSQLBlob;
    }
    return LKSQLText;
}

- (int)toOCType:(NSString *)type value:(id)value
{
//    NSNumber;
//    NSDecimalNumber;
    if([type isEqualToString:@"int"])
    {
        return [value intValue];
    }
    //BUG!!!
    if ([type isEqualToString:@"BOOL"])
    {
        return [value boolValue];
    }
    //floatdoublelongcharshort
    if ([type isEqualToString:@"float"])
    {
        return [value floatValue];
    }
    if ([type isEqualToString:@"double"])
    {
        return [value doubleValue];
    }
    if ([type isEqualToString:@"long"])
    {
        return [value longValue];
    }
    if ([type isEqualToString:@"char"])
    {
        return [value charValue];
    }
    if ([type isEqualToString:@"short"])
    {
        return [value shortValue];
    }
    return value;
}



- (NSString *)getCreateTableSQLString
{
//    NSString* createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ )", self.className, [self getCreateString]];
    
    NSMutableString* pars = [NSMutableString string];
    
    [pars appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (", self.className];
    
    for (NSDictionary *kvc in self.KVCs)
    {
        NSString *columeName = kvc[@"name"];
//        id columeValue = kvc[@"value"];
        NSString *columeType = kvc[@"type"];
        
        [pars appendFormat:@"%@ %@, ",columeName,[self toDBType:columeType]];
    }
    
    //子类化
    if ([self respondsToSelector:@selector(getSubclassCreateTableSQLStringWithString:)])
        [self getSubclassCreateTableSQLStringWithString:pars];
    
    [pars appendString:@"objectId INTEGER, "];
    [pars appendString:@"updatedAt DATETIME, "];
    [pars appendString:@"createdAt DATETIME, "];
    [pars appendString:LKSQLIntPrimaryKey(@"objectId")];
    
    [pars appendString:@")"];
    
    return pars;
}

- (NSString *)getUpdateSQLString
{
    NSMutableString* updateStr = [NSMutableString stringWithCapacity:0];
    
    for (NSDictionary *kvc in self.KVCs)
    {
        NSString *columeName = kvc[@"name"];

        [updateStr appendFormat:@"%@ = ?,",columeName];
    }
//    [updateKey deleteCharactersInRange:NSMakeRange(updateKey.length - 1, 1)];
    if ([self respondsToSelector:@selector(getSubclassUpdateSQLStringWithString:)])
        [self getSubclassUpdateSQLStringWithString:updateStr];
    
    NSString* updateSQLStr = [NSString stringWithFormat:@"UPDATE %@ SET %@ updatedAt=? WHERE objectId = ?",self.className,updateStr];
    
    return updateSQLStr;
}

- (NSArray *)getUpdateSQLArguments
{
    NSDate* date = [NSDate date];
    
//    NSMutableString* updateKey = [NSMutableString stringWithCapacity:0];
    
    NSMutableArray* updateValues = [NSMutableArray arrayWithCapacity:self.KVCs.count];
    
    for (NSDictionary *kvc in self.KVCs)
    {
        id columeValue = kvc[@"value"];

        [updateValues addObject:columeValue];
    }
    
    if ([self respondsToSelector:@selector(getSubclassUpdateSQLArguments:)])
        [self getSubclassUpdateSQLArguments:updateValues];
    
    [lastUpdateTime release];
    lastUpdateTime = [date retain];
    
    [updateValues addObject:date];
    [updateValues addObject:[NSNumber numberWithInt:self.objectId]];
    
    return updateValues;
}

- (NSString *)getInsertSQLString
{
    
    NSMutableString* insertKeyString = [NSMutableString stringWithCapacity:0];
    NSMutableString* insertValueString= [NSMutableString stringWithCapacity:0];
//    NSMutableArray* insertValues = [NSMutableArray arrayWithCapacity:self.KVCs.count];
    
    for (NSDictionary *kvc in self.KVCs)
    {
        
        NSString *columeName = kvc[@"name"];
//        id columeValue = kvc[@"value"];
        //        NSString *columeType = kvc[@"type"];
        
        [insertKeyString appendFormat:@"%@, ",columeName];
        [insertValueString appendString:@"?, "];
        
//        [insertValues addObject:columeValue];
        
    }
//    [insertKey deleteCharactersInRange:NSMakeRange(insertKey.length - 1, 1)];
//    [insertValuesString deleteCharactersInRange:NSMakeRange(insertValuesString.length - 1, 1)];
    if ([self respondsToSelector:@selector(getSubclassInsertSQLString:value:)])
        [self getSubclassInsertSQLString:insertKeyString value:insertValueString];
    
    NSString* insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (%@createdAt, updatedAt) values(%@?, ?)",self.className,insertKeyString,insertValueString];
//    [insertValues addObject:date];
//    [insertValues addObject:date];
    
//    NSLog(insertSQL);
    return insertSQL;
}

- (NSArray *)getInsertSQLArguments
{
    NSDate* date = [NSDate date];
//    NSMutableString* insertKey = [NSMutableString stringWithCapacity:0];
//    NSMutableString* insertValuesString = [NSMutableString stringWithCapacity:0];
    NSMutableArray* insertValues = [NSMutableArray arrayWithCapacity:self.KVCs.count];
    
    for (NSDictionary *kvc in self.KVCs)
    {
        
//        NSString *columeName = kvc[@"name"];
        id columeValue = kvc[@"value"];
        //        NSString *columeType = kvc[@"type"];
        
//        [insertKey appendFormat:@"%@,",columeName];
//        [insertValuesString appendString:@"?,"];
        
        [insertValues addObject:columeValue];
        
    }
//    [insertKey deleteCharactersInRange:NSMakeRange(insertKey.length - 1, 1)];
//    [insertValuesString deleteCharactersInRange:NSMakeRange(insertValuesString.length - 1, 1)];
    
    if ([self respondsToSelector:@selector(getSubclassInsertSQLArguments:)])
        [self getSubclassInsertSQLArguments:insertValues];
    
//    NSString* insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (%@, createdAt, updatedAt) values(%@,?,?)",self.className,insertKey,insertValuesString];
    
    [lastUpdateTime release];
    lastUpdateTime = [date retain];
    
    [insertValues addObject:date];
    [insertValues addObject:date];
    
//    NSLog(insertSQL);
    return insertValues;
}

- (NSString *)getDeleteSQLString
{
    return  [NSString stringWithFormat:@"DELETE FROM %@ WHERE objectId = ?",self.className];
}

- (NSArray *)getDeleteSQLArguments
{
    return @[[NSNumber numberWithInt:self.objectId]];
}

#pragma mark - SQL操作
- (void)createTableWithCallback:(void(^)(BOOL success))block
{
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;

    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
	}
    
    NSString* createTableSql = [self getCreateTableSQLString];
    
    NSLog(createTableSql);
    
    BOOL execute = [db executeUpdate:createTableSql];
    
    if(block != nil)
    {
        block(execute);
    }
    
    if(execute == NO)
    {
        NSLog(@"database update fail %@----->rowid: %d",NSStringFromClass(self.class),self.objectId);
    }
}

- (void)updateWithCallback:(void(^)(BOOL success))block
{
    if (self.objectId <= 0)
    {
        return;
    }
    
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
	}
    
    NSString *updateSQLStr = [self getUpdateSQLString];
    NSArray *updateSQLArg = [self getUpdateSQLArguments];
    
    BOOL execute = [db executeUpdate:updateSQLStr withArgumentsInArray:updateSQLArg];
    
    if(block != nil)
    {
        block(execute);
    }
    
    if(execute == NO)
    {
        NSLog(@"database update fail %@----->rowid: %d",NSStringFromClass(self.class),self.objectId);
    }
    /*
     [db executeUpdate:@"UPDATE PersonList SET Age = ? , Name = ? WHERE Name = ?",[NSNumber numberWithInt:30],@“Albert”,@“John”];
     */
}

- (void)insertDataWithCallback:(void(^)(BOOL success))block
{
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
	}
    
    NSString *insertSQL = [self getInsertSQLString];
    NSArray *insertValues = [self getInsertSQLArguments];
    
    BOOL execute = [db executeUpdate:insertSQL withArgumentsInArray:insertValues];
    
    if(block != nil)
    {
        block(execute);
    }
    
    if(execute == NO)
    {
        NSLog(@"database update fail %@----->rowid: %d",NSStringFromClass(self.class),self.objectId);
    }

    /*
     [db executeUpdate:@"INSERT INTO tabel1 (Name, Age, Sex, Phone, Address, Photo) VALUES (?,?,?,?,?,?)",@"Jone", [NSNumber numberWithInt:20], [NSNumber numberWithInt:0], @“091234567”, @“Taiwan, R.O.C”, [NSData dataWithContentsOfFile: filepath]];
     */
}

- (BOOL)deleteData
{
    if (self.objectId <= 0)
    {
        return NO;
    }
    
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return NO;
	}
    
    NSString *deleteSQLStr = [self getDeleteSQLString];
    NSArray *deleteSQLArg = [self getDeleteSQLArguments];
    
    return [db executeUpdate:deleteSQLStr withArgumentsInArray:deleteSQLArg];
}

- (void)deleteDataWithCallback:(void(^)(BOOL success))block
{
    BOOL success = [self deleteData];
    if (block) {
        block(success);
    }
}

- (NSString *)getCreateTabelSql
{
    FMDatabase *db = [ALFMDBHelper shareDBHelper].db;
    return [db stringForQuery:[NSString stringWithFormat:@"select sql from sqlite_master where type='table' and name='%@'",self.className]];
}

//判断是否有新字段
- (void)checkUndefindedColume
{
    NSString *ctSql = [self getCreateTabelSql];
    NSLog(ctSql);
    for (NSDictionary *kvc in self.KVCs)
    {
        NSString *columeName = kvc[@"name"];
        
        if ([ctSql rangeOfString:columeName].location == NSNotFound)
        {
            NSString *columeType = kvc[@"type"];
            [self addColume:columeName columeType:columeType];
        }
    }
    
}

//插入新字段
- (void)addColume:(NSString *)columeName columeType:(NSString *)columeType
{
//    ALTER TABLE student ADD COLUMN age1 INTEGER
    
    [[ALFMDBHelper shareDBHelper].db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@",self.className,columeName,[self toDBType:columeType]]];
}

//插入成功后，返回objectId(obj-->objId)
- (void)getSelfObjectId
{
    NSMutableString* whereKey = [NSMutableString stringWithCapacity:0];
//    NSMutableString* insertValuesString = [NSMutableString stringWithCapacity:0];
//    NSMutableArray* whereValues = [NSMutableArray arrayWithCapacity:self.KVCs.count];
//    
//    for (NSDictionary *kvc in self.KVCs)
//    {
//        
//        NSString *columeName = kvc[@"name"];
//        id columeValue = kvc[@"value"];
////        NSString *columeType = kvc[@"type"];
//        
//        [whereKey appendFormat:@"%@=?,",columeName];
//        
//        [whereValues addObject:columeValue];
//        
//    }
//    [whereKey deleteCharactersInRange:NSMakeRange(whereKey.length - 1, 1)];
    
    NSString *rsSQL = [NSString stringWithFormat:@"SELECT objectId, createdAt, updatedAt FROM %@ WHERE updatedAt=?",self.className];
    
    NSLog(rsSQL);
    
    FMResultSet *rs = [[ALFMDBHelper shareDBHelper].db executeQuery:rsSQL,lastUpdateTime];
    
    while ([rs next])
    {

        self.objectId = [rs intForColumn:@"objectId"];
        self.createdAt = [rs dateForColumn:@"createdAt"];
        self.updatedAt = [rs dateForColumn:@"updatedAt"];
        
    }
 
    [rs close];
}

- (void)getSelfWithRS:(FMResultSet *)rs
{
    if (rs == nil) {
        return;
    }
    
    self.objectId = [rs intForColumn:@"objectId"];
    self.createdAt = [rs dateForColumn:@"createdAt"];
    self.updatedAt = [rs dateForColumn:@"updatedAt"];
    
    if ([self respondsToSelector:@selector(getSubclassSelf:)])
        [self getSubclassSelf:rs];
    
    for (int i=0;i<rs.columnCount; i++)
    {
        NSString *name = [rs columnNameForIndex:i];
        
        BOOL isProperty = NO;
        for (NSDictionary *prop in self.propertys)
        {
            if ([name isEqualToString:prop[@"name"]] || [name rangeOfString:privateProperty].location != NSNotFound)
            {
                isProperty = YES;
                break;
            }
        }
        if (isProperty) continue;
        
        id value = [rs objectForColumnIndex:i];
        
        [self setValue:value forKey:name];
    }
    

}

//返回整个object(obj<--objId)
- (void)getSelf
{
    NSString *rsSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE objectId=?",self.className];
    
    NSLog(rsSQL);
    
    FMResultSet *rs = [[ALFMDBHelper shareDBHelper].db executeQuery:rsSQL,[NSString stringWithFormat:@"%d",self.objectId]];
    
    while ([rs next])
    {
        [self getSelfWithRS:rs];
    }
    [rs close];
}

#pragma mark - Save
- (BOOL)save
{
    [self checkUndefindedColume];
    
    //已存在数据，需要更新
    if (self.objectId > 0)
    {
        [self updateWithCallback:^(BOOL success) {
            NSLog(@"%@",success? @"更新成功":@"更新失败");
        }];
    }
    //新创建数据，需要插入
    else
    {
        [self insertDataWithCallback:^(BOOL success) {
            
            if (success) {
                [self getSelfObjectId];
            }
            
            NSLog(@"%@",success? @"插入成功":@"插入失败");
            
        }];
    }
    return NO;
}

- (BOOL)save:(NSError **)error
{
    return NO;
}


#pragma mark - Refresh
//有问题
- (void)load
{
    if (self.objectId <= 0)
    {
        return;
    }
    
    [self getSelf];
}

- (void)load:(NSError **)error
{
    
}

#pragma mark - Delete

- (BOOL)delete
{
    if (self.objectId <= 0)
    {
        return NO;
    }
    
    return [self deleteData];
}

- (BOOL)delete:(NSError **)error
{
    return NO;
}

#pragma mark - 子类化
+ (NSString *)subclassName
{    
    return NSStringFromClass(self.class);
    //    return [NSString stringWithUTF8String:object_getClassName(self)];
}

+ (id)object
{    
    return [self.class objectWithoutDataWithClassName:[self.class subclassName] objectId:0];
}

+ (id)objectWithoutDataWithObjectId:(unsigned int)objectId
{
    return [self.class objectWithoutDataWithClassName:[self.class subclassName] objectId:objectId];
}

#pragma mark - 属性设置字段

SEL getSetterFromPropertyName(NSString *propName)
{
    
    NSString *setName = [NSString stringWithFormat:@"set%@%@:",[[propName substringToIndex:1] uppercaseString],[propName substringFromIndex:1]];
    
    return NSSelectorFromString(setName);
}

SEL getGetterFromPropertyName(NSString *propName)
{
    return NSSelectorFromString(propName);
}

//返回添加到属性中name，之后就不用添加到KVCs中了
- (void)getSubclassSelf:(FMResultSet *)rs
{
    [self getPropertys];
    
//    NSLog(@"getPropertys=%@",self.propertys);
    
//    NSMutableArray *names = [NSMutableArray arrayWithCapacity:self.propertys.count];
    
    for (NSMutableDictionary *prop in self.propertys)
    {
        //属性名
        NSString *name = prop[@"name"];
        NSString *type = prop[@"type"];
        
        //字段对应的属性值
        id value = [rs objectForColumnName:name];
        
        
        
//        NSLog(@"value.class = %@",[value class]);
        //setName 方法名
        SEL setProperty = getSetterFromPropertyName(name);
        
        [self performSelector:setProperty withObject:[self toOCType:type value:value]];
    }
}

- (NSString *)getSubclassCreateTableSQLStringWithString:(NSMutableString *)pars
{
    //子类化
    if ([self respondsToSelector:@selector(getPropertys)])
    {
        [self getPropertys];
        
        for (NSDictionary *prop in self.propertys)
        {
//            NSLog(@"prop = %@",prop);
            NSString *propName = prop[@"name"];
//        id propValue = prop[@"value"];
            NSString *propType = prop[@"type"];
            
            [pars appendFormat:@"%@ %@, ",propName,[self toDBType:propType]];
        }
    }
    return pars;
}

- (NSString *)getSubclassUpdateSQLStringWithString:(NSMutableString *)updateStr
{
    //子类化
    if ([self respondsToSelector:@selector(getPropertys)])
    {
        [self getPropertys];
        
        for (NSDictionary *prop in self.propertys)
        {
            NSString *columeName = prop[@"name"];
            
            [updateStr appendFormat:@"%@ = ?,",columeName];
        }
    }
    return updateStr;
}

- (NSArray *)getSubclassUpdateSQLArguments:(NSMutableArray *)updateValues
{
    
    if ([self respondsToSelector:@selector(getPropertys)])
    {
        [self getPropertys];
        
        for (NSDictionary *prop in self.propertys)
        {
            id columeValue = prop[@"value"];
            
            [updateValues addObject:columeValue];
        }
    }
    return updateValues;
}

- (NSDictionary *)getSubclassInsertSQLString:(NSMutableString *)insertKeyString value:(NSMutableString *)insertValueString
{
    if ([self respondsToSelector:@selector(getPropertys)])
    {
        [self getPropertys];
        
        for (NSDictionary *prop in self.propertys)
        {
            NSString *columeName = prop[@"name"];
//        id columeValue = kvc[@"value"];
//        NSString *columeType = kvc[@"type"];
            
            [insertKeyString appendFormat:@"%@, ",columeName];
            [insertValueString appendString:@"?, "];
        }
    }
    return @{@"key":insertKeyString,@"value":insertValueString};
}

- (NSArray *)getSubclassInsertSQLArguments:(NSMutableArray *)insertValues
{
    if ([self respondsToSelector:@selector(getPropertys)])
    {
        //获取属性
        [self getPropertys];
        
        for (NSDictionary *prop in self.propertys)
        {
            id columeValue = prop[@"value"];
            //        NSString *columeType = kvc[@"type"];
            
            //        [insertKey appendFormat:@"%@,",columeName];
            //        [insertValuesString appendString:@"?,"];
            
            [insertValues addObject:columeValue];
        }
    }
    return insertValues;
}

//返回属性
- (void)getPropertys
{
    if([self.className isEqualToString:@""])
    {
        NSLog(@"ALFMDB子类化失败，请检查子类%@的命名",[self class]);
        return;
    }
    
    [self.propertys removeAllObjects];
    [self.class getSelf:self propertys:self.propertys isGetSuperPropertys:YES];
}

//获取对象的所有属性
+ (void)getSelf:(id)bSelf propertys:(NSMutableArray *)propertys isGetSuperPropertys:(BOOL)isGetSuper
{
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
//    NSLog(@"outCount=%d",outCount);
    
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
//        NSLog(propertyName);
        
        if([propertyName isEqualToString:@"primaryKey"]||[propertyName isEqualToString:@"rowid"])
        {
            continue;
        }
        
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         c char
         i int
         l long
         s short
         d double
         f float
         @ id //指针 对象
         ...  BOOL 获取到的表示 方式是 char
         .... ^i 表示  int*  一般都不会用到
         */
        
        //跳过ALFMDB的私有属性
//        BOOL isPrivateProp = NO;
        if ([propertyName rangeOfString:privateProperty].location != NSNotFound)
        {
            continue;
        }
        
//        for (NSString *pName in @[@"propertys",@"KVCs",@"className",@"updatedAt",@"createdAt"])
//        {
//            if ([propertyName isEqualToString:pName]) isPrivateProp = YES;
//        }
//        
//        if (isPrivateProp) continue;
        
        NSMutableDictionary *prop = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
         
        [prop setValue:propertyName forKey:@"name"];
        
        SEL getProperty = getGetterFromPropertyName(propertyName);
        
        if ([propertyType hasPrefix:@"T@"])
        {
            
            [prop setValue:[propertyType substringWithRange:NSMakeRange(3, [propertyType rangeOfString:@","].location-4)] forKey:@"type"];
            
            id value = [bSelf performSelector:getProperty];
            NSLog(@"%@",value);
            [prop setValue:value forKey:@"value"];

        }
        else if ([propertyType hasPrefix:@"Ti"])
        {
            [prop setValue:@"int" forKey:@"type"];
            
            int value = [bSelf performSelector:getProperty];
            [prop setValue:[NSNumber numberWithInt:value] forKey:@"value"];
        }
        else if ([propertyType hasPrefix:@"Tf"])
        {
            [prop setValue:@"float" forKey:@"type"];
            [prop setValue:propertyName forKey:@"value"];
            
            int value = [bSelf performSelector:getProperty];
            [prop setValue:[NSNumber numberWithFloat:value] forKey:@"value"];
        }
        else if([propertyType hasPrefix:@"Td"]) {

            [prop setValue:@"double" forKey:@"type"];
            [prop setValue:propertyName forKey:@"value"];
            
            int value = [bSelf performSelector:getProperty];
            [prop setValue:[NSNumber numberWithDouble:value] forKey:@"value"];
        }
        else if([propertyType hasPrefix:@"Tl"])
        {
            [prop setValue:@"long" forKey:@"type"];
            [prop setValue:propertyName forKey:@"value"];
            
            long value = [bSelf performSelector:getProperty];
            [prop setValue:[NSNumber numberWithLong:value] forKey:@"value"];
        }
        else if ([propertyType hasPrefix:@"Tc"]) {

            [prop setValue:@"BOOL" forKey:@"type"];
            [prop setValue:propertyName forKey:@"value"];
            
            BOOL value = [bSelf performSelector:getProperty];
            [prop setValue:[NSNumber numberWithBool:value] forKey:@"value"];
        }
        else if([propertyType hasPrefix:@"Ts"])
        {
            [prop setValue:@"short" forKey:@"type"];
            [prop setValue:propertyName forKey:@"value"];
            
            short value = [bSelf performSelector:getProperty];
            [prop setValue:[NSNumber numberWithBool:value] forKey:@"value"];
        }
        //一对一外链
        else if ([NSClassFromString(propertyType) isSubclassOfClass:[ALDBObject class]])
        {
            
        }
        //一对多外链
        else if ([propertyType isEqualToString:@"ALDBRelation"])
        {
            
        }
        else
        {
            NSLog(@"ERROR！！！无法识别类型属性：%@中的%@",[bSelf class],propertyName);
            continue;
        }

//        NSLog(@"prop = %@",prop);
        
        [propertys addObject:prop];

        [prop release];
        
//        else if([propertyType hasPrefix:@"T^c"])
//        {
//            [protypes addObject:@"^c"];
//        }
//        else if([propertyType hasPrefix:@"T^i"])
//        {
//            [protypes addObject:@"^i"];
//        }
//        else if([propertyType hasPrefix:@"T*"])
//        {
//            [protypes addObject:@"*"];
//        }
    }
    
    free(properties);
    
    if(isGetSuper && [bSelf class] != [NSObject class] && [bSelf superclass] != [ALDBObject class])
    {
        id bSuper = [[[[bSelf superclass] alloc] init] autorelease];
        if ([[bSelf superclass] respondsToSelector:@selector(getSelfPropertys:isGetSuperPropertys:)])
            [[bSelf superclass] getSelf:bSuper propertys:propertys isGetSuperPropertys:isGetSuper];
    }
}

#pragma mark - 查询
+ (ALDBQuery *)query
{
    return [ALDBQuery queryWithClassName:[self.class subclassName]];
}
@end
