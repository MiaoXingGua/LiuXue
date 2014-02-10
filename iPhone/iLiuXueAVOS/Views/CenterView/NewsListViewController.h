//
//  NewsListViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-20.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALUserEngine.h"
#import "ALThreadEngine.h"
#import "SuperViewController.h"
#import "Forum.h"
#import "EGORefreshTableHeaderView.h"

@interface NewsListViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *_collectNumArray;
    NSMutableArray *_datalist;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    Forum *_forum;
    
    UITableView *_tableView;
    
    __block UIActivityIndicatorView *_activityView;
    __block UIButton *loadCommentsBtn;
    UIView *footView;

}

@property(nonatomic,assign)BOOL isRequest;
@property(nonatomic,assign)BOOL isShowMore;

@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)Forum *forum;
@property(nonatomic,retain)NSMutableArray *collectNumArray;

@end
