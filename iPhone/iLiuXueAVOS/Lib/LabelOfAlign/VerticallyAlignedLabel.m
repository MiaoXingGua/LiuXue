//
//  VerticalAlignment.m
//  ITTimeMagazine
//
//  Created by superhomeliu on 13-5-7.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import "VerticallyAlignedLabel.h"

@implementation VerticallyAlignedLabel

@synthesize verticalAlignment = verticalAlignment_;


- (id)initWithFrame:(CGRect)frame

{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        
    }
    
    return self;
    
}


- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
    
    verticalAlignment_ = verticalAlignment;
    
    [self setNeedsDisplay];
    
}


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    
    switch (self.verticalAlignment) {
            
        case VerticalAlignmentTop:
            
            textRect.origin.y = bounds.origin.y;
            
            break;
            
        case VerticalAlignmentBottom:
            
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            
            break;
            
        case VerticalAlignmentMiddle:
            
            // Fall through.
            
        default:
            
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
            
    }
    
    return textRect;
    
}


-(void)drawTextInRect:(CGRect)requestedRect {
    
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    
    [super drawTextInRect:actualRect];
    
}


@end
