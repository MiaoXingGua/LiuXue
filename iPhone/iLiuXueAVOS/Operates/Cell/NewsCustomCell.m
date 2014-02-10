//
//  NewsCustomCell.m
//  ILiuXue
//
//  Created by superhomeliu on 13-10-21.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "NewsCustomCell.h"

@implementation NewsCustomCell
@synthesize userName = _userName;
@synthesize title = _title;
@synthesize content = _content;
@synthesize sendTime = _sendTime;
@synthesize click = _click;
@synthesize comments = _comments;
@synthesize homeCellLine = _homeCellLine;
@synthesize clickImage = _clickImage;
@synthesize commentsImage = _commentsImage;
@synthesize collect = _collect;
@synthesize timeImage = _timeImage;
@synthesize cellbackground = _cellbackground;
@synthesize asyImage = _asyImage;
@synthesize groupImage = _groupImage;
@synthesize editGroup = _editGroup;
@synthesize groupMember = _groupMember;
@synthesize closeGroup = _closeGroup;

- (void)dealloc
{
    [_editGroup release];
    [_groupMember release];
    [_closeGroup release];
    [_groupImage release];
    [_asyImage release];
    [_cellbackground release];
    [_userName release];
    [_title release];
    [_content release];
    [_sendTime release];
    [_click release];
    [_comments release];
    [_homeCellLine release];
    [_clickImage release];
    [_commentsImage release];
    [_collect release];
    [_timeImage release];
    
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.cellbackground = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 310, 250)] autorelease];
        self.cellbackground.userInteractionEnabled = YES;
        self.cellbackground.layer.cornerRadius = 5;
        self.cellbackground.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.cellbackground];
        
        
        self.groupImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50) ImageState:1] autorelease];
        self.groupImage.hidden=YES;
        self.groupImage.layer.borderWidth = 1;
        self.groupImage.layer.borderColor = [UIColor grayColor].CGColor;
        self.groupImage.defaultImage = 0;
        [self.contentView addSubview:self.groupImage];
        
        self.editGroup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.editGroup.frame = CGRectMake(0, 0, 80, 40);
        self.editGroup.hidden = YES;
        [self.contentView addSubview:self.editGroup];
        
        self.groupMember = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.groupMember.frame = CGRectMake(0, 0, 80, 40);
        self.groupMember.hidden = YES;
        [self.contentView addSubview:self.groupMember];
        
        self.closeGroup = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.closeGroup.frame = CGRectMake(0, 0, 80, 40);
        self.closeGroup.hidden = YES;
        [self.contentView addSubview:self.closeGroup];
        
        self.asyImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 155) ImageState:1] autorelease];
        self.asyImage.autoImage = YES;
        [self.contentView addSubview:self.asyImage];

        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(20, 172, 240, 20)] autorelease];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:1];
        [self.title setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.title];
        
        self.content = [[[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(20, 195, 280, 40)] autorelease];
        self.content.backgroundColor = [UIColor clearColor];
        self.content.verticalAlignment = VerticalAlignmentTop;
        self.content.font = [UIFont systemFontOfSize:12];
        self.content.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.content.numberOfLines = 0;
        [self.content setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.content];
        
        self.userName = [[[UILabel alloc] initWithFrame:CGRectMake(20, 234, 50, 20)] autorelease];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.font = [UIFont systemFontOfSize:11];
        self.userName.textColor = [UIColor colorWithRed:1 green:0.21 blue:0 alpha:1];
        [self.userName setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.userName];
        
        self.sendTime = [[[UILabel alloc] initWithFrame:CGRectMake(88, 235, 100, 20)] autorelease];
        self.sendTime.backgroundColor = [UIColor clearColor];
        self.sendTime.font = [UIFont systemFontOfSize:11];
        self.sendTime.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.sendTime.numberOfLines = 0;
        [self.sendTime setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.sendTime];

        self.collect = [UIButton buttonWithType:UIButtonTypeCustom];
        self.collect.frame = CGRectMake(270, 159, 40, 40);
        [self.contentView addSubview:self.collect];
        
        
        self.homeCellLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0028_line@2x.png"]] autorelease];
        self.homeCellLine.frame = CGRectMake(20, 232, 280, 1);
        [self.contentView addSubview:self.homeCellLine];
        
        self.timeImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0017_time@2x.png"]] autorelease];
        self.timeImage.frame = CGRectMake(75, 239, 23/2, 22/2);
        [self.contentView addSubview:self.timeImage];
        
        self.clickImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"浏览数.png"]] autorelease];
        self.clickImage.frame = CGRectMake(210, 239, 31/2, 21/2);
        [self.contentView addSubview:self.clickImage];
        
        self.commentsImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"评论数.png"]] autorelease];
        self.commentsImage.frame = CGRectMake(260, 240, 24/2, 23/2);
        [self.contentView addSubview:self.commentsImage];
        
        self.click = [[[UILabel alloc] initWithFrame:CGRectMake(227, 235, 50, 20)] autorelease];
        self.click.backgroundColor = [UIColor clearColor];
        self.click.font = [UIFont systemFontOfSize:11];
        self.click.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.click.numberOfLines = 0;
        [self.click setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.click];
        
        self.comments = [[[UILabel alloc] initWithFrame:CGRectMake(275, 235, 50, 20)] autorelease];
        self.comments.backgroundColor = [UIColor clearColor];
        self.comments.font = [UIFont systemFontOfSize:11];
        self.comments.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        self.comments.numberOfLines = 0;
        [self.comments setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.comments];
        
     
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
