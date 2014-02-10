//
//  UITextField+PlaceColor.m
//  test
//
//  Created by jay on 13-10-25.
//  Copyright (c) 2013年 jay. All rights reserved.
//

#import "UITextField+PlaceColor.h"

@implementation UITextField (PlaceColor)
- (void)drawPlaceholderInRect:(CGRect)rect
{
    
    [[UIColor lightGrayColor] setFill];
    
    
    [[self placeholder] drawInRect:rect withFont:self.font];
//    [self placeholder] drawInRect:rect withAttributes:@{}
}
@end
