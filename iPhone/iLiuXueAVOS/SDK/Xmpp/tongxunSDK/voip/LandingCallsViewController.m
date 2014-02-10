/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */


#import "LandingCallsViewController.h"
#import "LandingCallsStateViewController.h"

@interface LandingCallsViewController ()

@end

@implementation LandingCallsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"营销外呼";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    UIButton *btnBG = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnBG.frame = self.view.frame;
    [btnBG addTarget:self action:@selector(hidekeyboard) forControlEvents:(UIControlEventTouchDown)];
    [self.view addSubview:btnBG];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"开始外呼" target:self action:@selector(callSomebody)]];
    self.navigationItem.rightBarButtonItem = right;
    [right release];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbhead.backgroundColor = [UIColor clearColor];
    lbhead.textColor = [UIColor whiteColor];
    lbhead.textAlignment = UITextAlignmentLeft;
    lbhead.font = [UIFont systemFontOfSize:13.0f];
    lbhead.text =  @"    请输入一个或多个需要外呼的号码";
    [self.view addSubview:lbhead];
    [lbhead release];
    
    for (int i = 0; i< 5; i++)
    {
        UIImageView *img = [[UIImageView alloc] init];
        img = [[UIImageView alloc] initWithFrame:CGRectMake(18.0f, 37.0f+(7+28)*i, 284.0f, 28.0f)];
        img.image = [UIImage imageNamed:@"input_box@2x.png"];
        [self.view addSubview:img];
        [img release];
        
        UITextField *mtextField = [[UITextField alloc] initWithFrame:CGRectMake(28.0f, 37.0f+(7+28)*i, 274.0f, 28.0f)];
        mtextField.font = [UIFont systemFontOfSize:14];
        mtextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.view addSubview:mtextField];
        if (i == 0 && [self.modelEngineVoip.voipPhone length]>0)
        {
            mtextField.text = self.modelEngineVoip.voipPhone;
        }
        mtextField.placeholder = @"手机号/固号（加区号）";
        mtextField.delegate = self;
        mtextField.tag = 800+i;
        mtextField.keyboardType = UIKeyboardTypePhonePad;
        [mtextField release];
    }
        
    UIView* footerView = [[UIView alloc] init];
    footerView.frame = CGRectMake(0, 460-44.0f-44.0f, 320, 44);
    if (IPHONE5)
    {
        footerView.frame = CGRectMake(0, 548-44.0f-44.0f, 320, 44);
    }
    
    UIImageView *imgfooter = [[UIImageView alloc] init];
    imgfooter = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    imgfooter.image = [UIImage imageNamed:@"top_bg.png"];
    [footerView addSubview:imgfooter];
    [imgfooter release];
    UILabel *lbFooter = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] ;
    lbFooter.backgroundColor = [UIColor clearColor];
    lbFooter.textColor = [UIColor whiteColor];
    lbFooter.textAlignment = UITextAlignmentLeft;
    lbFooter.font = [UIFont systemFontOfSize:12.0f];
    lbFooter.text =  @"    上述号码接听后即可听到预设的语音";
    [footerView addSubview:lbFooter];
    [lbFooter release];
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(217.0f, 4.0f, 91.f, 37.0f);
    [btn setBackgroundImage:[UIImage imageNamed:@"button02_on.png"] forState:(UIControlStateNormal)];
    [btn setBackgroundImage:[UIImage imageNamed:@"button02_on.png"] forState:(UIControlStateSelected)];
    [btn setTitle:@"开始外呼" forState:(UIControlStateNormal)];
    [btn setTitle:@"开始外呼" forState:(UIControlStateSelected)];
    [btn addTarget:self action:@selector(callSomebody) forControlEvents:(UIControlEventTouchDown)];
    [footerView addSubview:btn];
    
    [self.view addSubview:footerView];
    [footerView release];    
}

-(void)callSomebody
{
    if (self.phoneNOArray)
    {
        [self.phoneNOArray removeAllObjects];
    }
    else
        self.phoneNOArray = [[[NSMutableArray alloc] init] autorelease];
    for (UIView * view in self.view.subviews)
    {
        if (view.tag >= 800)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                UITextField* field = (UITextField*)view;
                if ([field.text length]>0)
                {
                    [self.phoneNOArray addObject:field.text];
                }
            }
        }
    }
    if ([self.phoneNOArray count] > 0)
    {
        LandingCallsStateViewController* view = [[LandingCallsStateViewController alloc] initWithPhoneArray:self.phoneNOArray];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请至少输入一个号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
        [alert show];
        [alert release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hidekeyboard
{
    for (UIView * view in self.view.subviews)
    {
        if (view.tag >= 800)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                [view resignFirstResponder];
            }
        }
    }
}


@end
