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


#import "LandingCallsStateViewController.h"
#import "ModelEngineVoip.h"
@interface LandingCallsStateViewController ()

@end

@implementation LandingCallsStateViewController

@synthesize phoneArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithPhoneArray:(NSMutableArray*) phones
{
    self = [super init];
    if (self)
    {
        self.phoneArray = phones;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"营销外呼结果";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];    
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbhead.backgroundColor = [UIColor clearColor];
    lbhead.textColor = [UIColor whiteColor];
    lbhead.textAlignment = UITextAlignmentLeft;
    lbhead.font = [UIFont systemFontOfSize:13.0f];
    lbhead.text = [NSString stringWithFormat: @"    正在处理您提交的%d个号码",phoneArray.count];
    [self.view addSubview:lbhead];
    [lbhead release];
    
    int top = 0;
    for (int i = 0; i< phoneArray.count; i++)
    {
        UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(43.0f, 47.0f+(42)*i, 276.0f, 14.0f)];
        Label.backgroundColor = [UIColor clearColor];
        Label.textAlignment = UITextAlignmentLeft;
        Label.tag = 700+i;
        Label.text = [self.phoneArray objectAtIndex:i];
        [self.view addSubview:Label];
        [Label release];
        
        top = 47.0f+(42)*i;
        
        UILabel *LabelState = [[UILabel alloc] initWithFrame:CGRectMake(193.0f, top, 126.0f, 14.0f)];
        LabelState.backgroundColor = [UIColor clearColor];
        LabelState.textAlignment = UITextAlignmentLeft;
        LabelState.tag = 800+i;
        [self.view addSubview:LabelState];
        [LabelState release];
                
        UIImageView* iv = [[UIImageView alloc] init];
        if (i==0)
        {
            LabelState.text = @"";
            iv.image = [UIImage imageNamed:@"status_icon03.png"];
        }
        else if (i==1)
        {
            LabelState.text = @"";
            iv.image = [UIImage imageNamed:@"status_icon04.png"];
        }
        else if (i==2)
        {
            LabelState.text = @"";
            iv.image = [UIImage imageNamed:@"status_icon03.png"];
        }
        else 
        {
            LabelState.text = @"";            
            iv.image = [UIImage imageNamed:@"status_icon01.png"];
        }
        
        iv.frame = CGRectMake(15.0f, top+2, 9.f, 9.f);
        iv.tag = 900+i;
        [self.view addSubview:iv];
        [iv release];
    }
    top += 50;
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(114.5f, top, 91.f, 37.0f);
    
    [btn setBackgroundImage:[UIImage imageNamed:@"botton_off@2x.png"] forState:(UIControlStateNormal)];
    [btn setBackgroundImage:[UIImage imageNamed:@"botton_on@2x.png"] forState:(UIControlStateSelected)];
    [btn setTitle:@"完成" forState:(UIControlStateNormal)];
    [btn setTitle:@"完成" forState:(UIControlStateSelected)];
    [btn addTarget:self action:@selector(popToPreView) forControlEvents:(UIControlEventTouchDown)];
    [self.view addSubview:btn];
}


-(void)dealloc
{
    self.phoneArray = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//营销外呼回调
- (void)onLandingCAllsStatus:(NSInteger)reason  andCallSid:(NSString*)callSid  andDateCreated:(NSString*)dateCreated
{
    [self dismissProgressingView];
    if (reason == 0)
    {
        [theAppDelegate printLog:(@"调用营销外呼接口成功！")];
        for (UIView *view in self.view.subviews)
        {
            if (view.tag >= 800)
            {
                int i = view.tag - 800;
                //下方状态都是写死的，实际情况需要自己做判断
                if ([view isKindOfClass:[UILabel class]])
                {
                    ((UILabel*)view).text = @"呼叫失败";
                    if (i==0)
                    {
                        ((UILabel*)view).text = @"已成功接听";
                    }
                    else if (i==1)
                    {
                        ((UILabel*)view).text = @"对方忙";
                    }
                    else if (i==2)
                    {
                        ((UILabel*)view).text = @"正在呼叫";
                    }
                    else
                    {
                        ((UILabel*)view).text = @"等待呼叫";
                    }
                }
            }
        }
    }
    else
    {
        for (UIView *view in self.view.subviews) {
            if (view.tag >= 800)
            {
                if ([view isKindOfClass:[UILabel class]]) {
                    ((UILabel*)view).text = @"呼叫失败";
                }
            }
        }
        [theAppDelegate printLog:(@"调用营销外呼接口失败！")];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
    for (NSString* str in self.phoneArray)
    {
        [self displayProgressingView];
        [self.modelEngineVoip LandingCalls:str];
    }
}

@end
