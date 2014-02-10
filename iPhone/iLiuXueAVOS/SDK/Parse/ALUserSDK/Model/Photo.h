//
//  Photo.h
//  PARSE_DEMO
//
//  Created by Albert on 13-10-19.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface Photo : AVObject <AVSubclassing>

@property (nonatomic, retain) AVFile *image;
@property (nonatomic, retain) NSString *description;

@end
