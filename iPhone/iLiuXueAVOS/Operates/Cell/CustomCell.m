//
//  CustomCell.m
//  liuxue
//
//  Created by superhomeliu on 13-7-27.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell
@synthesize headImageView = _headImageView;
@synthesize userName = _userName;
@synthesize title = _title;
@synthesize content = _content;
@synthesize sendTime = _sendTime;
@synthesize city = _city;
@synthesize collect = _collect;
@synthesize homeCellLine = _homeCellLine;
@synthesize timeImage = _timeImage;
@synthesize friendImage = _friendImage;
@synthesize collectImage = _collectImage;
@synthesize friendNum = _friendNum;
@synthesize collectNum = _collectNum;
@synthesize headCoverImage = _headCoverImage;
@synthesize cellbackground = _cellbackground;
@synthesize stateLabel = _stateLabel;
@synthesize voiceBtn = _voiceBtn;

- (void)dealloc
{
    [_stateLabel release]; _stateLabel=nil;
    [_timeImage release]; _timeImage=nil;
    [_friendImage release]; _friendImage=nil;
    [_collectImage release]; _collectImage=nil;
    [_homeCellLine release]; _homeCellLine=nil;
    [_headImageView release]; _headImageView=nil;
    [_userName release]; _userName=nil;
    [_title release]; _title=nil;
    [_content release]; _content=nil;
    [_sendTime release]; _sendTime=nil;
    [_city release]; _city=nil;
    [_collect release]; _collect=nil;
    [_headCoverImage release]; _headCoverImage=nil;
    [_cellbackground release]; _cellbackground=nil;
    [_voiceBtn release]; _voiceBtn=nil;
    [_needText release]; _needText=nil;
    [_friendNum release]; _friendNum=nil;
    [_collectNum release]; _collectNum=nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.voiceBtn.frame = CGRectMake(70, 70, 100, 30);
        self.voiceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.voiceBtn setTitle:@"播 放" forState:UIControlStateNormal];
        [self.contentView addSubview:self.voiceBtn];
        self.voiceBtn.hidden = YES;
        
        
        self.stateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(215, 10, 70, 20)] autorelease];
        self.stateLabel.backgroundColor = [UIColor clearColor];
        self.stateLabel.font = [UIFont systemFontOfSize:12];
        self.stateLabel.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.stateLabel.numberOfLines = 0;
        [self.stateLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:self.stateLabel];
        
      
        self.headCoverImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfinduser.png.png"]] autorelease];
        self.headCoverImage.frame = CGRectMake(10, 10, 55, 55);
        self.headCoverImage.center = CGPointMake(35, 35);
        self.headCoverImage.hidden = YES;
        [self.contentView addSubview:self.headCoverImage];
        
        
        self.userName = [[[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 20)] autorelease];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.font = [UIFont systemFontOfSize:16];
        self.userName.textColor = [UIColor colorWithRed:1 green:0.21 blue:0 alpha:1];
        [self.userName setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.userName];
        
        
        
        self.content = [[[UILabel alloc] initWithFrame:CGRectMake(70, 70, 240, 20)] autorelease];
        self.content.backgroundColor = [UIColor clearColor];
        self.content.font = [UIFont systemFontOfSize:14];
        self.content.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.content.numberOfLines = 0;
        [self.content setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.content];
        
        self.sendTime = [[[UILabel alloc] initWithFrame:CGRectMake(70, 70, 100, 20)] autorelease];
        self.sendTime.backgroundColor = [UIColor clearColor];
        self.sendTime.font = [UIFont systemFontOfSize:11];
        self.sendTime.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.sendTime.numberOfLines = 0;
        [self.sendTime setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.sendTime];
        
        self.city = [[[UILabel alloc] initWithFrame:CGRectMake(150, 70, 100, 20)] autorelease];
        self.city.backgroundColor = [UIColor clearColor];
        self.city.font = [UIFont systemFontOfSize:11];
        self.city.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.city.numberOfLines = 0;
        [self.city setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.city];
        
        self.collect = [UIButton buttonWithType:UIButtonTypeCustom];
        self.collect.frame = CGRectMake(280, 0, 40, 40);
        self.collect.hidden = YES;
        [self.contentView addSubview:self.collect];
        
        self.needText = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)] autorelease];
        self.needText.backgroundColor = [UIColor clearColor];
        self.needText.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
        self.needText.font = [UIFont systemFontOfSize:14];
        self.needText.text = @"需要";
        self.needText.hidden = YES;
        [self.contentView addSubview:self.needText];
        
        self.homeCellLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0028_line@2x.png"]] autorelease];
        self.homeCellLine.frame = CGRectMake(0, 0, 320, 1);
        self.homeCellLine.hidden = YES;
        [self.contentView addSubview:self.homeCellLine];
        
        self.timeImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0017_time@2x.png"]] autorelease];
        self.timeImage.frame = CGRectMake(0, 0, 23/2, 22/2);
        self.timeImage.hidden = YES;
        [self.contentView addSubview:self.timeImage];
        
        self.friendImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"浏览数.png"]] autorelease];
        self.friendImage.frame = CGRectMake(0, 0, 31/2, 21/2);
        self.friendImage.hidden = YES;
        [self.contentView addSubview:self.friendImage];
        
        self.collectImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"评论数.png"]] autorelease];
        self.collectImage.frame = CGRectMake(0, 0, 24/2, 23/2);
        self.collectImage.hidden = YES;
        [self.contentView addSubview:self.collectImage];
        
        self.friendNum = [[[UILabel alloc] initWithFrame:CGRectMake(200, 70, 50, 20)] autorelease];
        self.friendNum.backgroundColor = [UIColor clearColor];
        self.friendNum.font = [UIFont systemFontOfSize:11];
        self.friendNum.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.friendNum.numberOfLines = 0;
        [self.friendNum setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.friendNum];
        
        self.collectNum = [[[UILabel alloc] initWithFrame:CGRectMake(200, 70, 50, 20)] autorelease];
        self.collectNum.backgroundColor = [UIColor clearColor];
        self.collectNum.font = [UIFont systemFontOfSize:11];
        self.collectNum.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.collectNum.numberOfLines = 0;
        [self.collectNum setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.collectNum];
        
        self.cellbackground = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 34)] autorelease];
        self.cellbackground.userInteractionEnabled = YES;
        [self.contentView addSubview:self.cellbackground];
        
        self.headImageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 49, 49) ImageState:0] autorelease];
        self.headImageView.exclusiveTouch = YES;
        self.headImageView.hidden = YES;
        self.headImageView.userInteractionEnabled = YES;
        self.headImageView.center = CGPointMake(35, 35);
        [self.contentView addSubview:self.headImageView];
        
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(70, 35, 240, 20)] autorelease];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
        [self.title setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.title];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
