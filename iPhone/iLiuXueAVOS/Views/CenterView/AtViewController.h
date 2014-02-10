//
//  AtViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-11-2.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "AVFoundation/AVFoundation.h"

@interface AtViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,AVAudioPlayerDelegate>
{
    UITableView *_tableView;
    UIImageView *animationImgview;
    
    BOOL _reloading;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    NSMutableArray *_atdatalist;
    NSMutableArray *_collectNumArray;

    __block UIActivityIndicatorView *_activityView;
    __block UIButton *loadCommentsBtn;
    UIView *footView;
    
    NSData *_voiceData;
    AVAudioPlayer *amrPlayer;
    UIButton *_sender;
    UIButton *_lastSender;
    BOOL isPlayCellVoice;
}

@property(nonatomic,assign)BOOL isRequest;

@property(nonatomic,retain)NSMutableArray *collectNumArray;
@property(nonatomic,retain)NSMutableArray *atdatalist;
@property(nonatomic,retain)NSData *voiceData;

@end
