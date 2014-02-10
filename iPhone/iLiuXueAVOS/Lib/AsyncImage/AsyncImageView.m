//
//  AsyncImageView.M
//  Musiline
//
//  Created by fuacici on 10-5-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AsyncImageView.h"
#import "CHAvatarView.h"


//设置默认图
static const NSString * gDefaultImages[]=
{
	@"默认头像.png",@"_0000_bg"
};
#define SPINNY_TAG 5555

@implementation AsyncImageView
@synthesize  urlString; 
@synthesize defaultImage;
@synthesize manager;
@synthesize selectedRow;
@synthesize selectedSection;
@synthesize isImage;
@synthesize autoImage;
@synthesize imageViewBorderWidth;
@synthesize imageViewBorderColor;
@synthesize imageViewCornerRadius;
@synthesize imageViewMasksToBounds;
@synthesize imageState;
@synthesize userCache;
@synthesize downimage = _downimage;

- (id)initWithFrame:(CGRect)frame ImageState:(int)state
{
	if (self = [super initWithFrame:frame]) 
	{
        self.imageState = state;
        
        if(self.imageState==0)
        {
            self.backgroundColor = [UIColor clearColor];
        }
        if(self.imageState==1)
        {
            self.backgroundColor = [UIColor whiteColor];
        }
		self.manager = [ImageManager sharedImageManager];
        
        self.userCache = YES;
	}
    return self;
}
- (void)awakeFromNib
{
	[super awakeFromNib];
	self.manager = [ImageManager sharedImageManager];
}
- (void) setUrlString:(NSString *) theUrl
{
	if ([urlString isEqualToString: theUrl ]) 
	{
		return;
	}
	[manager removeTarget: self forUrl: urlString];
	[urlString release];
	urlString = nil;
	[self imageDidLoaded: nil animate: NO];
	if (nil == theUrl) 
	{
		
		return;
	}
	urlString = [theUrl retain];
	if (nil == theUrl) 
	{
		
		return;
	}
	// setup the spiner
	UIActivityIndicatorView *spinny = (UIActivityIndicatorView *) [self viewWithTag: SPINNY_TAG];
	
	if (nil == spinny) 
	{
		spinny = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]autorelease];
	}
	
	spinny.tag = SPINNY_TAG;
	spinny.center = CGPointMake(self.center.x -self.frame.origin.x, self.center.y- self.frame.origin.y);
	[spinny startAnimating];
	[self addSubview:spinny];
	[manager addTaskWithURLString: urlString withDelegate: self UseCache:self.userCache];
	
}



- (void)dealloc 
{
    [_indexPath release]; _indexPath=nil;
    self.downimage = nil;
	[manager removeTarget: self forUrl: urlString];
	self.manager = nil;
	self.urlString = nil;
    
	[super dealloc];
}

- (void)setImage:(UIImage*) theImage animate: (BOOL) animate
{
	//remove the spinner first
    
    UIView * _spinny = [self viewWithTag:SPINNY_TAG];
	[_spinny removeFromSuperview];
    
    if(theImage==nil)
    {
        return;
    }
    
	
	if (autoImage==YES)
    {
        if (autoImageView)
        {
            [autoImageView removeFromSuperview];
            autoImageView=nil;
        }
        
        autoImageView = [[UIImageView alloc] initWithImage:theImage];
        autoImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        autoImageView.contentMode = UIViewContentModeScaleAspectFill;
        autoImageView.clipsToBounds = YES;
        [self addSubview:autoImageView];
        [autoImageView release];
        
        
        return;
				
		
//		if (theImage.size.width<=250&&theImage.size.height<300) {
//			self.bounds=CGRectMake(self.frame.origin.x, self.frame.origin.y, theImage.size.width, theImage.size.height);
//		}else if (theImage.size.width>250) {
//			self.bounds=CGRectMake(self.frame.origin.x, self.frame.origin.y, 250, 250*(theImage.size.height/theImage.size.width));
//		}else if (theImage.size.height>300) {
//			self.bounds=CGRectMake(self.frame.origin.x, self.frame.origin.y, 300*(theImage.size.width/theImage.size.height), 300);
//		}
//		
//		CGAffineTransform  affineTransform1=CGAffineTransformMakeScale(0.1, 0.1);
//		CGAffineTransform  affineTransform2=CGAffineTransformMakeScale(1, 1);
//
//		[self setTransform:affineTransform1];
//		[UIView beginAnimations:@"zfAnimations" context:nil];
//		[UIView setAnimationDuration:0.5];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//		[self setTransform:affineTransform2];
//		[UIView commitAnimations];
		
	}
	
	
	//set the image
    
  
    if (isImage==NO)
    {
        self.downimage = theImage;
    }
    
    //显示为圆形图
    if(self.imageState==0)
    {
        
        if(chavatarView==nil)
        {
            chavatarView  = [[CHAvatarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            chavatarView.image = theImage;
            chavatarView.userInteractionEnabled = NO;
            chavatarView.backgroundColor = [UIColor clearColor];
            [self addSubview:chavatarView];
            [chavatarView release];
        }
        else
        {
            chavatarView.image = theImage;
            [chavatarView setNeedsDisplay];
        }
        
        
    }
    //显示为原始形态
    if(self.imageState==1)
    {
        [self setImage:theImage forState:UIControlStateNormal];
    }
	
//    if (animate)
//    {
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        animation.fromValue = [NSNumber numberWithFloat:0.0f];
//        animation.toValue = [NSNumber numberWithFloat:1.0f];
//        animation.duration = 0.5f;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        [self.layer addAnimation: animation forKey: @"FadeIn"];
//    }
	
	[self setNeedsLayout];
}
- (void)setImage:(UIImage*) theImage
{
    
	[self setImage:theImage animate: NO];
}


- (UIImage*)image
{
    UIImageView* iv = imageView;
    return [iv image];
}


//代理方法，调用urlString的set方法时会执行，完成图片的设置。。。。
-(void)imageDidLoaded:(UIImage*)theImage animate:(BOOL) animate
{
	isImage = NO;
	
	if (nil == theImage)
	{
        
		[self setImage: [UIImage imageNamed:(NSString *) gDefaultImages[defaultImage]]];
        isImage = YES;
        
		return;
	}
	
	[self setImage:theImage animate:animate];
	
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	imageView.frame = self.bounds;
	UIActivityIndicatorView * spinny = (UIActivityIndicatorView *) [self viewWithTag: SPINNY_TAG];
	spinny.center = CGPointMake(self.center.x -self.frame.origin.x, self.center.y- self.frame.origin.y);
}

@end
