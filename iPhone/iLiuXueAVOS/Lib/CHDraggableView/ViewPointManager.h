//
//  ViewPointManager.h
//  ChatHeads
//
//  Created by superhomeliu on 13-7-25.
//  Copyright (c) 2013年 Matthias Hochgatterer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewPointManager : NSObject
{
    NSMutableArray *_viewPointAry;
    NSMutableArray *_viewAry;
}
@property(nonatomic,retain)NSMutableArray *viewPointAry,*viewAry;
@property(nonatomic,retain)NSString *viewState;
@property(nonatomic,assign)int showViewTag;
@property(nonatomic,retain)NSValue *lastViewPoint;
@property(nonatomic,retain)NSValue *removeViewPoint;
+ (ViewPointManager *)defultManager;

@end
