//
//  SuperViewController.h
//  NightTalk
//
//  Created by superhomeliu on 13-6-9.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "VCConfig.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"
//#import "SIAlertView.h"
#import "MLNavigationController.h"
#import "F3Swirly.h"

#define NSLOG_DEBUG NSLog(@"%s:%d", __func__, __LINE__);

#define REFRESHUI @"refreshUI"

@interface SuperViewController : UIViewController
{
    F3Swirly *_F3HUD;
}

@property(nonatomic,retain)F3Swirly *F3HUD;

- (void)showF3HUDLoad:(NSString *)text;
- (void)hideF3HUDSucceed:(NSString *)text;
- (void)hideF3HUDError:(NSString *)text;

//计算发帖时间
- (NSString *)calculateDate:(NSDate *)date;

@end
