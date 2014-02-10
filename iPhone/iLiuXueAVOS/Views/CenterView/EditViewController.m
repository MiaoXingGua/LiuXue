//
//  EditViewController.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-17.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "EditViewController.h"
#import "CustomCell.h"

@interface EditViewController ()

@end

@implementation EditViewController
@synthesize user = _user;
@synthesize userArray = _userArray;
@synthesize userImg = _userImg;
@synthesize emotionArray = _emotionArray;
@synthesize emotionStr = _emotionStr;
@synthesize bridayDate = _bridayDate;

- (void)dealloc
{
    [_bridayDate release]; _bridayDate=nil;
    [_user release]; _user=nil;
    [_userArray release]; _userArray=nil;
    [_userImg release]; _userImg=nil;
    [_emotionArray release]; _emotionArray=nil;
    [_emotionStr release]; _emotionStr=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [super dealloc];
}


- (id)initWithUser:(User *)user UserInfo:(NSArray *)userAry
{
    if (self = [super init])
    {
        self.user = user;
        self.userArray = [NSArray arrayWithArray:userAry];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardshow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardhide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.emotionArray = [NSMutableArray arrayWithCapacity:0];
    [self.emotionArray addObject:@"单身"];
    [self.emotionArray addObject:@"暗恋"];
    [self.emotionArray addObject:@"恋爱中"];
    [self.emotionArray addObject:@"失恋"];
    [self.emotionArray addObject:@"订婚"];
    [self.emotionArray addObject:@"已婚"];
    [self.emotionArray addObject:@"离异"];
    [self.emotionArray addObject:@"其它"];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.97 blue:0.96 alpha:1];
    
    UIView *stateView = [[UIView alloc] init];
    
    if ([ViewData defaultManager].version==6)
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    else
    {
        stateView.frame = CGRectMake(0, 0, 320, [ViewData defaultManager].versionHeight);
    }
    
    stateView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [self.view addSubview:stateView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, stateView.frame.size.height, 320, SCREEN_HEIGHT)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    [stateView release];
    [backgroundView release];
    
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    naviView.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
    [backgroundView addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.text = @"编辑资料";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 10, 30, 30);
    [cancelBtn setImage:[UIImage imageNamed:@"_0036_确认.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelPublish) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:cancelBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(280, 10, 30, 30);
    [doneBtn setImage:[UIImage imageNamed:@"_0035_取消.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:doneBtn];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(320, SCREEN_HEIGHT+160);
    _scrollView.backgroundColor = [UIColor clearColor];
    [backgroundView addSubview:_scrollView];
    [_scrollView release];
    
    
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    userView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:userView];
    [userView release];
    
    coverImage = [[UIImageView alloc] init];
    coverImage.frame = CGRectMake(0, 0, 76, 76);
    coverImage.center = CGPointMake(50, 50);
    coverImage.image = [UIImage imageNamed:@"unfinduser.png"];
    [userView addSubview:coverImage];
    [coverImage release];
    
    asyView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70) ImageState:0];
    asyView.urlString = [self.userArray objectAtIndex:5];
    asyView.center = CGPointMake(50, 50);
    [asyView addTarget:self action:@selector(selectHeadView) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:asyView];
    [asyView release];
    
    
    UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 15, 100, 20)];
    nicknameLabel.backgroundColor = [UIColor clearColor];
    nicknameLabel.text = @"昵称:";
    nicknameLabel.font = [UIFont systemFontOfSize:15];
    [userView addSubview:nicknameLabel];
    [nicknameLabel release];
    
    _text_nickname = [[UITextField alloc] initWithFrame:CGRectMake(140, 16, 150, 20)];
    _text_nickname.backgroundColor = [UIColor clearColor];
    _text_nickname.text = [self.userArray objectAtIndex:4];
    _text_nickname.delegate = self;
    _text_nickname.returnKeyType = UIReturnKeyDone;
    _text_nickname.font = [UIFont systemFontOfSize:15];
    [userView addSubview:_text_nickname];
    [_text_nickname release];
    
    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 100, 20)];
    ageLabel.backgroundColor = [UIColor clearColor];
    ageLabel.text = @"年龄:";
    ageLabel.font = [UIFont systemFontOfSize:15];
    [userView addSubview:ageLabel];
    [ageLabel release];
    
    ageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ageBtn.frame = CGRectMake(140, 51, 150, 20);
    ageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [ageBtn setTitle:[self.userArray objectAtIndex:6] forState:UIControlStateNormal];
    ageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [ageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [ageBtn addTarget:self action:@selector(selectBriday) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:ageBtn];
    
    UILabel *emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 85, 100, 20)];
    emotionLabel.backgroundColor = [UIColor clearColor];
    emotionLabel.text = @"情感状态:";
    emotionLabel.font = [UIFont systemFontOfSize:15];
    [userView addSubview:emotionLabel];
    [emotionLabel release];
    
    emotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emotionBtn.frame = CGRectMake(170, 86, 140, 20);
    emotionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [emotionBtn setTitle:[self.userArray objectAtIndex:7] forState:UIControlStateNormal];
    [emotionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [emotionBtn addTarget:self action:@selector(selectEmotion) forControlEvents:UIControlEventTouchUpInside];
    emotionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [userView addSubview:emotionBtn];
 
    
    genderMan = [UIButton buttonWithType:UIButtonTypeCustom];
    genderMan.frame = CGRectMake(100, 120, 30, 30);
    [genderMan addTarget:self action:@selector(changeGenderToMan) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:genderMan];
    
    UIImageView *manView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007_男.png"]];
    manView.frame = CGRectMake(140, 130, 23/2, 23/2);
    [userView addSubview:manView];
    [manView release];
    
    genderWoman = [UIButton buttonWithType:UIButtonTypeCustom];
    genderWoman.frame = CGRectMake(210, 120, 30, 30);
    [genderWoman addTarget:self action:@selector(changeGenderToWoman) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:genderWoman];
    
    UIImageView *womanView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0006_女.png"]];
    womanView.frame = CGRectMake(250, 130, 23/2, 23/2);
    [userView addSubview:womanView];
    [womanView release];
    
    BOOL _gender = [[self.userArray objectAtIndex:8] boolValue];
    
    if (_gender==0)
    {
        [genderMan setImage:[UIImage imageNamed:@"_0005_男—unselect.png"] forState:UIControlStateNormal];
        [genderWoman setImage:[UIImage imageNamed:@"_0001_女—select.png"] forState:UIControlStateNormal];
        coverImage.image = [UIImage imageNamed:@"nv.png"];
        
        isMan=0;

    }
    else
    {
        [genderMan setImage:[UIImage imageNamed:@"_0003_男—select.png"] forState:UIControlStateNormal];
        [genderWoman setImage:[UIImage imageNamed:@"_0004_女—unselect.png"] forState:UIControlStateNormal];
        coverImage.image = [UIImage imageNamed:@"nan.png"];
        
        isMan=1;
    }
    
    UIImageView *line5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007__.png"]];
    line5.frame = CGRectMake(0, 170, 320 , 1);
    [userView addSubview:line5];
    [line5 release];
    ////////////////////////////////////////////////////////////////////////////////////////
    
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, 320, 400)];
    textView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:textView];
    [textView release];
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 30)];
    label1.text = @"毕业学校:";
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    label1.font = [UIFont systemFontOfSize:15];
    [textView addSubview:label1];
    [label1 release];
    
    _textView_graduat = [[UITextView alloc] initWithFrame:CGRectMake(90, 8, 220, 60)];
    _textView_graduat.delegate = self;
    _textView_graduat.tag = 1000;
    _textView_graduat.text = [self.userArray objectAtIndex:0];
    _textView_graduat.font = [UIFont systemFontOfSize:15];
    _textView_graduat.backgroundColor = [UIColor whiteColor];
    _textView_graduat.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [textView addSubview:_textView_graduat];
    [_textView_graduat release];
    
    UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007__.png"]];
    line1.frame = CGRectMake(0, 80, 320 , 1);
    [textView addSubview:line1];
    [line1 release];
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 90, 80, 30)];
    label2.text = @"意向学校:";
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    label2.font = [UIFont systemFontOfSize:15];
    [textView addSubview:label2];
    [label2 release];
    
    _textView_study = [[UITextView alloc] initWithFrame:CGRectMake(90, 88, 220, 60)];
    _textView_study.delegate = self;
    _textView_study.tag = 1001;
    _textView_study.text = [self.userArray objectAtIndex:1];
    _textView_study.font = [UIFont systemFontOfSize:15];
    _textView_study.backgroundColor = [UIColor whiteColor];
    _textView_study.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [textView addSubview:_textView_study];
    [_textView_study release];
    
    UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007__.png"]];
    line2.frame = CGRectMake(0, 160, 320 , 1);
    [textView addSubview:line2];
    [line2 release];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, 170, 80, 30)];
    label3.text = @"兴趣爱好:";
    label3.backgroundColor = [UIColor clearColor];
    label3.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    label3.font = [UIFont systemFontOfSize:15];
    [textView addSubview:label3];
    [label3 release];
    
    _textView_like = [[UITextView alloc] initWithFrame:CGRectMake(90, 168, 220, 90)];
    _textView_like.delegate = self;
    _textView_like.tag = 1002;
    _textView_like.text = [self.userArray objectAtIndex:2];
    _textView_like.font = [UIFont systemFontOfSize:15];
    _textView_like.backgroundColor = [UIColor whiteColor];
    _textView_like.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [textView addSubview:_textView_like];
    [_textView_like release];
    
    UIImageView *line3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007__.png"]];
    line3.frame = CGRectMake(0, 270, 320 , 1);
    [textView addSubview:line3];
    [line3 release];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(15, 280, 80, 30)];
    label4.text = @"个性签名:";
    label4.backgroundColor = [UIColor clearColor];
    label4.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    label4.font = [UIFont systemFontOfSize:15];
    [textView addSubview:label4];
    [label4 release];
    
    _textView_qian = [[UITextView alloc] initWithFrame:CGRectMake(90, 278, 220, 90)];
    _textView_qian.delegate = self;
    _textView_qian.tag = 1003;
    _textView_qian.text = [self.userArray objectAtIndex:3];
    _textView_qian.font = [UIFont systemFontOfSize:15];
    _textView_qian.backgroundColor = [UIColor whiteColor];
    _textView_qian.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    [textView addSubview:_textView_qian];
    [_textView_qian release];
    
    UIImageView *line4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007__.png"]];
    line4.frame = CGRectMake(0, 380, 320 , 1);
    [textView addSubview:line4];
    [line4 release];
    
    
    if ([ViewData defaultManager].version==6)
    {
        backView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, 320, 180)];
        backView.backgroundColor = [UIColor grayColor];
        backView.alpha = 0.8;
        [self.view addSubview:backView];
        [backView release];
        
        seleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [seleBtn setImage:[UIImage imageNamed:@"_0001_完成2--.png"] forState:UIControlStateNormal];
        seleBtn.frame = CGRectMake(270, SCREEN_HEIGHT, 87/2, 30);
        [seleBtn addTarget:self action:@selector(selectTime) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:seleBtn];
        
        datePikerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, 320, 150)];
        datePikerView.datePickerMode = UIDatePickerModeDate;
        datePikerView.minimumDate = [NSDate dateWithTimeIntervalSince1970:0];
        datePikerView.maximumDate = [NSDate date];
        [self.view addSubview:datePikerView];
        [datePikerView release];
    }
    else
    {
        backView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, 320, 150)];
        backView.backgroundColor = [UIColor whiteColor];
        backView.alpha = 0.9;
        [self.view addSubview:backView];
        [backView release];
        
        seleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [seleBtn setImage:[UIImage imageNamed:@"_0001_完成2--.png"] forState:UIControlStateNormal];
        seleBtn.frame = CGRectMake(270, SCREEN_HEIGHT, 87/2, 30);
        [seleBtn addTarget:self action:@selector(selectTime) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:seleBtn];
        
        datePikerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT, 300, 130)];
        datePikerView.datePickerMode = UIDatePickerModeDate;
        datePikerView.minimumDate = [NSDate dateWithTimeIntervalSince1970:0];
        datePikerView.maximumDate = [NSDate date];
        [self.view addSubview:datePikerView];
        [datePikerView release];
    }
}

