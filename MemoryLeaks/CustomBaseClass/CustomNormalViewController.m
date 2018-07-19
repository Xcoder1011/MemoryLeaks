//
//  CustomNormalViewController.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/9.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "CustomNormalViewController.h"

@interface CustomNormalViewController ()

@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@property (strong, nonatomic) NSArray *colors;

@end

@implementation CustomNormalViewController


/**
 *  setup custom titleview
 */
- (void)setupTitleView {
    
    [super setupTitleView];
    
    // Title label.
    UILabel *titleLabel      = [UILabel new];
    titleLabel.font          = [UIFont fontWithName:@"DFPShaoNvW5-GB" size:20.f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor     = [UIColor whiteColor];
    titleLabel.text          =  self.title;
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(self.titleView.frame.size.width / 2.0, self.titleView.frame.size.height / 2.0 + 10);
    if (iPhoneX) {
        titleLabel.center = CGPointMake(self.titleView.frame.size.width / 2.0,
                                        self.titleView.frame.size.height / 2.0 + 20);
    }
    [self.titleView addSubview:titleLabel];
    
    // Bottom line
    UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, self.titleView.frame.size.width, 0.5f)];
    line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25f];
    [self.titleView addSubview:line];
    
    // Back btn
    if (self.shouldShowPopBackBtn) {
        UIImage *image =  [UIImage imageNamed:@"back_icon"];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, image.size.width/2, image.size.height/2);
        [backBtn setImage:image forState:UIControlStateNormal];
        [backBtn setCenter:CGPointMake(20, titleLabel.center.y)];
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:backBtn];
    }
    
    // GradientLayer
    [self.titleView.layer insertSublayer:self.gradientLayer atIndex:0];
    
}

- (void)backBtnClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupContentView {
    
    [super setupContentView];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}


#pragma mark --- Lazy loading

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [[CAGradientLayer alloc] init];
        _gradientLayer.frame = self.titleView.bounds;
        _gradientLayer.colors = self.colors[0];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    }
    return _gradientLayer;
}

- (NSArray *)colors {
    
    if (!_colors) {
        _colors = @[
                    @[(__bridge id)[UIColor colorWithHexString:@"#ff5a5f" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#ff5986" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#FFAFBD" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#ffc3a0" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#56ab2f" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#a8e063" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#EECDA3" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#EF629F" alpha:1.0].CGColor],
                    
                    @[(__bridge id)[UIColor colorWithHexString:@"#00c6ff" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#0072ff" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#DA22FF" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#9733EE" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#B993D6" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#8CA6DB" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#fc00ff" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#00dbde" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#E55D87" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#5FC3E4" alpha:1.0].CGColor],
                    @[(__bridge id)[UIColor colorWithHexString:@"#FF5F6D" alpha:1.0].CGColor, (__bridge id)[UIColor colorWithHexString:@"#FFC371" alpha:1.0].CGColor]
                    ];
    }
    return _colors;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
