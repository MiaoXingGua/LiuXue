//
//  ALDBQuery.h
//  FMDB_DEMO
//
//  Created by Albert on 13-8-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALDBObject;

@interface ALDBQuery : NSObject

@property (nonatomic, readonly) NSString *className;

//@property (nonatomic, readonly) Class myClass;

+ (ALDBQuery *)queryWithClassName:(NSString *)className;

//+ (ALDBQuery *)queryWithSubclass:(Class)myClass;

@property (nonatomic) NSInteger limit;

@property (nonatomic) NSInteger skip;


//基本约束
- (void)whereKeyExists:(NSString *)key;

- (void)whereKeyDoesNotExist:(NSString *)key;

- (void)whereKey:(NSString *)key equalTo:(id)object;

- (void)whereKey:(NSString *)key lessThan:(id)object;

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object;

- (void)whereKey:(NSString *)key greaterThan:(id)object;

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object;

- (void)whereKey:(NSString *)key notEqualTo:(id)object;

//添加一个约束来查询,需要一个特定的键的对象是包含在提供的数组。
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array;

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array;

- (void)whereKey:(NSString *)key containsAllObjectsInArray:(NSArray *)array;


- (void)whereKey:(NSString *)key containsString:(NSString *)substring;

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix;

- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;



- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex;

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex modifiers:(NSString *)modifiers;

//排序
/*!
 按key升序排序结果(优先级最高)
 */
- (void)orderByAscending:(NSString *)key;

/*!
 按key升序排序结果
 */
- (void)addAscendingOrder:(NSString *)key;

/*!
 按key降序排序结果(优先级最高)
 */
- (void)orderByDescending:(NSString *)key;
/*!
 按key降序排序结果
 */
- (void)addDescendingOrder:(NSString *)key;

/*!
 按sortDescriptor排序结果
 */
- (void)orderBySortDescriptor:(NSSortDescriptor *)sortDescriptor;

/*!

 */
- (void)orderBySortDescriptors:(NSArray *)sortDescriptors;

//查找
- (NSArray *)findObjects;

- (ALDBObject *)getFirstObject;

- (NSInteger)countObjects;

@end
