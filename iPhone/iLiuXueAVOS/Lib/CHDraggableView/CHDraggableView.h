//
//  CHDraggableView.h
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHDraggableViewDelegate;
@interface CHDraggableView : UIView
{
    int viewtag;
    int nowPointNum;
    CGPoint temp;
    BOOL isMoing;
    NSString *viewState;
    NSMutableArray *_pointAry;
    CGPoint movedPoint;
    NSTimer *_timer;
}
@property(nonatomic,retain)NSMutableArray *pointAry;
@property (nonatomic, assign) id<CHDraggableViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)snapViewCenterToPoint:(CGPoint)point edge:(CGRectEdge)edge;

@end

@protocol CHDraggableViewDelegate <NSObject>

- (void)draggableViewHold:(CHDraggableView *)view;
- (void)draggableView:(CHDraggableView *)view didMoveToPoint:(CGPoint)point;
- (void)draggableViewReleased:(CHDraggableView *)view;

- (void)draggableViewTouched:(CHDraggableView *)view;

@end