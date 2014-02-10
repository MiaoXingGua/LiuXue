//
//  userInfo.m
//  AVOS_DEMO
//
//  Created by Albert on 13-9-8.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "UserInfo.h"
#import <AVOSCloud/AVSubclassing.h>

@implementation UserInfo

@dynamic affectiveState,telephone,mobile,address,zipcode,nationality,brithProvince,graduateSchool,company,education,bloodType,QQ,MSN,interest,album;

@dynamic brithday,constellation,zodiac,age;

NSString *getZodiacWithDate(NSDate *date);

NSString *getConstellationWithDate(NSDate *date);

+ (NSString *)parseClassName
{
    return @"UserInfo";
}

- (void)setBrithday:(NSDate *)brithday
{
    if (brithday)
    {
        [self setObject:brithday forKey:@"brithday"];
        
        self.constellation = getConstellationWithDate(brithday);
        self.zodiac = getZodiacWithDate(brithday);
        self.age = getAgeWithDate(brithday);
    }
}

- (void)setConstellation:(NSString *)constellation
{
    if (constellation)
        [self setObject:constellation forKey:@"constellation"];
}

- (void)setZodiac:(NSString *)zodiac
{
    if (zodiac)
        [self setObject:zodiac forKey:@"zodiac"];
}


- (void)setAge:(int)age
{
    [self setObject:[NSNumber numberWithInt:age] forKey:@"age"];
}

@end

int getAgeWithDate(NSDate *date)
{
    int now = (int)[[NSDate date] timeIntervalSince1970];
    int send = (int)[date timeIntervalSince1970];
    
    return (now-send)/(60*60*24*30*12);
}

int yearFromDate(NSDate *date)
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
    return [destDateString intValue];
}

int mouthFromDate(NSDate *date)
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"MM"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
    return [destDateString intValue];
}

int dayFromDate(NSDate *date)
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"dd"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
    return [destDateString intValue];
}


NSString *getConstellationWithDate(NSDate *date)
{
    
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    int mouth = mouthFromDate(date);
    int day = dayFromDate(date);
    
    if (mouth<1||mouth>12||day<1||day>31)
    {
        return @"错误日期格式!";
    }
    if(mouth==2 && day>29)
    {
        return @"错误日期格式!!";
    }
    else if(mouth==4 || mouth==6 || mouth==9 || mouth==11)
    {
        if (day>30)
        {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(mouth*2-(day < [[astroFormat substringWithRange:NSMakeRange((mouth-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}

NSString *getZodiacWithDate(NSDate *date)
{
    NSArray *zodiacList = @[@"猴",@"鸡",@"狗",@"猪",@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊"];
    int year = yearFromDate(date);
    return zodiacList[year%12];
}

/*
 - (void)setGraduateSchool:(NSString *)graduateSchool
 {
 
 if (graduateSchool)
 {
 [self setObject:graduateSchool forKey:@"graduateSchool"];
 }
 }
 
 - (NSString *)graduateSchool
 {
 return [self objectForKey:@"graduateSchool"];
 }
 
 - (void)setCompany:(NSString *)company
 {
 
 if (company)
 {
 [self setObject:company forKey:@"company"];
 }
 }
 
 - (NSString *)company
 {
 return [self objectForKey:@"company"];
 }
 
 - (void)setEducation:(NSString *)education
 {
 
 if (education)
 {
 [self setObject:education forKey:@"graduateSchool"];
 }
 }
 
 - (NSString *)education
 {
 return [self objectForKey:@"education"];
 }
 
 - (void)setBloodType:(NSString *)bloodType
 {
 
 if (bloodType)
 {
 [self setObject:bloodType forKey:@"bloodType"];
 }
 }
 
 - (NSString *)bloodType
 {
 return [self objectForKey:@"bloodType"];
 }
 
 - (void)setQQ:(NSString *)QQ
 {
 
 if (QQ)
 {
 [self setObject:QQ forKey:@"QQ"];
 }
 }
 
 - (NSString *)QQ
 {
 return [self objectForKey:@"QQ"];
 }
 
 - (void)setMSN:(NSString *)MSN
 {
 
 if (MSN)
 {
 [self setObject:MSN forKey:@"MSN"];
 }
 }
 
 - (NSString *)MSN
 {
 return [self objectForKey:@"MSN"];
 }
 
 - (void)setInterest:(NSString *)interest
 {
 
 if (interest)
 {
 [self setObject:interest forKey:@"interest"];
 }
 }
 
 - (NSString *)interest
 {
 return [self objectForKey:@"interest"];
 }
 
 - (void)setBrithProvince:(NSString *)brithProvince
 {
 
 if (brithProvince)
 {
 [self setObject:brithProvince forKey:@"brithProvince"];
 }
 }
 
 - (NSString *)brithProvince
 {
 return [self objectForKey:@"brithProvince"];
 }
 
 - (void)setNationality:(NSString *)nationality
 {
 
 if (nationality)
 {
 [self setObject:nationality forKey:@"nationality"];
 }
 }
 
 - (NSString *)nationality
 {
 return [self objectForKey:@"nationality"];
 }
 
 - (void)setZipcode:(NSString *)zipcode
 {
 
 if (zipcode)
 {
 [self setObject:zipcode forKey:@"zipcode"];
 }
 }
 
 - (NSString *)zipcode
 {
 return [self objectForKey:@"zipcode"];
 }
 
 - (void)setAddress:(NSString *)address
 {
 
 if (address)
 {
 [self setObject:address forKey:@"address"];
 }
 }
 
 - (NSString *)address
 {
 return [self objectForKey:@"address"];
 }
 
 - (void)setMobile:(NSString *)mobile
 {
 
 if (mobile)
 {
 [self setObject:mobile forKey:@"mobile"];
 }
 }
 
 - (NSString *)mobile
 {
 return [self objectForKey:@"mobile"];
 }
 
 - (void)setTelephone:(NSString *)telephone
 {
 
 if (telephone)
 {
 [self setObject:telephone forKey:@"telephone"];
 }
 }
 
 - (NSString *)telephone
 {
 return [self objectForKey:@"telephone"];
 }
 

 */