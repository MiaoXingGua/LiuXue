//
//  emotionView.h
//  SinaWeibo
//
//  Created by Ibokan on 12-9-18.
//  Copyright (c) 2012年 Ibokan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TSEmojiViewDelegate;
@interface emotionView : UIView
{
    NSMutableArray *_emojiArray;
    NSMutableArray *_symbolArray;
    
    NSInteger _touchedIndex;
}
@property (assign, nonatomic) id<TSEmojiViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame inPage:(int)page;
@end

@protocol TSEmojiViewDelegate<NSObject>
@optional
- (void)didTouchEmojiView:(emotionView*)emojiView touchedEmoji:(NSString*)string;
- (void)stopScrollView;
- (void)startScrollView;
@end