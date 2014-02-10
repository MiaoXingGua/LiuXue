//
//  LinkManViewController.h
//  NightTalk
//
//  Created by superhomeliu on 13-6-9.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ChatViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "SuperViewController.h"
#import "ALGroupEngine.h"

@interface LinkManViewController : SuperViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView *_tableView;
    __block UITableView *_searchTableView;
    NSMutableArray *_personlist,*_grouplist,*_searchlist;
    
    float viewWidth;
    BOOL unfold;

    UITextField *_textfield;
    UIButton *coverView;
    UIButton *cancelBtn;
    
    BOOL isEditing,isAnimation;
    UIImageView *textfieldImage;
    
    UIImageView *deleteView;
    UIWindow *_window;
    UIImageView *markView;
    NSTimer *_timer;

    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    UIImageView *_logOutView;
    
    BOOL isFriendOpen;
    BOOL isShowRightPenl;
    
    UIImageView *searchImage;
    NSString *_searchTypeStr;
    
    __block UILabel *_unreadLabel;
    
    NSMutableArray *_linktypeAry;
}
@property(nonatomic,assign)BOOL isRequest;
@property(nonatomic,assign)BOOL isBeginChat;

@property(nonatomic,retain)NSMutableArray *linktypeAry;
@property(nonatomic,retain)NSString *searchTypeStr;
@property(nonatomic,retain)NSMutableArray *personlist,*grouplist,*searchlist;

@end
