//
//  ALThreadSDK.m
//  PARSE_DEMO
//
//  Created by Albert on 13-9-18.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALThreadSDK.h"

@implementation ALThreadSDK

+ (void)registerLKSDK
{
    [Forum registerSubclass];
    [Thread registerSubclass];
    [ThreadType registerSubclass];
    [ThreadFlag registerSubclass];
    [Post registerSubclass];
    [ThreadContent registerSubclass];
    [Comment registerSubclass];
    [ThreadImage registerSubclass];
    [ThreadReportLog registerSubclass];
}

@end
