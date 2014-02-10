//
//  ShowImageViewController.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-7.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ShowImageViewController.h"


@interface ShowImageViewController ()

@end

@implementation ShowImageViewController

@synthesize downimage = _downimage;
@synthesize imageUrl = _imageUrl;
@synthesize reciveData = _reciveData;

- (void)dealloc
{
    [_connection cancel];
    [_connection release];
    _connection = nil;
    [_reciveData release]; _reciveData=nil;
    [_downimage release]; _downimage=nil;
    [_imageUrl release]; _imageUrl=nil;

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame ImageUrl:(NSString *)imageUrl Image:(UIImage *)image
{
	
	if (self = [super init])
    {
        self.view.frame = frame;
		self.view.backgroundColor = [UIColor blackColor];
		
        self.imageUrl = imageUrl;
        self.downimage = image;
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(0, 0, 20, 20);
        _activityView.center = CGPointMake(160, SCREEN_HEIGHT/2);
        [self.view addSubview:_activityView];
        [_activityView startAnimating];
        [_activityView release];
        
        if(self.imageUrl)
        {
            tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self.view addGestureRecognizer:tapGesture1];
            [tapGesture1 release];
            
            [self downLoadImage];
        }
        
        if(self.downimage)
        {
            [self initImageView];
        }
        
        
	}
	
	return self;
}


- (void)downLoadImage
{
    NSURL *imgurl = [NSURL URLWithString:self.imageUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imgurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_connection start];
    [request release];
    
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.reciveData==nil) {
        
        self.reciveData = [[NSMutableData alloc] initWithCapacity:2048];
        
    }
    
    [self.reciveData appendData:data];
    
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downimage = [UIImage imageWithData:self.reciveData];
    
    if(self.downimage)
    {
        [_connection cancel];
        [_connection release];
        _connection=nil;
        
        [self.view removeGestureRecognizer:tapGesture1];
        
        [self initImageView];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    if(error)
    {
        [_connection cancel];
        [_connection release];
        _connection=nil;
        
        self.reciveData=nil;
        
        [_activityView stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请求超时" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex==0)
//    {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.view.transform = CGAffineTransformMakeScale(2, 2);
//            self.view.alpha = 0;
//        } completion:^(BOOL finished) {
//            
//            [self.view removeFromSuperview];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeImageView" object:nil];
//            
//        }];
//    }
}

- (void)initImageView
{
    [_activityView stopAnimating];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, SCREEN_HEIGHT)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 2.0;
    scrollView.center = CGPointMake(160, SCREEN_HEIGHT/2);
    
    _imageView = [[UIImageView alloc] initWithImage:self.downimage];
    _imageView.userInteractionEnabled = YES;
    _imageView.alpha = 0;
    
    if(self.downimage.size.width>=320)
    {
        _imageView.frame = CGRectMake(0, 0, 320, self.downimage.size.height/(self.downimage.size.width/320));
    }
    else
    {
        _imageView.frame = CGRectMake(0, 0, 320, self.downimage.size.height/(self.downimage.size.width/320));
    }
    
    if(_imageView.frame.size.height>=SCREEN_HEIGHT)
    {
        _imageView.center = CGPointMake(160, _imageView.frame.size.height/2);
    }
    else
    {
        _imageView.center = CGPointMake(160, SCREEN_HEIGHT/2);
    }
    
    scrollView.contentSize = CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height);
    [scrollView addSubview:_imageView];
    [self.view addSubview:scrollView];
    [_imageView release];
    [scrollView release];
    
    tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_imageView addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(savetheimage)];
    [_imageView addGestureRecognizer:longpress];
    [longpress release];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _imageView.alpha = 1;
    }];
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.view.transform = CGAffineTransformMakeScale(2, 2);
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeImageView" object:nil];

    }];
    
   
}

- (void)savetheimage
{
    if(sheet==nil)
    {
        sheet = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存", nil];
        [sheet showInView:self.view];
        [sheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    sheet=nil;
    
    if(buttonIndex==0)
    {
        if(_imageView.image)
        {
            [self show];
            UIImageWriteToSavedPhotosAlbum(_imageView.image, nil, nil,nil);
        }
    }
}

- (void)show
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片已保存到相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [scrollView setZoomScale:scale animated:NO];
    
    scrollView.contentSize = CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height);

    if(_imageView.frame.size.height>=SCREEN_HEIGHT)
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _imageView.center = CGPointMake(_imageView.center.x, _imageView.frame.size.height/2);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _imageView.center = CGPointMake(_imageView.center.x, SCREEN_HEIGHT/2);
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
