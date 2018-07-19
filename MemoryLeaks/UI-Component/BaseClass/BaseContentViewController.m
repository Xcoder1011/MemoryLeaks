//
//  BaseContentViewController.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/8.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "BaseContentViewController.h"

@interface BaseContentViewController ()

@end

@implementation BaseContentViewController


- (void)setup {
    [super setup];
    [self setupBackgroundView];
    [self setupContentView];
    [self setupTitleView];
}

- (void)setupTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.titleViewHeight)];
    self.titleView = titleView;
    [self.view addSubview:titleView];
}

- (void)setupContentView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleViewHeight, self.width, self.height - self.titleViewHeight)];
    self.contentView = contentView;
    [self.view addSubview:contentView];
}

- (void)setupBackgroundView {

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.backgroundView = backgroundView;
    [self.view addSubview:backgroundView];
}



- (void)setNavLeftItemWith:(NSString *)str andImage:(UIImage *)image {
    
    CGFloat topEdges = 10;
    if (iPhoneX) {
        topEdges = 20;
    }
    if (str == nil)
    {
        [self removeTagView:1001 inSuperView:self.titleView];
        UIButton *leftbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        leftbtn.tag = 1001;
        leftbtn.centerY = self.titleView.centerY + topEdges;
        leftbtn.imageEdgeInsets =UIEdgeInsetsMake(0, -30, 0, 0);
        [leftbtn setImage:image forState:UIControlStateNormal];
        [leftbtn setContentMode:UIViewContentModeScaleAspectFit];
        [leftbtn addTarget:self action:@selector(leftItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:leftbtn];
    }
    else
    {
        [self removeTagView:1001 inSuperView:self.titleView];
        CGFloat width = [self stringWidth:str].width;
        UIButton *leftbtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, width, 44)];
        leftbtn.tag = 1001;
        leftbtn.centerY = self.titleView.centerY + topEdges;
        [leftbtn setTitle:str forState:UIControlStateNormal];
        [leftbtn addTarget:self action:@selector(leftItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:leftbtn];

    }
}

- (void)setNavRightItemWith:(NSString *)str andImage:(UIImage *)image
{
    CGFloat topEdges = 10;
    if (self.height >= 812) {
       topEdges = 20;
    }
    
    if (str == nil)
    {
        [self removeTagView:1002 inSuperView:self.titleView];
        UIButton *rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(self.titleView.frame.size.width - 60, 0, 44, 44)];
        rightbtn.tag = 1002;
        rightbtn.centerY = self.titleView.centerY + topEdges;
        rightbtn.imageEdgeInsets =UIEdgeInsetsMake(0, 0, 0, -30);
        [rightbtn setImage:image forState:UIControlStateNormal];
        [rightbtn setContentMode:UIViewContentModeScaleAspectFit];
        [rightbtn addTarget:self action:@selector(rightItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:rightbtn];
    }
    else
    {
        [self removeTagView:1002 inSuperView:self.titleView];
        CGFloat width = [self stringWidth:str].width;
        UIButton *rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(self.titleView.frame.size.width - width - 10, 0, width, 44)];
        rightbtn.tag = 1002;
        rightbtn.centerY = self.titleView.centerY + topEdges;
        [rightbtn setTitle:str forState:UIControlStateNormal];
        [rightbtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [rightbtn addTarget:self action:@selector(rightItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:rightbtn];
    }
}

- (void)removeTagView:(NSInteger)tag inSuperView:(UIView *)superView {

    for (UIView *view in self.titleView.subviews) {
        if (view.tag == 1002) {
            [view removeFromSuperview];
        }
    }
}

- (CGSize)stringWidth:(NSString *)str {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    CGSize size = [str sizeWithAttributes:attributes];
    return size;
}

- (void)leftItemClick:(id)sender{
    
}

- (void)rightItemClick:(id)sender{
}

@end
