//
//  UIImage+imageNamed_Hack.m
//  iBokanApp
//
//  Created by Jack on 13-2-25.
//  Copyright (c) 2013年 Albert Lee. All rights reserved.
//

#import "UIImage+imageNamed_Hack.h"

@implementation UIImage (imageNamed_Hack)
+ (UIImage *)imageNamed:(NSString *)name
{
    
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath],name]];
}
@end

@implementation UIImage (imageNamed_Scaled)

- (UIImage *)imageScaled:(float)scale
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    NSLog(@"bbb:%f  %f",width,height);
    CGFloat targetWidth = width/scale;
    CGFloat targetHeight = height/scale;
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageScaledToSize:(CGSize)targetSize
{
    int h = self.size.height;
    int w = self.size.width;
    
    if(h <= targetSize.height && w <= targetSize.width)
    {
        return self;
    }
    else
    {
        float destWith = 0.0f;
        float destHeight = 0.0f;
        
        float suoFang = (float)w/h;
        float suo = (float)h/w;
        
        if (w>h) {
            destWith = (float)targetSize.width;
            destHeight = targetSize.width * suo;
        }
        else
        {
            destHeight = (float)targetSize.height;
            destWith = targetSize.height * suoFang;
        }
        
        CGSize itemSize = CGSizeMake(destWith, destHeight);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0, 0, destWith, destHeight);
        [self drawInRect:imageRect];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
//        return newImg;
        return [UIImage imageWithData:UIImageJPEGRepresentation(newImg,0.1)];
    }
   
}
    
@end