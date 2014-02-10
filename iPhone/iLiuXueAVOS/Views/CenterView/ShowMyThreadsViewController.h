//
//  ShowMyThreadsViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-10-5.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALUserEngine.h"
#import "ALThreadSDK.h"
#import "SuperViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "AVFoundation/AVFoundation.h"
#import "PersonalDataViewController.h"

@interface ShowMyThreadsViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,AVAudioPlayerDelegate>
{
    NSString *_titles;
    
    User *_users;
    
    UIActivityIndicatorView *_activityView;
    UIButton *showMoreBtn;
    UIView *footView;
    
    NSMutableArray *_datalist;
    NSMutableArray *_threadArry;
    NSMutableArray *_collectNumArray;

    UITableView *_tableView;
    
    __block EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

    BOOL isEdit;
    BOOL _fromself;
    BOOL isPlayCellVoice;
    
    UIButton *editBtn;
    UIView *backgroundView;
        
    NSData *_voiceData;
    UIImageView *animationImgview;
    AVAudioPlayer *amrPlayer;
    UIButton *_sender;
    UIButton *_lastSender;
}

@property(nonatomic,assign)BOOL isRequest;
@property(nonatomic,assign)BOOL isShowMore;
@property(nonatomic,assign)BOOL isCollect;
@property(nonatomic,assign)int selecttag;

@property(nonatomic,retain)NSData *voiceData;
@property(nonatomic,retain)NSMutableArray *collectNumArray;
@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)NSMutableArray *threadArry;
@property(nonatomic,retain)NSString *titles;
@property(nonatomic,retain)User *users;

- (id)initWithTitle:(NSString *)title User:(User *)user Tag:(int)tag FromSelf:(BOOL)fromself;
@end
