//
//  UIAdd.m
//  VENCI
//
//  Created by  on 12-2-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIAddition.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@implementation NSString(Addtions) 

- (NSString *)isNil
{
    if (self) return self; else return @"";
}

- (BOOL)checkName
{
    if (![self length]) {
        
        [UIAlertView alertViewWithInfo:@"请输入姓名"];
        return NO;
    }
    
    NSString *str = @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$€% ";
    
    for (int j = 0; j < [self length]; j++) {
        
        NSString *str1 = [self substringWithRange:NSMakeRange(j,1)];
        
        for (int i = 0; i < [str length]; i++) {
            
            if ([str1 isEqualToString:[str substringWithRange:NSMakeRange(i, 1)]]) {
                
                if ([str1 isEqualToString:@" "])  str1 = @"空格符";
                
                [UIAlertView alertViewWithInfo:[NSString stringWithFormat:@"姓名不能包含特殊字符:%@",str1]];
                return NO;
            }
        }
        
    }
    
    return YES;
}
- (BOOL)checkPhoneNum
{
    if (![self length]) {
        [UIAlertView alertViewWithInfo:@"请输入电话"];
        return NO;
    }

    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    if (![phoneTest evaluateWithObject:self]) {
        
        [UIAlertView alertViewWithInfo:@"电话号码不合法"];
        return NO;
    }
    
    return YES;
}
- (BOOL)checkEmail
{
    return YES;
}


@end;

@implementation NSArray(Addtions) 

- (NSMutableArray *)sortByKey:(NSString *)aKey
{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *dic in self) {
        
        [mDic setObject:dic forKey:[dic objectForKey:aKey]];
    }
    NSArray *arrKeys = [mDic allKeys];
    
    arrKeys = [arrKeys sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *key in arrKeys) {
        
        [mArr addObject:[mDic objectForKey:key]];
    }
    [mDic release]; 
    
    return [mArr autorelease];
}

@end;

@implementation UIProgressView(Addtions) 

+(UIProgressView *) progressVieWithFrame:(CGRect)frame 
                               superview:(UIView *)superview
{
    UIProgressView *lUIProgressView = [[UIProgressView alloc] initWithFrame:frame];
//    lUIProgressView.progressViewStyle = UIProgressViewStyleBar;
    if (superview != nil)
    {
        [superview addSubview:lUIProgressView];
    }
    [lUIProgressView release];
    return lUIProgressView;
}

@end

@implementation UILabel(Addtions)

+(UILabel *)labelWithFrame:(CGRect)aFrame 
                      Text:(NSString *)aText 
                      Font:(UIFont *)aFont 
                 TextColor:(UIColor *)aTextColor 
             textAlignment:(UITextAlignment)aTextAlignment
                 superview:(UIView *)superview
{
    UILabel *lUILabel = [[UILabel alloc] initWithFrame:aFrame];
    lUILabel.text = aText;
    lUILabel.font = aFont;
    lUILabel.textColor = aTextColor;
    lUILabel.textAlignment = aTextAlignment;
    lUILabel.backgroundColor = [UIColor clearColor];
    if (superview != nil)
    {
        [superview addSubview:lUILabel];
    }
    [lUILabel release];
    
    return lUILabel;
   
}

+(UILabel *)labelWithFrame:(CGRect)aFrame 
                      Text:(NSString *)aText 
                      Font:(UIFont *)aFont 
                 TextColor:(UIColor *)aTextColor 
             textAlignment:(UITextAlignment)aTextAlignment
                 superview:(UIView *)superview 
                   lineNum:(NSInteger)aNum
{
    UILabel *lUILabel = [UILabel labelWithFrame:aFrame 
                                           Text:aText 
                                           Font:aFont 
                                      TextColor:aTextColor 
                                  textAlignment:aTextAlignment 
                                      superview:superview];
    lUILabel.numberOfLines = aNum;
    
    return lUILabel;
}
                
@end



