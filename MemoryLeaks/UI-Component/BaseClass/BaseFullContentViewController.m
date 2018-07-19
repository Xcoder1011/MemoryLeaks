//
//  BaseFullContentViewController.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/9.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "BaseFullContentViewController.h"

@interface BaseFullContentViewController ()

@end

@implementation BaseFullContentViewController

- (void)setup {
    
    [super setup];
    [self setupBackgroundView];
    [self setupContentView];
    [self setupTitleView];
}

- (void)removeTitleView {

    if (self.titleView) {
        [self.titleView removeFromSuperview];
    }
}

- (void)setupTitleView {
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.titleViewHeight)];
    self.titleView = titleView;
    [self.view addSubview:titleView];
}

- (void)setupContentView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.contentView = contentView;
    [self.view addSubview:contentView];
}

- (void)setupBackgroundView {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.backgroundView = backgroundView;
    [self.view addSubview:backgroundView];
}


@end
