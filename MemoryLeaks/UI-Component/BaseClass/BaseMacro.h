//
//  BaseMacro.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/5/5.
//  Copyright © 2017年 animation. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <pthread.h>

#ifndef BaseMacro_h
#define BaseMacro_h


#ifdef DEBUG
#    define NSLog(...) NSLog(__VA_ARGS__)
#else
#    define NSLog(...) {}
#endif

#ifdef DEBUG
#   define DDLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#   define DDLog(...) do { } while (0)
#endif


#ifndef kWeakObj
    #if __has_feature(objc_arc)
    #define kWeakObj(obj)  __weak typeof(obj)  weak##obj = obj;
    #else
    #define kWeakObj(obj)  __block typeof(obj)  block##obj = obj;
    #endif
#endif

#ifndef kStrongObj
    #if __has_feature(objc_arc)
    #define kStrongObj(obj) __strong __typeof(obj)  obj = weak##obj;
    #else
    #define kStrongObj(obj)  __typeof(obj)  obj = block##obj;
    #endif
#endif





#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif



/**
 *  UIScreen width.
 */
#define  kDeviceWidth   [UIScreen mainScreen].bounds.size.width

/**
 *  UIScreen height.
 */
#define  kDeviceHeight  [UIScreen mainScreen].bounds.size.height

/**
 *  iPhoneX
 */
#define  iPhoneX        (kDeviceWidth == 375.f && kDeviceHeight == 812.f ? YES : NO)


static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

static inline void dispatch_async_on_main_queue(void(^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void dispatch_sync_on_main_queue(void(^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


static inline void dispatch_async_on_global_queue(void(^block)()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

static inline void dispatch_async_on_globalqueue_then_on_mainqueue(void(^globalblock)(),void(^mainblock)()){
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         globalblock();
         dispatch_async_on_main_queue(mainblock);
     });

}



#endif /* BaseMacro_h */
