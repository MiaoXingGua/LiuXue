//
//  UICustomView.m
//  TTAddressBook
//
//  Created by iphonekf2 on 12-1-12.
//  Copyright (c) 2012Âπ?__MyCompanyName__. All rights reserved.
//

#import "UICustomView.h"

@implementation UICustomView


- (id)initWithFrame:(CGRect)frame andIcon1Name:(NSString *)icon1Name andIcon2Name:(NSString *)icon2Name andIcon3Name:(NSString *)icon3Name
         andLabel1Text:(NSString *)label1Text andLabel2Text:(NSString *)label2Text andLabel3Text:(NSString *)label3Text
{
    self = [self initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 127)];
    menuImageView.backgroundColor = [UIColor clearColor];
    menuImageView.image = [UIImage imageNamed:@"dialog_three.png"];
    [self addSubview:menuImageView];
    menuImageView.tag = MENUVIEW_TAG;
    [menuImageView release];     
    
    btnBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, 135, 38)];
    btnBackGround.backgroundColor = [UIColor clearColor];
    btnBackGround.image = [UIImage imageNamed:@"dialog_on.png"];
    [self addSubview:btnBackGround];
    btnBackGround.hidden = YES;
    btnBackGround.tag = MENUVIEW_TAG;
    [btnBackGround release]; 
    
    if (icon1Name)
    {
        btn1Icon = [[UIImageView alloc] initWithFrame:CGRectMake(9, 21, 17, 17)];
        btn1Icon.backgroundColor = [UIColor clearColor];
        btn1Icon.image = [UIImage imageNamed:icon1Name];
        [self addSubview:btn1Icon];
        btn1Icon.tag = MENUVIEW_TAG;
        [btn1Icon release];
    }

    if (icon2Name)
    {
        btn2Icon = [[UIImageView alloc] initWithFrame:CGRectMake(9, 61, 17, 17)];
        btn2Icon.backgroundColor = [UIColor clearColor];
        btn2Icon.image = [UIImage imageNamed:icon2Name];
        [self addSubview:btn2Icon];
        btn2Icon.tag = MENUVIEW_TAG;
        [btn2Icon release];
    }

    if (icon3Name)
    {
        _btn3Icon = [[UIImageView alloc] initWithFrame:CGRectMake(9, 101, 17, 17)];
        _btn3Icon.backgroundColor = [UIColor clearColor];
        _btn3Icon.image = [UIImage imageNamed:icon3Name];
        [self addSubview:_btn3Icon];
        _btn3Icon.tag = MENUVIEW_TAG;
        [_btn3Icon release];        
    }

    btn1Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 130, 35)];
    btn1Label.text = label1Text;
    btn1Label.backgroundColor = [UIColor clearColor];
    [btn1Label setFont:[UIFont systemFontOfSize :16]];    
    btn1Label.textColor = [UIColor whiteColor];
    [self addSubview:btn1Label];
    btn1Label.tag = MENUVIEW_TAG;
    [btn1Label release]; 
    
    btn2Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 52, 130, 35)];
    
    if ([icon2Name isEqualToString:@"dialog_icon_choose_gray.png"])
    {
        btn2Label.textColor = [UIColor grayColor];
        viewflag = NO;
    }
    else
    {
        btn2Label.textColor = [UIColor whiteColor];
        viewflag = YES; 
    }
    
    btn2Label.text = label2Text;
    btn2Label.backgroundColor = [UIColor clearColor];
    [btn2Label setFont:[UIFont systemFontOfSize :16]];    
    [self addSubview:btn2Label];
    btn2Label.tag = MENUVIEW_TAG;
    [btn2Label release]; 
    
    _btn3Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 92, 130, 35)];
    
    if ([icon3Name isEqualToString:@"delete_button_disable"])
    {
        _btn3Label.textColor = [UIColor grayColor];
        viewflag = NO;
    }
    else
    {
        _btn3Label.textColor = [UIColor whiteColor];
        viewflag = YES; 
    }
    
    _btn3Label.text = label3Text;
    _btn3Label.backgroundColor = [UIColor clearColor];
    [_btn3Label setFont:[UIFont systemFontOfSize:16]];    
    [self addSubview:_btn3Label];
    _btn3Label.tag = MENUVIEW_TAG;
    [_btn3Label release]; 

    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code    
    }
    return self;
}
-(void)set_Delegate:(id)delegate{
    viewDelegate = delegate;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    if ( menuImageView.frame.size.height > 87 )
    {
        [self ShowView: pos isThree:YES];  
    }
    else
    {
        [self ShowView:pos isThree:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    if ( menuImageView.frame.size.height > 87 )
    {
        [self ShowView: pos isThree:YES];  
    }
    else
    {
        [self ShowView:pos isThree:NO];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    btnBackGround.hidden = YES; 
    [viewDelegate ChooseWithFlag:chooseFlag];
}

- (void)ShowView:(CGPoint)pos isThree:(BOOL)isThree
{
    chooseFlag = EChooseNone;
    
    if ((pos.x< 0)||(pos.x>127))
    {
        btnBackGround.hidden = YES; 
        return;
    }
    
    if ((pos.y < 49) && (pos.y > 0))
    {
        CGRect backFrame = btnBackGround.frame;
        backFrame.origin.y = 9;
        btnBackGround.frame = backFrame;
        btnBackGround.hidden = NO;
        chooseFlag = EChooseFirst;
    }
    else  if ((pos.y > 49) && (pos.y < 87))
    {
        if (!viewflag)
        {
            chooseFlag = EChooseDisalbe;
            return;
        }
        
        CGRect backFrame = btnBackGround.frame;
        backFrame.origin.y = 49;
        btnBackGround.frame = backFrame;
        btnBackGround.hidden = NO;
        chooseFlag = EChooseSecond;
    }
    else
    {
        if ( isThree )
        {
            if ((pos.y > 87) && (pos.y < 127))
            {
                if ( !viewflag )
                {
                    chooseFlag = EChooseDisalbe;
                    return;
                }
                
                CGRect backFrame = btnBackGround.frame;
                backFrame.origin.y = 87;
                btnBackGround.frame = backFrame;
                btnBackGround.hidden = NO;
                chooseFlag = EChooseThird;
            }
            else
            {
                btnBackGround.hidden = YES;
            }
        }
        else
        {
            btnBackGround.hidden = YES; 
        }
    }
}

-(void) dealloc{
    [super dealloc];
}


@end
