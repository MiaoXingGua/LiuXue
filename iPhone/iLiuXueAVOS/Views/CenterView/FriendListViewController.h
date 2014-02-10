//
//  FriendListViewController.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-19.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@protocol didSelectAtUserDelegate;

@interface FriendListViewController : SuperViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_friendArray;
    NSMutableArray *_datalist;
    
    UITableView *_tableView;
}

@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)NSMutableArray *friendArray;
@property(nonatomic,assign)id<didSelectAtUserDelegate>atDelegate;

- (id)initWithSelectUser:(NSMutableArray *)friendList;

@end

@protocol didSelectAtUserDelegate <NSObject>

- (void)didSelectAtUser:(NSMutableArray *)userArray;

@end