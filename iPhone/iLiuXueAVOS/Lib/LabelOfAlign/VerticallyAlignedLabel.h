//
//  VerticalAlignment.h
//  ITTimeMagazine
//
//  Created by superhomeliu on 13-5-7.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VerticalAlignment {
    
    VerticalAlignmentTop,
    
    VerticalAlignmentMiddle,
    
    VerticalAlignmentBottom,
    
} VerticalAlignment;


@interface VerticallyAlignedLabel : UILabel
{
    VerticalAlignment verticalAlignment_;
}


@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end
