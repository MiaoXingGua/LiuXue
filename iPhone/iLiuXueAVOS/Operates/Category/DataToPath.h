//
//  NSData+Path.h
//  NSReuestTest
//
//  Created by Jack on 13-6-28.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Path)

- (NSString *)dataToFilePath;

@end

@interface UIImage (Path)

- (NSString *)imageToFilePath;

@end