//
//  ThreadImage.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface ThreadImage : AVObject <AVSubclassing>

@property (nonatomic, retain) AVFile *image;

@property (nonatomic, retain) NSString *imageSize;

@property (nonatomic, assign) int state;//状态 -1:关闭 0:一般

@end
