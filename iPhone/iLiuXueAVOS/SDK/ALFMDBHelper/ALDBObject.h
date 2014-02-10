//
//  ALDBObject.h
//  FMDB_DEMO
//
//  Created by Albert on 13-8-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALFMDBConstants.h"
#import "ALDBSubclassing.h"

@interface ALDBObject : NSObject<ALDBSubclassing>

@property (nonatomic, readonly) int objectId;//主键

@property (nonatomic, readonly) NSDate *updatedAt;

@property (nonatomic, readonly) NSDate *createdAt;

@property (nonatomic, readonly) NSString *className;

#pragma mark - init

+ (ALDBObject *)objectWithClassName:(NSString *)className;

+ (ALDBObject *)objectWithoutDataWithClassName:(NSString *)className
                                      objectId:(unsigned int)objectId;

#pragma mark - Save

- (BOOL)save;

- (BOOL)save:(NSError **)error;


#pragma mark - Refresh

- (void)load;

- (void)load:(NSError **)error;

#pragma mark - Delete

- (BOOL)delete;

- (BOOL)delete:(NSError **)error;

#pragma mark - protocol subclassing

+ (id)object;

+ (id)objectWithoutDataWithObjectId:(unsigned int)objectId;

+ (ALDBQuery *)query;

@end
