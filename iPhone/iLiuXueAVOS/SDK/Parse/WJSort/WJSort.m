//
//  WJSort.m
//  pinyinSort
//
//  Created by jay on 12-8-8.
//  Copyright (c) 2012年 jay. All rights reserved.
//

#import "WJSort.h"
#import "pinyin.h"
#import "hanzi.h"
@implementation WJSort

-(NSString*)stringWithStringSort:(NSString*)longString{
    return [self stringWithStringArraySort:[longString componentsSeparatedByString:@" "]];
}

-(NSArray*)arrayWithStringSort:(NSString*)longString{
    return [self arrayWithStringArraySort:[longString componentsSeparatedByString:@" "]];
}

-(NSArray*)arrayWithStringArraySort:(NSArray*)aArray{
    NSMutableArray *temp=[[NSMutableArray alloc]init];
    for (int i=0; i<[aArray count]; i++) {
        hanzi *aHanzi=[[hanzi alloc]init];
        aHanzi.string=[NSString stringWithString:[aArray objectAtIndex:i]];
        if (aHanzi.string) {
            NSString *pinYinResult=[NSString string];
            for (int j=0; j<aHanzi.string.length; j++) {
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([aHanzi.string characterAtIndex:j])] uppercaseString];
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            aHanzi.pinyin=pinYinResult;
        }else{
            aHanzi.pinyin=@"";
        }
        [temp addObject:aHanzi];
        [aHanzi release];
    }
    
    NSArray *sortDes=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [temp sortUsingDescriptors:sortDes];
    return temp;
    
}

-(NSString*)stringWithStringArraySort:(NSArray*)aArray{
    NSArray *temp=[self arrayWithStringArraySort:aArray];
    NSString *str=[NSString string];
    for (int p=0; p<temp.count; p++) {
        str=[str stringByAppendingFormat:@"%@ ",((hanzi*)[temp objectAtIndex:p]).string];
    }
    return str;
}

@end
