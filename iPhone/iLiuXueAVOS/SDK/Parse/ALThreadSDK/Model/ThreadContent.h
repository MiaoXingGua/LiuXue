//
//  ThreadContent.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "ThreadImage.h"

@interface ThreadContent : AVObject <AVSubclassing>

@property (nonatomic, retain) NSString *text;

@property (nonatomic, retain) AVFile *voice;

@property (nonatomic, retain) AVRelation *images;//ThreadImage

@property (nonatomic, retain) AVFile *video;

@property (nonatomic, retain) AVGeoPoint *location;

@end
