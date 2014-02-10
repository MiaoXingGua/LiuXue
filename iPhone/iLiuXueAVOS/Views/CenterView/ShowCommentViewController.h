//
//  ShowCommentViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-9-23.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALThreadEngine.h"
#import "EGORefreshTableHeaderView.h"
#import "SuperViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "VoiceConverter.h"
//#import "STTweetLabel.h"
#import "MediaPlayer/MediaPlayer.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import "VoiceAnimationView.h"

@interface ShowCommentViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UITextFieldDelegate,AVAudioPlayerDelegate,UITextViewDelegate,VoiceRecorderBaseVCDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UITextViewDelegate>//<STLinkProtocol>
{
    NSDictionary *_threadDic;
    
    UITableView *_tableView;
    NSMutableArray *_datalist;
    NSMutableArray *_commentsArray;
    NSMutableArray *_atUserArray;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL isPulldown;
    BOOL isPlayHeadVoice,isPlayCellVoice;
    
    
    UIImageView *textView;
    UITextField *_textview_content;
    UIButton *voiceBtn;
    
    AVAudioPlayer *amrPlayer;

    NSString *_loginUserId;
    
    BOOL threadState;
    BOOL isrefresh;
    BOOL _exchange;
    
    int userNameLengths;
    UIView *footView;
    UIActivityIndicatorView *_activityView;
    UIButton *loadCommentsBtn;
    
    UIImageView *voiceAnimationView;
    
    UIView *userNameView;
    
    NSString *_exChangeUserName;
    NSString *_exChangeContents;
    
    UIButton *recordBtn;
    UIButton *voiceLengthBtn;
    ChatVoiceRecorderVC *_recorderVC;
    UILongPressGestureRecognizer *longPrees;
    AVAudioPlayer *playVoice;
    NSString *_originWav,*_convertAmr,*_convertWav;
    NSData *_amrData;
    __block AVFile *_amrfile;
    VoiceAnimationView *_animationView;
    UIImageView *animationImgview;
    
    UIButton *_sender;
    UIButton *_lastSender;
    
    User *_user;
    
    NSData *_voiceData;
    
    UILabel *atNameLabel;
    
    BOOL haveVoice;
}

@property(nonatomic,assign)BOOL isrequest;
@property(nonatomic,assign)BOOL isShowMore;

@property(nonatomic,retain)NSMutableArray *atUserArray;
@property(nonatomic,retain)NSData *voiceData;
@property(nonatomic,retain)AVFile *amrfile;
@property(nonatomic,retain)NSData *amrData;
@property (nonatomic,retain)NSString *originWav;         //原wav文件名
@property (nonatomic,retain)NSString *convertAmr;        //转换后的amr文件名
@property (nonatomic,retain)NSString *convertWav;        //amr转wav的文件名

@property(nonatomic,retain)User *user;
@property(nonatomic,retain)NSString *exChangeUserName;
@property(nonatomic,retain)NSString *exChangeContents;
@property(nonatomic,retain)NSMutableArray *commentsArray;
@property(nonatomic,retain)NSString *loginUserId;
@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)NSDictionary *threadDic;
@property(nonatomic,retain)Post *tposts;

- (id)initWithPostDic:(NSDictionary *)tdic ThreadState:(int)tState;

@end
