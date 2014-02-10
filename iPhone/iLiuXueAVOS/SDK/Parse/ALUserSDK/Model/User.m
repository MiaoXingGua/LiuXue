//
//  User.m
//  ParseTest
//
//  Created by Jack on 13-5-30.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "User.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation User

@dynamic nickName,headView,signature,creditsTitleSeries,location,place,userInfo,userCount,userFavicon,QQWeibo,SinaWeibo,RenRen,WeChat,userKey;

@dynamic gender,credits,experience,numberOfRemind;

+ (NSString *)parseClassName
{
    return @"_User";
}

//- (void)setNickName:(NSString *)nickName
//{
//    [nickName release];
//    
//    nickName = [nickName retain];
//
//    if (nickName)
//        [self setObject:nickName forKey:@"nickName"];
//}
//
//- (NSString *)nickName
//{
//    NSString *nickName = [self objectForKey:@"nickName"];
//    
//    if (nickName)
//    {
//        [nickName release];
//        nickName = [nickName retain];
//    }
//    
//    return nickName;
//}
//
//- (void)setSinaWeibo:(NSString *)SinaWeibo
//{
//    [SinaWeibo release];
//    
//    SinaWeibo = [SinaWeibo retain];
//    
//    if (SinaWeibo)
//        [self setObject:SinaWeibo forKey:@"SinaWeibo"];
//}
//
//- (NSString *)SinaWeibo
//{
//    NSString *SinaWeibo = [self objectForKey:@"SinaWeibo"];
//    
//    if (SinaWeibo)
//    {
//        [SinaWeibo release];
//        SinaWeibo = [SinaWeibo retain];
//    }
//    
//    return SinaWeibo;
//}
//
//- (void)setRenRen:(NSString *)RenRen
//{
//    [RenRen release];
//    
//    RenRen = [RenRen retain];
//    
//    if (RenRen)
//        [self setObject:RenRen forKey:@"RenRen"];
//}
//
//- (NSString *)RenRen
//{
//    NSString *RenRen = [self objectForKey:@"RenRen"];
//    
//    if (RenRen)
//    {
//        [RenRen release];
//        RenRen = [RenRen retain];
//    }
//    
//    return RenRen;
//}
//
//- (void)setWeChat:(NSString *)WeChat
//{
//    [WeChat release];
//    
//    WeChat = [WeChat retain];
//    
//    if (WeChat)
//        [self setObject:WeChat forKey:@"WeChat"];
//}
//
//- (NSString *)WeChat
//{
//    NSString *WeChat = [self objectForKey:@"WeChat"];
//    
//    if (WeChat)
//    {
//        [WeChat release];
//        WeChat = [WeChat retain];
//    }
//    
//    return WeChat;
//}

@end



