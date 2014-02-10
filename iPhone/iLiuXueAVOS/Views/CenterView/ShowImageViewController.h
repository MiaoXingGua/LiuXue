//
//  ShowImageViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-9-7.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCConfig.h"

@interface ShowImageViewController : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate>
{
    UIScrollView *scrollView;
	UIImageView *_imageView;
	
    NSMutableData *_reciveData;
    NSURLConnection *_connection;
    NSString *_imageUrl;
    UIImage *_downimage;
    
    UIActivityIndicatorView *_activityView;
    UIActionSheet *sheet;
    
    UITapGestureRecognizer *tapGesture1;
    UITapGestureRecognizer *tapGesture2;
    
}

@property(nonatomic,retain)NSString *imageUrl;
@property(nonatomic,retain)UIImage *downimage;
@property(nonatomic,retain)NSMutableData *reciveData;

- (id)initWithFrame:(CGRect)frame ImageUrl:(NSString *)imageUrl Image:(UIImage *)image;


@end
