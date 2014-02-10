//
//  InfoCustomCell.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-23.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "InfoCustomCell.h"

@implementation InfoCustomCell
@synthesize userName = _userName,levelLabel = _levelLabel,floorLabel = _floorLabel,timeLabel = _timeLabel,cityLabel = _cityLabel,content = _content;
@synthesize headImageView = _headImageView;
@synthesize headCoverImage = _headCoverImage;
@synthesize cityImage = _cityImage;
@synthesize timeImage = _timeImage;
@synthesize levelImage = _levelImage;
@synthesize sexImage = _sexImage;
@synthesize floorImage = _floorImage;
@synthesize lineImage = _lineImage;
@synthesize commontBtn = _commontBtn;
@synthesize goodBtn = _goodBtn;
@synthesize cellLineImage = _cellLineImage;
@synthesize postBackGround = _postBackGround;
@synthesize postCellLine = _postCellLine;
@synthesize voiceBtn = _voiceBen;
@synthesize commentLabel = _commentLabel;
@synthesize dingLabel = _dingLabel;
@synthesize deleteBtn = _deleteBtn;
@synthesize stateLabel = _stateLabel;
@synthesize backView = _backView;
@synthesize ownerLabel = _ownerLabel;

- (void)dealloc
{
    [_ownerLabel release];
    [_backView release];
    [_stateLabel release];
    [_deleteBtn release];
    [_commentLabel release];
    [_dingLabel release];
    [_voiceBen release];
    [_postCellLine release];
    [_postBackGround release];
    [_cellLineImage release];
    [_commontBtn release];
    [_goodBtn release];
    [_lineImage release];
    [_timeImage release];
    [_levelImage release];
    [_sexImage release];
    [_floorImage release];
    [_headCoverImage release];
    [_userName release];
    [_levelLabel release];
    [_floorLabel release];
    [_timeLabel release];
    [_cityLabel release];
    [_content release];
    [_headImageView release];
    
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backView = [[[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 200)] autorelease];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.backView];
        
        self.postBackGround = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 20)] autorelease];
        self.postBackGround.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [self.contentView addSubview:self.postBackGround];
        self.postBackGround.hidden = YES;
        
        self.postCellLine = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 1)] autorelease];
        self.postCellLine.image = [UIImage imageNamed:@"_0003s_0005_……………………………………………#0.png"];
        [self.contentView addSubview:self.postCellLine];
        self.postCellLine.hidden = YES;
        
        self.ownerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 18)] autorelease];
        self.ownerLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        self.ownerLabel.layer.cornerRadius = 5;
        self.ownerLabel.textColor = [UIColor whiteColor];
        [self.ownerLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.ownerLabel];
        self.ownerLabel.hidden = YES;
        
        self.headImageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 49, 49) ImageState:0] autorelease];
        self.headImageView.defaultImage = 0;
        self.headImageView.backgroundColor = [UIColor clearColor];
        self.headImageView.hidden = YES;
        self.headImageView.userInteractionEnabled = YES;
        self.headImageView.center = CGPointMake(45, 45);
        [self.contentView addSubview:self.headImageView];
        
        self.headCoverImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfinduser.png"]] autorelease];
        self.headCoverImage.frame = CGRectMake(10, 10, 55, 55);
        self.headCoverImage.center = CGPointMake(45, 45);
        self.headCoverImage.hidden = YES;
        [self.contentView addSubview:self.headCoverImage];
        
      
        
        self.userName = [[[UILabel alloc] initWithFrame:CGRectMake(80, 20, 220, 20)] autorelease];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.font = [UIFont systemFontOfSize:16];
        self.userName.textColor = [UIColor colorWithRed:1 green:0.21 blue:0 alpha:1];
        [self.userName setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.userName];
    
        self.levelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80, 20, 220, 20)] autorelease];
        self.levelLabel.backgroundColor = [UIColor clearColor];
        self.levelLabel.font = [UIFont systemFontOfSize:16];
        self.levelLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.levelLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.levelLabel];
        
        self.sexImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0000_♀-.png"]] autorelease];
        self.sexImage.frame = CGRectMake(0, 0, 17/2, 29/2);
        [self.contentView addSubview:self.sexImage];
        self.sexImage.hidden = YES;
        
        self.content = [[[UILabel alloc] initWithFrame:CGRectMake(70, 70, 220, 20)] autorelease];
        self.content.backgroundColor = [UIColor clearColor];
        self.content.font = [UIFont systemFontOfSize:14];
        self.content.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.content.numberOfLines = 0;
        [self.content setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.content];
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70, 70, 100, 20)] autorelease];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:11];
        self.timeLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.timeLabel.numberOfLines = 0;
        [self.timeLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.timeLabel];
        
        self.cityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150, 70, 100, 20)] autorelease];
        self.cityLabel.backgroundColor = [UIColor clearColor];
        self.cityLabel.font = [UIFont systemFontOfSize:11];
        self.cityLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.cityLabel.numberOfLines = 0;
        [self.cityLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.cityLabel];
        
        self.floorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)] autorelease];
        self.floorLabel.backgroundColor = [UIColor clearColor];
        self.floorLabel.center = CGPointMake(290, 30);
        self.floorLabel.font = [UIFont systemFontOfSize:10];
        self.floorLabel.textColor = [UIColor redColor];
        [self.floorLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.floorLabel];
        

        self.timeImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0002_time@2x.png"]] autorelease];
        self.timeImage.frame = CGRectMake(0, 0, 23/2, 22/2);
       // self.timeImage.hidden = YES;
        [self.contentView addSubview:self.timeImage];
        
        self.cityImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004s_0003_location.png"]] autorelease];
        self.cityImage.frame = CGRectMake(0, 0, 19/2, 22/2);
        // self.timeImage.hidden = YES;
        [self.contentView addSubview:self.cityImage];
        
        self.floorImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0003s_0006_1楼.png"]] autorelease];
        self.floorImage.frame = CGRectMake(0, 0, 58/2, 58/2);
        self.floorImage.center = CGPointMake(290, 30);
         self.floorImage.hidden = YES;
        [self.contentView addSubview:self.floorImage];
        
        self.commontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.commontBtn setImage:[UIImage imageNamed:@"_0003s_0000s_0000_comments.png"] forState:UIControlStateNormal];
        self.commontBtn.frame = CGRectMake(0, 0, 61/2, 61/2);
        [self.contentView addSubview:self.commontBtn];
        self.commontBtn.hidden = YES;
        
        self.goodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.goodBtn setImage:[UIImage imageNamed:@"_0003s_0001_赞.png"] forState:UIControlStateNormal];
        self.goodBtn.frame = CGRectMake(0, 0, 61/2, 61/2);
        [self.contentView addSubview:self.goodBtn];
        self.goodBtn.hidden = YES;
        
        self.lineImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0002s_0001__.png"]] autorelease];
        self.lineImage.frame = CGRectMake(35, 65, 1, 10);
        [self.contentView addSubview:self.lineImage];
        self.lineImage.hidden = YES;
        
        self.cellLineImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0002s_0000__cellline.png"]] autorelease];
        self.cellLineImage.frame = CGRectMake(0, 0, 320-35, 1);
        [self.contentView addSubview:self.cellLineImage];
        self.cellLineImage.alpha = 0.6;
        self.cellLineImage.hidden = YES;
        
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.voiceBtn.frame = CGRectMake(80, 80, 100, 30);
        [self.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        self.voiceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.voiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.voiceBtn];
        self.voiceBtn.hidden = YES;
        
        self.commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)] autorelease];
        self.commentLabel.backgroundColor = [UIColor clearColor];
        self.commentLabel.font = [UIFont systemFontOfSize:12];
        self.commentLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.commentLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.commentLabel];
        
        self.dingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)] autorelease];
        self.dingLabel.backgroundColor = [UIColor clearColor];
        self.dingLabel.font = [UIFont systemFontOfSize:12];
        self.dingLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.dingLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.dingLabel];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.frame = CGRectMake(0, 0, 70, 30);
        self.deleteBtn.hidden = YES;
        [self.contentView addSubview:self.deleteBtn];
        
        self.stateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200, 20, 70, 20)] autorelease];
        self.stateLabel.backgroundColor = [UIColor clearColor];
        self.stateLabel.font = [UIFont systemFontOfSize:12];
        self.stateLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.stateLabel.numberOfLines = 0;
        [self.stateLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:self.stateLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
