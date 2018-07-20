//
//  SKEmitterLayer.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/21.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "SKEmitterLayer.h"
#import "SKTimer.h"

#define kOpacityDuration  2.0

@interface Particle : NSObject
@property(nonatomic, strong) UIColor* color;
@property(nonatomic, assign) CGPoint point;
@end

@implementation Particle
@end

@interface SKEmitterLayer () <CAAnimationDelegate> {
    
    NSInteger _index;
}

@property (nonatomic ,strong)  SKTimer* timer;
@property (nonatomic ,strong)  NSMutableArray* layerArray;
@property (nonatomic ,strong)  NSMutableArray* particleArray;
@end

@implementation SKEmitterLayer

#pragma mark -- Initialize

- (instancetype)init {
    
    if (self = [super init]) {
        _ignoredBlack = YES;
        _ignoredWhite = YES;
        _index = 0;
        _removedOnCompletion = YES;
        _delayRemoveTime = 1.0;
        _lifetime = 5.0;
        _cellSize = CGSizeMake(1.8, 1.8);
        _emittersCountRate = 1.0;
        _rotateAngle = 0;
        _rotateRange = 0;
    }
    return self;
}

#pragma mark -- 获取图片的像素数据

- (NSMutableArray*)getRGBAsFromImage:(UIImage*)image {
    
    //1. get the image into your data buffer.
    CGImageRef imageRef = [image CGImage];
    NSUInteger imageW = CGImageGetWidth(imageRef);
    NSUInteger imageH = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * imageW;
    unsigned char *rawData = (unsigned char*)calloc(imageH*imageW*bytesPerPixel, sizeof(unsigned char));
    NSUInteger bitsPerComponent = 8;

    CGContextRef context = CGBitmapContextCreate(rawData, imageW, imageH, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, imageW, imageH), imageRef);
    CGContextRelease(context);
    
    // 2. Now your rawData contains the image data in the RGBA8888 pixel format.
    CGFloat addY = 2 ;
    CGFloat addX = 2 ;
    NSMutableArray *result = [NSMutableArray new];
    for (int y = 0; y < imageH; y+=addY) {
        for (int x = 0; x < imageW; x+=addX) {
            NSUInteger byteIndex = bytesPerRow*y + bytesPerPixel*x;
            CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / 255.0f;
            CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / 255.0f;
            CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / 255.0f;
            CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
            
            if (alpha == 0 ||
                (_ignoredWhite && (red+green+blue >= 2.6)) ||
                (_ignoredBlack && (red+green+blue <= 0.4))) {
                // 要忽略的粒子
                continue;
            }
            
            Particle *particle = [Particle new];
            particle.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            particle.point = CGPointMake(x, y);
            [result addObject:particle];
        }
    }
    free(rawData);
    return result;
}

#pragma mark -- Private Methods

-(void)startshow{
    
    SKTimer *timer = [SKTimer scheduledDispatchTimerWithTimeInterval:0.005 target:self selector:@selector(emitterAnim) userInfo:nil repeats:YES dispatchQueue:nil];
    self.timer = timer;
}

- (void)emitterAnim {
    
    if (_index >= self.particleArray.count * _emittersCountRate) {
        [self reset];
        [self removeFromSuperlayer];
        _index = 0;
        return;
    }
    [self rocketLayerWith:(Particle *)self.particleArray[_index]];
    _index ++;
}

- (void)animate {
    
    __weak typeof(self) weakSelf = self;
    UIImage * image = [self.class imageCompressForWidthScale:self.emitterImage targetWidth:self.frame.size.width * 0.7];
    [self.class compressImageQuality:image toMaxBytes:50 withBlock:^(UIImage *resultImage) {
        weakSelf.emitterImage = image;
        dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            weakSelf.particleArray = [weakSelf getRGBAsFromImage:image];
            __strong typeof(weakSelf) self = weakSelf;
            if (self && self.particleArray.count) {
                // 洗牌
                NSLog(@"self.particleArray.count = %ld",self.particleArray.count);
                dispatch_apply([self.particleArray count], queue, ^(size_t index) {
                    NSInteger random = arc4random() % self.particleArray.count;
                    random == index ? nil : [self.particleArray exchangeObjectAtIndex:index withObjectAtIndex:random];
                });
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startshow];
                });
            }
        });
    }];
   
}

