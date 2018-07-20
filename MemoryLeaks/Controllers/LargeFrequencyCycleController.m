//
//  LargeFrequencyCycleController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/20.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "LargeFrequencyCycleController.h"

@interface LargeFrequencyCycleController ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation LargeFrequencyCycleController


- (void)setup {
    
    [super setup];
 
    self.array = [NSMutableArray new];
    
    // 试着不断点击Test按钮，去查看内存占用
    
    [self setNavRightItemWith:@"Test" andImage:nil];

}

- (void)rightItemClick:(id)sender {
    
    int i = 0;
    while (i < 100000) {
        [self.array addObject:[[NSObject alloc] init]];
        ++i;
    }
}


@end
