//
//  Friend.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

typedef NS_ENUM(NSUInteger, ALUserFollowState) {
    ALUserFollowStateOfNone = 0,    //没关系
    ALUserFollowStateOfNormal,      //普通关注
    ALUserFollowStateOfSpecial,     //特别关注
};

@class User;

@interface Friend : AVObject <AVSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) User *User;

@property (nonatomic, retain) NSString *bkName;//备注名

@property (nonatomic, assign) ALUserFollowState state;

@end
