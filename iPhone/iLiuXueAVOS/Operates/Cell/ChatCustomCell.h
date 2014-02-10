//
//  ChatCustomCell.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-15.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ChatCustomCell : UITableViewCell
{
//    UILabel *_messageNumLable;
//    AsyncImageView *_linkManImageView;
    UILabel *_linkManNameLabel;
//    UILabel *_lastMessageLabel;
//    UILabel *_lastMessageTime;
    UIView *_popview;
}

@property(nonatomic,retain)UILabel *linkManNameLabel;

//@property(nonatomic,retain)UILabel *messageNumLable,,*lastMessageLabel;
//@property(nonatomic,retain)UILabel *lastMessageTime;
//@property(nonatomic,retain)AsyncImageView *linkManImageView;
@property(nonatomic,retain)UIView *popview;
@end
