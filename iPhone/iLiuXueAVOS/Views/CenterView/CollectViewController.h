//
//  CollectViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-9-24.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALThreadEngine.h"
#import "SuperViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "CommentCustomCell.h"
#import "InfoViewController.h"

@interface CollectViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *_datalist;
    NSMutableArray *_threadArry;
    
    UITableView *_tableView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL isrequest;
    BOOL isPulldown;
    BOOL isEdit;
    
    UIButton *editBtn;
    
    __block UIActivityIndicatorView *_activityView;
    __block UIButton *loadCommentsBtn;
    UIView *footView;
}


@property(nonatomic,retain)NSMutableArray *threadArry;
@property(nonatomic,retain)NSMutableArray *datalist;

@end
