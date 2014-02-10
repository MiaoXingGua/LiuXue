//
//  UserFavicon.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@class Thread;

@interface UserFavicon : AVObject <AVSubclassing>

@property (nonatomic, retain) AVRelation *threads;

@property (nonatomic, retain) AVRelation *supports;

@end
