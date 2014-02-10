//
//  MLNavigationController.h
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MLNavigationAnimationType)
{
    MLNavigationAnimationTypeOfNone = 0,
    MLNavigationAnimationTypeOfScale = 1
};

@interface MLNavigationController : UINavigationController
{
    //MLNavigationAnimationType _animationType;
    
    

}
// Enable the drag to back interaction, Defalt is YES.
@property (nonatomic,assign) BOOL canDragBack;
//@property (nonatomic,assign) MLNavigationAnimationType animationType;
@property(nonatomic,retain)NSMutableArray *operationType;

- (void)pushViewController:(UIViewController *)viewController AnimatedType:(MLNavigationAnimationType)animatedType;

- (void)popViewControllerAnimated;

@end


@interface UINavigationController (MLNavigationController)

- (void)pushViewController:(UIViewController *)viewController AnimatedType:(MLNavigationAnimationType)animatedType;

- (void)popViewControllerAnimated;

@end