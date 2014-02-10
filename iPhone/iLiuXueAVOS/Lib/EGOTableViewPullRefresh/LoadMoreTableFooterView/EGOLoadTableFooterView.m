//
//  EGOLoadTableFooterView.m
//  Demo
//
//


#define  loadViewHight 65.0f

#import "EGOLoadTableFooterView.h"
//#import "FMDatabase.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGOLoadTableFooterView (Private)
- (void)setState:(EGOPullLoadState)aState;
@end

@implementation EGOLoadTableFooterView
@synthesize curFont10, curFont12, curFont15, curFont20;
@synthesize delegate=_delegate;
@synthesize activityView=_activityView;


- (id)initWithFrame:(CGRect)frame  
{
    return [self initWithFrame:frame arrowImageName:@"blackArrow.png" textColor:TEXT_COLOR];
}

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor
{
    self = [super initWithFrame: frame];
    if (self) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, loadViewHight - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = curFont12;
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, loadViewHight - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = curFont12;
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, loadViewHight - loadViewHight, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) 
        {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, loadViewHight - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		[self setState:EGOOPullLoadNormal];
    }
    return self;
}


#pragma mark -
#pragma mark Setters

- (void)loadLastUpdatedDate 
{
	if ([_delegate respondsToSelector:@selector(egoLoadTableFooterDataSourceLastUpdated:)]) 
    {
		NSDate *date = [_delegate egoLoadTableFooterDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:NSLocalizedString(@"AM", nil)];
		[formatter setPMSymbol:NSLocalizedString(@"PM", nil)];
		[formatter setDateFormat:@"yyyy/MM/dd hh:mm"];
        NSString* lastUpdatedStr = [NSString stringWithFormat:@"更新时间: %@", [formatter stringFromDate:date]];
		_lastUpdatedLabel.text = NSLocalizedString(lastUpdatedStr, nil);
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:14];

		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGOLoadTableView_LastLoad"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[formatter release];
	} 
    else 
    {
		_lastUpdatedLabel.text = nil;
	}
}

- (void)setState:(EGOPullLoadState)aState
{
	
	switch (aState) 
    {
		case EGOOPullLoadPulling:
			
			_statusLabel.text = NSLocalizedString(@"松开即可更新...", nil);
            _statusLabel.font = [UIFont systemFontOfSize:14];
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullLoadNormal:
			
			if (_state == EGOOPullLoadPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"加载更多...", nil);
            _statusLabel.font = [UIFont systemFontOfSize:14];
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self loadLastUpdatedDate];
			
			break;
		case EGOOPullLoadLoading:
			
			_statusLabel.text = NSLocalizedString(@"加载中...", nil);
            _statusLabel.font = [UIFont systemFontOfSize:14];
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

//手指屏幕上不断拖动调用此方法
- (void)egoLoadScrollViewDidScroll:(UIScrollView *)scrollView 
{		
	if (_state == EGOOPullLoadLoading) 
    {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, loadViewHight, 0.0f);
	} 
    else if (scrollView.isDragging) 
    {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoLoadTableFooterDataSourceIsLoading:)]) {
			_loading = [_delegate egoLoadTableFooterDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullLoadPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + loadViewHight && scrollView.contentOffset.y > 0.0f && !_loading) 
        {
			[self setState:EGOOPullLoadNormal];
		} 
        else if (_state == EGOOPullLoadNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + loadViewHight  && !_loading) 
        {
			[self setState:EGOOPullLoadPulling];
		}
		
		if (scrollView.contentInset.bottom != 0) 
        {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)egoLoadScrollViewDidEndDragging:(UIScrollView *)scrollView 
{	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoLoadTableFooterDataSourceIsLoading:)]) 
    {
		_loading = [_delegate egoLoadTableFooterDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + loadViewHight && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoLoadTableFooterDidTriggerLoad:)]) {
			[_delegate egoLoadTableFooterDidTriggerLoad:self];
		}
		
		[self setState:EGOOPullLoadLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, loadViewHight, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

//当开发者页面刷新完毕调用此方法，[delegate egoLoadScrollViewDataSourceDidFinishedLoading: scrollView];
- (void)egoLoadScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	[self setState:EGOOPullLoadNormal];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    self.curFont10 = nil;
    self.curFont12 = nil;
    self.curFont15 = nil;
    self.curFont20 = nil;
    [super dealloc];
}


@end
