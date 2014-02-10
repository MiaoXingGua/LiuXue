//
//  TitleRule.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface TitleRule : AVObject <AVSubclassing>//待续

@property (nonatomic, assign) int level;

@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSString *series;//系列名

@end
