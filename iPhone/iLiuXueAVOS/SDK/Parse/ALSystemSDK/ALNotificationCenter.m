//
//  ALNotificationEngine.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-18.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALNotificationCenter.h"
#import "ALUserEngine.h"
#import "User.h"

static ALNotificationCenter *notificationCenter = nil;

@implementation ALNotificationCenter

+ (ALNotificationCenter *)defauleCenter
{
    if (!notificationCenter)
    {
        notificationCenter = [[ALNotificationCenter alloc] init];
        [notificationCenter addNotification];
    }
    return notificationCenter;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_threadNotificationHandle:) name:NOTIFICATION_THREAD_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_friendNotificationHandle:) name:NOTIFICATION_FRIEND_NOTIFICATION object:nil];
}

#pragma mark - 获取通知
//获取帖子通知
- (void)getNotificationsOfThreadNotContainedIn:(NSArray *)theNotifications
                                          type:(ALThreadNotificationType)type
                                      isUnread:(BOOL)isUnread
                                         block:(void(^)(NSArray *notifications, NSError *error))resultBlock
{
    if (![User currentUser]) return;
    
    [resultBlock copy];
    
    AVQuery *notificationQ = [self _getQueryOfNotificationsOfThreadWithNotContainedIn:theNotifications type:type isUnread:isUnread isOnlyCount:NO];
    
    [notificationQ findObjectsInBackgroundWithBlock:resultBlock];
    
    [resultBlock release];
}

//获取帖子通知数
- (void)getNotificationsOfThreadCountWithType:(ALThreadNotificationType)type
                                     isUnread:(BOOL)isUnread
                                        block:(void(^)(int count, NSError *error))resultBlock
{
    if (![User currentUser]) return;
    
    [resultBlock copy];
    
    AVQuery *notificationQ = [self _getQueryOfNotificationsOfThreadWithNotContainedIn:nil type:type isUnread:isUnread isOnlyCount:YES];
    
    [notificationQ countObjectsInBackgroundWithBlock:resultBlock];
    
    [resultBlock release];
}

//获取用户通知
- (void)getNotificationsOfFriendNotContainedIn:(NSArray *)theNotifications
                                          type:(ALFriendNotificationType)type
                                      isUnread:(BOOL)isUnread
                                         block:(void(^)(NSArray *notifications, NSError *error))resultBlock
{
    if (![User currentUser]) return;
    
    [resultBlock copy];
    
    AVQuery *notificationQ = [self _getQueryOfNotificationsOfFriendWithNotContainedIn:theNotifications type:type isUnread:isUnread isOnlyCount:NO];
    
    [notificationQ findObjectsInBackgroundWithBlock:resultBlock];
    
    [resultBlock release];
}


//获取用户通知数
- (void)getNotificationsOfFriendCountWithType:(ALFriendNotificationType)type
                                     isUnread:(BOOL)isUnread
                                        block:(void(^)(int count, NSError *error))resultBlock
{
    if (![User currentUser]) return;
    
    [resultBlock copy];
    
    AVQuery *notificationQ = [self _getQueryOfNotificationsOfFriendWithNotContainedIn:nil type:type isUnread:isUnread isOnlyCount:YES];
    
    [notificationQ countObjectsInBackgroundWithBlock:resultBlock];
    
    [resultBlock release];
}

//帖子通知的Query
- (AVQuery *)_getQueryOfNotificationsOfThreadWithNotContainedIn:(NSArray *)theNotifications
                                                           type:(ALThreadNotificationType)type
                                                       isUnread:(BOOL)isUnread
                                                    isOnlyCount:(BOOL)isOnlyCount
{
    AVQuery *notificationQ = [NotificationOfThread query];
    
    [notificationQ whereKey:@"toUser" equalTo:[User currentUser]];
    [notificationQ whereKey:@"type" equalTo:[NSNumber numberWithInt:type]];
    
    //只显示未读的
    if (isUnread)  [notificationQ whereKey:@"isReaded" notEqualTo:@YES];
    else [notificationQ whereKey:@"isReaded" equalTo:@YES];
    
    [notificationQ whereKey:@"isDeleted" notEqualTo:@YES];
    
    //需要数据
    if (!isOnlyCount)
    {
//        [self _includeKeyWithNotificationOfThread:notificationQ];
        
        theNotifications = [self _orderWithCreatedAtByDescendingWithArray:theNotifications];//updatedAt逆序
        
        NotificationOfThread *lastNotifications = [theNotifications lastObject];
        
        NSArray *objIdArray = [self _objectIdListWithArray:theNotifications];
        
        [notificationQ orderByDescending:@"createdAt"];
        
        notificationQ.limit = PERPAGE_OF_THREAD_NOTIFICATION;
        
        if (theNotifications.count) [notificationQ whereKey:@"objectId" notContainedIn:objIdArray];
        
        if (theNotifications.count) [notificationQ whereKey:@"createdAt" lessThanOrEqualTo:lastNotifications.createdAt];
    }

    return notificationQ;
}

