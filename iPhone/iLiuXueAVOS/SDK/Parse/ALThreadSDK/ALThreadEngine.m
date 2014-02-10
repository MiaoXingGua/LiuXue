//
//  ALThreadEngine.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALThreadEngine.h"
#import "ALUserEngine.h"
#import "AVRelation+AddUniqueObject.h"


static ALThreadEngine *engine = nil;


const NSString * threadProperty = @"title content forum postUser lastPoster lastPostAt type flag tags price views viewsOfToday viewsOfYesterday location place state numberOfPosts posts numberOfFavicon";

@interface ALThreadEngine()
@property (nonatomic, retain) __block Thread *tempThread;
@property (nonatomic, retain) __block Post *tempPost;
@property (nonatomic, retain) __block Comment *tempComment;
@property (nonatomic, retain) NSDictionary *errorCode;
@end

@implementation ALThreadEngine

- (void)dealloc
{
    [_tempComment release];
    [_tempPost release];
    [_tempThread release];
    [super dealloc];
}

+ (ALThreadEngine *)defauleEngine
{
    if (!engine)
    {
        engine = [[ALThreadEngine alloc] init];
        engine.errorCode = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ErrorCode" ofType:@"plist"]] valueForKey:ERROR_CODE_KEY];
    }
    return engine;
}

#pragma mark - 通用接口
//检查积分
- (void)checkRemainderCreditWithPrice:(NSInteger)thePrice
                                block:(PFBooleanResultBlock)resultBlock
                              callback:(void(^)(BOOL success))callback
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    __block typeof (self) bself = self;
    [engine.user refreshInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        User *user = (User *)object;
        if (user.credits < 5+thePrice)
        {
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_CREDITS_IS_NOT_ENOUGH]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_CREDITS_IS_NOT_ENOUGH, errorInfo));
                
                if (callback)
                {
                    callback(NO);
                }
            }
        }
        else
        {
            if (callback)
            {
                callback(YES);
            }
        }
    }];
}

- (void)_cachePolicy:(AVQuery *)quert
{
//    quert.cachePolicy = kPFCachePolicyCacheElseNetwork;
}

#pragma mark - 写入接口
//发主题
- (void)sendThreadWithForum:(Forum *)theForum
                   andTitle:(NSString *)theTitle
                 andContent:(ThreadContent *)theContent
                    andType:(ThreadType *)theType
                       flag:(ThreadFlag *)theFlags
                       tags:(NSString *)theTags
                      price:(int)thePrice
                    atUsers:(NSArray *)users
                   latitude:(CGFloat)theLatitude
                  longitude:(CGFloat)theLongitude
                      place:(NSString *)thePlace
                      block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    
    //CC
//    [self checkRemainderCreditWithPrice:thePrice  block:resultBlock callback:^(BOOL success) {
//     //CC
//        if (success)
//        {
            Thread *newThread = [Thread object];
            if (theForum) newThread.forum = theForum;
            if (theTitle) newThread.title = theTitle;
//          NSLog(@"theContent=%@",theContent.objectId);
            if (theContent) newThread.content = theContent;
            if (theType) newThread.type = theType;
            if (theFlags) newThread.flag = theFlags;
            if (theTags) newThread.tags = theTags;
            if (thePrice) newThread.price = thePrice;
            
            if (thePlace) newThread.place = thePlace;
            if (theLatitude && theLongitude)
            {
                newThread.location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
            }
            
            newThread.views = 0;
            newThread.viewsOfToday = 0;
            newThread.viewsOfYesterday = 0;
            newThread.numberOfPosts = 0;
            newThread.numberOfFavicon = 0;
            newThread.state = 0;
            
            newThread.postUser = engine.user;
            newThread.lastPoster = engine.user;

            [newThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error)
                {
                    [newThread refresh];
//                    NSLog(@"%@",newThread.updatedAt);
                    newThread.lastPostAt = newThread.updatedAt;
                    [newThread saveEventually];
                    
                    //////////////////////CC//////////////////////
                    
                    //发通知给积分中心
//                    POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfSendThread, engine.user, -1*thePrice);
//                    //发帖数+1
//                    [engine.user.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//                        
//                        [object incrementKey:@"numberOfThreads"];
//                        [object saveEventually];
//                    }];
                    //////////////////////CC//////////////////////
                    
                    //At好友
                    if (users.count) POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfAt, users, engine.user, newThread, [NSNull null], [NSNull null]);
                }
                
                if (resultBlock)
                {
                    resultBlock(succeeded,error);
                }
            }];
//        }
//    }];

//    [resultBlock release];
}

//发回复
- (void)sendPostWithThread:(Thread *)theThread
                andContent:(ThreadContent *)theContent
                   atUsers:(NSArray *)users
                  latitude:(CGFloat)theLatitude
                 longitude:(CGFloat)theLongitude
                     place:(NSString *)thePlace
                     block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
    if (!theContent) return;
    
