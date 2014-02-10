//
//  CommentViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-30.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "MediaPlayer/MediaPlayer.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import "VoiceAnimationView.h"
#import "ALThreadEngine.h"
#import "PCStackMenu.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "VoiceAnimationView.h"

@interface CommentViewController : SuperViewController<UITextViewDelegate,VoiceRecorderBaseVCDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    Thread *_threads;
    Post *_tposts;
    
    UITextView *_textview_content;
    
    AVAudioPlayer *playVoice;
    UIButton *voiceBtn;
    UILongPressGestureRecognizer *longPrees;
    ChatVoiceRecorderVC *_recorderVC;
    AVAudioPlayer *_player;
    NSString *_originWav,*_convertAmr,*_convertWav;
    NSData *_amrData;
    __block AVFile *_amrfile;

    PCStackMenu *stackMenu;
    UIView *coverView;
    UIButton *operationBtn;
    UIButton *voiceLengthBtn;
    
    VoiceAnimationView *_animationView;

    BOOL iscomment;
}

@property(nonatomic,retain)Post *tposts;
@property(nonatomic,retain)Thread *threads;
@property(nonatomic,retain)AVFile *amrfile;
@property(nonatomic,retain)NSData *amrData;
@property (nonatomic,retain)NSString *originWav;         //原wav文件名
@property (nonatomic,retain)NSString *convertAmr;        //转换后的amr文件名
@property (nonatomic,retain)NSString *convertWav;        //amr转wav的文件名

- (id)initWithThread:(Thread *)threads;

- (id)initWithPost:(Post *)tposts;
@end
