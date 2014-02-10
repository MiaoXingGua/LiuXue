//
//  PublishRequirementsViewController.h
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceConverter.h"
#import "MediaPlayer/MediaPlayer.h"
#import "ChatVoiceRecorderVC.h"
#import "SuperViewController.h"
#import "VoiceAnimationView.h"
#import "PCStackMenu.h"
#import "ALGPSHelper.h"
#import "ALThreadEngine.h"
//#import "STTweetLabel.h"
//#import "CPTextViewPlaceholder.h"
#import "FriendListViewController.h"

@interface PublishRequirementsViewController : SuperViewController<UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIScrollViewDelegate,VoiceRecorderBaseVCDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,didSelectAtUserDelegate>//<STLinkProtocol>
{
    UIImage *_uploadImg;
    NSMutableArray *_classAry,*_typeArray,*_imageArray,*_tempArray,*_defaultArray;
    UILabel *classLabel;
    
    NSMutableArray *_updateImageArray;
    
    BOOL isShowClass,isShowType;
    UITableView *_classTableView,*_typeTableView;
    
    
    UITextField *_textfield_title,*_textfield_money;
    UITextView *_textview_content;
    
    UIScrollView *_scrollView,*_scrollViewbg;
    UIView *naviView;
    ChatVoiceRecorderVC *_recorderVC;
    AVAudioPlayer *playVoice;
    NSString *_originWav,*_convertAmr,*_convertWav;
    __block UIButton *voiceLengthBtn;
    __block UIButton *videoLengthBtn;

    NSData *_amrData;
    NSData *_videoData;
    __block AVFile *_amrfile;
    __block AVFile *_videofile;

    int _imageOfNum;
    
    UIImageView *classImageView,*typeImageView;
    
    VoiceAnimationView *_animationView;
    
    PCStackMenu *stackMenu;
    UIView *coverView;
    UIButton *operationBtn;
    
    BOOL isHaveImage;
    UIButton *voiceBtn;
    UIButton *photoBtn;
    UIImageView *line3;
    
    UIButton *classBtn;
    UIButton *typeBtn;
    
    
    NSMutableArray *_imageFileArray;
    
    Forum *_forums;
    AVRelation *_altype;
    
    ThreadType *_selectType;
    ThreadFlag *_selectFlag;
    
    UIView *backgroundView;
    
    UILongPressGestureRecognizer *longPrees;
    
    NSString *_atUserName;
    NSMutableArray *_atUserArray;
    
//    STTweetLabel *_friendLabel;
    UIScrollView *_nameScrollView;
    
}

@property(nonatomic,assign)BOOL uploadVideo;

@property(nonatomic,retain)NSMutableArray *atUserArray;
@property(nonatomic,retain)NSString *atUserName;
@property(nonatomic,retain)NSMutableArray *updateImageArray;
@property(nonatomic,retain)ThreadFlag *selectFlag;
@property(nonatomic,retain)ThreadType *selectType;
@property(nonatomic,retain)AVRelation *altype;
@property(nonatomic,retain)Forum *forums;
@property(nonatomic, retain)AVFile *videofile;
@property(nonatomic, retain)AVFile *amrfile;
@property(nonatomic,retain)NSMutableArray *imageFileArray;
@property(nonatomic,retain)NSData *videoData;
@property(nonatomic,retain)NSData *amrData;
@property (nonatomic,retain)NSString *originWav;         //原wav文件名
@property (nonatomic,retain)NSString *convertAmr;        //转换后的amr文件名
@property (nonatomic,retain)NSString *convertWav;        //amr转wav的文件名
@property(nonatomic,retain)UIImage *uploadImg;
@property(nonatomic,retain)NSMutableArray *classAry,*imageArray,*tempArray,*defaultArray,*typeArray;
@end
