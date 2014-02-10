//
//  MenuViewController.h
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "User.h"

@interface MenuViewController : SuperViewController <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    
    UILabel *Label_num;
   
   // int notReadPostCounts;
}

@property(nonatomic,assign)int notReadPostCounts;

@end
