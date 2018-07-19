//
//  BaseContentViewController.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/8.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseContentViewController : BaseViewController

//  titleView           (0, 0, width, 64) 

//  contentView         (0, 64, width, height - 64)

//  backgroundView      (0, 0, width, height)

@property (nonatomic , strong) UIView   *titleView;
@property (nonatomic , strong) UIView   *contentView;
@property (nonatomic , strong) UIView   *backgroundView;


/**
 *  overwrite by subclass
 */
- (void)setupTitleView;

/**
 *  overwrite by subclass
 */
- (void)setupContentView;

/**
 *  overwrite by subclass
 */
- (void)setupBackgroundView;


/**
 *  设置导航条的leftiterm
 */
- (void)setNavLeftItemWith:(NSString *)str andImage:(UIImage *)image;

/**
 *  设置导航的rightitem
 */
- (void)setNavRightItemWith:(NSString *)str andImage:(UIImage *)image;

- (void)rightItemClick:(id)sender;

- (void)leftItemClick:(id)sender;
@end
