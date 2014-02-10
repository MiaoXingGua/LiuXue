//
//  UIImage+imageNamed_Hack.h
//  iBokanApp
//
//  Created by Jack on 13-2-25.
//  Copyright (c) 2013年 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageNamed_Hack)
+ (UIImage *)imageNamed:(NSString *)name;
@end

@interface UIImage (imageNamed_Scaled)

- (UIImage *)imageScaled:(float)scale;

- (UIImage *)imageScaledToSize:(CGSize)scaleSize;

@end