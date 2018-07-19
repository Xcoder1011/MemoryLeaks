//
//  MainListCell.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "MainListCell.h"
#import "Item.h"

@interface MainListCell ()

@property (nonatomic , strong) UILabel *titleLabel;

@property (nonatomic , strong) UILabel *subtitleLabel;

@end

@implementation MainListCell


- (void)configureCell {
    
    self.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupSubviews {
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width - 20, 30)];
        _titleLabel.font  = [UIFont fontWithName:@"Heiti SC" size:17.f];
    }
    return _titleLabel;
}


- (UILabel *)subtitleLabel {
    
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, self.width - 60, 15)];
        _subtitleLabel.font  = [UIFont fontWithName:@"Heiti SC" size:12.f];
        _subtitleLabel.textColor = [UIColor grayColor];
    }
    return _subtitleLabel;
}


- (void)loadContent {
    
    if (self.cellAdapter.data) {
        Item *item = self.cellAdapter.data;
        self.titleLabel.text = item.name;
        self.subtitleLabel.text = [NSString stringWithFormat:@"%@", [item.object class]];
    }
    
    if (self.indexPath.row % 2) {
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.05f];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}


- (void)clickEvent {
    
    if (self.cellAdapter.data) {
//        Item *item = self.cellAdapter.data;
//        UIViewController *controller = [[item.object class] new];
//        controller.title             = item.name;
//        [self.controller.navigationController pushViewController:controller animated:YES];
    }
}



@end