//帖子通知的Query
- (AVQuery *)_getQueryOfNotificationsOfFriendWithNotContainedIn:(NSArray *)theNotifications
                                                           type:(ALFriendNotificationType)type
                                                       isUnread:(BOOL)isUnread
                                                    isOnlyCount:(BOOL)isOnlyCount
{
    AVQuery *notificationQ = [NotificationOfThread query];
    
    [notificationQ whereKey:@"toUser" equalTo:[User currentUser]];
    [notificationQ whereKey:@"type" equalTo:[NSNumber numberWithInt:type]];
    
    //只显示未读的
    if (isUnread)  [notificationQ whereKey:@"isReaded" notEqualTo:@YES];
    else [notificationQ whereKey:@"isReaded" equalTo:@YES];
    
    [notificationQ whereKey:@"isDeleted" notEqualTo:@YES];
    
    //需要数据
    if (!isOnlyCount)
    {
//        [self _includeKeyWithNotificationOfFriend:notificationQ];
    
        theNotifications = [self _orderWithCreatedAtByDescendingWithArray:theNotifications];//updatedAt逆序
        
        NotificationOfFriend *lastNotifications = [theNotifications lastObject];
        
        NSArray *objIdArray = [self _objectIdListWithArray:theNotifications];
        
        [notificationQ orderByDescending:@"createdAt"];
        
        notificationQ.limit = PERPAGE_OF_FRIEND_NOTIFICATION;
        
        if (theNotifications.count) [notificationQ whereKey:@"objectId" notContainedIn:objIdArray];
        
        if (theNotifications.count) [notificationQ whereKey:@"createdAt" lessThanOrEqualTo:lastNotifications.createdAt];
    }
    
    return notificationQ;
}



+ (void)refreashNotificaitionWithBlock:(void(^)(NSDictionary *resultDictionary))resultBlock
{
    
    if (![ALUserEngine defauleEngine].user) return;
    
    [resultBlock copy];
    
    __block int count = 2;
    
    __block NSMutableDictionary *reslutDic = [[NSMutableDictionary dictionaryWithCapacity:count] retain];
    
    AVQuery *threadNotificationQ = [NotificationOfThread query];
    
    [threadNotificationQ whereKey:@"toUser" equalTo:[ALUserEngine defauleEngine].user];
    
    [threadNotificationQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [reslutDic setValue:objects forKey:@"threadNotification"];
        
        if (--count == 0)
        {
            [reslutDic release];
            if (resultBlock)
            {
                resultBlock(reslutDic);
            }
        }
    }];
    
    AVQuery *friendNotificationQ = [NotificationOfFriend query];
    
    [friendNotificationQ whereKey:@"toUser" equalTo:[ALUserEngine defauleEngine].user];
    
    [friendNotificationQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [reslutDic setValue:objects forKey:@"friendNotification"];
        
        if (--count == 0)
        {
            [reslutDic release];
            if (resultBlock)
            {
                resultBlock(reslutDic);
            }
        }
    }];
    
    [resultBlock release];
}


//更改通知未读状态为已读
- (void)updateUnreadStateOfNotification:(AVObject *)notification
                                  block:(PFBooleanResultBlock)resultBlock
{
    NSLog(@"%@",notification.allKeys);
    
    if ([notification isKindOfClass:[NotificationOfFriend class]] || [notification isKindOfClass:[NotificationOfThread class]])
    {
//        BOOL isReaded = [[notification objectForKey:@"isReaded"] boolValue];
        [notification setObject:@YES forKey:@"isReaded"];
        [notification saveInBackgroundWithBlock:resultBlock];
    }
    else
    {
        if (resultBlock)
        {
            resultBlock(NO,ALERROR(@"", -1, @"传入的参数不是一个通知！！！"));
        }
    }
}