//    [resultBlock copy];

    [theThread fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        if (object)
        {
            Thread *theThread = (Thread *)object;
            
            self.tempPost = [Post object];
            self.tempPost.content = theContent;
            self.tempPost.postUser = engine.user;
            if (theLatitude && theLongitude)
            {
                self.tempPost.location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
            }
            if (thePlace) self.tempPost.place = thePlace;
            self.tempPost.numberOfSupports = 0;
            self.tempPost.numberOfComments = 0;
            self.tempPost.state = 0;
            self.tempPost.thread = theThread;
            
            __block typeof (self) bself = self;
            
            [self.tempPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                ///////////////////////////CC/////////////////////////
//                //主题回复数+1
//                theThread.numberOfPosts ++;
//                
//                //BUG:AVRelation 中的对象要有objectId!!!!!!
                [theThread.posts addObject:_tempPost];
                theThread.lastPoster = engine.user;
                //最后回复时间
                theThread.lastPostAt = _tempPost.createdAt;
                
//                [theThread saveEventually];
                [theThread saveEventually:^(BOOL succeeded, NSError *error) {
                    
                    if (!error)
                    {
//                        //用户回复数
//                        [engine.user.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//                            
//                            //user的发帖数+1
//                            [object incrementKey:@"numberOfPosts"];
//                            [object saveEventually];
//                        }];

                        //发通知给积分中心
                        POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfPost, engine.user, 0);
                    }
                
                    ///////////////////////////CC/////////////////////////
                
                    [theThread.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                        
                        User *toUser = (User *)object;//帖子的作者
                        if (![toUser.objectId isEqualToString:engine.user.objectId])//自己回复自己的主题不会发通知
                        {
                            //发通知给通知中心
                            POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfThreadNewPost, @[toUser], engine.user, theThread, bself.tempPost, [NSNull null]);
                        }
                    }];
                
                    if (resultBlock)
                    {
                        resultBlock(succeeded,error);
                    }
                    
                    //At好友
                    if (users.count) POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfAt, users, engine.user, theThread, bself.tempPost, [NSNull null]);
                    
                }];
            }];
        }
        else
        {
            if (resultBlock)
            {
                NSString *errorInfo = [self.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_THE_THREAD_IS_NOT_EXIST]];
                
                resultBlock(NO,ALERROR([self.errorCode valueForKey:@"domain"], ERROR_CODE_OF_THE_THREAD_IS_NOT_EXIST, errorInfo));
            }
        }
    }];

//    [resultBlock release];
}

//发评论
- (void)sendCommentWithPost:(Post *)thePost
                 andContent:(ThreadContent *)theContent
                    atUsers:(NSArray *)users
                      block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
    if (!theContent) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    [thePost fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
     
        if (object)
        {
            Post *thePost = (Post *)object;
            bself.tempComment = [Comment object];
            
            bself.tempComment.content = theContent;
            bself.tempComment.postUser = engine.user;
            bself.tempComment.state = 0;
            bself.tempComment.post = thePost;
            
            [bself.tempComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                //////////////////////////////CC/////////////////////////////////
                [thePost.comments addObject:_tempComment];
                [thePost setObject:engine.user forKey:@"lastCommenter"];
                //最后回复时间
                [thePost setObject:_tempPost.createdAt forKey:@"lastCommentAt"];
//                thePost.numberOfComments ++;//回复的的评论数+1
//                //        [thePost incrementKey:@"numberOfComments"];
//                
                [thePost saveEventually:^(BOOL succeeded, NSError *error) {
//
//                    if (!error)
//                    {
//                        [engine.user.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//                            
//                            //user的发帖数+1
//                            [object incrementKey:@"numberOfComments"];
//                            [object saveEventually];
//                        }];
//                        
//                        //发通知给积分中心
//                        POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfComment, engine.user, 0);
//                    }
                    //////////////////////////////CC/////////////////////////////////
                    if (resultBlock)
                    {
                        resultBlock(succeeded,error);
                    }
                    
                    [thePost.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                        
                        User *toUser = (User *)object;//回复的作者
                        [thePost.thread fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                            
                            Thread *thread = (Thread *)object;
                            
                            //发通知给通知中心
                            POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfPostNewComment, @[toUser], engine.user, thread, thePost, bself.tempComment);
                            
                            //At好友
                            if (users.count) POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfAt, users, engine.user, thread, thePost, bself.tempComment);
                            
                        }];
                    }];
                }];
            }];
        }
        else
        {
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_THE_POST_IS_NOT_EXIST]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_THE_POST_IS_NOT_EXIST, errorInfo));
            }
        }
    }];

//    [resultBlock release];
}

