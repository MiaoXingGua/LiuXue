//
//  WJSort.h
//  pinyinSort
//
//  Created by jay on 12-8-8.
//  Copyright (c) 2012年 jay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJSort : NSObject
-(NSString*)stringWithStringSort:(NSString*)longString;//将一个字符串排序，并返回一个字符串，适用于输入排序输出结果。
-(NSArray*)arrayWithStringSort:(NSString*)longString;//将一个字符串排序，并返回一个数组，适用于输入排序输出列表调用。
-(NSArray*)arrayWithStringArraySort:(NSArray*)aArray;//将一个数组排序，并返回一个数组，适用于列表排序。
-(NSString*)stringWithStringArraySort:(NSArray*)aArray;//将一个数组排序，并返回一个字符串，适用于排序一个数组然后打印结果。
@end
