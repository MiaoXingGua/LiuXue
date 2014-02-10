//
//  ReportThreadViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-9-24.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALThreadEngine.h"
#import "SuperViewController.h"

@interface ReportThreadViewController : SuperViewController<UITextViewDelegate>
{
    Thread *_threads;
    UITextView *_textview_content;
}

@property(nonatomic,retain)Thread *threads;

- (id)initWIthThread:(Thread *)threads;
@end
