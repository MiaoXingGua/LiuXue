//
//  XMPPHelper.m
//  Cloopen_DEMO
//
//  Created by Albert on 13-10-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "ALXMPPHelper.h"

@implementation ALXMPPHelper


//user to voip
+ (UserXmppDB *)_saveWithXmppInfo:(UserXmppInfo *)userXI
{
    if (!userXI) return nil;
    
    UserXmppDB *xmppDB = [UserXmppDB object];
    xmppDB.userId = userXI.user.objectId;
    xmppDB.subAccountSid = userXI.subAccountSid;
    xmppDB.subToken = userXI.subToken;
    xmppDB.voipAccount = userXI.voipAccount;
    xmppDB.voipPwd = userXI.voipPwd;
    [xmppDB save];
    return xmppDB;
}

+ (UserXmppDB *)_loadWithUser:(User *)theUser
{
    if (!theUser) return nil;
    
    ALDBQuery *xmppDBQ = [UserXmppDB query];
    [xmppDBQ whereKey:@"userId" equalTo:theUser.objectId];
    UserXmppDB *xmppDB = (UserXmppDB *)[xmppDBQ getFirstObject];
    return xmppDB;
}

+ (UserXmppDB *)_loadWithVoip:(NSString *)theVoip
{
    if (!theVoip) return nil;
    
    ALDBQuery *xmppDBQ = [UserXmppDB query];
    [xmppDBQ whereKey:@"voipAccount" equalTo:theVoip];
    UserXmppDB *xmppDB = (UserXmppDB *)[xmppDBQ getFirstObject];
    return xmppDB;
}


//user to voip
+ (void)getVoipFromUser:(User *)theUser
                   block:(void(^)(UserXmppDB *userXmppDB, NSError *error))resultBlock
{
    [resultBlock copy];
    
    if (!theUser)
    {
        if (resultBlock)
        {
            resultBlock(nil, nil);
        }
        return;
    }
    
//    NSString *voip = [[NSUserDefaults standardUserDefaults] stringForKey:theUser.objectId];
    
//    ALDBQuery *xmppDBQ = [UserXmppDB query];
//    [xmppDBQ whereKey:@"userId" equalTo:theUser.objectId];
//    UserXmppDB *xmppDB = (UserXmppDB *)[xmppDBQ getFirstObject];
//    NSString *voip = xmppDB.voipAccount;
    
    UserXmppDB *xmppDB = [ALXMPPHelper _loadWithUser:theUser];
    
    if (xmppDB)
    {
        if (resultBlock)
        {
            resultBlock(xmppDB,nil);
        }
    }
    else
    {
        AVQuery *userXIQ = [UserXmppInfo query];
        
        [userXIQ whereKey:@"user" equalTo:theUser];
        
        [userXIQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
//            UserXmppInfo *userXI = (UserXmppInfo *)object;
//            NSString *voip = userXI.voipAccount;
            
//            [[NSUserDefaults standardUserDefaults] setObject:voip forKey:theUser.objectId];
//            [[NSUserDefaults standardUserDefaults] setObject:theUser.objectId forKey:voip];
            
//            UserXmppDB *xmppDB = [UserXmppDB object];
//            xmppDB.userId = userXI.user.objectId;
//            xmppDB.subAccountSid = userXI.subAccountSid;
//            xmppDB.subToken = userXI.subToken;
//            xmppDB.voipAccount = userXI.voipAccount;
//            xmppDB.voipPwd = userXI.voipPwd;
//            [xmppDB save];
            
            if (object)
            {
                UserXmppDB *xmppDB = [ALXMPPHelper _saveWithXmppInfo:(UserXmppInfo *)object];
                
                if (resultBlock)
                {
                    resultBlock(xmppDB,error);
                }
                
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(nil,error);
                }
            }
            
        }];
    }

    [resultBlock release];
}

//批量 user to voip
+ (void)getVoipFromUsers:(NSArray *)theUsers//User
                   block:(void(^)(NSArray *userXmppDBs, NSError *error))resultBlock
{
    [resultBlock copy];
    
    if (theUsers.count == 0 || !theUsers)
    {
        if (resultBlock)
        {
            resultBlock(nil, nil);
        }
        return;
    }
    
    NSMutableArray *resultVoips = [[NSMutableArray array] retain];
    
    for (User *theUser in theUsers)
    {
//        NSString *voip = [[NSUserDefaults standardUserDefaults] stringForKey:theUser.objectId];
        
//        ALDBQuery *xmppDBQ = [UserXmppDB query];
//        [xmppDBQ whereKey:@"userId" equalTo:theUser.objectId];
//        UserXmppDB *xmppDB = (UserXmppDB *)[xmppDBQ getFirstObject];
        
        UserXmppDB *xmppDB = [self _loadWithUser:theUser];
        
        if (xmppDB)
        {
            [resultVoips addObject:xmppDB];
        }
        else
        {
            [resultVoips addObject:theUser];
        }
    }
    
    NSMutableArray *queriesArray = [NSMutableArray arrayWithCapacity:theUsers.count];
    
    for (id theUser in resultVoips)
    {
        if ([theUser isKindOfClass:[User class]])
        {
            AVQuery *query = [UserXmppInfo query];
            [query whereKey:@"user" equalTo:theUser];
            
            [queriesArray addObject:query];
        }

    }

    if (queriesArray.count == 0)
    {
        if (resultBlock)
        {
            resultBlock(resultVoips, nil);
        }
        return ;
    }
    
    AVQuery *queries = [AVQuery orQueryWithSubqueries:queriesArray];
    
    [queries includeKey:@"user"];
    
    [queries findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects)
        {
            for (int i=0; i<resultVoips.count; i++)
            {
                User *theUser = resultVoips[i];
                
                if ([theUser isKindOfClass:[User class]])
                {
                    for (UserXmppInfo *userXI in objects)
                    {
                        if ([theUser.objectId isEqualToString:userXI.user.objectId])
                        {
//                            [[NSUserDefaults standardUserDefaults] setObject:userXI.voipAccount forKey:theUser.objectId];
//                            [[NSUserDefaults standardUserDefaults] setObject:theUser.objectId forKey:userXI.voipAccount];
                            
//                            UserXmppDB *xmppDB = [UserXmppDB object];
//                            xmppDB.userId = userXI.user.objectId;
//                            xmppDB.subAccountSid = userXI.subAccountSid;
//                            xmppDB.subToken = userXI.subToken;
//                            xmppDB.voipAccount = userXI.voipAccount;
//                            xmppDB.voipPwd = userXI.voipPwd;
//                            [xmppDB save];
                            
                            UserXmppDB *xmppDB = [self _saveWithXmppInfo:userXI];
                            
                            [resultVoips replaceObjectAtIndex:i withObject:xmppDB];
                        }
                    }
                }
            }
            
            if (resultBlock)
            {
                resultBlock(resultVoips, nil);
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(nil, error);
            }
        }
        [resultVoips release];
    }];
    
    [resultBlock release];
}

