//
//  UIAdd.h
//  VENCI
//
//  Created by  on 12-2-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.

//常用便利构造器

#define FONT_HELVETICA(a) [UIFont fontWithName:@"Helvetica" size:(a)]
#define FONT_HELVETICA_BOLD(a) [UIFont fontWithName:@"Helvetica-Bold" size:(a)]
#define COLOR_RBGA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define ROWNUM(a,b) (a)/(b) + (((a)%(b))==0 ? 0 : 1)
#define COLOR_BLUE COLOR_RBGA(18, 47, 120, 1) 
#define FRAM_CENTER(a,b) CGRectMake((1024 - (a))/2, (748 - (b))/2, (a), (b))
#define IS_CLASS(a,b) [(a) isKindOfClass:[(b) class]]
#define NSNOTIFICATION_POST(a,b,c) [[NSNotificationCenter defaultCenter] postNotificationName:(a) object:(b) userInfo:(c)];

#define NavigationBar_HEIGHT 44
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
//#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define SAFE_RELEASE(x) [x release];x=nil
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion ([[UIDevice currentDevice] systemVersion])
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define BACKGROUND_COLOR [UIColor colorWithRed:242.0/255.0 green:236.0/255.0 blue:231.0/255.0 alpha:1.0]


#pragma mark - self Methods

#pragma mark - User Actions

#pragma mark - View lifecycle

#pragma mark - UIApplicationDelegate  Methods

#pragma mark - UITableViewDelegate  Methods

#pragma mark - UITableViewDataSource  Methods

#import <Foundation/Foundation.h>
//#import "CustomTextField.h"

@interface NSString(Addtions) 

- (NSString *)isNil;
- (BOOL)checkName;
- (BOOL)checkPhoneNum;
- (BOOL)checkEmail;
@end

@interface NSArray(Addtions) 

- (NSMutableArray *)sortByKey:(NSString *)aKey;

@end

@interface UIProgressView(Addtions) 

+(UIProgressView *) progressVieWithFrame:(CGRect)frame 
                            superview:(UIView *)superview;

@end

@interface UILabel(Addtions) 

+(UILabel *)labelWithFrame:(CGRect)aFrame 
                      Text:(NSString *)aText 
                      Font:(UIFont *)aFont 
                 TextColor:(UIColor *)aTextColor 
                 textAlignment:(UITextAlignment)textAlignment
                 superview:(UIView *)superview;

+(UILabel *)labelWithFrame:(CGRect)aFrame 
                      Text:(NSString *)aText 
                      Font:(UIFont *)aFont 
                 TextColor:(UIColor *)aTextColor 
             textAlignment:(UITextAlignment)aTextAlignment
                 superview:(UIView *)superview 
                   lineNum:(NSInteger)aNum;

@end

@interface UIButton(Addtions)

+(UIButton *)buttonWithFrame:(CGRect)frame
                       title:(NSString *)title
                        font:(UIFont *)font
                  titleColor:(UIColor *)normalColor
             backgroundImage:(NSString *)backgroundImage
             normalImageName:(NSString *)normalImageName
           selectedImageName:(NSString *)selectedImageName
                      target:(id)target
                      action:(SEL)action
                   superview:(UIView *)superview;

@end

//
//@interface CustomTextField(Addtions)
//
//+(CustomTextField *)CustomTextFieldWithFrame:(CGRect)frame 
//                                bgImageName:(NSString *)bgImageName 
//                                       text:(NSString *)aText 
//                                placeholder:(NSString *)placeholder
//                                  superview:(UIView *)superview;
//
//@end

@interface UIImageView(Addtions) 

+(UIImageView *) imageViewWithFrame:(CGRect)frame
                           CapWidth:(NSInteger)capWidth
                          CapHeight:(NSInteger)capHeight
                          imageName:(NSString *)imageName 
             userInteractionEnabled:(BOOL)userInteractionEnabled 
                          superview:(UIView *)superview;

