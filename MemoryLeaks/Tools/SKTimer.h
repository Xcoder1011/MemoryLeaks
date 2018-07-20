//
//  SKTimer.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/4/19.
//  Copyright © 2017年 animation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKTimer : NSObject

typedef void(^TimerBlock)(SKTimer *timer);

/** 时间精度（误差，秒）*/
@property (copy) NSDate *fireDate;
/** 时间间隔（秒）*/
@property (readonly) NSTimeInterval timeInterval;
/** 时间精度（误差，秒）*/
@property (nonatomic , assign) NSTimeInterval tolerance;

/**
 * GCD Timer
 */
+ (SKTimer *)scheduledDispatchTimerWithTimeInterval:(NSTimeInterval)ti
                                             target:(id)aTarget
                                           selector:(SEL)aSelector
                                           userInfo:(nullable id)userInfo
                                            repeats:(BOOL)yesOrNo
                                      dispatchQueue:(nullable dispatch_queue_t)dispatchQueue;

/**
 * GCD Timer block
 */
+ (SKTimer *)scheduledDispatchTimerWithTimeInterval:(NSTimeInterval)ti
                                           userInfo:(nullable id)userInfo
                                            repeats:(BOOL)yesOrNo
                                      dispatchQueue:(nullable dispatch_queue_t)dispatchQueue
                                              block:(TimerBlock)block;


/**
 * NSTimer 需要调用fire方法手动开启
 */
+ (SKTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                            target:(id)aTarget
                          selector:(SEL)aSelector
                          userInfo:(nullable id)userInfo
                           repeats:(BOOL)yesOrNo;

/**
 * NSTimer 自动开启
 */
+ (SKTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(nullable id)userInfo
                                    repeats:(BOOL)yesOrNo;

// __attribute((deprecated("推荐使用GCD Timer")))
/**
 * 开启
 */
- (void)fire;

/**
 * 停止
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
