//
//  AppDelegate.h
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/*
一、循环引用的产生

内存中和变量有关的分区： 堆、栈、静态区

栈和静态区是操作系统自己管理的
 
我们只需要关注 堆 的内存分配 , 循环引用会导致 堆 里的内存无法正常回收

回收机制：

•    对堆里面的一个对象发送release消息来使其引用计数减一；
•    查询引用计数表，将引用计数为0的对象dealloc；
 */
@end

