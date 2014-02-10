//
//  HomeViewController.h
//  liuxue
//
//  Created by superhomeliu on 13-7-27.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGOLoadTableFooterView.h"
#import "CHAvatarView.h"
#import "SuperViewController.h"
#import "ThreadFlag.h"

@interface HomeViewController : SuperViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
{
    
    UITableView *_tableView;
    UITableView *_searchTableView,*_classTableView;
    NSMutableArray *_datalist,*_searchDatalist,*_adDataList;
    UITextField *seacchTextfield;
    UIButton *cancelbtn;
    UIView *naviView;
    UILabel *classLabel;
    BOOL isSearch,isShowClass;
    UIImageView *textfieldImage2,*textfieldImage3,*textfieldImage1;
    UIScrollView *_scrollView;
    UIPageControl *_control;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UIImageView *arrowsImage;
    UIImageView *classImageView;
    __block UIView *headView;
    int _typeNum;
    BOOL isType;
    
    NSString *_userId;
    BOOL isShowChatView;
    
    NSMutableArray *_huodeUserInfo;
    NSMutableArray *_threadArray;

    __block NSMutableArray *_forumArray;
    __block NSMutableArray *_collectNumArray;
    
    ThreadFlag *_selectFlag;
    BOOL changeFlag;
    
    UIActivityIndicatorView *_activityView;
    UIButton *showMoreBtn;
    
    UIView *changeSearchView;
    
    UIButton *distanceBtn;
    UIButton *rewardBtn;
    
    BOOL searchDistance;

}

@property(nonatomic,assign)BOOL isSearching;
@property(nonatomic,assign)BOOL isRequest;
@property(nonatomic,assign)BOOL isShowMore;
@property(nonatomic,assign)BOOL isPulldown;
@property(nonatomic,assign)BOOL isCollect;

@property(nonatomic,retain)ThreadFlag *selectFlag;
@property(nonatomic,retain)NSMutableArray *collectNumArray;
@property(nonatomic,retain)NSMutableArray *threadArray;
@property(nonatomic,retain)NSMutableArray *forumArray;
@property(nonatomic,retain)NSMutableArray *huodeUserInfo;
@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSMutableArray *datalist;
@property(nonatomic,retain)NSMutableArray *searchDatalist;
@property(nonatomic,retain)NSMutableArray *adDataList;
@end
