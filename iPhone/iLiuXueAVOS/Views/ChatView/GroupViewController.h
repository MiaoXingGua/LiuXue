//
//  GroupViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-23.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import "MediaPlayer/MediaPlayer.h"
#import "SuperViewController.h"
#import "VoiceAnimationView.h"
#import "ShowImageViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ALXMPPEngine.h"
#import "ALUserEngine.h"
#import "emotionView.h"

@interface GroupViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,VoiceRecorderBaseVCDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,EGORefreshTableHeaderDelegate,TSEmojiViewDelegate,UITextViewDelegate>
{
	NSMutableArray		       *_chatArray;
	
	UITableView                *_chatTableView;
	UITextView                *_messageTextView;
	BOOL                       _isFromNewSMS;
	NSDate                     *_lastTime;
    
    BOOL isVoice;
    UIButton *inputBtn;
    UIImageView *textImage;
    UIButton *coverBtn;
    UIButton *voiceBtn;
    AVAudioPlayer *amrPlayer;
    int _row,_lastViewRow;
    UIImageView *textBackView;
    
    BOOL _sendUsergender;
    BOOL _takeUsergender;
    
    UIImage *_selfheadImg,*_otherheadImg;
    
    NSString *_selfImageUrl,*_otherImageUrl;
    NSData *_previewData;
    
    CGRect _aframe;
    
    
    BOOL isFromNotifition;
    
    
    VoiceAnimationView *_animationView;
    BOOL isSelectSqlite;
    
    ShowImageViewController *showImageView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    BOOL isShowHistroy;
    
    UIButton *imageBtn;
    
    BOOL tapOperation;
    BOOL keyboardshow;
    BOOL isShowTextView;
    BOOL isRefresh;
    BOOL isShowFace;
    
    UIImageView *stateView;
    
    AVAudioPlayer *amrPlayersend;
    NSData *sendAmrData;
    
    NSString *_gid,*_gname;
    
    User *_sendUser;
    
    UIScrollView *faceView;
    UIPageControl *facePageControl;
    NSDictionary *_faceMap;
    
    NSMutableArray *_messageId;
}

@property(nonatomic,retain)NSMutableArray *messageId;
@property(nonatomic,retain)User *sendUser;
@property(nonatomic,retain)NSString *gid,*gname;
@property(nonatomic,retain)NSData *previewData;
@property(nonatomic,retain)NSString *selfImageUrl,*otherImageUrl;
@property(nonatomic,retain)UIImage *selfheadImg,*otherheadImg;

@property (nonatomic,retain)UITableView *chatTableView;
@property(nonatomic,retain)UITextView *messageTextView;
@property (retain, nonatomic)ChatVoiceRecorderVC *recorderVC;

@property (retain, nonatomic)AVAudioPlayer *player;

@property (copy, nonatomic)NSString *originWav;         //原wav文件名
@property (copy, nonatomic)NSString *convertAmr;        //转换后的amr文件名
@property (copy, nonatomic)NSString *convertWav;        //amr转wav的文件名

@property (nonatomic, retain)NSMutableArray *chatArray;

@property (nonatomic, retain)NSDate *lastTime;

- (id)initWithGroupId:(NSString *)gId GroupName:(NSString *)gName;

@end
