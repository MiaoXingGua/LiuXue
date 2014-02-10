//
//  EGOLoadTableFooterView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullLoadPulling = 0,
	EGOOPullLoadNormal,
	EGOOPullLoadLoading,	
} EGOPullLoadState;

@protocol EGOLoadTableFooterDelegate;
@interface EGOLoadTableFooterView : UIView {
	
	id _delegate;
	EGOPullLoadState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}
@property (nonatomic, retain) UIFont *curFont10, *curFont12, *curFont15, *curFont20;
@property(nonatomic,assign) id <EGOLoadTableFooterDelegate> delegate;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)loadLastUpdatedDate;
- (void)egoLoadScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoLoadScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoLoadScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol EGOLoadTableFooterDelegate
- (void)egoLoadTableFooterDidTriggerLoad:(EGOLoadTableFooterView*)view;
- (BOOL)egoLoadTableFooterDataSourceIsLoading:(EGOLoadTableFooterView*)view;
@optional
- (NSDate*)egoLoadTableFooterDataSourceLastUpdated:(EGOLoadTableFooterView*)view;
@end
