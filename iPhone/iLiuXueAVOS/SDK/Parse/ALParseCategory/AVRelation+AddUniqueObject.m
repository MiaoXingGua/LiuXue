//
//  AVRelation+AddUniqueObject.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-14.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "AVRelation+AddUniqueObject.h"

@implementation AVRelation (AddUniqueObject)

+ (BOOL)isExsitTheObject:(AVObject *)object inObjects:(NSArray *)theObjects
{
    BOOL isExist = NO;
    for (AVObject *tmpObj in theObjects)
    {
        if ([tmpObj.objectId isEqualToString:object.objectId])
        {
            isExist = YES;
        }
    }
    return isExist;
}

- (void)isExsitObject:(AVObject *)object block:(void(^)(BOOL isExsit))callbackBlock
{
    [callbackBlock copy];
    
    if (callbackBlock)
    {
        __block int count = 2;
        __block NSArray * __objects = nil;
        __block AVObject * __object = nil;
        
        [[self query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           
            __objects = [objects retain];
            
            if (--count==0)
            {
                BOOL isExsit = [[self class] isExsitTheObject:__object inObjects:__objects];
                [__object release];
                [__objects release];
                callbackBlock(isExsit);
            }
        }];
        
        [object fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
            __object = [object retain];
            
            if (--count==0)
            {
                BOOL isExsit = [[self class] isExsitTheObject:__object inObjects:__objects];
                [__object release];
                [__objects release];
                callbackBlock(isExsit);
            }
        }];
    
    }
    [callbackBlock release];
}

- (void)addUniqueObject:(AVObject *)object block:(void(^)(void))callbackBlock
{
    [callbackBlock copy];

    __block typeof (self) bself = self;
    
    [self isExsitObject:object block:^(BOOL isExsit) {
        if (!isExsit)
        {
            [bself addObject:object];
        }
        
        if (callbackBlock)
        {
            callbackBlock();
        }
    }];
    
    [callbackBlock release];
}
//不存在则添加



@end
