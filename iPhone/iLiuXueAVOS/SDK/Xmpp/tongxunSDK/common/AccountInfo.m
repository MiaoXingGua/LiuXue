/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "AccountInfo.h"

@implementation AccountInfo
@synthesize subAccount;
@synthesize subToken;
@synthesize voipId;
@synthesize password;
@synthesize isChecked;

-(void)dealloc
{
    self.subAccount = nil;
    self.subToken = nil;
    self.voipId = nil;
    self.password = nil;
    [super dealloc];
}
@end