- (void)changeGenderToMan
{
    isMan = 1;
    [genderMan setImage:[UIImage imageNamed:@"_0003_男—select.png"] forState:UIControlStateNormal];
    [genderWoman setImage:[UIImage imageNamed:@"_0004_女—unselect.png"] forState:UIControlStateNormal];
    
    coverImage.image = [UIImage imageNamed:@"nan.png"];
}

- (void)changeGenderToWoman
{
    isMan = 0;
    
    [genderMan setImage:[UIImage imageNamed:@"_0005_男—unselect.png"] forState:UIControlStateNormal];
    [genderWoman setImage:[UIImage imageNamed:@"_0001_女—select.png"] forState:UIControlStateNormal];
    coverImage.image = [UIImage imageNamed:@"nv.png"];
}

- (void)selectBriday
{
    [_text_nickname resignFirstResponder];
    [_textView_graduat resignFirstResponder];
    [_textView_like resignFirstResponder];
    [_textView_qian resignFirstResponder];
    [_textView_study resignFirstResponder];

    if ([ViewData defaultManager].version==6)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            backView.frame = CGRectMake(0, SCREEN_HEIGHT-190, 320, 190);
            seleBtn.frame = CGRectMake(270, SCREEN_HEIGHT-185, 87/2, 30);
            datePikerView.frame = CGRectMake(0, SCREEN_HEIGHT-150, 320, 150);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            backView.frame = CGRectMake(0, SCREEN_HEIGHT-150, 320, 150);
            seleBtn.frame = CGRectMake(270, SCREEN_HEIGHT-150, 87/2, 30);
            datePikerView.frame = CGRectMake(10, SCREEN_HEIGHT-150, 300, 130);
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)selectTime
{
    self.bridayDate = datePikerView.date;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *destDateString = [dateFormatter stringFromDate:self.bridayDate];
    
    [dateFormatter release];
    
    [ageBtn setTitle:destDateString forState:UIControlStateNormal];
    
    if ([ViewData defaultManager].version==6)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            backView.frame = CGRectMake(0, SCREEN_HEIGHT, 320, 190);
            seleBtn.frame = CGRectMake(260, SCREEN_HEIGHT, 87/2, 30);
            datePikerView.frame = CGRectMake(0, SCREEN_HEIGHT, 320, 150);
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            backView.frame = CGRectMake(0, SCREEN_HEIGHT, 320, 150);
            seleBtn.frame = CGRectMake(260, SCREEN_HEIGHT, 87/2, 30);
            datePikerView.frame = CGRectMake(10, SCREEN_HEIGHT, 300, 130);
            
        } completion:^(BOOL finished) {
            
            
        }];
        
    }
}

