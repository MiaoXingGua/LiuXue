//
//  NSData+Path.m
//  NSReuestTest
//
//  Created by Jack on 13-6-28.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "DataToPath.h"
#import "NSString+Encode.h"

@implementation NSData (Path)

- (NSString *)dataToFilePath
{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"file%@.mov",[NSString getCurrentTimeString]]];
    
    if ([self writeToFile:filePath atomically:YES])
    {
        
        return filePath;
    }
    else
    {
        return nil;
    }
}

@end


@implementation UIImage (Path)

- (NSString *)imageToFilePath
{
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"image%@.png",[NSString getCurrentTimeString]]];   // 保存文件的名称
    // 保存成功会返回地址
    
    if ([UIImagePNGRepresentation(self) writeToFile:filePath atomically:YES])
    {
        
        return filePath;
    }
    else
    {
        return nil;
    }
}

@end
