//
//  ALGroupEngine.m
//  PARSE_DEMO
//
//  Created by Albert on 13-10-21.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALGroupEngine.h"


static ALGroupEngine *groupEngine = nil;

@implementation ALGroupEngine

+ (instancetype)defauleEngine
{
    if (!groupEngine)
    {
        groupEngine = [[ALGroupEngine alloc] init];
    }
    
    return groupEngine;
}

- (void)setGroupImage:(NSData *)theImage
              toGroup:(NSString *)groupId
                block:(void(^)(BOOL success, NSError *error))block
{
//    [block copy];
//    __block typeof (self) bself = self;
    AVFile *imageFile = [AVFile fileWithData:theImage];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        AVObject *groupInfo = [AVObject objectWithClassName:@"GroupInfo"];
        [groupInfo setObject:imageFile forKey:@"headView"];
        [groupInfo setObject:groupId forKey:@"groupId"];
        [groupInfo saveInBackgroundWithBlock:block];
        
    }];
    
//    [block release];
}


- (void)getGroupImageWithGroupId:(NSString *)groupId
                           block:(void(^)(AVFile *imageFile, NSError *error))block
{
    AVQuery *giQ = [AVQuery queryWithClassName:@"GroupInfo"];
    [giQ whereKey:@"groupId" equalTo:groupId];
    [giQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        if (block)
        {
            if (object && !error)
            {
                AVFile *imageFile = [object objectForKey:@"headView"];
                block(imageFile,nil);
            }
            else
            {
                block(nil,error);
            }
        }
    }];
}



@end