//发赞
- (void)sendSupportWithPost:(Post *)thePost
                      block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    
    [thePost fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
       
        if (object)
        {
            Post *thePost = (Post *)object;
            [thePost.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                
                //判断我是不是post作者（自己不能赞自己）
                if ([object.objectId isEqualToString:engine.user.objectId])
                {
                    //            if (resultBlock)
                    //            {
                    //                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_ALREADY_SUPPORT userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_ALREADY_SUPPORT],@"error":@"你不能赞你自己的回复"}]);
                    //            }
                    
                    if (resultBlock)
                    {
                        NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_THE_POST_IS_NOT_SUPPORT_YOUSELF_POST]];
                        
                        resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_THE_POST_IS_NOT_SUPPORT_YOUSELF_POST, errorInfo));
                    }
                }
                else
                {
                    //查找我赞过的帖子
                    NSLog(@"support=%@",engine.user.userFavicon.supports);
                    [engine.user.userFavicon.supports isExsitObject:thePost block:^(BOOL isExsit) {
                        
                        //已经赞过了
                        if (isExsit)
                        {
                            //                    if (resultBlock)
                            //                    {
                            //                        resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_ALREADY_SUPPORT userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_ALREADY_SUPPORT],@"error":@"你已经赞过该回复了了"}]);
                            //                    }
                            if (resultBlock)
                            {
                                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_ALREADY_SUPPORT]];
                                
                                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_ALREADY_SUPPORT, errorInfo));
                            }
                        }
                        else
                        {
                            
                            [engine.user.userFavicon.supports addUniqueObject:thePost block:^{
                                
                                [engine.user.userFavicon saveEventually:^(BOOL succeeded, NSError *error) {
                                    
                                    if (resultBlock)
                                    {
                                        resultBlock(succeeded,error);
                                    }
                                    
                                    if (!error)
                                    {
                                        //                                  thePost.numberOfSupports ++;
                                        [thePost incrementKey:@"numberOfSupports"];
                                        [thePost saveEventually];
                                        
                                        [engine.user.userCount incrementKey:@"numberOfSupports"];
                                        [engine.user.userCount saveEventually];
                                        
                                        //发通知给积分中心
                                        POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfSupport, engine.user, 0);
                                        
                                        
                                        [thePost.thread fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                                            
                                            Thread *thread = (Thread *)object;
                                            
                                            //发通知给通知中心
                                            POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfPostNewSupport, @[thePost.postUser], engine.user, thread, thePost, [NSNull null]);
                                        }];
                                    }
                                }];
                            }];
                        }
                    }];
                    
                    //            [[engine.user.userFavicon.supports query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    //                
                    //                BOOL isExsit = [AVRelation isExsitTheObject:thePost inObjects:objects];
                    //                
                    //                
                    //            }];
                }
            }];
        }
        else
        {
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_THE_POST_IS_NOT_EXIST]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_THE_POST_IS_NOT_EXIST, errorInfo));
            }
        }
        
    }];
    
//    [resultBlock release];
}

//举报
- (void)reportThread:(Thread *)theThread
              orPost:(Post *)thePost
           orCommnet:(Comment *)theComment
           andReason:(NSString *)theReason
               block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    
    ThreadReportLog *threadLog = [ThreadReportLog object];
    if (theThread) threadLog.thread = theThread;
    if (thePost) threadLog.post = thePost;
    if (theReason) threadLog.reason = theReason;
    if (theComment) threadLog.comment = theComment;
    threadLog.fromUser = engine.user;
    threadLog.state = 0;
    [threadLog saveEventually:resultBlock];
    
//    [resultBlock release];
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
    
//    for (int i=0; i<sortedArray.count; i++)
//    {
//        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] updatedAt]);
//    }
    
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
    
//    for (int i=0; i<sortedArray.count; i++)
//    {
//        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] updatedAt]);
//    }
    
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
    
//    for (int i=0; i<sortedArray.count; i++)
//    {
//        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] createdAt]);
//    }
    
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
    
//    for (int i=0; i<sortedArray.count; i++)
//    {
//        NSLog(@"sortedArray[%d]=%@",i,[sortedArray[i] createdAt]);
//    }
    
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

