//
//  LevelRule.h
//  PARSE_DEMO
//
//  Created by Albert on 13-9-16.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

/*
 等级规则
 知道成长体系共包含20个等级，由知道经验值、采纳率、被采纳回答数（含提问者采纳与被管理员采纳）三因素决定，三者越高，等级越高，头衔不同（等级特权即将推出）。
 
 等级	经验值	采纳率	被采纳答案数
 1	0       0%	0
 2	81      0%	2
 3	401     10%	5
 4	801     10%	10
 5	2001	15%	30
 6	4001	15%	70
 7	7001	20%	120
 8	10001	20%	200
 9	14001	25%	300
 10	18001	25%	450
 11	22001	27%	650
 12	32001	27%	900
 13	45001	29%	1300
 14	60001	29%	1800
 15	100001	31%	2500
 16	150001	31%	3500
 17	250001	33%	5000
 18	400001	33%	7000
 19	700001	35%	10000
 20	1000001	35%	15000
 
 注1：知道等级条件由经验值调整为经验值、采纳率、被采纳答案数决定，意在更合理体现用户影响力，正常用户现有等级将不受到影响，继续升级需满足新等级调整；同时对有作弊等行为的用户进行降级。
 注2：因用户量较大，以上相应数据将会有一定延迟，但是一定不会漏加，请大家放心，如有问题可随时反馈
 
 
 
 
 */

#import <AVOSCloud/AVOSCloud.h>

@interface LevelRule : AVObject <AVSubclassing>

@property (nonatomic, assign) int level;//等级

@property (nonatomic, assign) int experienceLimit;//经验值

@property (nonatomic, assign) double acceptRate;//采纳率

@property (nonatomic, assign) int acceptCount;//被采纳答案数

@end