- (void)selectHeadView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    actionSheet=nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
        imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePiker.delegate = self;
        imagePiker.allowsEditing = YES;
        [self presentViewController:imagePiker
                           animated:YES
                         completion:NULL];
        [imagePiker release];
    }
    if (buttonIndex == 1)
    {
        
        UIImagePickerController *imagPickerC = [[UIImagePickerController alloc] init];//图像选取器
        imagPickerC.delegate = self;
        imagPickerC.allowsEditing = YES;
        imagPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
        imagPickerC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
        [self presentViewController:imagPickerC animated:YES completion:nil];
        [imagPickerC release];
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.userImg = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (self.userImg)
    {
        asyView.image = self.userImg;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    UITextView *temp;
    float moveheight;
    
    if (textView.tag==1000)
    {
        temp = (UITextView *)[self.view viewWithTag:1000];
        moveheight = 100;
    }
    
    if (textView.tag==1001)
    {
        temp = (UITextView *)[self.view viewWithTag:1001];
        moveheight = 160;
    }
    
    
    if (textView.tag==1002)
    {
        temp = (UITextView *)[self.view viewWithTag:1002];
        moveheight = 300;
        
    }
    if (textView.tag==1003)
    {
        temp = (UITextView *)[self.view viewWithTag:1003];
        moveheight = 360;
    }
    
    [self animaiton:temp MoveHeight:moveheight];
    
    return YES;
}

- (void)animaiton:(UITextView *)textview MoveHeight:(float)height
{
    [UIView animateWithDuration:0.3 animations:^{
        
        _scrollView.contentOffset = CGPointMake(0, height);
        
    }];
}

- (void)keyboardshow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        _scrollView.contentSize = CGSizeMake(320, _scrollView.contentSize.height+keyboardRect.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}


- (void)keyboardhide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        _scrollView.contentSize = CGSizeMake(320, SCREEN_HEIGHT+160);
        
    } completion:^(BOOL finished) {
        
    }];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        
        return YES;
    }
    
    return YES;
}

