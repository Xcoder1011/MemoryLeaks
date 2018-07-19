//
//  CustomFullViewController.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "CustomFullViewController.h"

@interface CustomFullViewController ()

@end

@implementation CustomFullViewController

/**
 *  setup custom titleview
 */
- (void)setupTitleView {
    
    [super setupTitleView];
    
    // Title label.
    UILabel *titleLabel      = [UILabel new];
    titleLabel.font          = [UIFont fontWithName:@"DFPShaoNvW5-GB" size:20.f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor     = [UIColor blackColor];
    titleLabel.text          =  self.title;
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(self.titleView.frame.size.width / 2.0, self.titleView.frame.size.height / 2.0 + 10);
    [self.titleView addSubview:titleLabel];
    
    // Bottom line
    UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, self.titleView.frame.size.width, 0.5f)];
    line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25f];
    // [self.titleView addSubview:line];
    
    // Back btn
    if (self.shouldShowPopBackBtn) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 60, 40);
        [backBtn setImage:[UIImage imageNamed:@"back_btn_"] forState:UIControlStateNormal];
        [backBtn setCenter:CGPointMake(20, self.titleView.frame.size.height/2.0 + 10)];
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:backBtn];
    }
    
    self.titleView.backgroundColor = [UIColor whiteColor];

}

- (void)setupContentView {
    
    [super setupContentView];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)backBtnClick {

    [self.navigationController popViewControllerAnimated:YES];
}


@end