//删除通知
- (void)deleteStateOfNotification:(AVObject *)notification
                            block:(PFBooleanResultBlock)resultBlock
{
    if ([notification respondsToSelector:@selector(setIsDeleted:)])
    {
        
        //        BOOL isReaded = [[notification objectForKey:@"isReaded"] boolValue];
        [notification setObject:@YES forKey:@"isDeleted"];
        [notification saveInBackgroundWithBlock:resultBlock];
    }
    else
    {
        if (resultBlock)
        {
            resultBlock(NO,ALERROR(@"", -1, @"传入的参数不是一个通知！！！"));
        }
    }
}

#pragma mark - 发送通知
//发送thread通知
- (void)_threadNotificationHandle:(NSNotification *)notification
{
    //保存提醒
    NSDictionary *userInfo = notification.userInfo;

    ALThreadNotificationType type = [userInfo[@"ALThreadNotificationType"] integerValue];
    
    NSArray *toUser = userInfo[@"toUser"];
    
    User *fromUser = userInfo[@"fromUser"];
    
    Thread *thread = userInfo[@"thread"];
    
    Post *post = userInfo[@"post"];
    
    Comment *comment = userInfo[@"comment"];
    
    
    NSMutableArray *nTs = [NSMutableArray array];
    for (User *user in toUser)
    {
        NotificationOfThread *notiThread = [NotificationOfThread object];
        if (toUser) notiThread.toUser = user;
        if (fromUser) notiThread.fromUser = fromUser;
        if (thread) notiThread.thread = thread;
        if (post) notiThread.post = post;
        if (comment) notiThread.comment = comment;
        if (type) notiThread.type = type;
        notiThread.isReaded = NO;
        [nTs addObject:notiThread];
    }

    if (nTs.count>0) [AVObject saveAllInBackground:nTs];
    
    
    //发通知
    AVQuery *installationQ = [AVInstallation query];
    [installationQ whereKey:@"owner" containedIn:toUser];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setValue:@"message.wav" forKey:@"sound"];
    
    [dic setValue:@"Increment" forKey:@"badge"];
    
    switch (type)
    {
        case ALThreadNotificationTypeOfThreadNewPost:
        {
            [dic setValue:@"您的提问有了新的回答" forKey:@"alert"];
        }
            break;
        case ALThreadNotificationTypeOfThreadNewFavicon:
        {
            [dic setValue:@"您的提问被收藏" forKey:@"alert"];
            
            // [pushThreadNotification setMessage:@"您的提问被收藏"];
        }
            break;
        case ALThreadNotificationTypeOfPostNewSupport:
        {
            [dic setValue:@"您的回答被赞" forKey:@"alert"];
            
            //  [pushThreadNotification setMessage:@"您的回答被赞"];
        }
            break;
        case ALThreadNotificationTypeOfPostNewComment:
        {
            [dic setValue:@"您的回答被评论" forKey:@"alert"];
            
            //  [pushThreadNotification setMessage:@"您的回答被评论"];
        }
            break;
        case ALThreadNotificationTypeOfPostToBestPost:
        {
            [dic setValue:@"您的回答被选为最佳答案" forKey:@"alert"];
            
            //  [pushThreadNotification setMessage:@"您的回答被选为最佳答案"];
        }
            break;
        case ALThreadNotificationTypeOfFaviconThreadNewPost:
        {
            [dic setValue:@"您收藏的问题有了新的回答" forKey:@"alert"];
            
            //  [pushThreadNotification setMessage:@"您收藏的问题有了新的回答"];
        }
            break;
        case ALThreadNotificationTypeOfFaviconThreadToBestPost:
        {
            [dic setValue:@"您收藏的问题选择了最佳答案" forKey:@"alert"];
            
            //  [pushThreadNotification setMessage:@"您收藏的问题选择了最佳答案"];
        }
            break;
        case ALThreadNotificationTypeOfFaviconThreadToClose:
        {
            [dic setValue:@"您收藏的问题已关闭" forKey:@"alert"];
            
            //  [pushThreadNotification setMessage:@"您收藏的问题已关闭"];
        }
            break;
        case ALThreadNotificationTypeOfAt:
        {
            [dic setValue:@"您被@了" forKey:@"alert"];
            
            //   [pushThreadNotification setMessage:@"您被@了"];
        }
            break;
        default:
        {
            [dic setValue:@"您收到一条新的消息" forKey:@"alert"];
            
            //    [pushThreadNotification setMessage:@"您收到一条新的消息"];
        }
            break;
    }

    [AVPush sendPushDataToQueryInBackground:installationQ withData:dic];

}

