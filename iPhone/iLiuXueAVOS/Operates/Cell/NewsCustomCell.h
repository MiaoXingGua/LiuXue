//
//  NewsCustomCell.h
//  ILiuXue
//
//  Created by superhomeliu on 13-10-21.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "VerticallyAlignedLabel.h"

@interface NewsCustomCell : UITableViewCell
{
    UILabel *_userName;
    UILabel *_title;
    VerticallyAlignedLabel *_content;
    UILabel *_sendTime;
    UILabel *_click;
    UILabel *_comments;
    
    UIImageView *_homeCellLine;
    UIImageView *_timeImage;
    UIImageView *_clickImage;
    UIImageView *_commentsImage;
    
    UIButton *_collect;
    
    UIView *_cellbackground;
    
    AsyncImageView *_asyImage;
    
    AsyncImageView *_groupImage;
    
    UIButton *_editGroup,*_groupMember,*_closeGroup;
}

@property(nonatomic,retain)UIButton *editGroup,*groupMember,*closeGroup;
@property(nonatomic,retain)AsyncImageView *groupImage;
@property(nonatomic,retain)AsyncImageView *asyImage;
@property(nonatomic,retain)UIView *cellbackground;
@property(nonatomic,retain)UILabel *userName;
@property(nonatomic,retain)UILabel *title;
@property(nonatomic,retain)VerticallyAlignedLabel *content;
@property(nonatomic,retain)UILabel *sendTime;
@property(nonatomic,retain)UILabel *click;
@property(nonatomic,retain)UILabel *comments;
@property(nonatomic,retain)UIImageView *homeCellLine;
@property(nonatomic,retain)UIImageView *timeImage;
@property(nonatomic,retain)UIImageView *clickImage;
@property(nonatomic,retain)UIImageView *commentsImage;
@property(nonatomic,retain)UIButton *collect;

@end
