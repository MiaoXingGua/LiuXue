//
//  AppDelegate.h
//  iLiuXueAVOS
//
//  Created by Albert on 13-12-22.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "CustomWindow.h"
#import "CustomStatueBar.h"

@class User;

@interface AppDelegate : UIResponder <UIApplicationDelegate,tapNewMessageDelegate>
{
    CustomStatueBar *customBar;
    User *_chatUser;
}

@property (strong, nonatomic) JASidePanelController *panelViewController;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) CustomWindow *window;
@property(nonatomic,retain)User *chatUser;

@end