//@implementation CustomTextField(Addtions)
//+(CustomTextField *) CustomTextFieldWithFrame:(CGRect)frame 
//                                bgImageName:(NSString *)bgImageName 
//                                       text:(NSString *)aText 
//                                placeholder:(NSString *)placeholder
//                                  superview:(UIView *)superview
//{
//    CustomTextField *lCustomTextField = [[CustomTextField alloc] initWithFrame:frame bgImageName:bgImageName text:aText placeholder:placeholder];  
//    if (superview != nil)
//    {
//        [superview addSubview:lCustomTextField];
//        
//    }
//    [lCustomTextField release];
//    return lCustomTextField;
//}
//@end

@implementation UIImage(Addtions) 

+(UIImage *) imageWithImageName:(NSString *)imageName
{
    if (!imageName) return nil;
    if (![imageName length]) return nil;
    if (![imageName hasSuffix:@".png"] && ![imageName hasSuffix:@".jpg"]) return nil;

    UIImage *image;
    
    if ([imageName hasPrefix:@"/"]) {
        
        image = [UIImage imageWithContentsOfFile:imageName];
        
    }else{
        
        NSArray *arr = [imageName componentsSeparatedByString:@"."];
        
        if (![arr count] == 2) return nil;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] 
                                                         ofType:[arr objectAtIndex:1]];
        image =  [UIImage imageWithContentsOfFile:path];
    }
    
    return image;
}

@end

@implementation UIImageView(Addtions) 

+(UIImageView *) imageViewWithFrame:(CGRect)frame
                           CapWidth:(NSInteger)capWidth
                          CapHeight:(NSInteger)capHeight
                          imageName:(NSString *)imageName 
             userInteractionEnabled:(BOOL)userInteractionEnabled 
                          superview:(UIView *)superview
{
    UIImageView *imageView = [[self alloc] initWithFrame:frame];
    
    imageView.image = [UIImage imageWithImageName:imageName];
    
    if (userInteractionEnabled) imageView.userInteractionEnabled = userInteractionEnabled;
    
    if (superview != nil) {
        [superview addSubview:imageView];
        [imageView release];
    }
    
    if ((capWidth != 0) && (capHeight != 0)) {
        
        imageView.image = [imageView.image stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
    }
    return imageView;
}

+(UIImageView *) imageViewWithFrame:(CGRect)frame 
                          imageName:(NSString *)imageName 
             userInteractionEnabled:(BOOL)userInteractionEnabled 
                          superview:(UIView *)superview
{
    return [self imageViewWithFrame:frame
                           CapWidth:0
                          CapHeight:0
                                 imageName:imageName
                    userInteractionEnabled:userInteractionEnabled 
                                 superview:superview];
}

@end

@implementation UIScrollView(Addtions) 

+(UIScrollView *) scrollViewWithFrame:(CGRect)frame 
                          contentSize:(CGSize)size 
                            superview:(UIView *)superview
{
    UIScrollView *lUIScrollView = [[UIScrollView alloc] initWithFrame:frame];
    lUIScrollView.contentSize = size;
    if (superview != nil) {
        [superview addSubview:lUIScrollView];
        [lUIScrollView release];
    }
     return lUIScrollView;
}

@end

@implementation UITableView(Addtions) 

+(UITableView *) tableViewWithFrame:(CGRect)frame 
                           delegate:(id)delegate 
                          superview:(UIView *)superview 
                     separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
{
    UITableView *lUITableView = [[UITableView alloc] initWithFrame:frame];
    lUITableView.delegate = delegate;
    lUITableView.dataSource = delegate;
    lUITableView.showsHorizontalScrollIndicator = NO;
    lUITableView.showsVerticalScrollIndicator = NO;
    lUITableView.backgroundColor = [UIColor clearColor];
    lUITableView.separatorStyle = separatorStyle;
    if (superview != nil) {
        [superview addSubview:lUITableView];
        [lUITableView release];
    }
    return lUITableView;
}

+(UITableView *) tableViewWithFrame:(CGRect)frame 
                           delegate:(id)delegate 
                          superview:(UIView *)superview
{
    return [UITableView tableViewWithFrame:(CGRect)frame 
                                  delegate:(id)delegate 
                                 superview:(UIView *)superview 
                            separatorStyle:UITableViewCellSeparatorStyleNone];
}
@end

@implementation UIButton(Addtions)

+(UIButton *)buttonWithFrame:(CGRect)frame
                       title:(NSString *)title
                        font:(UIFont *)font
                  titleColor:(UIColor *)normalColor
             backgroundImage:(NSString *)backgroundImage
             normalImageName:(NSString *)normalImageName
           selectedImageName:(NSString *)selectedImageName
                      target:(id)target
                      action:(SEL)action
                   superview:(UIView *)superview
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.titleLabel.font = font;
    
    button.backgroundColor = [UIColor clearColor];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithImageName:normalImageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithImageName:normalImageName] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    
    if (superview != nil) {
        [superview addSubview:button];
    }
    
    return button;
}

