//
//  BaseFullContentViewController.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/9.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseFullContentViewController : BaseViewController

//  titleView           (0, 0, width, 64)

//  contentView         (0, 0, width, height)

//  backgroundView      (0, 0, width, height)

@property (nonatomic , strong) UIView   *titleView;
@property (nonatomic , strong) UIView   *contentView;
@property (nonatomic , strong) UIView   *backgroundView;


/**
 *  overwrite by subclass
 */
- (void)setupTitleView;

/**
 *  Remove titleView.
 */
- (void)removeTitleView;

/**
 *  overwrite by subclass
 */
- (void)setupContentView;

/**
 *  overwrite by subclass
 */
- (void)setupBackgroundView;
@end
