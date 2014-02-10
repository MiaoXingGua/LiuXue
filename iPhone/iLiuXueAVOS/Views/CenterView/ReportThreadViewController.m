//
//  ReportThreadViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-24.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ReportThreadViewController.h"
#import "ViewData.h"

@interface ReportThreadViewController ()

@end

@implementation ReportThreadViewController
@synthesize threads = _threads;

- (void)dealloc
{
    [_threads release]; _threads=nil;
    
    [super dealloc];
}

- (id)initWIthThread:(Thread *)threads
{
    if (self = [super init])
    {
        self.threads = threads;
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [_textview_content becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [_textview_content resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    titleLabel.text = @"收藏";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.center = CGPointMake(160, 23);
    [naviView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *showLeftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftViewBtn.frame = CGRectMake(10, 10, 30, 30);
    [showLeftViewBtn setImage:[UIImage imageNamed:@"_0010_chat_返回.png"] forState:UIControlStateNormal];
    [showLeftViewBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:showLeftViewBtn];
    
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(270, 7, 40, 30);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendReport) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:sendBtn];
    
    NSLog(@"%@",self.threads.title);
    
    UILabel *threadtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 290, 30)];
    threadtitleLabel.text = [NSString stringWithFormat:@"主题：%@",self.threads.title];
    threadtitleLabel.font = [UIFont systemFontOfSize:16];
    threadtitleLabel.textColor = [UIColor blackColor];
    threadtitleLabel.backgroundColor = [UIColor clearColor];
    [threadtitleLabel setTextAlignment:NSTextAlignmentLeft];
    [backgroundView addSubview:threadtitleLabel];
    [threadtitleLabel release];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_______.png"]];
    lineImage.frame = CGRectMake(0, 90, 320, 1);
    [backgroundView addSubview:lineImage];
    [lineImage release];
    
    _textview_content = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, 300, SCREEN_HEIGHT-330-[ViewData defaultManager].versionHeight)];
    _textview_content.delegate = self;
    _textview_content.textColor = [UIColor grayColor];
    _textview_content.font = [UIFont systemFontOfSize:16];
    _textview_content.backgroundColor = [UIColor clearColor];
    _textview_content.returnKeyType = UIReturnKeyDefault;
    [backgroundView addSubview:_textview_content];
    [_textview_content release];
}

- (void)sendReport
{
    if(_textview_content.text.length==0)
    {
        return;
    }
    
    if(self.threads)
    {
        __block typeof(self) bself = self;

        [self showF3HUDLoad:nil];
        
        [[ALThreadEngine defauleEngine] reportThread:self.threads orPost:nil andReason:_textview_content.text block:^(BOOL succeeded, NSError *error) {
            
            if(succeeded && !error)
            {
                [bself hideF3HUDSucceed:nil];
                
                [bself.navigationController popViewControllerAnimated];
            }
            else
            {
                [bself hideF3HUDError:nil];
            }
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"主题已被删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert=nil;
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
