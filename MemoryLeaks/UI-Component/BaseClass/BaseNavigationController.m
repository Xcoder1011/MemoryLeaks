//
//  BaseNavigationController.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/9.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "BaseNavigationController.h"
#import "BaseViewController.h"

@interface BaseNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController navigationBarHidden:(BOOL)hidden {

    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:rootViewController];
    [nav setNavigationBarHidden:hidden];
    nav.navigationController.interactivePopGestureRecognizer.delegate = self;
    return nav;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.childViewControllers.count >= 1) {
        viewController.shouldShowPopBackBtn = YES;
        viewController.hidesBottomBarWhenPushed = YES; // 隐藏底部的工具条
    }
    [super pushViewController:viewController animated:animated];
}


/**
 *  拦截手势触发
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.childViewControllers.count <= 1) {
        return NO;
    }
    
    UIViewController *topViewController = self.topViewController;
    if (!topViewController.enalbleFullScreenInteractivePopGestureRecognizer) {
        return NO;
    }
    
    // 导航控制器当前处于转换状态时忽略平移手势。
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    
    return self.topViewController;
}

- (void)dealloc {
    
#ifdef DEBUG
    
   // printf("######## Did released the %s .\n", NSStringFromClass(self.class).UTF8String);
    
#endif
}

@end


