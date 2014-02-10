//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
//箭头变化动画
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;
@synthesize activityView=_activityView;

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor beginStr:(NSString *)bStr stateStr:(NSString *)sStr endStr:(NSString *)eStr haveArrow:(BOOL)arrow
{
    if((self = [super initWithFrame:frame])) 
    {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        _beginStr = bStr;
        _stateStr = sStr;
        _endStr = eStr;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = textColor;

		label.backgroundColor = [UIColor clearColor];
		[label setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label2.font = [UIFont boldSystemFontOfSize:13.0f];
		label2.textColor = textColor;
		label2.backgroundColor = [UIColor clearColor];
		[label2 setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:label2];
		_statusLabel=label2;
		[label2 release];
		
//		CALayer *layer = [CALayer layer];
//		layer.frame = CGRectMake(25.0f, 300.0f, 30.0f, 55.0f);
//		layer.contentsGravity = kCAGravityResizeAspect;
//		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
//		
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
//		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) 
//        {
//			layer.contentsScale = [[UIScreen mainScreen] scale];
//		}
//#endif
//		
//		[[self layer] addSublayer:layer];
//		_arrowImage=layer;
        
        NSArray *array = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"pulldownimage_1.png"],[UIImage imageNamed:@"pulldownimage_2.png"], nil];
        
        _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pulldownimage_1.png"]];
       
        
        float _height = self.frame.size.height;
        
        if(_height==370)
        {
            _arrowImage.frame = CGRectMake(230, _height, 90*0.7, 100*0.7);

        }
        else
        {
            _arrowImage.frame = CGRectMake(230, _height, 90*0.7, 100*0.7);

        }
        _arrowImage.animationImages = array;
        _arrowImage.animationDuration = 0.4;
        [self addSubview:_arrowImage];
        [_arrowImage release];
        
        [array release];
        array=nil;
        
        
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		view.frame = CGRectMake(70.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
        
        showActivityView = NO;
        
        if(arrow==NO)
        {
            showActivityView = YES;
            
            _arrowImage.hidden = YES;
        }
		
		[self setState:EGOOPullRefreshNormal];
    }
    return self;
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate 
{	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) 
    {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:NSLocalizedString(@"AM", nil)];
		[formatter setPMSymbol:NSLocalizedString(@"PM", nil)];
		[formatter setDateFormat:@"yyyy/MM/dd hh:mm"];
        NSString* lastUpdatedStr = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
		_lastUpdatedLabel.text = NSLocalizedString(lastUpdatedStr, nil);
        
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefres"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[formatter release];
	}
    else 
    {
		_lastUpdatedLabel.text = nil;
	}
}

- (void)setState:(EGOPullRefreshState)aState
{
	switch (aState) 
    {
		case EGOOPullRefreshPulling:
        {
			_statusLabel.text = NSLocalizedString(_stateStr, nil);
            //@"Release to refresh...", @"Release to refresh status"
            //@"松开即可更新...", @"松开即可更新..."
//			[CATransaction begin];
//			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            //沿着z轴旋转
			//_arrowImage.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            //CATransform3DMakeRotation(弧度,x,y,z)
			//[CATransaction commit];
            
			break;
        }
            
		case EGOOPullRefreshNormal:
        {
			if (_state == EGOOPullRefreshPulling) 
            {
//				[CATransaction begin];
//				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
//                //还原
//				_arrowImage.layer.transform = CATransform3DIdentity;
//				[CATransaction commit];
			}
            
			//括号里第一个参数是要显示的内容,与各Localizable.strings中的id对应
            //第二个是对第一个参数的注释,一般可以为空串
			_statusLabel.text = NSLocalizedString(_beginStr, nil);
            //@"Pull down to refresh...", @"Pull down to refresh status"
            //@"上拉即可更新...", @"上拉即可更新..."
            
            if(showActivityView==YES)
            {
                [_activityView stopAnimating];
            }
            
            [_arrowImage stopAnimating];
            
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
//			_arrowImage.hidden = NO;
//			_arrowImage.layer.transform = CATransform3DIdentity;
//			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
        }
            
		case EGOOPullRefreshLoading:
        {
			_statusLabel.text = NSLocalizedString(_endStr, nil);
            //@"Loading...", @"Loading Status"
            //@"加载中...", @"加载中..."
            
            if(showActivityView==YES)
            {
                [_activityView startAnimating];
            }
            
            [_arrowImage startAnimating];
            
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
//			_arrowImage.hidden = YES;
//			[CATransaction commit];
			
			break;
        }
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView 
{
    if(scrollView.contentOffset.y>-65 && scrollView.contentOffset.y<0)
    {
        float _height = self.frame.size.height;
        
        if(_height==370)
        {
            _arrowImage.frame = CGRectMake(230, _height+scrollView.contentOffset.y, 90*0.7, 100*0.7);

        }
        else
        {
            _arrowImage.frame = CGRectMake(230, _height+scrollView.contentOffset.y, 90*0.7, 100*0.7);
        }
    }

	if (_state == EGOOPullRefreshLoading)
    {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 65);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
	} 
    else if (scrollView.isDragging) 
    {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) 
        {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) 
        {
			[self setState:EGOOPullRefreshNormal];
		} 
        else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) 
        {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) 
        {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView 
{
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) 
    {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) 
    {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) 
        {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}
//
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView 
{	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