- (void)done
{
    if(_text_nickname.text.length==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if (_text_nickname.text.length>10)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称长度不能超过10个字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }

    __block typeof(self) bself = self;

    [self showF3HUDLoad:nil];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:_textView_graduat.text forKey:@"graduateSchool"];
    [dic setValue:_textView_study.text forKey:@"company"];
    [dic setValue:_textView_like.text forKey:@"interest"];
    [dic setValue:_textView_qian.text forKey:@"signature"];
    
    [dic setValue:_text_nickname.text forKey:@"nickName"];
    [dic setValue:[NSNumber numberWithBool:isMan] forKey:@"gender"];
    [dic setValue:self.emotionStr forKey:@"affectiveState"];
    
    if (self.bridayDate)
    {
        [dic setValue:self.bridayDate forKey:@"brithday"];
    }
    
    if (self.userImg)
    {
        AVFile *imageAVFile = [AVFile fileWithName:[NSString stringWithFormat:@"%d.jpg",(int)[[NSDate date] timeIntervalSince1970]] data:UIImageJPEGRepresentation(self.userImg, 0.5)];
        [imageAVFile save];
        
        [dic setValue:imageAVFile forKey:@"headView"];
    }

    
    [[ALUserEngine defauleEngine] updateMyCardWithUserInfo:dic block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error)
        {
            [bself hideF3HUDSucceed:nil];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEUSERINFO object:nil];
            
            [bself.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
    }];
}

