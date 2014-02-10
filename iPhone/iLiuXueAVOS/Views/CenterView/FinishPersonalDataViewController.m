//
//  FinishPersonalDataViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-10-4.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "FinishPersonalDataViewController.h"
#import "HomeViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MenuViewController.h"
#import "ViewData.h"

@interface FinishPersonalDataViewController ()

@end

@implementation FinishPersonalDataViewController
@synthesize touxingImg = _touxingImg;
@synthesize nickName = _nickName;
@synthesize bridayDate = _bridayDate;
@synthesize headUrl = _headUrl;
@synthesize gender = _gender;

- (void)dealloc
{
    [_bridayDate release]; _bridayDate=nil;
    [_headUrl release]; _headUrl=nil;
    [_nickName release]; _nickName=nil;
    [_touxingImg release]; _touxingImg=nil;
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sidePanelController.recognizesPanGesture = NO;

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
    titleLabel.text = @"填写个人资料";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, SCREEN_HEIGHT)];
    scrollView.contentSize = CGSizeMake(320, SCREEN_HEIGHT);
    scrollView.backgroundColor = [UIColor clearColor];
    [backgroundView addSubview:scrollView];
    [scrollView release];

    coverImage = [[UIImageView alloc] init];
    coverImage.frame = CGRectMake(0, 0, 96, 96);
    coverImage.center = CGPointMake(160, 80);
    coverImage.image = [UIImage imageNamed:@"unfinduser.png"];
    [scrollView addSubview:coverImage];
    [coverImage release];
 
    
    touxiangView = [[CHAvatarView alloc] initWithFrame:CGRectMake(0, 0, 89, 89)];
    touxiangView.image = [UIImage imageNamed:@"默认头像.png"];
    touxiangView.center = CGPointMake(160, 80);
    touxiangView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:touxiangView];
    [touxiangView release];
    
    selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(0, 0, 100, 100);
    [selectBtn addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.center = CGPointMake(160, 80);
    [scrollView addSubview:selectBtn];
    
    if (self.headUrl.length>1)
    {
        [self performSelectorInBackground:@selector(downLoadHeadView) withObject:nil];
    }
    
    UIImageView *nickNameImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0010_昵称.png"]];
    nickNameImage.frame = CGRectMake(0, 0, 542/2, 86/2);
    nickNameImage.center = CGPointMake(160, 170);
    [scrollView addSubview:nickNameImage];
    [nickNameImage release];
  
    UIButton *bridayImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [bridayImage setImage:[UIImage imageNamed:@"_0009_生日.png"] forState:UIControlStateNormal];
    bridayImage.frame = CGRectMake(0, 0, 542/2, 86/2);
    bridayImage.center = CGPointMake(160, 230);
    [bridayImage addTarget:self action:@selector(selectBriday:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bridayImage];
    
    bridayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190, 20)];
    bridayLabel.backgroundColor = [UIColor clearColor];
    bridayLabel.textAlignment = NSTextAlignmentLeft;
    bridayLabel.center = CGPointMake(180, 230);
    bridayLabel.textColor = [UIColor blackColor];
    [scrollView addSubview:bridayLabel];
    [bridayLabel release];
    
    
    if (self.bridayDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *destDateString = [dateFormatter stringFromDate:self.bridayDate];
        
        [dateFormatter release];
        
        bridayLabel.text = destDateString;
        
    }
    
    if ([ViewData defaultManager].version==6)
    {
        textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 190, 30)];
        textfield1.borderStyle = UITextBorderStyleNone;
        textfield1.center = CGPointMake(180, 175);
        textfield1.placeholder = @"可以填写10个字";
        textfield1.delegate = self;
        textfield1.textColor = [UIColor blackColor];
        [scrollView addSubview:textfield1];
        textfield1.returnKeyType = UIReturnKeyDone;
        [textfield1 release];
    }
    else
    {
        textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 190, 30)];
        textfield1.borderStyle = UITextBorderStyleNone;
        textfield1.center = CGPointMake(180, 170);
        textfield1.delegate = self;
        textfield1.placeholder = @"可以填写10个字";
        textfield1.textColor = [UIColor blackColor];
        [scrollView addSubview:textfield1];
        textfield1.returnKeyType = UIReturnKeyDone;
        [textfield1 release];
    }
    
    if (self.nickName.length>0)
    {
        textfield1.text = self.nickName;
    }
    
    genderMan = [UIButton buttonWithType:UIButtonTypeCustom];
    genderMan.frame = CGRectMake(0, 0, 32, 32);
    genderMan.center = CGPointMake(80, 280);
    [genderMan setImage:[UIImage imageNamed:@"_0003_男—select.png"] forState:UIControlStateNormal];
    [genderMan addTarget:self action:@selector(changeGenderToMan) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:genderMan];
    
    UIImageView *manView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0007_男.png"]];
    manView.frame = CGRectMake(0, 0, 23/2, 23/2);
    manView.center = CGPointMake(110, 280);
    [scrollView addSubview:manView];
    [manView release];
    
    genderWoman = [UIButton buttonWithType:UIButtonTypeCustom];
    genderWoman.frame = CGRectMake(0, 0, 32, 32);
    genderWoman.center = CGPointMake(220, 280);
    [genderWoman setImage:[UIImage imageNamed:@"_0004_女—unselect.png"] forState:UIControlStateNormal];
    [genderWoman addTarget:self action:@selector(changeGenderToWoman) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:genderWoman];
    
    UIImageView *womanView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0006_女.png"]];
    womanView.frame = CGRectMake(0, 0, 23/2, 23/2);
    womanView.center = CGPointMake(250, 280);
    [scrollView addSubview:womanView];
    [womanView release];
    
    if (self.gender==0)
    {
        isMan=1;
        coverImage.image = [UIImage imageNamed:@"nan.png"];
        [genderMan setImage:[UIImage imageNamed:@"_0003_男—select.png"] forState:UIControlStateNormal];
    }
    else
    {
        isMan=0;
        coverImage.image = [UIImage imageNamed:@"nv.png"];
        [genderWoman setImage:[UIImage imageNamed:@"_0001_女—select.png"] forState:UIControlStateNormal];
    }
    
    UIButton *zhuce = [UIButton buttonWithType:UIButtonTypeCustom];
    zhuce.frame = CGRectMake(0, 0, 542/2, 86/2);
    zhuce.center = CGPointMake(160, SCREEN_HEIGHT-130);
    [zhuce setImage:[UIImage imageNamed:@"_0008_完-成.png"] forState:UIControlStateNormal];
    [zhuce addTarget:self action:@selector(submitPersonalData) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:zhuce];

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