#pragma mark - 读取接口
//查看所有板块
- (void)getForumsWithBlock:(void(^)(NSArray *forums,NSError *error))resultBlock
{
//    [resultBlock copy];
    
    AVQuery *forumQ = [Forum query];
    
    [self _cachePolicy:forumQ];
    
    [forumQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

- (void)_includeKeyWithThread:(AVQuery *)threadQuery
{
    [threadQuery includeKey:@"content"];
    [threadQuery includeKey:@"postUser"];
    [threadQuery includeKey:@"forum"];
    [threadQuery includeKey:@"lastPoster"];
    [threadQuery includeKey:@"type"];
    [threadQuery includeKey:@"flag"];
}

//逆序 less   orderByDescending
//顺序 greater  orderByAscending
//查看主题列表
- (void)getThreadsWithForum:(Forum *)theForum
             notContainedIn:(NSArray *)theThreads
                      block:(void(^)(NSArray *threads,NSError *error))resultBlock
{
//    if (!theForum) return;
    
//    [resultBlock copy];
    
    AVQuery *threadQ = [Thread query];
    if (theThreads.count == 0)
    {
//        [self _cachePolicy:threadQ];
    }
//    AVQuery *threadQ = [AVQuery queryWithClassName:@"Thread"];
    
    if (theForum)
    {
        [threadQ whereKey:@"forum" equalTo:theForum];
    }

    [self _includeKeyWithThread:threadQ];

    theThreads = [self _orderWithUpdatedAtByDescendingWithArray:theThreads];//updatedAt逆序
    
    Thread *lastThread = [theThreads lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theThreads];
    
    [threadQ orderByDescending:@"lastPostAt"];
    [threadQ addDescendingOrder:@"createdAt"];
    
    threadQ.limit = PERPAGE_OF_THREAD;
    
    if (theThreads.count) [threadQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theThreads.count) [threadQ whereKey:@"lastPostAt" lessThanOrEqualTo:lastThread.lastPostAt];
    
    [threadQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (resultBlock) {
            resultBlock(objects,error);
        };
        
//        Thread *thread = objects[0];
//        [thread.content fetchIfNeeded];
//        id images = thread.content.images;
//        NSLog(@"images1=%@",[images class]);
    }];
    
//    [resultBlock release];
}

- (void)_includeKeyWithPost:(AVQuery *)postQuery
{
    [postQuery includeKey:@"content"];
    [postQuery includeKey:@"postUser"];
}

//查看回复列表
- (void)getPostsWithThread:(Thread *)theThread
            notContainedIn:(NSArray *)thePosts
                     block:(void(^)(NSArray *posts,NSError *error))resultBlock
{
    if (!theThread) return;
    
//    [resultBlock copy];
    
//    [theThread incrementKey:@"views"];
    [theThread fetchIfNeeded];
    theThread.views ++;
    [theThread saveEventually];

    AVQuery *postQ = [theThread.posts query];
    [self _cachePolicy:postQ];
//    [self _includeKeyWithPost:postQ];
    
    thePosts = [self _orderWithCreatedAtByAscendingWithArray:thePosts];//createdAt顺序
    
    Post *lastPost = [thePosts lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:thePosts];
    
    [postQ orderByAscending:@"createdAt"];
    
    postQ.limit = PERPAGE_OF_POST;
    
    if (thePosts.count) [postQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (thePosts.count) [postQ whereKey:@"createdAt" greaterThanOrEqualTo:lastPost.createdAt];
            
    [postQ findObjectsInBackgroundWithBlock:resultBlock];
   
//    [resultBlock release];
}

- (void)_includeKeyWithComment:(AVQuery *)commentQuery
{
    [commentQuery includeKey:@"postUser"];
}

//查看评论列表
- (void)getCommentsWithPost:(Post *)thePost
             notContainedIn:(NSArray *)theComments
                      block:(void(^)(NSArray *comments,NSError *error))resultBlock
{
    if (!thePost) return;
    
//    [resultBlock copy];
    
    theComments = [self _orderWithCreatedAtByAscendingWithArray:theComments];//createdAt顺序
    
    Comment *lastComment = [theComments lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theComments];
    
    AVQuery *commentQ = [thePost.comments query];
    [self _cachePolicy:commentQ];
//    [self _includeKeyWithComment:commentQ];
    
    [commentQ orderByAscending:@"createdAt"];
    
    commentQ.limit = PERPAGE_OF_COMMENT;
    
    if (theComments.count) [commentQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theComments.count) [commentQ whereKey:@"createdAt" greaterThanOrEqualTo:lastComment.createdAt];

    [commentQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

#pragma mark - 读取我的接口
//查看用户问题
//我的帖子
- (void)getMyThreadsNotContainedIn:(NSArray *)theThreads
                             block:(PFArrayResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    [self getThreadsWithUser:engine.user notContainedIn:theThreads block:resultBlock];
//    [resultBlock release];
}

- (void)getThreadsWithUser:(User *)theUser
            notContainedIn:(NSArray *)theThreads
                     block:(PFArrayResultBlock)resultBlock
{
//    [resultBlock copy];
    
    AVQuery *threadQ = [Thread query];
    [self _cachePolicy:threadQ];
    [threadQ whereKey:@"postUser" equalTo:theUser];
    
    [self _includeKeyWithThread:threadQ];
    
    theThreads = [self _orderWithCreatedAtByDescendingWithArray:theThreads];//creadtedAt逆序+lessthen
    
    Thread *lastThread = [theThreads lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theThreads];
    
    [threadQ orderByDescending:@"createdAt"];
    
    threadQ.limit = PERPAGE_OF_THREAD;
    
    if (theThreads.count) [threadQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theThreads.count) [threadQ whereKey:@"createdAt" lessThanOrEqualTo:lastThread.createdAt];
    
    [threadQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

//我的回答
- (void)getMyPostsNotContainedIn:(NSArray *)thePosts
                           block:(PFArrayResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    [self getPostsWithUser:engine.user notContainedIn:thePosts block:resultBlock];
//    [resultBlock release];
}

- (void)getPostsWithUser:(User *)theUser
          notContainedIn:(NSArray *)thePosts
                   block:(PFArrayResultBlock)resultBlock
{
//    [resultBlock copy];
    
    AVQuery *postQ = [Post query];
//    [self _cachePolicy:postQ];
    
    [postQ whereKey:@"postUser" equalTo:theUser];
    
    thePosts = [self _orderWithCreatedAtByDescendingWithArray:thePosts];//creadtedAt逆序+lessthen
    
    Post *lastPost = [thePosts lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:thePosts];
    
    [postQ orderByDescending:@"createdAt"];
    
    postQ.limit = PERPAGE_OF_POST;
    
    if (thePosts.count) [postQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (thePosts.count) [postQ whereKey:@"createdAt" lessThanOrEqualTo:lastPost.createdAt];
    
    [postQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

//我的最佳回答
- (void)getMyBestPostsNotContainedIn:(NSArray *)thePosts
                               block:(void(^)(NSArray *posts,NSError *error))resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    [self getBestPostsWithUser:engine.user notContainedIn:thePosts block:resultBlock];
//    [resultBlock release];
}

- (void)getBestPostsWithUser:(User *)theUser
              notContainedIn:(NSArray *)thePosts
                       block:(void(^)(NSArray *posts,NSError *error))resultBlock
{
//    [resultBlock copy];
    
    AVQuery *postQ = [Post query];
    [self _cachePolicy:postQ];
    
    [postQ whereKey:@"postUser" equalTo:theUser];
    
    thePosts = [self _orderWithCreatedAtByDescendingWithArray:thePosts];//creadtedAt逆序+lessthen
    
    Post *lastPost = [thePosts lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:thePosts];
    
    [postQ orderByDescending:@"createdAt"];
    
    postQ.limit = PERPAGE_OF_POST;
    
    [postQ whereKey:@"state" equalTo:@1];
    
    if (thePosts.count) [postQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (thePosts.count) [postQ whereKey:@"createdAt" lessThanOrEqualTo:lastPost.createdAt];
    
    [postQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

//我的评论
- (void)getMyCommentNotContainedIn:(NSArray *)theComments
                             block:(void(^)(NSArray *comments,NSError *error))resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    [self getCommentWithUser:engine.user notContainedIn:theComments block:resultBlock];
//    [resultBlock release];
}

- (void)getCommentWithUser:(User *)theUser
            notContainedIn:(NSArray *)theComments
                     block:(void(^)(NSArray *comments,NSError *error))resultBlock
{
//    [resultBlock copy];
    
    theComments = [self _orderWithCreatedAtByDescendingWithArray:theComments];//creadtedAt逆序+lessthen
    
    Comment *lastComment = [theComments lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theComments];
    
    AVQuery *commentQ = [Comment query];
    [self _cachePolicy:commentQ];
    
    [commentQ whereKey:@"postUser" equalTo:theUser];
    
//    [self _includeKeyWithComment:commentQ];
    
    [commentQ orderByDescending:@"createdAt"];
    
    commentQ.limit = PERPAGE_OF_COMMENT;
    
    if (theComments.count) [commentQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theComments.count) [commentQ whereKey:@"createdAt" lessThanOrEqualTo:lastComment.createdAt];
    
    [commentQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

//我的收藏
- (void)getMyFaviconThreadNotContainedIn:(NSArray *)theThreads
                                   block:(void(^)(NSArray *threads,NSError *error))resultBlock
{
//    [resultBlock copy];
    
    [self getFaviconThreadWithUser:[ALUserEngine defauleEngine].user notContainedIn:theThreads block:resultBlock];
    
//    [resultBlock release];
}

- (void)getFaviconThreadWithUser:(User *)theUser
                  notContainedIn:(NSArray *)theThreads
                           block:(void(^)(NSArray *threads,NSError *error))resultBlock
{
//    [resultBlock copy];
    __block typeof (self) bself = self;
    [theUser.userFavicon fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        if (object)
        {
//            UserFavicon *userFavicon = (UserFavicon *)object;
//            
//            AVQuery *threadFQ = [userFavicon.threads query];
            
            AVQuery *threadFQ = [[object relationforKey:@"threads"] query];
            [bself _cachePolicy:threadFQ];
            
            [bself _includeKeyWithThread:threadFQ];
            
            
            NSArray *threads = [bself _orderWithCreatedAtByDescendingWithArray:theThreads];//creadtedAt逆序+lessthen
            
            Thread *lastThread = [threads lastObject];
            
            NSArray *objIdArray = [bself _objectIdListWithArray:threads];
            
            [threadFQ orderByDescending:@"createdAt"];
            
            threadFQ.limit = PERPAGE_OF_FAVICON;
            
            if (threads.count) [threadFQ whereKey:@"objectId" notContainedIn:objIdArray];
            
            if (threads.count) [threadFQ whereKey:@"createdAt" lessThanOrEqualTo:lastThread.createdAt];
            
            [threadFQ findObjectsInBackgroundWithBlock:resultBlock];
        }
        
    }];
    
//    [resultBlock release];
}

#pragma mark - 修改接口

//关闭主题
- (void)closeThread:(Thread *)theThread
              block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    //主题发起人
    [theThread.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
       
        User *master = (User *)object;
        if (![master.objectId isEqualToString:engine.user.objectId])
        {
            //我不是发帖人
//            if (resultBlock)
//            {
//                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_CREDITS_IS_NOT_ENOUGH],@"error":@"你不是给该帖子的作者，不能执行这个操作"}]);
//            }
            
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER, errorInfo));
            }
            
            return;
        }
        theThread.state = -1;
        [theThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (resultBlock)
            {
                resultBlock(succeeded,error);
            }
            
        }];
    }];
    
//    [resultBlock release];
}

//删除主题
- (void)deleteThread:(Thread *)theThread
               block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    //主题发起人
    [theThread.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        User *master = (User *)object;
        if (![master.objectId isEqualToString:engine.user.objectId])
        {
            //我不是发帖人
//            if (resultBlock)
//            {
//                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER],@"error":@"你不是给该帖子的作者，不能执行这个操作"}]);
//            }
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER, errorInfo));
            }
            return;
        }
        
        [theThread deleteEventually];
        
        [master.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
            UserCount *userCount = (UserCount *)object;
            if (userCount.numberOfThreads > 0)
            {
                [userCount incrementKey:@"numberOfThreads" byAmount:@-1];
                [userCount saveEventually];
            }
            
        }];
        
        if (resultBlock)
        {
            resultBlock(YES,error);
        }
        
    }];
    