@end

@implementation UITextView(Addtions) 

+(UITextView *) textViewWithFrame:(CGRect)frame 
                         editable:(BOOL)flag 
                             text:(NSString *)text
                        textColor:(UIColor *)color
                             font:(UIFont *)font
                        superview:(UIView *)superview
{
    UITextView *lUITextView = [[UITextView alloc] initWithFrame:frame];
    lUITextView.editable = flag;
    lUITextView.text = text;
    lUITextView.textColor = color;
    lUITextView.font = font;
    if (superview != nil) {
        [superview addSubview:lUITextView];
        [lUITextView release];
    }
    return lUITextView;
}
@end

@implementation UIPageControl(Addtions) 

+(UIPageControl *) pageControlWithFrame:(CGRect)frame 
                       numberOfPages:(NSInteger)num 
                         currentPage:(NSInteger)index
                              target:(id)target 
                              action:(SEL)action 
                           superview:(UIView *)superview
{
    UIPageControl *lUIPageControl = [[UIPageControl alloc] initWithFrame:frame];
    lUIPageControl.backgroundColor = [UIColor clearColor];
    lUIPageControl.numberOfPages = num;
    lUIPageControl.currentPage = index;
    lUIPageControl.hidesForSinglePage = YES;
    
    lUIPageControl.userInteractionEnabled = NO;
    if (target) {
        [lUIPageControl addTarget:target 
                           action:@selector(action) 
                 forControlEvents:UIControlEventValueChanged];
    }
    
    if (superview != nil) {
        [superview addSubview:lUIPageControl];
        [lUIPageControl release];
    }
    return lUIPageControl;
}
@end


@implementation UIView(Addtions) 

- (void)cornerRadius:(CGFloat)cornerRadius 
       masksToBounds:(BOOL)masksToBounds 
         borderWidth:(CGFloat)borderWidth 
         borderColor:(UIColor *)borderColor
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = masksToBounds;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = [borderColor CGColor];
}
- (void)shadowRadius:(CGFloat)shadowRadius 
        shadowOffset:(CGSize)shadowOffset 
       shadowOpacity:(float)shadowOpacity 
         shadowColor:(UIColor *)shadowColor
{
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowOffset = shadowOffset;
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowColor = [shadowColor CGColor];
}
+(UIView *) viewWithFrame:(CGRect)frame
                    color:(UIColor *)color
                superview:(UIView *)superview
{
    UIView *lUIView = [[UIView alloc] initWithFrame:frame];
    lUIView.backgroundColor = color;
    if (superview != nil) {
        [superview addSubview:lUIView];
        [lUIView release];
    }
    return lUIView;
}

+(UIView *) viewWithFrame:(CGRect)frame
                superview:(UIView *)superview
{
    return [self viewWithFrame:frame
                         color:nil
                     superview:superview];
}
@end

@implementation UIWebView(Addtions) 

