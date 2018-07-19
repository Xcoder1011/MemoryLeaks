//
//  BaseViewController.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/8.
//  Copyright © 2017年 animation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

/**
 *  Screen's width.
 */
@property (nonatomic , assign) CGFloat  width;

/**
 *  Screen's height.
 */
@property (nonatomic , assign) CGFloat  height;

/**
 *  Navigation height.
 */
@property (nonatomic , assign) CGFloat  titleViewHeight;


/**
 *  Base config.
 */
- (void)setup;

@end


@interface UIViewController (InteractivePopGestureRecognizer)

/**
 *  enable full screen PopGestureRecognizer
 */
@property (nonatomic, assign) BOOL enalbleFullScreenInteractivePopGestureRecognizer;

/**
 *  nav.childViewControllers.count > 1, shouldShowPopBackBtn = YES
 */
@property (nonatomic, assign) BOOL shouldShowPopBackBtn;

@end