- (void)rocketLayerWith:(Particle *)particle {
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:self.startPosition];
    
    CGImageRef imageRef = [self.emitterImage CGImage];
    CGFloat imageW = CGImageGetWidth(imageRef);
    CGFloat imageH = CGImageGetHeight(imageRef);
    CGFloat rate = (CGFloat)(imageW / imageH) ;
    CGPoint particleNewpoint = CGPointMake(particle.point.x , particle.point.y);
    
    if (imageW > self.frame.size.width || imageH > self.frame.size.height) { // 宽高
        if (imageW > imageH) { //适配宽度，高度缩小
            
            CGFloat  newImageW = self.frame.size.width * (3/4.0);
            CGFloat scaleRate = imageW / newImageW ;
            imageW = newImageW;
            imageH = imageW / rate;
            particleNewpoint = CGPointMake(particle.point.x / scaleRate , particle.point.y / scaleRate);
            
        } else { //适配高度，宽度缩小
            
            CGFloat  newImageH = self.frame.size.height * (3/4.0);
            CGFloat scaleRate = imageH / newImageH ;
            imageH = newImageH;
            imageW = imageH * rate;
            particleNewpoint = CGPointMake(particle.point.x / scaleRate , particle.point.y / scaleRate);
        }
    }
    
    CGPoint picCenter = self.emitterImagePosition;
    CGSize layerSize = self.cellSize;
    // random end point
    CGPoint endPoint = CGPointMake(picCenter.x - imageW/2.0 +  particleNewpoint.x, picCenter.y - imageH/2.0 + particleNewpoint.y);
    NSInteger fuhaoX = arc4random_uniform(2) ? 1:-1;
    NSInteger fuhaoY = arc4random_uniform(2) ? 1:-1;
    CGFloat offsetY = arc4random_uniform(10);
    CGFloat offsetX = arc4random_uniform(10);
    CGPoint randomPostion = CGPointMake(endPoint.x  +  offsetX * fuhaoX , endPoint.y +offsetY * fuhaoY );
    [bezierPath addLineToPoint:randomPostion];
    [bezierPath addLineToPoint:endPoint];
    
    CALayer *shiplayer = [CALayer layer];
    if (self.cellContents) {
        shiplayer.contents = self.cellContents;
        shiplayer.backgroundColor = [[UIColor clearColor] CGColor];
    } else {
        shiplayer.backgroundColor = [particle.color CGColor];
    }
    shiplayer.position = self.startPosition;
    shiplayer.frame  = CGRectMake(endPoint.x - layerSize.width/2.0, endPoint.y - layerSize.height/2.0, layerSize.width, layerSize.height);
    [self.layerArray addObject:shiplayer];
    [self addSublayer:shiplayer];
    
    NSInteger durationTime = self.lifetime;
    
    if (_rotateRange >= 0) {
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position";
        animation.duration = durationTime;
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        // animation.delegate = self;
        animation.path = bezierPath.CGPath;
        // 让动画沿切线角度旋转
        animation.rotationMode = kCAAnimationRotateAuto;
        animation.autoreverses = NO;
        [shiplayer addAnimation:animation forKey:@"position"];
        
        // 旋转效果
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"3"];
        NSInteger fuhao = arc4random_uniform(2) ? 1:-1;
        CGFloat angle = _rotateAngle + fuhao * _rotateRange;
        rotationAnimation.toValue = @(angle);
        rotationAnimation.duration = durationTime;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[animation, rotationAnimation];
        group.duration = durationTime;
        // group.delegate = self;
        group.removedOnCompletion = YES;
        group.repeatCount = 1;
        [shiplayer addAnimation:group forKey:@"ship"];
        
    } else {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position";
        animation.duration = durationTime;
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        // animation.delegate = self;
        animation.path = bezierPath.CGPath;
        // 让动画沿切线角度旋转
        animation.rotationMode = kCAAnimationRotateAuto;
        animation.autoreverses = NO;
        [shiplayer addAnimation:animation forKey:@"position"];
    }
   
}

