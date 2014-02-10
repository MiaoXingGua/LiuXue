//
//  UnReadMessageListViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-27.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface UnReadMessageListViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView *_tableView;
    
    NSMutableArray *_userlist;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    
    
    
    NSDictionary *_faceMap;
}

@property(nonatomic,assign)BOOL isRefresh;
@property(nonatomic,assign)BOOL isEditing;

@property(nonatomic,retain)NSMutableArray *userlist;

@end
