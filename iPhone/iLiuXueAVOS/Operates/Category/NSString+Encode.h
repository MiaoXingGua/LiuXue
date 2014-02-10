//
//  NSString+Encode.h
//  ALXMPPDemo
//
//  Created by Albert on 13-7-7.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>

//UTF8编码
@interface NSString (Encode)

- (NSString *)URLDecodedString;
- (NSString *)URLEncodedString;

@end

//时间戳
@interface NSString (timeStamp)

+ (NSString*)getCurrentTimeString;

@end
