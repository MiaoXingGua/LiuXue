//
//  ChatRecorderView.m
//  Jeans
//
//  Created by Jeans on 3/24/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import "ChatRecorderView.h"

#define kTrashImage1         [UIImage imageNamed:@""]
#define kTrashImage2         [UIImage imageNamed:@""]
#define kTrashImage3         [UIImage imageNamed:@""]

@interface ChatRecorderView(){
    NSArray         *peakImageAry;
    NSArray         *trashImageAry;
    BOOL            isPrepareDelete;
    BOOL            isTrashCanRocking;
}

@end

@implementation ChatRecorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initilization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)initilization{
    //初始化音量peak峰值图片数组
    peakImageAry = [[NSArray alloc]initWithObjects:
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""],
                    [UIImage imageNamed:@""], nil];
    trashImageAry = [[NSArray alloc]initWithObjects:kTrashImage1,kTrashImage2,kTrashImage3,kTrashImage2, nil];
}

- (void)dealloc {
    [peakImageAry release];
    [trashImageAry release];
    [_peakMeterIV release];
    [_trashCanIV release];
    [_countDownLabel release];
    [super dealloc];
}

#pragma mark -还原显示界面
- (void)restoreDisplay{
    //还原录音图
    _peakMeterIV.image = nil;
    //停止震动
    [self rockTrashCan:NO];
    //还原倒计时文本
    _countDownLabel.text = @"";
}

#pragma mark - 是否准备删除
- (void)prepareToDelete:(BOOL)_preareDelete{
    if (_preareDelete != isPrepareDelete) {
        isPrepareDelete = _preareDelete;
        [self rockTrashCan:isPrepareDelete];
    }
}
#pragma mark - 是否摇晃垃圾桶
- (void)rockTrashCan:(BOOL)_isTure{
    if (_isTure != isTrashCanRocking) {
        isTrashCanRocking = _isTure;
        if (isTrashCanRocking) {
            //摇晃
            _trashCanIV.animationImages = nil;
            _trashCanIV.animationRepeatCount = 0;
            _trashCanIV.animationDuration = 1;
            [_trashCanIV startAnimating];
        }else{
            //停止
            if (_trashCanIV.isAnimating)
                [_trashCanIV stopAnimating];
            _trashCanIV.animationImages = nil;
            _trashCanIV.image = kTrashImage1;
        }
    }
}


#pragma mark - 更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower{
    //-160表示完全安静，0表示最大输入值
    //
    NSInteger imageIndex = 0;
    if (_avgPower >= -60 && _avgPower < -54)
        imageIndex = 0;
    else if (_avgPower >= -54 && _avgPower < -48)
        imageIndex = 1;
    else if (_avgPower >= -48 && _avgPower < -42)
        imageIndex = 2;
    else if (_avgPower >= -42 && _avgPower < -36)
        imageIndex = 3;
    else if (_avgPower >= -36 && _avgPower < -30)
        imageIndex = 4;
    else if (_avgPower >= -30 && _avgPower < -24)
        imageIndex = 5;
    else if (_avgPower >= -24 && _avgPower < -18)
        imageIndex = 6;
    else if (_avgPower >= -12 && _avgPower < -6)
        imageIndex = 7;
    else if (_avgPower >= -6 && _avgPower < -3)
        imageIndex = 8;
    else if (_avgPower >= -3)
        imageIndex = 9;
    
    _peakMeterIV.image = nil;
}

@end
