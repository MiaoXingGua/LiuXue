//
//  GroupMembersViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-21.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALXMPPEngine.h"
#import "ALUserEngine.h"
#import "SuperViewController.h"
#import "ViewData.h"
#import "CustomCell.h"
#import "EGORefreshTableHeaderView.h"

@interface GroupMembersViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    NSString *_gId;
    
    UITableView *_tableView;
    
    NSMutableArray *_datalist;
    NSMutableArray *_friendList;
    
    
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    int _row;
}

@property(nonatomic,assign)BOOL isRequest;


@property(nonatomic,retain)NSMutableArray *friendList;
@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)NSString *gId;

- (id)initWithGroupID:(NSString *)gId;

@end
