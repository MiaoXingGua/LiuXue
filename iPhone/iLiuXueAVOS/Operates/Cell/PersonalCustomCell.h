//
//  PersonalCustomCell.h
//  iLiuXue
//
//  Created by superhomeliu on 13-8-20.
//  Copyright (c) 2013年 Albert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalCustomCell : UITableViewCell
{
    UILabel *_question,*_answer,*_bestAnswer;
    UILabel *_fans,*_attention,*_level;
    
    UILabel *_label1,*_label2,*_label3,*_label4;
    
    UILabel *_graduateSchool,*_studyAbroadSchool,*_interest,*_introduce;
    
    UIButton *_editBtn;
    UITextField *_textfield;
    
    UIImageView *_shuxian1,*_shuxian2;
    UIImageView *_hengxian1;
    
    UIButton *_conBtn1,*_conBtn2,*_conBtn3;
}

@property(nonatomic,retain)UIButton *conBtn1,*conBtn2,*conBtn3;
@property(nonatomic,retain)UIImageView *hengxian1;
@property(nonatomic,retain)UIImageView *shuxian1,*shuxian2;

@property(nonatomic,retain)UITextField *textfield;
@property(nonatomic,retain)UIButton *editBtn;
@property(nonatomic,retain)UILabel *label1,*label2,*label3,*label4;
@property(nonatomic,retain)UILabel *question,*answer,*bestAnswer;
@property(nonatomic,retain)UILabel *fans,*attention,*level;
@property(nonatomic,retain)UILabel *graduateSchool,*studyAbroadSchool,*interest,*introduce;
@end
