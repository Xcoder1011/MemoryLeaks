//
//  TimerLeakViewController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "TimerLeakViewController.h"
#import "SKTimer.h"

@interface TimerLeakViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) SKTimer *timer1;

@end

@implementation TimerLeakViewController

- (void)setup {
    
    [super setup];
    
    // NSTimer
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAct) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    // 改进的timer
    
    //_timer1 = [SKTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAct) userInfo:nil repeats:YES];
}

- (void)timerAct {
    
    NSLog(@"timer running....");
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}


//- (void)viewWillDisappear:(BOOL)animated {
//
//    [super viewWillDisappear:animated];
//    [self.timer invalidate];
//    self.timer = nil;
//}


/*
 
 Timer 添加到 Runloop 的时候，会被 Runloop 强引用。当前viewController对timer强引用
 
 因为 target:self ，也就是target引用了当前viewController，导致控制器的引用计数加1，而Timer又会有一个对 Target 的强引用。
 
 如果没有将这个NSTimer 销毁，它将一直保留该viewController，无法释放，也就不会调用dealloc方法。
 
 需要在viewWillDisappear之前需要把控制器用到的NSTimer销毁
 
 注意： repeats:NO 不会引起内存泄漏
 
 */

@end