//    [resultBlock release];
}

//删除回复
- (void)deletePost:(Post *)thePost
             block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    //回复发起人
    [thePost.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        User *master = (User *)object;
        if (![master.objectId isEqualToString:engine.user.objectId])
        {
            //我不是回复人
//            if (resultBlock)
//            {
//                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_YOU_ARE_NOT_THE_POST_POSTUSER userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_YOU_ARE_NOT_THE_POST_POSTUSER],@"error":@"你不是给该回复的作者，不能执行这个操作"}]);
//            }
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_YOU_ARE_NOT_THE_POST_POSTUSER]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_YOU_ARE_NOT_THE_POST_POSTUSER, errorInfo));
            }
            return;
        }
        
        [thePost deleteEventually];
        
//        [master.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//            
//            UserCount *userCount = (UserCount *)object;
//            if (userCount.numberOfPosts > 0)
//            {
//                [userCount incrementKey:@"numberOfPosts" byAmount:@-1];
//                [userCount saveEventually];
//            }
//        }];
        
        if (resultBlock)
        {
            resultBlock(YES,error);
        }
        
    }];
    
//    [resultBlock release];
}

//删除评论
- (void)deleteComment:(Comment *)theComment
                block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    
    //回复发起人
    [theComment.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        User *master = (User *)object;
        if (![master.objectId isEqualToString:engine.user.objectId])
        {
            //我不是回复人
//            if (resultBlock)
//            {
//                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_YOU_ARE_NOT_THE_COMMENT_POSTUSER userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_YOU_ARE_NOT_THE_COMMENT_POSTUSER],@"error":@"你不是给该评论的作者，不能执行这个操作"}]);
//            }
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_YOU_ARE_NOT_THE_COMMENT_POSTUSER]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_YOU_ARE_NOT_THE_COMMENT_POSTUSER, errorInfo));
            }
            return;
        }
        
        [theComment deleteEventually];
        
        [master.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
            UserCount *userCount = (UserCount *)object;
            if (userCount.numberOfComments > 0)
            {
                [userCount incrementKey:@"numberOfComments" byAmount:@-1];
                [userCount saveEventually];
            }
        }];
        
        if (resultBlock)
        {
            resultBlock(YES,error);
        }
        
    }];
    
    [resultBlock release];
}

