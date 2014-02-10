//
//  MenuCustomCell.h
//  liuxue
//
//  Created by superhomeliu on 13-8-4.
//  Copyright (c) 2013年 liujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHAvatarView.h"
#import "AsyncImageView.h"

@interface MenuCustomCell : UITableViewCell
{
    UIImageView *_headCoverImage;
    AsyncImageView *_headView;
    UILabel *_userName;
    UILabel *_title;
    UILabel *_titleEnglish;
    UIImageView *_titleImage;
    UIImageView *_menuCellLine;
    UILabel *_mainText;
}
@property(nonatomic,retain)UIImageView *headCoverImage;
@property(nonatomic,retain)UIImageView *titleImage;
@property(nonatomic,retain)UIImageView *menuCellLine;
@property(nonatomic,retain)UILabel *userName;
@property(nonatomic,retain)UILabel *title;
@property(nonatomic,retain)UILabel *titleEnglish;
@property(nonatomic,retain)AsyncImageView *headView;
@property(nonatomic,retain)UILabel *mainText;
@end