+(UIImageView *) imageViewWithFrame:(CGRect)frame 
                          imageName:(NSString *)imageName 
             userInteractionEnabled:(BOOL)userInteractionEnabled 
                          superview:(UIView *)superview;

@end

@interface UIImage(Addtions) 

+(UIImage *) imageWithImageName:(NSString *)imageName;

@end

@interface UIScrollView(Addtions) 

+(UIScrollView *) scrollViewWithFrame:(CGRect)frame 
                             contentSize:(CGSize)size 
                            superview:(UIView *)superview;

@end

@interface UITableView(Addtions) 

+(UITableView *) tableViewWithFrame:(CGRect)frame 
                           delegate:(id)delegate 
                          superview:(UIView *)superview 
                     separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;

+(UITableView *) tableViewWithFrame:(CGRect)frame 
                          delegate:(id)delegate 
                            superview:(UIView *)superview;

@end

@interface UITextView(Addtions) 

+(UITextView *) textViewWithFrame:(CGRect)frame 
                           editable:(BOOL)flag 
                               text:(NSString *)text
                          textColor:(UIColor *)color
                               font:(UIFont *)font
                          superview:(UIView *)superview;

@end

@interface UIView(Addtions) 

- (void)cornerRadius:(CGFloat)cornerRadius 
       masksToBounds:(BOOL)masksToBounds 
         borderWidth:(CGFloat)borderWidth 
         borderColor:(UIColor *)borderColor;

- (void)shadowRadius:(CGFloat)shadowRadius 
        shadowOffset:(CGSize)shadowOffset 
       shadowOpacity:(float)shadowOpacity 
         shadowColor:(UIColor *)shadowColor;

+(UIView *) viewWithFrame:(CGRect)frame
                    color:(UIColor *)color
                superview:(UIView *)superview;

+(UIView *) viewWithFrame:(CGRect)frame
                superview:(UIView *)superview;

@end

@interface UIWebView(Addtions) 

+(UIWebView *) webviewWithFrame:(CGRect)frame 
                       delegate:(id)delegate 
                      superview:(UIView *)superview;

@end

@interface UIPageControl(Addtions) 

+(UIPageControl *) pageControlWithFrame:(CGRect)frame 
                       numberOfPages:(NSInteger)num 
                         currentPage:(NSInteger)index
                              target:(id)target 
                              action:(SEL)action 
                           superview:(UIView *)superview;

@end

@interface UISearchBar(Addtions) 

+(UISearchBar *) searchViewWithFrame:(CGRect)frame 
                         placeholder:(NSString *)placeholder
                           delegate:(id)delegate 
                          superview:(UIView *)superview;

@end

@interface UIPickerView(Addtions) 

+(UIPickerView *) pickerviewWithFrame:(CGRect)frame 
                             delegate:(id)delegate 
                            superview:(UIView *)superview;

@end

@interface UIAlertView(Addtions)

+ (UIAlertView *) alertViewWithInfo:(NSString *)info delegate:(id)delegate tag:(NSInteger)tag;
+ (UIAlertView *) alertViewWithInfo:(NSString *)info;


@end

@interface UITextField(Addtions)

+ (UITextField *) textFieldWithFrame:(CGRect)frame
                         placeholder:(NSString *)placeholder
                                text:(NSString *)text
                            delegate:(id)delegate
                           superview:(UIView *)superview;

@end

@interface UITapGestureRecognizer(Addtions) 

+(UITapGestureRecognizer *) tapGestureRecognizerWithTargetView:(UIView *)view 
                                                        Target:(id)target
                                                        Action:(SEL)action;
@end


@interface UISwipeGestureRecognizer(Addtions) 

+(UISwipeGestureRecognizer *) swipeGestureRecognizerWithTargetView:(UIView *)view 
                                                         Direction:(UISwipeGestureRecognizerDirection)direction
                                                            Target:(id)target
                                                            Action:(SEL)action;
@end