//编辑修改问题
- (void)updateThread:(Thread *)theThread
            andTitle:(NSString *)theTitle
          andContent:(ThreadContent *)theContent
             andType:(ThreadType *)theType
                flag:(ThreadFlag *)theFlags
                tags:(NSString *)theTags
               price:(int)thePrice
            latitude:(CGFloat)theLatitude
           longitude:(CGFloat)theLongitude
               place:(NSString *)thePlace
               block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    
//    __block typeof (self) bself = self;
    
    Thread *newThread = [Thread object];

    if (theTitle) newThread.title = theTitle;
    if (theContent) newThread.content = theContent;
    if (theType) newThread.type = theType;
    if (theFlags) newThread.flag = theFlags;
    if (theTags) newThread.tags = theTags;
    if (thePrice) newThread.price = thePrice;
    if (theLatitude && theLongitude)
    {
        newThread.location = [AVGeoPoint geoPointWithLatitude:theLatitude longitude:theLongitude];
    }
    if (thePlace) newThread.place = thePlace;
    
    newThread.postUser = engine.user;
    newThread.lastPoster = engine.user;
    newThread.state = 0;
    
    [newThread saveInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

//收藏主题
- (void)faviconThread:(Thread *)theThread
                block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    
    [engine.user.userFavicon fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        
        UserFavicon *userFavicon = (UserFavicon *)object;
        
        //是否已经收藏过
        [userFavicon.threads isExsitObject:theThread block:^(BOOL isExsit) {
            
            if (isExsit)
            {
//                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_ALREADY_FAVICON userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_ALREADY_FAVICON],@"error":@"你已收藏该主题"}]);
                if (resultBlock)
                {
                    NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_ALREADY_FAVICON]];
                    
                    resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_ALREADY_FAVICON, errorInfo));
                }
            }
            else
            {
                //用户收藏帖子
                [userFavicon.threads addUniqueObject:theThread block:^{
                    
                    [userFavicon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                       
                        if (resultBlock)
                        {
                            resultBlock(succeeded,error);
                        }
                        
                        if (!error && succeeded)
                        {
                            //增加收藏数(主题)
                            [theThread incrementKey:@"numberOfFavicon"];
                            [theThread saveEventually];
                            
                            //增加收藏数(人)
//                            [engine.user.userCount incrementKey:@"numberOfFavicon"];
//                            [engine.user.userCount saveEventually];
                        }
                    }];
                }];
            }
        }];
    }];
    
//    [resultBlock release];
}

- (void)unfaviconThread:(Thread *)theThread
                  block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    
//    NSLog(@"id = %@",theThread.objectId);
//    NSLog(@"threads = %@",engine.user.userFavicon.threads);
    [engine.user.userFavicon.threads removeObject:theThread];
    [engine.user.userFavicon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (resultBlock)
        {
            resultBlock(succeeded,error);
        }
        
        if (!error && succeeded)
        {
            //减少收藏数(主题)
            [theThread fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                
                Thread *thread = (Thread *)object;
                if (thread.numberOfFavicon > 0)
                {
                    [thread incrementKey:@"numberOfFavicon" byAmount:@-1];
                    [thread saveEventually];
                }
                
            }];
            
            
            //减少收藏数(人)
//            [engine.user.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//                
//                UserCount *userCount = (UserCount *)object;
//                if (userCount.numberOfFavicon > 0)
//                {
//                    [userCount incrementKey:@"numberOfFavicon" byAmount:@-1];
//                    [userCount saveEventually];
//                }
//            }];
        }
    }];
    
