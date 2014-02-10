
//
//  ThreadFlag.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface ThreadFlag : AVObject <AVSubclassing>

@property (nonatomic, retain) NSString *name;//住房，考试，工作...

@property (nonatomic, assign) int state;//状态 -1:关闭 0:一般

@end
