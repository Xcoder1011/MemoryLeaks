//
//  MainListViewController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "MainListViewController.h"
#import "Item.h"
#import "MainListCell.h"
#import "TestViewController.h"

@interface MainListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableview;

@property (nonatomic , strong) NSMutableArray *adapterArray;

@property (nonatomic , assign) BOOL tableViewShouldLoad;
@end

@implementation MainListViewController


- (void)setup {
    
    self.title = @"Memory Leaks";
    
    [super setup];
    
    [self loadDataSource];
    
    [self.tableview registerClass:[MainListCell class] forCellReuseIdentifier:NSStringFromClass([MainListCell class])];
    
    [self.contentView addSubview:self.tableview];
    
    [self insertDataToTableview];
    
}

- (void)loadDataSource {
    
    NSArray * items = @[
                        [Item itemWithName:@"test" object:[TestViewController class]],
                        [Item itemWithName:@"test" object:[TestViewController class]],
                        [Item itemWithName:@"test" object:[TestViewController class]],
                        [Item itemWithName:@"test" object:[TestViewController class]],
                        [Item itemWithName:@"test" object:[TestViewController class]],
                        [Item itemWithName:@"test" object:[TestViewController class]]
                        ];
    
    for (int i = 0; i < items.count; i ++) {
        [self.adapterArray addObject:[MainListCell cellAdapterWithData:items[i] cellHeight:0]];
    }
}

-(void)insertDataToTableview {
    
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (int i = 0; i < self.adapterArray.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableViewShouldLoad = YES;
        [self.tableview insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}


#pragma mark - Lazy loading

- (NSMutableArray *)adapterArray {
    
    if (!_adapterArray) {
        _adapterArray = @[].mutableCopy;
    }
    return _adapterArray;
}

- (UITableView *)tableview {
    
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 65.f;
        
        if (@available (iOS 11.0, *)) {
            _tableview.estimatedSectionHeaderHeight=0;
            _tableview.estimatedSectionFooterHeight=0;
            _tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableview;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (UITableViewCell *)[tableView dequeueReusableCustomTableViewCellWithCellAdapter:self.adapterArray[indexPath.row] indexPath:indexPath controller:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableViewShouldLoad ? self.adapterArray.count : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [(CustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] clickEvent];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


@end
