//
//  MenuCustomCell.m
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import "MenuCustomCell.h"

@implementation MenuCustomCell
@synthesize headCoverImage = _headCoverImage;
@synthesize headView = _headView;
@synthesize userName = _userName;
@synthesize titleImage = _titleImage;
@synthesize title = _title;
@synthesize titleEnglish = _titleEnglish;
@synthesize menuCellLine = _menuCellLine;
@synthesize mainText = _mainText;

- (void)dealloc
{
    [_menuCellLine release];
    [_headCoverImage release];
    [_headView release];
    [_userName release];
    [_title release];
    [_titleEnglish release];
    [_titleImage release];
    [_mainText release];
    [super dealloc];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.headView = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 71, 71) ImageState:0] autorelease];
        self.headView.backgroundColor = [UIColor clearColor];
        self.headView.hidden = YES;
        self.headView.defaultImage = 0;
        self.headView.center = CGPointMake(128, 80);
        [self.contentView addSubview:self.headView];
        
        
        self.headCoverImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0016_主页头像@2x.png"]] autorelease];
        self.headCoverImage.frame = CGRectMake(0, 0, 78, 78);
        self.headCoverImage.center = CGPointMake(128, 80);
        self.headCoverImage.hidden = YES;
        [self.contentView addSubview:self.headCoverImage];
        
        
        
        self.userName = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 256, 30)] autorelease];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.font = [UIFont systemFontOfSize:18];
        self.userName.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        self.userName.center = CGPointMake(128-25, 140);
        [self.userName setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.userName];
        
        self.mainText = [[[UILabel alloc] init] autorelease];
        self.mainText.text = @"的主页";
        [self.mainText setTextAlignment:NSTextAlignmentLeft];
        self.mainText.backgroundColor = [UIColor clearColor];
        self.mainText.font = [UIFont systemFontOfSize:15];
        self.mainText.textColor = [UIColor colorWithRed:0.58 green:0.58 blue:0.58 alpha:1];
        [self.contentView addSubview:self.mainText];
        
        self.titleImage = [[[UIImageView alloc] init] autorelease];
        self.titleImage.frame = CGRectMake(10, 20, 78, 78);
        [self.contentView addSubview:self.titleImage];
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 30)] autorelease];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = [UIColor whiteColor];
        [self.title setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.title];
        
        self.titleEnglish = [[[UILabel alloc] initWithFrame:CGRectMake(62, 25, 200, 20)] autorelease];
        self.titleEnglish.backgroundColor = [UIColor clearColor];
        self.titleEnglish.font = [UIFont systemFontOfSize:11];
        self.titleEnglish.textColor = [UIColor colorWithRed:0.58 green:0.58 blue:0.58 alpha:1];
        [self.titleEnglish setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.titleEnglish];
        
        
        self.menuCellLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_0004_line-right@2x.png"]] autorelease];
        self.menuCellLine.frame = CGRectMake(0, 0, 320, 1);
        [self.contentView addSubview:self.menuCellLine];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
