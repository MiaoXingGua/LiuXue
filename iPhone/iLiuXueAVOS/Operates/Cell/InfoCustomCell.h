//
//  InfoCustomCell.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-23.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface InfoCustomCell : UITableViewCell
{
    AsyncImageView *_headImageView;
    UILabel *_userName;
    UILabel *_content;
    UILabel *_timeLabel;
    UILabel *_cityLabel;
    UILabel *_levelLabel;
    UILabel *_floorLabel;
    UILabel *_ownerLabel;
    
    UIImageView *_headCoverImage;
    UIImageView *_timeImage;
    UIImageView *_cityImage;
    UIImageView *_levelImage;
    UIImageView *_sexImage;
    UIImageView *_floorImage;
    UIImageView *_lineImage;
    UIButton *_commontBtn,*_goodBtn;
    UIImageView *_cellLineImage;
    
    UIView *_postBackGround;
    UIImageView *_postCellLine;
    
    UIButton *_voiceBtn;
    
    UILabel *_commentLabel;
    UILabel *_dingLabel;
    
    UIButton *_deleteBtn;
    
    UILabel *_stateLabel;

    UIView *_backView;

}

@property(nonatomic,retain)UILabel *ownerLabel;
@property(nonatomic,retain)UIView *backView;
@property(nonatomic,retain)UILabel *stateLabel;
@property(nonatomic,retain)UIButton *deleteBtn;
@property(nonatomic,retain)UILabel *dingLabel;
@property(nonatomic,retain)UILabel *commentLabel;
@property(nonatomic,retain)UILabel *userName,*content,*levelLabel,*floorLabel,*timeLabel,*cityLabel;
@property(nonatomic,retain)AsyncImageView *headImageView;
@property(nonatomic,retain)UIImageView *headCoverImage;
@property(nonatomic,retain)UIImageView *timeImage,*cityImage,*levelImage,*sexImage,*floorImage;
@property(nonatomic,retain)UIImageView *lineImage;
@property(nonatomic,retain)UIButton *commontBtn,*goodBtn;
@property(nonatomic,retain)UIImageView *cellLineImage;
@property(nonatomic,retain)UIView *postBackGround;
@property(nonatomic,retain)UIImageView *postCellLine;
@property(nonatomic,retain)UIButton *voiceBtn;
@end
