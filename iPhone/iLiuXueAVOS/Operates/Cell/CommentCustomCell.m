//
//  CommentCustomCell.m
//  iLiuXue
//
//  Created by superhomeliu on 13-9-23.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "CommentCustomCell.h"
#import "QuartzCore/QuartzCore.h"

@implementation CommentCustomCell
@synthesize headCoverImage = _headCoverImage;
@synthesize headImageView = _headImageView;
@synthesize userName = _userName;
@synthesize content = _content;
@synthesize timeImage = _timeImage;
@synthesize timeLabel = _timeLabel;
@synthesize backView = _backView;
@synthesize deleteBtn = _deleteBtn;
@synthesize floorImage = _floorImage;
@synthesize floorLabel = _floorLabel;
@synthesize voiceBtn = _voiceBtn;

- (void)dealloc
{
    [_voiceBtn release]; _voiceBtn=nil;
    [_floorLabel release]; _floorLabel=nil;
    [_floorImage release]; _floorImage=nil;
    [_content release]; _content=nil;
    [_deleteBtn release]; _deleteBtn=nil;
    [_headImageView release]; _headImageView=nil;
    [_headCoverImage release]; _headCoverImage=nil;
    [_userName release]; _userName=nil;
    [_timeLabel release]; _timeLabel=nil;
    [_timeImage release]; _timeImage=nil;
    [_backView release]; _backView=nil;
    
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backView = [[[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 200)] autorelease];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.backView];
        
        self.headCoverImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfinduser.png"]] autorelease];
        self.headCoverImage.frame = CGRectMake(10, 10, 45, 45);
        self.headCoverImage.center = CGPointMake(40, 40);
        self.headCoverImage.hidden = YES;
        [self.contentView addSubview:self.headCoverImage];
        
        self.headImageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 39, 39) ImageState:0] autorelease];
        self.headImageView.defaultImage = 0;
        self.headImageView.backgroundColor = [UIColor clearColor];
        self.headImageView.hidden = YES;
        self.headImageView.userInteractionEnabled = YES;
        self.headImageView.center = CGPointMake(40, 40);
        [self.contentView addSubview:self.headImageView];
        
        self.userName = [[[UILabel alloc] initWithFrame:CGRectMake(70, 15, 240, 20)] autorelease];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.font = [UIFont systemFontOfSize:12];
        self.userName.textColor = [UIColor colorWithRed:1 green:0.21 blue:0 alpha:1];
        [self.userName setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.userName];
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(85, 36, 150, 20)] autorelease];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
        self.timeLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.timeLabel.numberOfLines = 0;
        [self.timeLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.timeLabel];
        
        self.timeImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0002_time@2x.png"]] autorelease];
        self.timeImage.frame = CGRectMake(70, 40, 23/2, 22/2);
        [self.contentView addSubview:self.timeImage];
        
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.frame = CGRectMake(0, 0, 50, 20);
        self.deleteBtn.hidden = YES;
        [self.contentView addSubview:self.deleteBtn];
        
        
        self.content = [[[UILabel alloc] initWithFrame:CGRectMake(70, 85, 240, 20)] autorelease];
        self.content.backgroundColor = [UIColor clearColor];
        self.content.font = [UIFont systemFontOfSize:14];
        self.content.numberOfLines=0;
        self.content.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
        [self.content setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.content];
        
        
        self.floorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)] autorelease];
        self.floorLabel.backgroundColor = [UIColor clearColor];
        self.floorLabel.center = CGPointMake(290, 30);
        self.floorLabel.font = [UIFont systemFontOfSize:10];
        self.floorLabel.textColor = [UIColor redColor];
        [self.floorLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.floorLabel];
        
        
        self.floorImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0003s_0006_1楼.png"]] autorelease];
        self.floorImage.frame = CGRectMake(0, 0, 58/2, 58/2);
        self.floorImage.center = CGPointMake(290, 30);
        [self.contentView addSubview:self.floorImage];
        
        
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.voiceBtn.frame = CGRectMake(0, 0, 100, 30);
        self.voiceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        self.voiceBtn.hidden = YES;
        [self.contentView addSubview:self.voiceBtn];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
