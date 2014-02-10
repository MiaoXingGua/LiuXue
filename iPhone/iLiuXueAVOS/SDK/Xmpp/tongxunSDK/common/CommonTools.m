/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

@implementation UINavigationBar (Customized)

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"top_bg.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end


#import "CommonTools.h"

@implementation CommonTools

+ (UIButton*) navigationBackItemBtnInitWithTarget:(id)target action:(SEL)actMethod {
    return [CommonTools navigationItemBtnInitWithNormalImageNamed:@"title_bar_back_icon.png" andHighlightedImageNamed:@"title_bar_back_icon_on.png" target:target action:actMethod];
}

+ (UIButton*) navigationItemBtnInitWithNormalImageNamed:(NSString*)normalImageName andHighlightedImageNamed:(NSString*)highlighedImageName target:(id)target action:(SEL)actMethod {
    UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:normalImageName];
    itemBtn.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    [itemBtn setBackgroundImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [itemBtn setBackgroundImage:[UIImage imageNamed:highlighedImageName] forState:UIControlStateHighlighted];
    [itemBtn addTarget:target action:actMethod forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}

+ (UIButton*) navigationItemBtnInitWithTitle:(NSString*)title target:(id)target action:(SEL)actMethod {
    UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIFont* font = [UIFont boldSystemFontOfSize:14];
    CGSize titlesize = [title sizeWithFont:font];
    itemBtn.frame = CGRectMake(0, 0, titlesize.width+20, 30);
    [itemBtn setTitle:title forState:UIControlStateNormal];
//    UIEdgeInsets titleInset = itemBtn.titleEdgeInsets;
//    titleInset.left = 10.0f;
//    itemBtn.titleEdgeInsets = titleInset;
    itemBtn.titleLabel.font = font;
    UIImage *offimg = [UIImage imageNamed: @"button01_off.png"];
    UIImage *onimg = [UIImage imageNamed: @"button01_on.png"];
    [itemBtn setBackgroundImage:[offimg stretchableImageWithLeftCapWidth:offimg.size.width*0.5 topCapHeight:offimg.size.height*0.5] forState:UIControlStateNormal];
    [itemBtn setBackgroundImage:[onimg stretchableImageWithLeftCapWidth:onimg.size.width*0.5 topCapHeight:onimg.size.height*0.5] forState:UIControlStateHighlighted];
    [itemBtn addTarget:target action:actMethod forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}

+ (UIButton*) navigationItemNewBtnInitWithTitle:(NSString*)title target:(id)target action:(SEL)actMethod {
    UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIFont* font = [UIFont boldSystemFontOfSize:14];
    CGSize titlesize = [title sizeWithFont:font];
    itemBtn.frame = CGRectMake(0, 0, titlesize.width+36-titlesize.height, 30);
    [itemBtn setTitle:title forState:UIControlStateNormal];
    itemBtn.titleLabel.font = font;
    [itemBtn setBackgroundImage:[[UIImage imageNamed: @"view_image_bg_icon.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [itemBtn setBackgroundImage:[[UIImage imageNamed: @"view_image_bg_icon_on.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    [itemBtn addTarget:target action:actMethod forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}


@end
