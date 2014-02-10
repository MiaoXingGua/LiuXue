//
//  ALNotificationConfig.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#ifndef PARSE_DEMO_ALNotificationConfig_h
#define PARSE_DEMO_ALNotificationConfig_h

#define PERPAGE_OF_THREAD_NOTIFICATION 10
#define PERPAGE_OF_FRIEND_NOTIFICATION 10

#import "ALParseConfig.h"

//#define NOTIFICATION_NEW_SYSTEM_NOTIFICATION  @"SFKAYWYER73Q4IGR7GQ24YIVFRQKRFJAFRGWQIOEQ3497GR3QQEHS4H"
#define NOTIFICATION_THREAD_NOTIFICATION  @"EFWYEGRO74QIYTVQ34O74FBAILURUYFGO8W74VYFUAWFW6342OQR8Y4"
#define NOTIFICATION_FRIEND_NOTIFICATION  @"WEUFIUW4RLQ43G8F8Q934VI2O73IBQVFUI79E4Q3O8GFASFGAKSUYDR"

//#define POST_NOTIFICATION_NEW_SYSTEM_NOTIFICATION(type,toUser,price)  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_SYSTEM_NOTIFICATION object:self userInfo:@{@"ALCreditRuleType":[NSNumber numberWithInteger:type],@"toUser":user,@"price":[NSNumber numberWithInteger:price]}]

#define POST_NOTIFICATION_THREAD_NOTIFICATION(type,toUser,fromUser,thread,post,comment)  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_THREAD_NOTIFICATION object:self userInfo:@{@"ALThreadNotificationType":[NSNumber numberWithInteger:type],@"toUser":toUser,@"fromUser":fromUser,@"thread":thread,@"post":post,@"comment":comment}]

#define POST_NOTIFICATION_FRIEND_NOTIFICATION(type,toUser,fromUser)  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FRIEND_NOTIFICATION object:self userInfo:@{@"ALFriendNotificationType":[NSNumber numberWithInteger:type],@"toUser":toUser,@"fromUser":fromUser}]

////SYSTEM
//typedef NS_ENUM(NSUInteger, ALFriendNotificationType) {
//    
//    //异常
//    ALFriendNotificationTypeOfUndefined = 0,
//    
//
// 
//};

@class User;

//THREAD
typedef NS_ENUM(NSUInteger, ALThreadNotificationType) {
    
    //异常
    ALThreadNotificationTypeOfUndefined = 0,
    
    //我的提问有了新的回答
    ALThreadNotificationTypeOfThreadNewPost,//done
    
    //我的提问被收藏
    ALThreadNotificationTypeOfThreadNewFavicon,
    
    //我的回答被赞
    ALThreadNotificationTypeOfPostNewSupport,//done
    
    //我的回答被评论
    ALThreadNotificationTypeOfPostNewComment,//done
    
    //我的回答被选为最佳答案
    ALThreadNotificationTypeOfPostToBestPost,//done
    
    //我收藏的问题有了新的回答
    ALThreadNotificationTypeOfFaviconThreadNewPost,
    
    //我收藏的问题选择了最佳答案
    ALThreadNotificationTypeOfFaviconThreadToBestPost,
    
    //我收藏的问题已关闭
    ALThreadNotificationTypeOfFaviconThreadToClose,
    
    //被@
    ALThreadNotificationTypeOfAt,//问题
    
};


//FRIEND
typedef NS_ENUM(NSUInteger, ALFriendNotificationType) {
    
    //异常
    ALFriendNotificationTypeOfUndefined = 0,
    
    //user成为你的粉丝
    ALFriendNotificationTypeOfNewFollower,
    
    
};




#endif
