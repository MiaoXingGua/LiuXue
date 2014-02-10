//
//  emotionView.m
//  SinaWeibo
//
//  Created by Ibokan on 12-9-18.
//  Copyright (c) 2012年 Ibokan. All rights reserved.
//

#import "emotionView.h"
#import <QuartzCore/QuartzCore.h>

@interface TSEmojiViewLayer : CALayer
{
@private
    CGImageRef _keytopImage;;
}
@property (nonatomic, retain) UIImage* emoji;
@end

@implementation TSEmojiViewLayer
@synthesize emoji = _emoji;

- (void)dealloc
{
    _keytopImage = nil;
    _emoji = nil;
    [super dealloc];
}
- (void)drawInContext:(CGContextRef)context
{
    _keytopImage = [[UIImage imageNamed:@"emoticon_keyboard_magnifier"] CGImage];
    UIGraphicsBeginImageContext(CGSizeMake(64, 92));
    CGContextTranslateCTM(context, 0, 92);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, 64, 92), _keytopImage);
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(30, 30));
    CGContextDrawImage(context, CGRectMake(16, 45, 30, 30), [_emoji CGImage]);
    
    UIGraphicsEndImageContext();
}
@end

@interface emotionView()
{
    TSEmojiViewLayer *_emojiPadLayer;
}

@end

