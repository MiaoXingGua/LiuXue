//
//  AVRelation+AddUniqueObject.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-14.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface AVRelation (AddUniqueObject)

+ (BOOL)isExsitTheObject:(AVObject *)object inObjects:(NSArray *)theUsers;

//往AVRelation中是否存在AVObject
- (void)isExsitObject:(AVObject *)object block:(void(^)(BOOL isExsit))callbackBlock;

//往AVRelation中添加唯一AVObject
- (void)addUniqueObject:(AVObject *)object block:(void(^)(void))callbackBlock;

@end