- (void)cancelPublish
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"信息未保存，是否退出" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    [alert show];
    [alert release];
    alert=nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_text_nickname resignFirstResponder];
    
    return YES;
}


#pragma mark ChangeClass 切换显示分类

//关闭分类
- (void)cancelClass
{
    isShowClass = NO;

    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _classTableView.alpha = 0;
        classImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_classTableView removeFromSuperview];
        [classImageView removeFromSuperview];
        classImageView=nil;
        _classTableView=nil;
    }];
}



//切换显示标签
- (void)selectEmotion
{
    if(isShowClass==NO)
    {
        isShowClass = YES;
        
        
        if(_classTableView==nil)
        {
            classImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xialakuang.png"]];
            classImageView.frame = CGRectMake(74, 120+[ViewData defaultManager].versionHeight, 361/2, 421/2);
            [_scrollView addSubview:classImageView];
            classImageView.alpha = 0;
            [classImageView release];
            
            _classTableView = [[UITableView alloc] initWithFrame:CGRectMake(78, 128+[ViewData defaultManager].versionHeight, 361/2-8, 421/2-13) style:UITableViewStylePlain];
            _classTableView.dataSource = self;
            _classTableView.delegate = self;
            _classTableView.tag = 5002;
            _classTableView.backgroundColor = [UIColor clearColor];
            _classTableView.separatorColor = [UIColor clearColor];
            [_scrollView addSubview:_classTableView];
            _classTableView.alpha = 0;
            _classTableView.layer.cornerRadius = 8;
            [_classTableView release];
        }
        
        [_classTableView reloadData];
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _classTableView.alpha = 1;
            classImageView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self cancelClass];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    static NSString *Cellidentifier = @"cell1";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if(cell==nil)
    {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellidentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSString *str = [self.emotionArray objectAtIndex:indexPath.row];
    
    [cell.title setTextAlignment:NSTextAlignmentCenter];
    cell.title.text = str;
    cell.title.frame = CGRectMake(0, 17, 170, 20);
    
    cell.homeCellLine.hidden = NO;
    cell.homeCellLine.image = [UIImage imageNamed:@"_0000_______.png"];
    cell.homeCellLine.frame = CGRectMake(0, 49, 361/2-8, 1);
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.emotionArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [emotionBtn setTitle:[self.emotionArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    self.emotionStr = [self.emotionArray objectAtIndex:indexPath.row];
    
    [self cancelClass];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
