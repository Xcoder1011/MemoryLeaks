//
//  SKTimer.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/4/19.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "SKTimer.h"
#import <objc/runtime.h>


NS_ASSUME_NONNULL_BEGIN

@interface SKTimer()

@property (nonatomic, assign)  NSTimeInterval timeInterval;
@property (nonatomic, weak  )              id target;
@property (nonatomic, strong)              id userInfo;
@property (nonatomic, assign)             SEL selector;
@property (nonatomic, assign)            BOOL repeats;
@property (nonatomic, strong)         NSTimer *timer;         // NSTimer定时器
@property (nonatomic, copy  )      TimerBlock timerBlock;

@property (nonatomic, strong)dispatch_source_t dispatchTimer; // GCD定时器
@property (nonatomic, strong) dispatch_queue_t targetSerialQueue;

@end

@implementation SKTimer


@synthesize tolerance = _tolerance;

#pragma mark - Adapter

+ (SKTimer *)scheduledDispatchTimerWithTimeInterval:(NSTimeInterval)ti
                                             target:(id)aTarget
                                           selector:(SEL)aSelector
                                           userInfo:(nullable id)userInfo
                                            repeats:(BOOL)yesOrNo
                                      dispatchQueue:(nullable dispatch_queue_t)dispatchQueue {
    
    SKTimer *timer = [[self alloc] initWithDispatchTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo dispatchQueue:dispatchQueue];
    [timer fire];
    return timer;
}

+ (SKTimer *)scheduledDispatchTimerWithTimeInterval:(NSTimeInterval)ti
                                           userInfo:(nullable id)userInfo
                                            repeats:(BOOL)yesOrNo
                                      dispatchQueue:(nullable dispatch_queue_t)dispatchQueue
                                              block:(TimerBlock)block {
    
    SKTimer *timer = [[self alloc] initWithDispatchTimeInterval:ti userInfo:userInfo repeats:yesOrNo block:block dispatchQueue:dispatchQueue];
    [timer fire];
    return timer;
    
}

+ (SKTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    SKTimer *timer = [[self alloc] initWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    return timer;
}

+ (SKTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    SKTimer *timer = [SKTimer timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    [timer fire];
    return timer;
}

#pragma mark - Initialization

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {

    if (self = [super init]) {
        
        self.timeInterval = ti;
        self.target = aTarget;
        self.selector = aSelector;
        self.repeats = yesOrNo;
        self.timer = [NSTimer timerWithTimeInterval:ti target:self selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
    }
    return self;
}

- (instancetype)initWithDispatchTimeInterval:(NSTimeInterval)ti
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(nullable id)userInfo
                                     repeats:(BOOL)yesOrNo
                               dispatchQueue:(dispatch_queue_t)dispatchQueue {
    
    if (self = [super init]) {
        
        self.timeInterval = ti;
        self.target = aTarget;
        self.selector = aSelector;
        self.repeats = yesOrNo;
        self.userInfo = userInfo;
        if (nil == dispatchQueue) {
            dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        }
        self.targetSerialQueue = dispatch_queue_create("com.sktimer.targetSerialQueue", DISPATCH_QUEUE_SERIAL);
        
        //设置targetSerialQueue和dispatchQueue的优先级一样
        dispatch_set_target_queue(self.targetSerialQueue, dispatchQueue);
        
        self.dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.targetSerialQueue);

    }
    return self;
}

- (instancetype)initWithDispatchTimeInterval:(NSTimeInterval)ti
                                    userInfo:(nullable id)userInfo
                                     repeats:(BOOL)yesOrNo
                                       block:(TimerBlock)block
                                        dispatchQueue:(nullable dispatch_queue_t)dispatchQueue {
    
    if (self = [super init]) {
        
        self.timeInterval = ti;
        self.repeats = yesOrNo;
        self.userInfo = userInfo;
        self.timerBlock = block;
        if (nil == dispatchQueue) {
            dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        }
        self.targetSerialQueue = dispatch_queue_create("com.sktimer.targetSerialQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.targetSerialQueue, dispatchQueue);
        self.dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.targetSerialQueue);
        
    }
    return self;
}

#pragma mark - Private Method

- (void)fire:(NSTimer *)timer {
    
    if (self.target && [self.target respondsToSelector:self.selector]) {
        
        [self.target performSelector:self.selector withObject:self.userInfo afterDelay:0.0f];
        
    } else if (self.timerBlock) {
        self.timerBlock(self);
        
    } else {
        [self invalidate];
    }
}


- (void)dispatchFired:(dispatch_source_t)dispatchTimer {
        
    if (self.target && [self.target respondsToSelector:self.selector]) {
        
        [self.target performSelector:self.selector withObject:self.userInfo afterDelay:0.0f];
        
    } else if (self.timerBlock) {
        self.timerBlock(self);
        
    } else {
        [self invalidate];
    }
    
    if (!self.repeats) {
        [self invalidate];
    }
}


- (void)configDispatchTimer {
    // 1.开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
    
    // 2.时间间隔
    int64_t intervalInSeconds = (int64_t)(self.timeInterval * NSEC_PER_SEC);

    // 3.误差（时间精度）
    int64_t toleranceInSeconds = (int64_t)((self.tolerance == 0 ? 0.0 : self.tolerance) * NSEC_PER_SEC);

     // 每intervalInSeconds秒执行一次 , 误差toleranceInSeconds秒
    dispatch_source_set_timer(self.dispatchTimer, start, intervalInSeconds, toleranceInSeconds);
}

#pragma mark - Common Method

- (void)fire {
    
    if (self.timer) {
        // 加入主循环池中
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
        return;
    }
    
    if(self.dispatchTimer) {
        
        [self configDispatchTimer];

        __weak typeof(self) weakSelf = self;

        dispatch_source_set_event_handler(self.dispatchTimer, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf dispatchFired:weakSelf.dispatchTimer];
            });
        });
        
        dispatch_resume(self.dispatchTimer);
    }
}

- (void)invalidate {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
        return;
    }
    
    if (self.dispatchTimer ) {
        __block dispatch_source_t timer = self.dispatchTimer;
        dispatch_async(self.targetSerialQueue, ^{
            dispatch_source_cancel(timer);
            timer = nil;
        });
    }
}

#pragma mark - Setter / Getter

- (void)setTolerance:(NSTimeInterval)tolerance {

    // @synchronized互斥锁, 线程保护  保证此时没有其它线程对self对象进行修改
    @synchronized (self) {
        if (tolerance != _tolerance) {
            _tolerance = tolerance;
            [self configDispatchTimer];
        }
    }
}

- (NSTimeInterval)tolerance {
    
    @synchronized (self) {
        return _tolerance;
    }
}

- (void)dealloc {
    [self invalidate];
}

@end

NS_ASSUME_NONNULL_END
