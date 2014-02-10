//
//  ALParseConfig.h
//  PARSE_DEMO
//
//  Created by Albert on 13-10-7.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#ifndef PARSE_DEMO_ALParseConfig_h
#define PARSE_DEMO_ALParseConfig_h

#define ALERROR(_domain,_code,_error) !_error ? ([NSError errorWithDomain:_domain code:_code userInfo:@{@"code":[NSNumber numberWithInteger:_code],@"error":[NSNull null]}]) : ([NSError errorWithDomain:_domain code:_code userInfo:@{@"code":[NSNumber numberWithInteger:_code],@"error":_error}])

#define ERROR_CODE_KEY          @"alparse"                       //ERROR的domain
#define ERROR_CODE_OF_ALREADY_SUPPORT                           120001 //该用户已经赞过该帖
#define ERROR_CODE_OF_ALREADY_FAVICON                           120002 //该用户已经收藏该帖
#define ERROR_CODE_OF_CREDITS_IS_NOT_ENOUGH                     120003 //积分不足
#define ERROR_CODE_OF_YOU_ARE_NOT_THE_THEAD_POSTUSER            120004 //你不是该帖子的作者
#define ERROR_CODE_OF_YOU_ARE_NOT_THE_POST_POSTUSER             120005 //你不是该回复的作者
#define ERROR_CODE_OF_YOU_ARE_NOT_THE_COMMENT_POSTUSER          120006 //你不是该评论的作者
#define ERROR_CODE_OF_THE_POST_IS_NOT_IN_THE_THREAD             120007 //这个post不数据这个thread
#define ERROR_CODE_OF_THE_POST_IS_NOT_SUPPORT_YOUSELF_POST      120008 //您不能赞您自己发的回复
#define ERROR_CODE_OF_THE_THREAD_IS_NOT_EXIST    120009 //此主题已不存在
#define ERROR_CODE_OF_THE_POST_IS_NOT_EXIST      120010 //此回复已不存在
#define ERROR_CODE_OF_THE_POST_IS_NOT_COMMENT      120011 //此评论已不存在
#define ERROR_CODE_OF_TOKEN_IS_EXIST                           120021 //token已经被使用

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [[self alloc] init]; \
} \
} \
\
return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [super allocWithZone:zone]; \
return shared##classname; \
} \
} \
\
return nil; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
} \
\
- (id)retain \
{ \
return self; \
} \
\
- (NSUInteger)retainCount \
{ \
return NSUIntegerMax; \
} \
\
- (void)release \
{ \
} \
\
- (id)autorelease \
{ \
return self; \
}


#endif
