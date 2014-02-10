//
//  ALGroupEngine.h
//  PARSE_DEMO
//
//  Created by Albert on 13-10-21.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface ALGroupEngine : NSObject

+ (instancetype)defauleEngine;

- (void)setGroupImage:(NSData *)theImage
              toGroup:(NSString *)groupId
                block:(void(^)(BOOL success, NSError *error))block;


- (void)getGroupImageWithGroupId:(NSString *)groupId
                           block:(void(^)(AVFile *imageFile, NSError *error))block;

@end