//    [resultBlock release];
}



//设置最佳答案
- (void)setBestAnswernWithThread:(Thread *)theThread
                         andPost:(Post *)thePost
                           block:(PFBooleanResultBlock)resultBlock
{
    ALUserEngine *engine = [ALUserEngine defauleEngine];
    if (![engine isLoggedIn]) return;
    
//    [resultBlock copy];
    __block typeof (self) bself = self;
    [theThread.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
       
        User *master = (User *)object;
        if (![master.objectId isEqualToString:engine.user.objectId])
        {
            //我不是发帖人
//            if (resultBlock)
//            {
//                resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER],@"error":@"你不是给该帖子的作者，不能执行这个操作"}]);
//            }
            
            if (resultBlock)
            {
                NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER]];
                
                resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER, errorInfo));
            }
            return;
        }
        
        //这个回复(post)属于这个主题(thread)
        [theThread.posts isExsitObject:thePost block:^(BOOL isExsit) {
            
            //这个回复不属于属于这个主题
            if (!isExsit)
            {
                //我不是发帖人
//                if (resultBlock)
//                {
//                    resultBlock(NO,[NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_OF_THE_POST_IS_NOT_IN_THE_THREAD userInfo:@{@"code":[NSNumber numberWithInt:ERROR_CODE_OF_THE_POST_IS_NOT_IN_THE_THREAD],@"error":@"这个post不数据这个thread"}]);
//                }
                
                if (resultBlock)
                {
                    NSString *errorInfo = [bself.errorCode valueForKey:[NSString stringWithFormat:@"%d",ERROR_CODE_OF_THE_POST_IS_NOT_IN_THE_THREAD]];
                    
                    resultBlock(NO,ALERROR([bself.errorCode valueForKey:@"domain"], ERROR_CODE_OF_THE_POST_IS_NOT_IN_THE_THREAD, errorInfo));
                }
                return ;
            }
            else
            {
                theThread.state = 1;//完成
                
//                NSLog(@"objId=%@",thePost.objectId);
                thePost.state = 1;//最佳答案
                [thePost saveEventually:^(BOOL succeeded, NSError *error) {
                    
//                    NSLog(@"error=%@",error);
                    
                }];
                //            [thePost.postUser.userCount fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                //
                //
                //                [object incrementKey:@"numberOfBestPosts"];
                //                [object saveEventually];
                //            }];
                
                [theThread saveEventually:^(BOOL succeeded, NSError *error) {
                    
                    if (!error)
                    {
                        
                        //回复的时间载15分钟之内
                        if ([thePost.createdAt timeIntervalSinceDate:theThread.createdAt] <= 15*60)
                        {
                            //发通知给积分中心
                            POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfBecomeExcellentAnswern, thePost.postUser, -1*theThread.price);
                        }
                        else
                        {
                            //发通知给积分中心(对回答人)
                            POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfBecomeBestAnswern, thePost.postUser, -1*theThread.price);
                        }
                        
                        //发通知给积分中心(对主题作者)
                        POST_NOTIFICATION_CREDITS_CHANGE(ALCreditRuleTypeOfAppointBestAnswern, theThread.postUser, 0);
                        
                        [thePost.postUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                            
                            User *toUser = (User *)object;
                            
                            //发通知给通知中心
                            POST_NOTIFICATION_THREAD_NOTIFICATION(ALThreadNotificationTypeOfPostToBestPost, @[toUser], engine.user, theThread, thePost, [NSNull null]);
                            
                        }];
                        
                    }
                    
                    if (resultBlock)
                    {
                        resultBlock(succeeded,error);
                    }
                    
                }];
            }

        }];
    }];
    
//    [resultBlock release];
}

- (void)setUnbestAnswernWithThread:(Thread *)theThread
                           andPost:(Post *)thePost
                             block:(PFBooleanResultBlock)resultBlock
{
    
}

