//
//  PersonalDataViewController.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "SuperViewController.h"
#import "User.h"
#import "EGORefreshTableHeaderView.h"
#import "ShowImageViewController.h"
#import "Photo.h"
#import "MWPhotoBrowser.h"

@interface PersonalDataViewController : SuperViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate>
{
    User *_user;
    UITableView *_tableView;
    NSMutableDictionary *_datalist;
    AsyncImageView *headImageAsy;
    UILabel *username;
    UIImageView *sexImage;
    UILabel *locationLabel;
    UILabel *ageLabel;
    UILabel *starLabel;
    UILabel *marryLabel;
    UILabel *disdanceLabel;
    
    UIButton *attentioBtn,*cancelAttentioBtn;
    
    BOOL _from;
    BOOL _fromcenter;
    BOOL _edit;
    BOOL _showUserImageView;
    BOOL _editphotoalbum;
    
    NSString *_userName;
    UIImageView *touxiang;
    UIView *_userImageView;
    UIView *backgroundView;
    UIView *headView;
    
    UIButton *updateData;
    UIButton *addImageBtn;
    
    ShowImageViewController *showImageView;
    
    __block EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL isShowMore;
    BOOL isDownLoadUserImage;
    
    int deleteImageTag;
    
    NSString *_interest;
    NSString *_gradute;
    NSString *_study;
    NSString *_signature;
    UIView *naviView;
    UIImageView *tabelViewHeadView;
    UIImage *_userImg;
    
    UIActivityIndicatorView *_activityView;
    
    NSMutableArray *_userImageArray;
    NSMutableArray *_userPhotosArray;
    NSMutableArray *_userPointArray;
    
    NSArray *_photos;

}

@property(nonatomic,assign)BOOL isRequest;
@property(nonatomic,assign)BOOL isAttention;
@property(nonatomic,assign)BOOL completeDownLoadImage;
@property(nonatomic,assign)BOOL isBeginChat;

@property(nonatomic,retain)NSArray *photos;
@property(nonatomic,retain)NSMutableArray *userPointArray;
@property(nonatomic,retain)NSMutableArray *userPhotosArray;
@property(nonatomic,retain)NSMutableArray *userImageArray;
@property(nonatomic,retain)UIImage *userImg;
@property(nonatomic,retain)NSString *signature;
@property(nonatomic,retain)NSString *study;
@property(nonatomic,retain)NSString *gradute;
@property(nonatomic,retain)NSString *interest;
@property(nonatomic,retain)User *user;;
@property(nonatomic,retain)NSMutableDictionary *datalist;
@property(nonatomic,retain)NSString *userName;

- (id)initWithUser:(User *)user FromSelf:(BOOL)from SelectFromCenter:(BOOL)fromcenter;

- (id)initWithUserName:(NSString *)userName FromSelf:(BOOL)from SelectFromCenter:(BOOL)fromcenter;
@end

