//
//  ALThreadEngine.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forum.h"
#import "Thread.h"
#import "ThreadType.h"
#import "ThreadFlag.h"
#import "Post.h"
#import "Comment.h"
#import "ThreadContent.h"
//#import "ALThreadContent.h"
#import "ThreadReportLog.h"
#import "ALThreadConfig.h"

#define PERPAGE_OF_THREAD 10
#define PERPAGE_OF_POST 10
#define PERPAGE_OF_COMMENT 10
#define PERPAGE_OF_FAVICON 100000


@interface ALThreadEngine : NSObject

/////////////////////////////////
/////////////////////////////////
/////////////初始化///////////////
/////////////////////////////////
/////////////////////////////////

+ (instancetype)defauleEngine;

/////////////////////////////////
/////////////////////////////////
/////////////写入接口/////////////
/////////////////////////////////
/////////////////////////////////

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
                      block:(PFBooleanResultBlock)resultBlock;

//发回复
- (void)sendPostWithThread:(Thread *)theThread
                andContent:(ThreadContent *)theContent
                   atUsers:(NSArray *)users
                  latitude:(CGFloat)theLatitude
                 longitude:(CGFloat)theLongitude
                     place:(NSString *)thePlace
                     block:(PFBooleanResultBlock)resultBlock;

//发评论
- (void)sendCommentWithPost:(Post *)thePost
                 andContent:(ThreadContent *)theContent
                    atUsers:(NSArray *)users
                      block:(PFBooleanResultBlock)resultBlock;
//发赞
- (void)sendSupportWithPost:(Post *)thePost
                      block:(PFBooleanResultBlock)resultBlock;

//举报帖子
- (void)reportThread:(Thread *)theThread
              orPost:(Post *)thePost
           andReason:(NSString *)reason
               block:(PFBooleanResultBlock)resultBlock;

/////////////////////////////////
/////////////////////////////////
/////////////读取接口/////////////
/////////////////////////////////
/////////////////////////////////

//查看所有板块
- (void)getForumsWithBlock:(void(^)(NSArray *forums,NSError *error))resultBlock;

//查看主题列表
- (void)getThreadsWithForum:(Forum *)theForum
             notContainedIn:(NSArray *)theThreads
                      block:(void(^)(NSArray *threads,NSError *error))resultBlock;


//查看回复列表
- (void)getPostsWithThread:(Thread *)theThread
            notContainedIn:(NSArray *)thePosts
                    block:(void(^)(NSArray *posts,NSError *error))resultBlock;

//查看评论列表
- (void)getCommentsWithPost:(Post *)thePost
             notContainedIn:(NSArray *)theComments
                      block:(void(^)(NSArray *comments,NSError *error))resultBlock;

//我的帖子
- (void)getMyThreadsNotContainedIn:(NSArray *)theThreads
                             block:(void(^)(NSArray *threads,NSError *error))resultBlock;

- (void)getThreadsWithUser:(User *)theUser
            notContainedIn:(NSArray *)theThreads
                     block:(void(^)(NSArray *threads,NSError *error))resultBlock;

//我的回答
- (void)getMyPostsNotContainedIn:(NSArray *)thePosts
                           block:(void(^)(NSArray *posts,NSError *error))resultBlock;
- (void)getPostsWithUser:(User *)theUser
          notContainedIn:(NSArray *)thePosts
                   block:(void(^)(NSArray *posts,NSError *error))resultBlock;

//我的最佳回答
- (void)getMyBestPostsNotContainedIn:(NSArray *)thePosts
                               block:(void(^)(NSArray *posts,NSError *error))resultBlock;
- (void)getBestPostsWithUser:(User *)theUser
              notContainedIn:(NSArray *)thePosts
                       block:(void(^)(NSArray *posts,NSError *error))resultBlock;
//我的评论
- (void)getMyCommentNotContainedIn:(NSArray *)theComments
                             block:(void(^)(NSArray *comments,NSError *error))resultBlock;

- (void)getCommentWithUser:(User *)theUser
            notContainedIn:(NSArray *)theComments
                     block:(void(^)(NSArray *comments,NSError *error))resultBlock;

//我的收藏
- (void)getMyFaviconThreadNotContainedIn:(NSArray *)theThreads
                                   block:(void(^)(NSArray *threads,NSError *error))resultBlock;

- (void)getFaviconThreadWithUser:(User *)theUser
                  notContainedIn:(NSArray *)theThreads
                           block:(void(^)(NSArray *threads,NSError *error))resultBlock;

//搜索问题
- (void)searchThreadsWithTags:(NSString *)theTags
               notContainedIn:(NSArray *)theThreads
                        block:(PFArrayResultBlock)resultBlock;

- (void)searchThreadsWithKeyword:(NSString *)theKeyword
                  notContainedIn:(NSArray *)theThreads
                           block:(PFArrayResultBlock)resultBlock;


//@{@"fid":[NSString stringWithFormat:@"%d",FALDZFidOfBanner],@"order":@"dateline"}
//@{@"realname[like]":@[@"123",@"456",@"789"]}
//@{@"score[min]":@"100",@"score[max]":@"10000"}

//复合查找帖字
- (void)searchThreadsWithSearchInfo:(NSDictionary *)searchInfo
                     notContainedIn:(NSArray *)theThreads
                              block:(PFArrayResultBlock)resultBlock;

//热门问答
- (void)getHotQuestionNotContainedIn:(NSArray *)theThreads
                               block:(PFArrayResultBlock)resultBlock;


/////////////////////////////////
/////////////////////////////////
/////////////修改接口/////////////
/////////////////////////////////
/////////////////////////////////



//设置最佳答案
- (void)setBestAnswernWithThread:(Thread *)theThread
                         andPost:(Post *)thePost
                           block:(PFBooleanResultBlock)resultBlock;

//取消最佳答案
- (void)setUnbestAnswernWithThread:(Thread *)theThread
                           andPost:(Post *)thePost
                             block:(PFBooleanResultBlock)resultBlock;

//关闭主题
- (void)closeThread:(Thread *)theThread
              block:(PFBooleanResultBlock)resultBlock;

//打开主题
- (void)openThread:(Thread *)theThread
              block:(PFBooleanResultBlock)resultBlock;

//删除主题
- (void)deleteThread:(Thread *)theThread
               block:(PFBooleanResultBlock)resultBlock;

//删除回复
- (void)deletePost:(Post *)thePost
             block:(PFBooleanResultBlock)resultBlock;

//删除评论
- (void)deleteComment:(Comment *)theComment
                block:(PFBooleanResultBlock)resultBlock;

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
               block:(PFBooleanResultBlock)resultBlock;

//收藏主题
- (void)faviconThread:(Thread *)theThread
                block:(PFBooleanResultBlock)resultBlock;

//取消收藏主题
- (void)unfaviconThread:(Thread *)theThread
                  block:(PFBooleanResultBlock)resultBlock;


@end