- (void)_friendNotificationHandle:(NSNotification *)notification
{
    
}

- (void)_includeKeyWithNotificationOfThread:(AVQuery *)notificationOfThreadQuery
{
    [notificationOfThreadQuery includeKey:@"toUser"];
    [notificationOfThreadQuery includeKey:@"fromUser"];
    [notificationOfThreadQuery includeKey:@"thread"];
    [notificationOfThreadQuery includeKey:@"post"];
    [notificationOfThreadQuery includeKey:@"comment"];
}

- (void)_includeKeyWithNotificationOfFriend:(AVQuery *)notificationOfFriendQuery
{
    [notificationOfFriendQuery includeKey:@"toUser"];
    [notificationOfFriendQuery includeKey:@"fromUser"];
}


#pragma mark - 排序
//updatedAt
- (NSArray *)_orderWithUpdatedAtByDescendingWithArray:(NSArray *)array//updatedAt逆排序
{
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(AVObject *obj1, AVObject *obj2){
        
        NSTimeInterval time = [obj1.updatedAt timeIntervalSinceDate:obj2.updatedAt];
        if (time < 0)//obj1<obj2
        {
            return NSOrderedDescending;//下行
        }
        if (time > 0)
        {
            return NSOrderedAscending;//上行
        }
        return NSOrderedSame;
    }];
    
    for (int i=0; i<sortedArray.count; i++)
    {
        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] updatedAt]);
    }
    
    return sortedArray;
}

- (NSArray *)_orderWithUpdatedAtByAscendingWithArray:(NSArray *)array//updatedAt顺排序
{
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(AVObject *obj1, AVObject *obj2){
        
        NSTimeInterval time = [obj1.updatedAt timeIntervalSinceDate:obj2.updatedAt];
        if (time > 0)//obj1<obj2
        {
            return NSOrderedDescending;//下行
        }
        if (time < 0)
        {
            return NSOrderedAscending;//上行
        }
        return NSOrderedSame;
    }];
    
    for (int i=0; i<sortedArray.count; i++)
    {
        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] updatedAt]);
    }
    
    return sortedArray;
}

//createdAt
- (NSArray *)_orderWithCreatedAtByDescendingWithArray:(NSArray *)array//逆排序
{
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(AVObject *obj1, AVObject *obj2){
        
        NSTimeInterval time = [obj1.createdAt timeIntervalSinceDate:obj2.createdAt];
        if (time < 0)//obj1<obj2
        {
            return NSOrderedDescending;//下行
        }
        if (time > 0)
        {
            return NSOrderedAscending;//上行
        }
        return NSOrderedSame;
    }];
    
    for (int i=0; i<sortedArray.count; i++)
    {
        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] createdAt]);
    }
    
    return sortedArray;
}

- (NSArray *)_orderWithCreatedAtByAscendingWithArray:(NSArray *)array//顺排序
{
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(AVObject *obj1, AVObject *obj2){
        
        NSTimeInterval time = [obj1.createdAt timeIntervalSinceDate:obj2.createdAt];
        if (time > 0)//obj1<obj2
        {
            return NSOrderedDescending;//下行
        }
        if (time < 0)
        {
            return NSOrderedAscending;//上行
        }
        return NSOrderedSame;
    }];
    
    for (int i=0; i<sortedArray.count; i++)
    {
        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] createdAt]);
    }
    
    return sortedArray;
}

- (NSArray *)_objectIdListWithArray:(NSArray *)array
{
    __block NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:array.count];
    
    [array enumerateObjectsUsingBlock:^(AVObject * obj, NSUInteger idx, BOOL *stop){
        
        [mutArr addObject:obj.objectId];
        
    }];
    
    return mutArr;
}
@end
