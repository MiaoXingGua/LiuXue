//
//  TakeMessageViewController.h
//  NightTalk
//
//  Created by superhomeliu on 13-6-9.
//  Copyright (c) 2013年 superhomeliu. All rights reserved.
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

@interface ChatViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,VoiceRecorderBaseVCDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,EGORefreshTableHeaderDelegate,UITextViewDelegate>
{
	NSMutableString            *_messageString;
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
    
    BOOL keyboardshow;
    BOOL isShowTextView;
    BOOL isShowFaceView;
    BOOL isShowOperationView;
    
    User *_chatUser;
    
    __block BOOL isRefresh;

    
    UIImageView *stateView;
    
    AVAudioPlayer *amrPlayersend;
    NSData *sendAmrData;
    
    NSMutableArray *_messageIDArray;
    
    UIImageView *textBackView;

    UIView *operationView;
    UIView *faceBackView;

    UIScrollView *faceView;
    UIPageControl *facePageControl;
    NSDictionary *_faceMap;
    
    UILabel *title;
    
    UIView *coverView;
}

@property(nonatomic,retain)NSMutableArray *messageIDArray;
@property(nonatomic,retain)User *chatUser;

@property(nonatomic,retain)NSData *previewData;
@property(nonatomic,retain)NSString *selfImageUrl,*otherImageUrl;
@property(nonatomic,retain)UIImage *selfheadImg,*otherheadImg;

@property (nonatomic,retain)UITableView *chatTableView;
@property(nonatomic,retain)UITextView *messageTextView;
@property (retain, nonatomic)  ChatVoiceRecorderVC      *recorderVC;

@property (retain, nonatomic)   AVAudioPlayer           *player;

@property (copy, nonatomic)     NSString                *originWav;         //原wav文件名
@property (copy, nonatomic)     NSString                *convertAmr;        //转换后的amr文件名
@property (copy, nonatomic)     NSString                *convertWav;        //amr转wav的文件名

@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;

@property (nonatomic, retain) NSDate                 *lastTime;

- (id)initWithUser:(User *)user;
- (id)initWithUser:(User *)user fromNotifition:(NSDictionary *)info IsFromNotifition:(BOOL)isFrom;
@end