@implementation emotionView
@synthesize delegate = _delegate;
- (id)initWithFrame:(CGRect)frame inPage:(int)page
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _emojiArray = [[NSMutableArray alloc] initWithCapacity:0];
        switch (page)
        {
            case 0:
                
                _symbolArray = [[NSMutableArray alloc] initWithObjects: @"[兔子]",
                                @"[熊猫]",
                                @"[给力]",
                                @"[神马]",
                                @"[浮云]",
                                @"[织]",
                                @"[围观]",
                                @"[威武]",
                                @"[嘻嘻]",
                                @"[哈哈]",
                                @"[爱你]",
                                @"[晕]",
                                @"[泪]",
                                @"[馋嘴]",
                                @"[抓狂]",
                                @"[哼]",
                                @"[可爱]",
                                @"[怒]",
                                @"[汗]",
                                @"[呵呵]",
                                @"[睡觉]",
                                @"[钱]",
                                @"[偷笑]",
                                @"[酷]",
                                @"[衰]",
                                @"[吃惊]",
                                @"[闭嘴]",
                                @"[鄙视]",nil];
                break;
                case 1:
            {
                _symbolArray = [[NSMutableArray alloc] initWithObjects: @"[挖鼻屎]",
                                @"[花心]",
                                @"[鼓掌]",
                                @"[失望]",
                                @"[帅]",
                                @"[照相机]",
                                @"[落叶]",
                                @"[汽车]",
                                @"[飞机]",
                                @"[爱心传递]",
                                @"[奥特曼]",
                                @"[实习]",
                                @"[思考]",
                                @"[生病]",
                                @"[亲亲]",
                                @"[怒骂]",
                                @"[太开心]",
                                @"[懒得理你]",
                                @"[右哼哼]",
                                @"[左哼哼]",
                                @"[嘘]",
                                @"[委屈]",
                                @"[吐]",
                                @"[可怜]",
                                @"[打哈气]",
                                @"[顶]",
                                @"[疑问]",
                                @"[做鬼脸]", nil];
                break;
            }
                case 2:
            {
                _symbolArray = [[NSMutableArray alloc] initWithObjects: @"[害羞]",
                                @"[书呆子]",
                                @"[困]",
                                @"[悲伤]",
                                @"[感冒]",
                                @"[拜拜]",
                                @"[黑线]",
                                @"[不要]",
                                @"[good]",
                                @"[弱]",
                                @"[ok]",
                                @"[赞]",
                                @"[来]",
                                @"[耶]",
                                @"[haha]",
                                @"[拳头]",
                                @"[最差]",
                                @"[握手]",
                                @"[心]",
                                @"[伤心]",
                                @"[猪头]",
                                @"[咖啡]",
                                @"[话筒]",
                                @"[月亮]",
                                @"[太阳]",
                                @"[干杯]",
                                @"[萌]",
                                @"[礼物]", nil];
                break;
            }
                case 3:
            {
                _symbolArray = [[NSMutableArray alloc] initWithObjects: @"[互粉]",
                                @"[蜡烛]",
                                @"[绿丝带]",
                                @"[沙尘暴]",
                                @"[钟]",
                                @"[自行车]",
                                @"[蛋糕]",
                                @"[围脖]",
                                @"[手套]",
                                @"[雪]",
                                @"[雪人]",
                                @"[温暖帽子]",
                                @"[威风]",
                                @"[足球]",
                                @"[电影]",
                                @"[风扇]",
                                @"[鲜花]",
                                @"[喜]",
                                @"[QQ]",
                                @"[音乐]", nil];
                break;
            }
            default:
                break;
        }
        
        if (page == 3)
        {
            for (int i = 28*page+1; i<100; i++)
            {
                if (i>10&&i<100)
                {
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"0%d",i]];
                    [_emojiArray addObject:image];
                }
                else
                {
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
                    [_emojiArray addObject:image];
                }
            }
        }
        else
        {
            for (int i = 28*page+1; i<(page+1)*28+1; i++)
            {
                if (i<10)
                {
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"00%d",i]];
                    [_emojiArray addObject:image];
                }
                else if (i>=10 && i<100)
                {
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"0%d",i]];
                    [_emojiArray addObject:image];
                }
                else if (i>100)
                {
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
                    [_emojiArray addObject:image];
                }
            }

        }
        _emojiPadLayer = [TSEmojiViewLayer layer];
        [self.layer addSublayer:_emojiPadLayer];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
   int index = 0;
    for (UIImage *image in _emojiArray)
    {
        float originX = (self.bounds.size.width/7)*(index%7)+(self.bounds.size.width-30*7)/16;
        float originY = (self.bounds.size.width/7)*(index/7)+(self.bounds.size.width-30*7)/16;
        [image drawInRect:CGRectMake(originX, originY, 30, 30)];
        index++;
    }
}
- (void)dealloc
{
    [_emojiArray release];
    _emojiPadLayer = nil;
    [super dealloc];
}
- (void)updateWithIndex:(NSUInteger)index
{
    _touchedIndex = index;
    NSLog(@"66666666666666666666666 = %d",index);
    if (_emojiPadLayer.opacity != 1.0)
    {
        _emojiPadLayer.opacity = 1.0;
    }
    float originX = (self.bounds.size.width/7)*(index%7)+(self.bounds.size.width-30*7)/16;
    float originY = (self.bounds.size.width/7)*(index/7)+(self.bounds.size.width-30*7)/16;
    [_emojiPadLayer setEmoji:[_emojiArray objectAtIndex:index]];
    [_emojiPadLayer setFrame:CGRectMake(originX+15-32, originY+15-92, 64, 92)];
    [_emojiPadLayer setNeedsDisplay];
}
- (NSUInteger)indexWithEvent:(UIEvent*)event
{
    UITouch *touch = [[event allTouches] anyObject];
    NSUInteger x = [touch locationInView:self].x/(self.bounds.size.width/7);
    NSUInteger y = [touch locationInView:self].y/(self.bounds.size.width/7);
    NSUInteger index = x + y*7;
    return index;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate stopScrollView];
    NSUInteger index = [self indexWithEvent:event];
    if (index<_emojiArray.count)
    {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self updateWithIndex:index];
        [CATransaction commit];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate stopScrollView];
    NSUInteger index = [self indexWithEvent:event];
    if (index < _emojiArray.count)
    {
        [self updateWithIndex:index];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate startScrollView];
    [self.delegate didTouchEmojiView:self touchedEmoji:[_symbolArray objectAtIndex:_touchedIndex]];
    _touchedIndex = -1;
    _emojiPadLayer.opacity = 0.0;
    [self setNeedsDisplay];
    [_emojiPadLayer setNeedsDisplay];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
