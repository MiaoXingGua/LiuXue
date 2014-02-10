//
//  ALUserConfig.h
//  AVOS_DEMO
//
//  Created by Albert on 13-9-9.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#ifndef AVOS_DEMO_ALUserConfig_h
#define AVOS_DEMO_ALUserConfig_h

#import "ALNotificationConfig.h"
#import "ALCreditConfig.h"
#import "ALParseConfig.h"

//请先登录
#define NOTIFICATION_PARSE_IS_NEED_LOGIN @"FBI72TG483TKUFK24RFGIL3RCDUD34FKU37GV4KYF873"
//
////你已经关注了这个好友
//#define NOTIFICATION_FRIEND_IS_EXSIT @"OUGFO87WELIFGU3892388OVF8ADKGUTQ39KAJBSQ872TE"
//
////你还没有关注这个好友
//#define NOTIFICATION_FRIEND_IS_NOT_EXSIT @"GFE478FRKUYW4RFGO78O83RFOE4RBGI4782WFBRO83WBV"

//or不存在这个用户




typedef NS_ENUM(NSInteger, ALRelationRequestType)
{
    ALRelationTypeOfNone = 0,
    ALRelationTypeOfFriend,
    ALRelationTypeOfBan,
};


#endif