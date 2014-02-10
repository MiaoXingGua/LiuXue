//
//  PersonalCustomCell.m
//  iLiuXue
//
//  Created by superhomeliu on 13-8-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import "PersonalCustomCell.h"

@implementation PersonalCustomCell
@synthesize label1 = _label1,label2 = _label2,label3 = _label3;
@synthesize question = _question,answer = _answer,bestAnswer = _bestAnswer,fans = _fans,attention = _attention,level = _level;
@synthesize graduateSchool = _graduateSchool,studyAbroadSchool = _studyAbroadSchool,interest = _interest,introduce = _introduce;
@synthesize editBtn = _editBtn;
@synthesize textfield = _textfield;
@synthesize shuxian1 = _shuxian1;
@synthesize shuxian2 = _shuxian2;
@synthesize hengxian1 = _hengxian1;
@synthesize conBtn1 = _conBtn1,conBtn2 = _conBtn2,conBtn3 = _conBtn3;

- (void)dealloc
{
    [_conBtn1 release]; _conBtn1=nil;
    [_conBtn2 release]; _conBtn2=nil;
    [_conBtn3 release]; _conBtn3=nil;
    
    [_shuxian1 release]; _shuxian1=nil;
    [_shuxian2 release]; _shuxian2=nil;
    [_hengxian1 release]; _hengxian1=nil;
    
    [_editBtn release]; _editBtn=nil;
    [_textfield release]; _textfield=nil;
    [_graduateSchool release]; _graduateSchool=nil;
    [_studyAbroadSchool release]; _studyAbroadSchool=nil;
    [_interest release]; _interest=nil;
    [_introduce release]; _interest=nil;
    [_question release]; _question=nil;
    [_answer release]; _answer=nil;
    [_bestAnswer release]; _bestAnswer=nil;
    [_fans release]; _fans=nil;
    [_attention release]; _attention=nil;
    [_level release]; _level=nil;
    [_label1 release]; _label1=nil;
    [_label2 release]; _label2=nil;
    [_label3 release]; _label3=nil;
    [_label4 release]; _label4=nil;
    
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.label1 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 40, 106, 20)] autorelease];
        self.label1.backgroundColor = [UIColor clearColor];
        self.label1.font = [UIFont systemFontOfSize:15];
        [self.label1 setTextAlignment:NSTextAlignmentCenter];
        self.label1.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.label1];
        self.label1.hidden = YES;
        
        self.label2 = [[[UILabel alloc] initWithFrame:CGRectMake(106, 40, 106, 20)] autorelease];
        self.label2.backgroundColor = [UIColor clearColor];
        self.label2.font = [UIFont systemFontOfSize:15];
        [self.label2 setTextAlignment:NSTextAlignmentCenter];
        self.label2.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.label2];
        self.label2.hidden = YES;
        
        self.label3 = [[[UILabel alloc] initWithFrame:CGRectMake(212, 40, 106, 20)] autorelease];
        self.label3.backgroundColor = [UIColor clearColor];
        self.label3.font = [UIFont systemFontOfSize:15];
        [self.label3 setTextAlignment:NSTextAlignmentCenter];
        self.label3.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.label3];
        self.label3.hidden = YES;
        
        self.label4 = [[[UILabel alloc] initWithFrame:CGRectMake(40, 25, 200, 20)] autorelease];
        self.label4.backgroundColor = [UIColor clearColor];
        self.label4.font = [UIFont systemFontOfSize:15];
        [self.label4 setTextAlignment:NSTextAlignmentLeft];
        self.label4.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.label4];
        self.label4.hidden = YES;
        
        self.question = [[[UILabel alloc] initWithFrame:CGRectMake(0, 15, 106, 20)] autorelease];
        self.question.backgroundColor = [UIColor clearColor];
        self.question.font = [UIFont systemFontOfSize:22];
        [self.question setTextAlignment:NSTextAlignmentCenter];
        self.question.textColor = [UIColor colorWithRed:0.1 green:0.73 blue:0.6 alpha:1];
        [self.contentView addSubview:self.question];
        
        self.answer = [[[UILabel alloc] initWithFrame:CGRectMake(106, 15, 106, 20)] autorelease];
        self.answer.backgroundColor = [UIColor clearColor];
        self.answer.font = [UIFont systemFontOfSize:22];
        [self.answer setTextAlignment:NSTextAlignmentCenter];
        self.answer.textColor = [UIColor colorWithRed:0.97 green:0.7 blue:0.31 alpha:1];
        [self.contentView addSubview:self.answer];
        
        self.bestAnswer = [[[UILabel alloc] initWithFrame:CGRectMake(212, 15, 106, 20)] autorelease];
        self.bestAnswer.backgroundColor = [UIColor clearColor];
        self.bestAnswer.font = [UIFont systemFontOfSize:22];
        [self.bestAnswer setTextAlignment:NSTextAlignmentCenter];
        self.bestAnswer.textColor = [UIColor colorWithRed:0.12 green:0.62 blue:0.82 alpha:1];
        [self.contentView addSubview:self.bestAnswer];
        
        self.fans = [[[UILabel alloc] initWithFrame:CGRectMake(0, 15, 106, 20)] autorelease];
        self.fans.backgroundColor = [UIColor clearColor];
        self.fans.font = [UIFont systemFontOfSize:22];
        [self.fans setTextAlignment:NSTextAlignmentCenter];
        self.fans.textColor = [UIColor colorWithRed:0.55 green:0.78 blue:0.2 alpha:1];
        [self.contentView addSubview:self.fans];
        
        self.attention = [[[UILabel alloc] initWithFrame:CGRectMake(106, 15, 106, 20)] autorelease];
        self.attention.backgroundColor = [UIColor clearColor];
        self.attention.font = [UIFont systemFontOfSize:22];
        [self.attention setTextAlignment:NSTextAlignmentCenter];
        self.attention.textColor = [UIColor colorWithRed:1 green:0.46 blue:0.74 alpha:1];
        [self.contentView addSubview:self.attention];
        
        self.level = [[[UILabel alloc] initWithFrame:CGRectMake(212, 15, 106, 20)] autorelease];
        self.level.backgroundColor = [UIColor clearColor];
        self.level.font = [UIFont systemFontOfSize:22];
        [self.level setTextAlignment:NSTextAlignmentCenter];
        self.level.textColor = [UIColor colorWithRed:0.66 green:0.53 blue:0.74 alpha:1];
        [self.contentView addSubview:self.level];
        
        self.graduateSchool = [[[UILabel alloc] initWithFrame:CGRectMake(80, 40, 200, 20)] autorelease];
        self.graduateSchool.numberOfLines = 0;
        self.graduateSchool.backgroundColor = [UIColor clearColor];
        self.graduateSchool.font = [UIFont systemFontOfSize:15];
        [self.graduateSchool setTextAlignment:NSTextAlignmentLeft];
        self.graduateSchool.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.graduateSchool];
        
        self.studyAbroadSchool = [[[UILabel alloc] initWithFrame:CGRectMake(90, 40, 200, 20)] autorelease];
        self.studyAbroadSchool.numberOfLines = 0;
        self.studyAbroadSchool.backgroundColor = [UIColor clearColor];
        self.studyAbroadSchool.font = [UIFont systemFontOfSize:15];
        [self.studyAbroadSchool setTextAlignment:NSTextAlignmentLeft];
        self.studyAbroadSchool.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.studyAbroadSchool];
        
        self.interest = [[[UILabel alloc] initWithFrame:CGRectMake(80, 40, 200, 20)] autorelease];
        self.interest.backgroundColor = [UIColor clearColor];
        self.interest.numberOfLines = 0;
        self.interest.font = [UIFont systemFontOfSize:15];
        [self.interest setTextAlignment:NSTextAlignmentLeft];
        self.interest.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.interest];
        
        self.introduce = [[[UILabel alloc] initWithFrame:CGRectMake(90, 40, 200, 20)] autorelease];
        self.introduce.backgroundColor = [UIColor clearColor];
        self.introduce.numberOfLines = 0;
        self.introduce.font = [UIFont systemFontOfSize:15];
        [self.introduce setTextAlignment:NSTextAlignmentLeft];
        self.introduce.textColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1];
        [self.contentView addSubview:self.introduce];
        
        self.editBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        self.editBtn.frame = CGRectMake(260, 10, 30, 30);
        self.editBtn.hidden = YES;
        [self.contentView addSubview:self.editBtn];
        
        self.textfield = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 20)] autorelease];
        self.textfield.hidden = YES;
        [self.contentView addSubview:self.textfield];
        
        self.shuxian1 = [[[UIImageView alloc] init] autorelease];
        _shuxian1.userInteractionEnabled = YES;
        [self.contentView addSubview:_shuxian1];
        
        self.shuxian2 = [[[UIImageView alloc] init] autorelease];
        _shuxian2.userInteractionEnabled = YES;
        [self.contentView addSubview:_shuxian2];
        
        self.hengxian1 = [[[UIImageView alloc] init] autorelease];
        _hengxian1.userInteractionEnabled = YES;
        [self.contentView addSubview:_hengxian1];
        
        self.conBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_conBtn1];
        
        self.conBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_conBtn2];
        
        self.conBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_conBtn3];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
