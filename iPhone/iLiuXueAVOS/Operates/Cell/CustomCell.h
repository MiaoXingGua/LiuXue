//
//  CustomCell.h
//  liuxue
//
//  Created by superhomeliu on 13-7-27.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHAvatarView.h"
#import "AsyncImageView.h"

@interface CustomCell : UITableViewCell
{
    AsyncImageView *_headImageView;
    UILabel *_userName;
    UILabel *_title;
    UILabel *_content;
    UILabel *_sendTime;
    UILabel *_city;
    UIButton *_collect;
    UILabel *_needText;
    UIImageView *_homeCellLine;
    UIImageView *_timeImage;
    UIImageView *_friendImage;
    UIImageView *_collectImage;
    UILabel *_friendNum;
    UILabel *_collectNum;
    UIImageView *_headCoverImage;
    UIImageView *_cellbackground;

    UILabel *_stateLabel;
    
    UIButton *_voiceBtn;

}
@property(nonatomic,retain)UIButton *voiceBtn;

@property(nonatomic,retain)UILabel *stateLabel;
@property(nonatomic,retain)AsyncImageView *headImageView;
@property(nonatomic,retain)UILabel *userName;
@property(nonatomic,retain)UILabel *title;
@property(nonatomic,retain)UILabel *content;
@property(nonatomic,retain)UILabel *sendTime;
@property(nonatomic,retain)UILabel *city;
@property(nonatomic,retain)UIButton *collect;
@property(nonatomic,retain)UILabel *needText;
@property(nonatomic,retain)UIImageView *homeCellLine;
@property(nonatomic,retain)UIImageView *timeImage;
@property(nonatomic,retain)UIImageView *friendImage;
@property(nonatomic,retain)UIImageView *collectImage;
@property(nonatomic,retain)UILabel *friendNum;
@property(nonatomic,retain)UILabel *collectNum;
@property(nonatomic,retain)UIImageView *headCoverImage;
@property(nonatomic,retain)UIImageView *cellbackground;

@end
