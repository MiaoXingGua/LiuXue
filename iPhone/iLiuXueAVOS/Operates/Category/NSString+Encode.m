//
//  NSString+Encode.m
//  ALXMPPDemo
//
//  Created by Albert on 13-7-7.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "NSString+Encode.h"

@implementation NSString (Encode)

- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}

- (NSString*)URLDecodedString
{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
@end


@implementation NSString (timeStamp)

+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];//???
    [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *timeDesc = [dateformat stringFromDate:[NSDate date]];
    [dateformat release];
    
    return timeDesc;
}

@end