//UserXmppInfo to User
+ (void)getUserFromVoip:(NSString *)voip
                  block:(void(^)(UserXmppDB *userXmppDB, NSError *error))resultBlock
{
    [resultBlock copy];
    
    if (voip.length  == 0 || !voip)
    {
        if (resultBlock)
        {
            resultBlock(nil, nil);
        }
        return;
    }
    
//    NSString *userObjectId = [[NSUserDefaults standardUserDefaults] stringForKey:voip];
    
    UserXmppDB *xmppDB = [self _loadWithVoip:voip];
    
    if (xmppDB)
    {
        if (resultBlock)
        {
            resultBlock(xmppDB, nil);
        }
    }
    else
    {
        AVQuery *userXIQ = [UserXmppInfo query];
        
        [userXIQ whereKey:@"voipAccount" equalTo:voip];
        [userXIQ includeKey:@"user"];
        
        [userXIQ getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
            if (object)
            {
                UserXmppInfo *userXI = (UserXmppInfo *)object;
                
//                [[NSUserDefaults standardUserDefaults] setObject:voip forKey:userXI.user.objectId];
                
                UserXmppDB *xmppDB = [ALXMPPHelper _saveWithXmppInfo:userXI];
                
                if (resultBlock)
                {
                    resultBlock(xmppDB, error);
                }
            }
            else
            {
                if (resultBlock)
                {
                    resultBlock(nil, error);
                }
            }
            
        }];
    }

    [resultBlock release];
}

//批量UserXmppInfo to User
+ (void)getUsersFromVoips:(NSArray *)voips
                     block:(void(^)(NSArray *users, NSError *error))resultBlock
{
    [resultBlock copy];
    
    if (voips.count == 0 || !voips)
    {
        if (resultBlock)
        {
            resultBlock(nil, nil);
        }
        return;
    }
    
    NSMutableArray *resultUsers = [[NSMutableArray array] retain];
    
    
    for (int i=0; i<voips.count; i++)
    {
        NSString *temVoip = voips[i];

        UserXmppDB *xmppDB = [self _loadWithVoip:temVoip];
        
        if (xmppDB)
        {
            [resultUsers addObject:xmppDB];
        }
        else
        {
            [resultUsers addObject:temVoip];
        }
    }
    
    NSMutableArray *queriesArray = [NSMutableArray array];
    
    for (int i=0; i<resultUsers.count; i++)
    {
        id theVoip = resultUsers[i];
        
        if ([theVoip isKindOfClass:[NSString class]])
        {
            AVQuery *query = [UserXmppInfo query];
            [query whereKey:@"voipAccount" equalTo:theVoip];
            
            [queriesArray addObject:query];
        }
    }
    
    if (queriesArray.count == 0)
    {
        if (resultBlock)
        {
            resultBlock(resultUsers, nil);
        }
        return ;
    }
    
    AVQuery *queries = [AVQuery orQueryWithSubqueries:queriesArray];
    
    [queries includeKey:@"user"];
    
    [queries findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count && objects)
        {
            //resultUsers  voip
            for (int i=0; i<resultUsers.count; i++)
            {
                id voip = resultUsers[i];
                if ([voip isKindOfClass:[NSString class]])
                {
                    for (UserXmppInfo *userXI in objects)
                    {
//                        [[NSUserDefaults standardUserDefaults] setObject:userXI.user.objectId forKey:voip];
//                        [[NSUserDefaults standardUserDefaults] setObject:voip forKey:userXI.user.objectId];
                        
                        if ([userXI.voipAccount isEqualToString:voip])
                        {
                            UserXmppDB *xmppDB = [ALXMPPHelper _saveWithXmppInfo:userXI];
                            
                            [resultUsers replaceObjectAtIndex:i withObject:xmppDB];
                        }
                       
                    }
                }
            }
            
            if (resultBlock)
            {
                resultBlock(resultUsers, nil);
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(nil, error);
            }
        }
        
        [resultUsers release];
        
    }];
    
    [resultBlock release];
}


@end
