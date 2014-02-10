//
//  CommentCustomCell.h
//  iLiuXue
//
//  Created by superhomeliu on 13-9-23.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
//#import "STTweetLabel.h"

@interface CommentCustomCell : UITableViewCell //<STLinkProtocol>
{
    AsyncImageView *_headImageView;
    UILabel *_userName;
    UILabel *_content;
    UILabel *_timeLabel;
    
    UIImageView *_headCoverImage;
    UIImageView *_timeImage;

    UIView *_backView;
    
    UIButton *_deleteBtn;

    UILabel *_floorLabel;
    UIImageView *_floorImage;
    
    UIButton *_voiceBtn;

}

@property(nonatomic,retain)UIButton *voiceBtn;
@property(nonatomic,retain)UIImageView *floorImage;
@property(nonatomic,retain)UILabel *floorLabel;
@property(nonatomic,retain)UIButton *deleteBtn;
@property(nonatomic,retain)UIView *backView;
@property(nonatomic,retain)UILabel *userName;
@property(nonatomic,retain)UILabel *timeLabel;
@property(nonatomic,retain)UILabel *content;
@property(nonatomic,retain)AsyncImageView *headImageView;
@property(nonatomic,retain)UIImageView *headCoverImage;
@property(nonatomic,retain)UIImageView *timeImage;

@end