+(UIWebView *) webviewWithFrame:(CGRect)frame 
                       delegate:(id)delegate 
                      superview:(UIView *)superview
{
    UIWebView *lUIWebView = [[UIWebView alloc] initWithFrame:frame];
    lUIWebView.delegate = delegate;
    lUIWebView.backgroundColor = [UIColor clearColor];
    lUIWebView.opaque = NO;
    lUIWebView.scalesPageToFit = YES;
    
    if (superview != nil) {
        [superview addSubview:lUIWebView];
        [lUIWebView release];
    }
    return lUIWebView;
}
@end

@implementation UIPickerView(Addtions) 

+(UIPickerView *) pickerviewWithFrame:(CGRect)frame 
                             delegate:(id)delegate 
                            superview:(UIView *)superview
{

    UIPickerView *lUIPickerView = [[UIPickerView alloc] initWithFrame:frame];
    lUIPickerView.delegate = delegate;
    lUIPickerView.showsSelectionIndicator = YES;
    
    if (superview != nil) {
        [superview addSubview:lUIPickerView];
        [lUIPickerView release];
    }
    return lUIPickerView;
}
@end

@implementation UISearchBar(Addtions) 

+(UISearchBar *) searchViewWithFrame:(CGRect)frame 
                         placeholder:(NSString *)placeholder
                            delegate:(id)delegate 
                           superview:(UIView *)superview
{
    UISearchBar *lUISearchBar = [[UISearchBar alloc] initWithFrame:frame];
    lUISearchBar.delegate = delegate;
    lUISearchBar.placeholder = placeholder;
    lUISearchBar.text = @"";
    [[lUISearchBar.subviews objectAtIndex:0] removeFromSuperview];
    //    searchBar.barStyle=UIBarStyleDefault;
    //    searchBar.translucent = YES;
    lUISearchBar.autocorrectionType = UITextAutocorrectionTypeNo;  
    lUISearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if (superview != nil) {
        [superview addSubview:lUISearchBar];
        [lUISearchBar release];
    }
    return lUISearchBar;
}

@end



@implementation UIAlertView(Addtions)

+ (UIAlertView *) alertViewWithInfo:(NSString *)info delegate:(id)delegate tag:(NSInteger)tag
{
    NSString *str = nil;
    
    if (tag) str = @"取消";
    
    UIAlertView *lUIAlertView = [[UIAlertView alloc]initWithTitle:@"提醒!"
                                                          message:info
                                                         delegate:delegate
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:str,nil];
    lUIAlertView.tag = tag;
    [lUIAlertView show];
    [lUIAlertView release];
    
    return nil;
}

+ (UIAlertView *) alertViewWithInfo:(NSString *)info
{
    return [UIAlertView alertViewWithInfo:info delegate:nil tag:0];
}

@end


@implementation UITextField(Addtions)

+ (UITextField *) textFieldWithFrame:(CGRect)frame
                          placeholder:(NSString *)placeholder
                                 text:(NSString *)text
                             delegate:(id)delegate
                            superview:(UIView *)superview
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.delegate = delegate;
    textField.placeholder = placeholder;
    textField.text = text;
//    [[textField.subviews objectAtIndex:0] removeFromSuperview];
//    textField.autocorrectionType = UITextAutocorrectionTypeNo;
//    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if (superview != nil) {
        [superview addSubview:textField];
        [textField release];
    }
    return textField;}

@end


@implementation UITapGestureRecognizer(Addtions)

+(UITapGestureRecognizer *) tapGestureRecognizerWithTargetView:(UIView *)view 
                                                        Target:(id)target
                                                        Action:(SEL)action
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target 
                                                                          action:action];
    [view addGestureRecognizer:tap];
    [tap release];
    return tap;
}
@end


@implementation UISwipeGestureRecognizer(Addtions) 

+(UISwipeGestureRecognizer *) swipeGestureRecognizerWithTargetView:(UIView *)view 
                                                         Direction:(UISwipeGestureRecognizerDirection)direction
                                                            Target:(id)target
                                                            Action:(SEL)action
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:action];
    swipe.direction = direction;
    [view addGestureRecognizer:swipe];
    [swipe release];
    return swipe;
}
@end