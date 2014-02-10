//
//  NewsInfoViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-22.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SuperViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "ShowImageViewController.h"
#import "ALThreadEngine.h"

@interface NewsInfoViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,AVAudioPlayerDelegate>
{
    NSMutableDictionary *_tdic;
    int _tid;
    __block UITableView *_tableView;
    NSMutableArray *_datalist,*_imageArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    __block UIImageView *lineImage;
    UIView *footView;
    
    __block UIView *headView;
    __block NSData *_voiceData;
    __block NSData *_headVoiceData;
    
    int headViewHeight;
    __block UIButton *voiceBtn;
    __block UIButton *videoBtn;
    
    BOOL isPlayingVoice;
    
    AVAudioPlayer *amrPlayer;
    UIActivityIndicatorView *_activity;
    NSMutableArray *_voiceArray;
    __block NSMutableArray *_voiceDataArray;
    NSMutableArray *_tempArray;
    BOOL isPlayHeadVoice,isPlayCellVoice;
    
    UIButton *_sender;
    UIButton *_lastSender;
        
    __block NSString *_videoFilePath;
    
    __block NSMutableArray *_showImageArray;
    
    NSMutableArray *_postsArray;
    
    UIImageView *animationImgview;
    ShowImageViewController *showImageView;
    
    Thread *_threads;
    
    NSString *_loginUserId;
    
    UIView *moreOperation;
    
    BOOL showOperation;
    BOOL fromSelf;
    
    UIButton *collectBtn;
    
    UIButton *closeBtn;
    
    __block UIActivityIndicatorView *_activityView;
    __block UIButton *loadCommentsBtn;
    
    User *_user;
    
    NSMutableArray *_imageAry;

}
@property(nonatomic,assign)BOOL isrequest;
@property(nonatomic,assign)BOOL isCollect;
@property(nonatomic,assign)BOOL isloadMore;
@property(nonatomic,assign)BOOL isPulldown;
@property(nonatomic,assign)int threadStates;

@property(nonatomic,retain)NSMutableArray *imageAry;
@property(nonatomic,retain)User *user;
@property(nonatomic,retain)NSString *loginUserId;
@property(nonatomic,retain)NSMutableArray *postsArray;
@property(nonatomic,retain)Thread *threads;
@property(nonatomic,retain)NSMutableArray *showImageArray;
@property(nonatomic,retain)NSMutableDictionary *tdic;
@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)NSData *voiceData;
@property(nonatomic,retain)NSData *headVoiceData;
@property(nonatomic,retain)NSMutableArray *imageArray;
@property(nonatomic,retain)NSMutableArray *voiceArray;
@property (nonatomic,retain)NSMutableArray *voiceDataArray;
@property(nonatomic,retain) NSMutableArray *tempArray;
@property(nonatomic,retain)NSString *videoFilePath;

- (id)initWithThread:(Thread *)threads Collect:(BOOL)collect ThreadState:(int)tState Image:(NSArray *)imagearray;

@end