#pragma mark - 搜索
//搜索问题
- (void)searchThreadsWithTags:(NSString *)theTags
               notContainedIn:(NSArray *)theThreads
                        block:(PFArrayResultBlock)resultBlock
{
//    [resultBlock copy];
    
    AVQuery *threadQ = [Thread query];
    [self _cachePolicy:threadQ];
    
    [threadQ whereKey:@"tags" matchesRegex:[NSString stringWithFormat:@".*%@.*",theTags]];
    
    [self _includeKeyWithThread:threadQ];
    
    theThreads = [self _orderWithCreatedAtByDescendingWithArray:theThreads];//creadtedAt逆序+lessthen
    
    Thread *lastThread = [theThreads lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theThreads];
    
    [threadQ orderByDescending:@"updatedAt"];
    
    threadQ.limit = PERPAGE_OF_THREAD;
    
    if (theThreads.count) [threadQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theThreads.count) [threadQ whereKey:@"updatedAt" lessThanOrEqualTo:lastThread.createdAt];
    
    [threadQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

- (void)searchThreadsWithKeyword:(NSString *)theKeyword
                  notContainedIn:(NSArray *)theThreads
                           block:(PFArrayResultBlock)resultBlock
{
//    [resultBlock copy];
    
    AVQuery *threadQ = [Thread query];
    [self _cachePolicy:threadQ];
    
    [threadQ whereKey:@"title" matchesRegex:[NSString stringWithFormat:@".*%@.*",theKeyword]];
    
    [self _includeKeyWithThread:threadQ];
    
    theThreads = [self _orderWithCreatedAtByDescendingWithArray:theThreads];//creadtedAt逆序+lessthen
    
    Thread *lastThread = [theThreads lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theThreads];
    
    [threadQ orderByDescending:@"updatedAt"];
    
    threadQ.limit = PERPAGE_OF_THREAD;
    
    if (theThreads.count) [threadQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theThreads.count) [threadQ whereKey:@"updatedAt" lessThanOrEqualTo:lastThread.createdAt];
    
    [threadQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}

//复合查找帖字
- (void)searchThreadsWithSearchInfo:(NSDictionary *)searchInfo
                     notContainedIn:(NSArray *)theThreads
                              block:(PFArrayResultBlock)resultBlock
{
//    [resultBlock copy];
    
    AVQuery *threadQ = [Thread query];
    [self _cachePolicy:threadQ];
    
    for (NSString *key in searchInfo.allKeys)
    {
        
        if ([key rangeOfString:@"[like]"].location != NSNotFound)
        {
            NSString *temKey = [key substringToIndex:[key rangeOfString:@"[like]"].location];
            
            if ([threadProperty rangeOfString:temKey].location != NSNotFound)
            {
                [threadQ whereKey:temKey matchesRegex:[NSString stringWithFormat:@".*%@.*",searchInfo[key]]];
            }
        }
        else if ([key rangeOfString:@"[min]"].location != NSNotFound)
        {
            NSString *temKey = [key substringToIndex:[key rangeOfString:@"[min]"].location];
            
            if ([threadProperty rangeOfString:temKey].location != NSNotFound)
            {
                [threadQ whereKey:temKey lessThan:searchInfo[key]];
            }

        }
        else if ([key rangeOfString:@"[max]"].location != NSNotFound)
        {
            NSString *temKey = [key substringToIndex:[key rangeOfString:@"[max]"].location];
            
            if ([threadProperty rangeOfString:temKey].location != NSNotFound)
            {
                [threadQ whereKey:temKey greaterThan:searchInfo[key]];
            }
        }
        else if ([key rangeOfString:@"primaryOrderByAscending"].location != NSNotFound)
        {
            [threadQ orderByAscending:searchInfo[@"primaryOrderByAscending"]];
            
        }
        else if ([key rangeOfString:@"secondaryOrderByAscending"].location != NSNotFound)
        {
            [threadQ addAscendingOrder:searchInfo[@"secondaryOrderByAscending"]];
        }
        
        else if ([key rangeOfString:@"primaryOrderByDescending"].location != NSNotFound)
        {
            [threadQ orderByDescending:searchInfo[@"primaryOrderByDescending"]];
            
        }
        else if ([key rangeOfString:@"secondaryOrderByDescending"].location != NSNotFound)
        {
            [threadQ addDescendingOrder:searchInfo[@"secondaryOrderByDescending"]];
        }
        else
        {
            if ([threadProperty rangeOfString:key].location != NSNotFound)
            {
                [threadQ whereKey:key equalTo:searchInfo[key]];
            }
        }
    }
    
//    [threadQ orderByAscending:@"price"];
    
    [self _includeKeyWithThread:threadQ];
    
    theThreads = [self _orderWithCreatedAtByDescendingWithArray:theThreads];//creadtedAt逆序+lessthen
    
    Thread *lastThread = [theThreads lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theThreads];
    
    [threadQ addDescendingOrder:@"updatedAt"];
    
    threadQ.limit = PERPAGE_OF_THREAD;
    
    if (theThreads.count) [threadQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theThreads.count) [threadQ whereKey:@"updatedAt" lessThanOrEqualTo:lastThread.createdAt];
    
    [threadQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (resultBlock) {
            resultBlock(objects,error);
        };
//        Thread *thread = objects[0];
//        [thread.content fetchIfNeeded];
//        id images = thread.content.images;
//        NSLog(@"images2=%@",[images class]);
    }];
    
//    [resultBlock release];

}

//热门问答
- (void)getHotQuestionNotContainedIn:(NSArray *)theThreads
                               block:(PFArrayResultBlock)resultBlock
{
//    [resultBlock copy];
    
    AVQuery *threadQ = [Thread query];
    [self _cachePolicy:threadQ];
    
    [threadQ orderByDescending:@"viewsOfToday"];
    
    [self _includeKeyWithThread:threadQ];
    
    theThreads = [self _orderWithCreatedAtByDescendingWithArray:theThreads];//creadtedAt逆序+lessthen
    
    Thread *lastThread = [theThreads lastObject];
    
    NSArray *objIdArray = [self _objectIdListWithArray:theThreads];
    
    [threadQ orderByDescending:@"updatedAt"];
    
    threadQ.limit = PERPAGE_OF_THREAD;
    
    if (theThreads.count) [threadQ whereKey:@"objectId" notContainedIn:objIdArray];
    
    if (theThreads.count) [threadQ whereKey:@"updatedAt" lessThanOrEqualTo:lastThread.createdAt];
    
    [threadQ findObjectsInBackgroundWithBlock:resultBlock];
    
//    [resultBlock release];
}



@end