-(void)removeFromSuperlayer {
    
    if (self.removedOnCompletion) {
        NSInteger durationTime = _lifetime;
        CABasicAnimation * animation = [CABasicAnimation animation];
        animation.delegate = self;
        animation.keyPath = @"opacity";
        animation.fromValue = @1;
        animation.toValue = @0;
        animation.duration = kOpacityDuration;
        animation.beginTime = CACurrentMediaTime() + durationTime + _delayRemoveTime;
        animation.removedOnCompletion = true;
        [self addAnimation:animation forKey:@"opacity"];
        NSInteger removeTime =  durationTime + _delayRemoveTime + kOpacityDuration - 0.2;
        
        __weak typeof(self) weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(removeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakself.emitterDelegate && [weakself.emitterDelegate respondsToSelector:@selector(emitterLayerDidRemoveFromSuperView:)]) {
                [weakself.emitterDelegate emitterLayerDidRemoveFromSuperView:weakself];
            }
            [super removeFromSuperlayer];
        });
    }
}

-(void)reset {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark -- CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

}

#pragma mark -- 压缩图片

+ (void)compressImageQuality:(UIImage *)originImage toMaxBytes:(NSInteger)maxBytes withBlock:(void(^)(UIImage *))block {
    
    __block NSData *data = [self imageDataRepresentation:originImage];
    NSLog(@"originImage bytes = %ld",data.length/1000);
    if (data.length / 1000 < maxBytes) block(originImage);
    __block UIImage *resultImage ;
    __block CGFloat compressionQuality = 1;
    __block CGFloat max = 1;
    __block CGFloat min = 0;
    __block BOOL dbreak = NO;
    
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(6, queue, ^(size_t index) {
        if (!dbreak) {
            compressionQuality = (max + min) / 2;
            data = UIImageJPEGRepresentation(originImage, compressionQuality);
        }
        // 压缩到 （ 0.9*maxBytes  <= x <= maxBytes ) 区间最佳
        if ((data.length / 1000) > maxBytes) {
            max = compressionQuality;
        } else if ((data.length / 1000) < 0.9 * maxBytes) {
            min = compressionQuality;
        } else { // 最佳区间内
            dbreak = YES;
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        resultImage = [UIImage imageWithData:data];
        if (resultImage) {
            block(resultImage);
        }
        NSLog(@"resultImage data bytes = %ld",data.length/1000);
    });
}

+ (NSData *)imageDataRepresentation:(UIImage *)image {
    
    NSData *data = nil;
    CGImageRef imageRef = image.CGImage ? (CGImageRef)CFRetain(image.CGImage) : nil;
    if (imageRef) {
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        @autoreleasepool {
            UIImage *newImage = [UIImage imageWithCGImage:imageRef];
            if (newImage) {
                if (hasAlpha) {
                    data = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
                } else {
                    data = UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 1.0);
                }
            }
        }
        CFRelease(imageRef);
    }
    
    if (!data) {
        data = UIImagePNGRepresentation(image);
    }
    return data;
}

/**
 * 指定宽度按比例缩放
 */
+ (UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark -- setter / getter

- (void)setEmitterImage:(UIImage *)emitterImage {
    _emitterImage = emitterImage;
}

- (NSMutableArray *)particleArray {
    if (!_particleArray) {
        _particleArray = @[].mutableCopy;
    }
    return _particleArray;
}

- (NSMutableArray *)layerArray {
    if (!_layerArray) {
        _layerArray = @[].mutableCopy;
    }
    return _layerArray;
}

- (void)dealloc {
    self.emitterDelegate = nil;
}



@end


