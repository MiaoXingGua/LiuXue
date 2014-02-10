//
//  MessageCenter.h
//  iLiuXue
//
//  Created by Albert on 13-9-5.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALXMPPEngine.h"
#import "ALUserEngine.h"

@interface MessageCenter : NSObject
{
    NSTimer *_timer;
    UIImageView *deleteView;
    
    NSMutableDictionary *_userInfos;
    
    User *_sendUser;
    
    User *_lastUser;
    
    int unReadNum;
}

+ (MessageCenter *)defauleCenter;
- (void)addNotification;
- (void)removeChatView:(NSNotification *)info;

@property(nonatomic,retain)User *lastUser;
@property(nonatomic,retain)User *sendUser;
@property(nonatomic,retain)NSMutableDictionary *userInfos;
@property(nonatomic,assign)BOOL isShowChatView;
@end
