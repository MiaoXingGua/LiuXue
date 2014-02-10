//
//  MIDCreate.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-13.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "MIDCreate.h"

@implementation MIDCreate
NSString* _x_getCurrentTimeString()
{
    NSDateFormatter *dateformat=[[NSDateFormatter alloc] init];//???
    [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *timeDesc = [dateformat stringFromDate:[NSDate date]];
    return timeDesc;
}

//生成字符串
NSString* _x_getRandomStringGenerator(int len)
{
    const NSArray *arr = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:len];
    
    for (int i=0; i<len; i++) [str appendString:arr[arc4random()%arr.count]];
    
    return str;
}

NSString *getMID()
{
    return [NSString stringWithFormat:@"%@%@",_x_getCurrentTimeString(),_x_getRandomStringGenerator(11)];
}
@end
