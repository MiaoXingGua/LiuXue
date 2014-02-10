//
//  CheckNetViewController.h
//  CCPVoipDemo
//
//  Created by wang ming on 13-6-24.
//  Copyright (c) 2013年 hisun. All rights reserved.
//

#import "UIBaseViewController.h"
#import "HPGrowingTextView.h"
@interface CheckNetViewController : UIBaseViewController<HPGrowingTextViewDelegate>
{
    NSInteger send;
    NSInteger notSend;
    NSInteger received;
    NSInteger lost;
    NSInteger minRevTime;
    NSInteger maxRevTime;
    NSInteger sumRevTime;
    UILabel *lbSend;
    UILabel *lbReceived;
    UILabel *lbLostRate;
    UILabel *lbMinRevTime;
    UILabel *lbMaxRevTime;
    UILabel *lbAvgRevTime;
}
@end