- (void)selectBriday:(UIButton *)sender
{
    [textfield1 resignFirstResponder];
    
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

- (void)downLoadHeadView
{
    self.touxingImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.headUrl]]];
    
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}

- (void)refreshUI
{
    if (touxiangView)
    {
        [touxiangView removeFromSuperview];
        touxiangView=nil;
    }
    
    touxiangView = [[CHAvatarView alloc] initWithFrame:CGRectMake(0, 0, 89, 89)];
    touxiangView.image = self.touxingImg;
    touxiangView.center = CGPointMake(160, 80);
    touxiangView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:touxiangView];
    [touxiangView release];
    
    [scrollView bringSubviewToFront:selectBtn];
}

- (void)selectTime
{
    self.bridayDate = datePikerView.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *destDateString = [dateFormatter stringFromDate:self.bridayDate];
    
    [dateFormatter release];
    
    bridayLabel.text = destDateString;
    
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

- (void)selectImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
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
    UIImage *image = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (touxiangView)
    {
        [touxiangView removeFromSuperview];
        touxiangView=nil;
    }
    
    touxiangView = [[CHAvatarView alloc] initWithFrame:CGRectMake(0, 0, 89, 89)];
    touxiangView.image = image;
    touxiangView.center = CGPointMake(160, 80);
    touxiangView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:touxiangView];
    [touxiangView release];
    
    [scrollView bringSubviewToFront:selectBtn];
    
    self.touxingImg = nil;
    self.touxingImg = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)submitPersonalData
{
    if(textfield1.text.length==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if (textfield1.text.length>10)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称长度不能超过10个字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
 
    if(self.touxingImg == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择头像！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    if (self.bridayDate==nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择生日！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
        
        return;
    }
    
    __block typeof(self) bself = self;
    

    AVFile *imageAVFile = [AVFile fileWithName:[NSString stringWithFormat:@"%d.jpg",(int)[[NSDate date] timeIntervalSince1970]] data:UIImageJPEGRepresentation(self.touxingImg, 0.5)];
    
    [imageAVFile save];
    
    NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:textfield1.text, @"nickName", [NSNumber numberWithBool:isMan], @"gender", imageAVFile, @"headView", self.bridayDate, @"brithday", nil];
    
    [self showF3HUDLoad:nil];

    [[ALUserEngine defauleEngine] updateMyCardWithUserInfo:_dic block:^(BOOL succeeded, NSError *error) {
        
        if(succeeded && !error)
        {
            [[ALUserEngine defauleEngine].user refresh];
            
            bself.sidePanelController.recognizesPanGesture = YES;
            
            MenuViewController *menu = [[[MenuViewController alloc] init] autorelease];
            bself.sidePanelController.leftPanel = menu;
            
            if([ViewData defaultManager].homeVc!=nil)
            {
                MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:[ViewData defaultManager].homeVc] autorelease];
                bself.sidePanelController.centerPanel = n;
                
            }
            else
            {
                HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
                MLNavigationController *n = [[[MLNavigationController alloc] initWithRootViewController:home] autorelease];
                bself.sidePanelController.centerPanel = n;
                [ViewData defaultManager].homeVc = home;
            }
            
            [bself hideF3HUDSucceed:nil];
        }
        else
        {
            [bself hideF3HUDError:nil];
        }
    }];
}

- (void)showCenterView
{
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
