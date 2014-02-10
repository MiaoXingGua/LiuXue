//
//  FinishPersonalDataViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-10-4.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "ALUserEngine.h"
#import "CHAvatarView.h"

@interface FinishPersonalDataViewController : SuperViewController<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIScrollView *scrollView;
    UIImage *_touxingImg;
    CHAvatarView *touxiangView;
    UIButton *selectBtn;
    UITextField *textfield1;
    
    BOOL isMan;
    UIImageView *coverImage;
    UILabel *bridayLabel;
    
    UIButton *genderMan;
    UIButton *genderWoman;
    

    UIDatePicker *datePikerView;
    UIView *backView;
    UIButton *seleBtn;
    
    
    User *_user;
    
    NSString *_nickName;
    NSString *_headUrl;
    int _gender;
    NSDate *_bridayDate;

}
@property(nonatomic,retain)NSString *headUrl;
@property(nonatomic,assign)int gender;
@property(nonatomic,retain)NSString *nickName;

@property(nonatomic,retain)User *user;
@property(nonatomic,retain)NSDate *bridayDate;
@property(nonatomic,retain)UIImage *touxingImg;

@end
