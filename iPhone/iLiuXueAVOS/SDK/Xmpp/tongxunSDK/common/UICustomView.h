//
//  UICustomView.h
//  TTAddressBook
//
//  Created by iphonekf2 on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDefine.h"

@protocol UIViewDelegate <NSObject>

-(void)ChooseWithFlag:(NSInteger) Flag;//返回1代表选择按钮1； 返回2代表选择按钮2 返回其他值则认为是啥都没选
@end

typedef enum
{
    EChooseNone = 0,
    EChooseFirst,
    EChooseSecond,
    EChooseThird,
    EChooseDisalbe
} EChooseFlag;

@interface UICustomView : UIView
{
    UIImageView             *btn1Icon;
    UIImageView             *btn2Icon;
    UIImageView             *_btn3Icon;
    UIImageView             *btnBackGround;
    UIImageView             *menuImageView;
    UILabel                 *btn1Label;
    UILabel                 *btn2Label;
    UILabel                 *_btn3Label;
    id<UIViewDelegate>      viewDelegate;
    NSInteger               chooseFlag;
    BOOL                    viewflag;
}

- (void)ShowView:(CGPoint)pos isThree:(BOOL)isThree;

- (void)set_Delegate:(id)delegate;

- (id)initWithFrame:(CGRect)frame andIcon1Name:(NSString *)icon1Name andIcon2Name:(NSString *)icon2Name andIcon3Name:(NSString *)icon3Name
      andLabel1Text:(NSString *)label1Text andLabel2Text:(NSString *)label2Text andLabel3Text:(NSString *)label3Text;

@end


