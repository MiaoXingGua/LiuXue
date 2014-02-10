//
//  ViewPointManager.m
//  ChatHeads
//
//  Created by superhomeliu on 13-7-25.
//  Copyright (c) 2013年 Matthias Hochgatterer. All rights reserved.
//

#import "ViewPointManager.h"

static ViewPointManager *viewpoint=nil;

@implementation ViewPointManager
@synthesize viewPointAry;

+ (ViewPointManager *)defultManager
{
    if(viewpoint==nil)
    {
        viewpoint = [[ViewPointManager alloc] init];
        viewpoint.viewPointAry = [NSMutableArray arrayWithCapacity:0];
        viewpoint.viewAry = [NSMutableArray arrayWithCapacity:0];
        viewpoint.viewState = @"fold";
        viewpoint.showViewTag = 1000;
    }
    
    
    
    return viewpoint;

}
@end
