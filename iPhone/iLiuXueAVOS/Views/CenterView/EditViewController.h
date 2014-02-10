//
//  EditViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-17.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "ALUserEngine.h"
#import "ViewData.h"
#import "AsyncImageView.h"

@interface EditViewController : SuperViewController<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    User *_user;
    UIScrollView *_scrollView;
    
    UITextView *_textView_graduat;
    UITextView *_textView_study;
    UITextView *_textView_like;
    UITextView *_textView_qian;
    
    NSArray *_userArray;
    
    UIButton *genderMan,*genderWoman;
    
    BOOL isMan;
    BOOL isShowClass;
    
    UITableView *_classTableView;
    
    UIImageView *coverImage;
    UIImage *_userImg;
    AsyncImageView *asyView;
    UIDatePicker *datePikerView;
    UIView *backView;
    UIButton *seleBtn;
    NSDate *_bridayDate;
    UIButton *ageBtn;
    UITextField *_text_nickname;
    UIButton *emotionBtn;
    UIImageView *classImageView;
    NSString *_emotionStr;
    
    NSMutableArray *_emotionArray;
}

@property(nonatomic,retain)NSString *emotionStr;
@property(nonatomic,retain)NSMutableArray *emotionArray;
@property(nonatomic,retain)NSDate *bridayDate;
@property(nonatomic,retain)UIImage *userImg;
@property(nonatomic,retain)NSArray *userArray;
@property(nonatomic,retain)User *user;

- (id)initWithUser:(User *)user UserInfo:(NSArray *)userAry;

@end
