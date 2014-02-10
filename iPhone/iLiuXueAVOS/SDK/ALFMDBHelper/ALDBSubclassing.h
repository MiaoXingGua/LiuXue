//
//  ALDBSubclassing.h
//  FMDB_DEMO
//
//  Created by Albert on 13-8-19.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 目前子类化支持属性类型：int bool  @对象
 */
//@class ALDBQuery;
#import "ALDBQuery.h"

@protocol ALDBSubclassing <NSObject>

+ (id)object;

+ (id)objectWithoutDataWithObjectId:(NSString *)objectId;

//+ (BOOL)registerSubclass;

+ (ALDBQuery *)query;

@end
