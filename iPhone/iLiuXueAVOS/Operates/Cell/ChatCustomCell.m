//
//  ChatCustomCell.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ChatCustomCell.h"

@implementation ChatCustomCell

- (void)dealloc
{
//    [_linkManImageView release];
    [_linkManNameLabel release]; _linkManNameLabel=nil;
//    [_messageNumLable release];
//    [_lastMessageLabel release];
//    [_lastMessageTime release];
    [_popview release]; _popview=nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        self.linkManImageView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)] autorelease];
//        [self.contentView addSubview:self.linkManImageView];
//        
//        self.messageNumLable = [[[UILabel alloc] initWithFrame:CGRectMake(43, 3, 20, 10)] autorelease];
//        self.messageNumLable.backgroundColor = [UIColor clearColor];
//        self.messageNumLable.font = [UIFont systemFontOfSize:14];
//        self.messageNumLable.textColor = [UIColor grayColor];
//        [self.messageNumLable setTextAlignment:NSTextAlignmentRight];
//        self.messageNumLable.font = [UIFont boldSystemFontOfSize:14];
//        [self.contentView addSubview:self.messageNumLable];
        
        
        self.linkManNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 25)] autorelease];
        self.linkManNameLabel.backgroundColor = [UIColor blackColor];
        self.linkManNameLabel.alpha = 0.1;
        self.linkManNameLabel.layer.cornerRadius = 6;
        self.linkManNameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.linkManNameLabel];
        self.linkManNameLabel.hidden=YES;
        
//        self.lastMessageTime = [[[UILabel alloc] initWithFrame:CGRectMake(200, 8, 100, 20)] autorelease];
//        self.lastMessageTime.backgroundColor = [UIColor clearColor];
//        [self.lastMessageTime setTextAlignment:NSTextAlignmentRight];
//        self.lastMessageTime.textColor = [UIColor grayColor];
//        self.lastMessageTime.font = [UIFont systemFontOfSize:10];
//        [self.contentView addSubview:self.lastMessageTime];
//        
//        self.lastMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70, 35, 230, 20)] autorelease];
//        self.lastMessageLabel.backgroundColor = [UIColor clearColor];
//        self.lastMessageLabel.font = [UIFont systemFontOfSize:14];
//        self.lastMessageLabel.textColor = [UIColor grayColor];
//        [self.lastMessageLabel setTextAlignment:NSTextAlignmentLeft];
//        [self.contentView addSubview:self.lastMessageLabel];
        
        self.popview = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
        // self.popview.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.popview];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
