//
//  SKEmitterLayer.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/21.
//  Copyright © 2017年 animation. All rights reserved.
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <QuartzCore/QuartzCore.h>
NS_ASSUME_NONNULL_BEGIN

@class SKEmitterCell;
@class SKEmitterLayer;

@protocol SKEmitterLayerDelegate <NSObject>

- (void)emitterLayerDidRemoveFromSuperView:(SKEmitterLayer *)emitter;
@end

@interface SKEmitterLayer : CALayer

@property (nonatomic ,nonnull, strong) UIImage *emitterImage;
@property (nonatomic ,nullable, strong) id cellContents;
@property (nonatomic ,nullable, weak) id <SKEmitterLayerDelegate> emitterDelegate;

@property CGPoint startPosition;
@property CGPoint emitterImagePosition;

/*每个粒子的生命周期 */
@property float   lifetime;

/*值越大，发出的粒子数越多 ，取值范围[0 , 1] */
@property float   emittersCountRate;   // [0 , 1]

/* 旋转角 Defaults to zeroe **/
@property CGFloat rotateAngle;
@property CGFloat rotateRange;

/* 动画结束是否 remove **/
@property (nonatomic ,assign)  BOOL removedOnCompletion;

/* 延迟多少秒remove , default 2.0 **/
@property (nonatomic ,assign)  NSInteger delayRemoveTime;

/* 粒子大小 , default CGSizeMake(1.8, 1.8) **/
@property (nonatomic ,assign)  CGSize cellSize;

@property (nonatomic ,assign)  BOOL ignoredBlack;
@property (nonatomic ,assign)  BOOL ignoredWhite;

- (void)animate;

@end

NS_ASSUME_NONNULL_END
