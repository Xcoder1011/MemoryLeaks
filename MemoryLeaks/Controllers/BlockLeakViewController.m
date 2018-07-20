//
//  BlockLeakViewController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "BlockLeakViewController.h"

typedef void(^Block2)(void);

@interface BlockLeakViewController ()

@property (nonatomic, copy) dispatch_block_t block;

@property (nonatomic, copy) void (^block1)(void);

@property (nonatomic, copy) Block2 block2;

@end

@implementation BlockLeakViewController

- (void)setup {
    
    [super setup];
    
    [self setNavRightItemWith:@"Test" andImage:nil];
}

- (void)rightItemClick:(id)sender {
    
    [self simpleBlockTest];
    
    //[self notSimpleWeakTest];
    
    //[self strongselfTest];
    
    //[self weakify_strongify_Test];

}

/*
 * self持有block，而堆上的block又会持有self，所以会导致循环引用
 */
- (void)simpleBlockTest {
    
    __weak typeof(self) weakSelf = self;

    self.block = ^{
        weakSelf.contentView.backgroundColor = [UIColor blueColor];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.block();
    });
}



/*
 * weakself的缺陷，可能会导致内存提前回收
 */
- (void)notSimpleWeakTest {
    
    __weak typeof(self) weakSelf = self;
    
    self.title = @"weakself的缺陷";
    
    self.block = ^{
        
        weakSelf.contentView.backgroundColor = [UIColor blueColor];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            weakSelf.title = @"10秒后weakself的缺陷";
            NSLog(@"++++++++++++++++ title is %@",weakSelf.title);
        });
    };
    
    self.block();
}


/*
 * strongself的用处
 */
- (void)strongselfTest {
    
    __weak typeof(self) weakSelf = self;

    self.title = @"strongself的用处";
    
    self.block = ^{
        
        //[weakSelf doSomething];
        
        // __strong __typeof在编译的时候,实际是对weakSelf的强引用， 指针连带关系self的引用计数还会增加
        __strong typeof(self) strongSelf = weakSelf;

        strongSelf.contentView.backgroundColor = [UIColor blueColor];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (strongSelf) {
                strongSelf.title = @"10秒后strongself的用处";
                NSLog(@"++++++++++++++++ title is %@",strongSelf.title);
                // strongSelf的 生命周期也只在当前block的作用域.
                // 当这个block结束, strongSelf随之也就被释放了
                // 当发现可能的内存泄漏对象并给出 alert 之后，MLeaksFinder 会进一步地追踪该对象的生命周期，并在该对象释放时给出 Object Deallocated 的 alert。
            }
        });
    };
    
    self.block();
    
    /*
     这么做和直接用self有什么区别，为什么不会有循环引用：外部的weakSelf是为了打破环，从而使得没有循环引用，
     
     而内部的strongSelf仅仅是个局部变量，存在栈中，会在block执行结束后回收，不会再造成循环引用。
     
     这里的strongSelf会使 BlockLeakViewController 的对象引用计数＋1，使得BlockLeakViewController pop到 上个controller 的时候，并不会执行dealloc，因为引用计数还不为0，
     
     strongSelf仍持有BlockLeakViewController，而在block执行完，局部的strongSelf才会回收，此时BlockLeakViewController dealloc。
     
     weakSelf和self是两个内容,doSomething有可能就直接对self自身引用计数减到0了，self可能会被释放了.
     
     问题1. block内部必须使用strongSelf，不如直接使用self简便。
     
     问题2. 很容易在block内部不小心使用了self，这样还是会引起循环引用，这种错误很难发觉。
     
     AFN 或者 SDWebImage 都有用到此种写法
     
     */
}


/*
 *  @weakify的用处
 */
- (void)weakify_strongify_Test {
    
    
    @weakify(self)
    
    self.title = @"weakify_strongify";
    
    self.block = ^{
        
        @strongify(self)
        
        self.contentView.backgroundColor = [UIColor blueColor];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self) {
                self.title = @"10秒后weakify_strongify";
                NSLog(@"++++++++++++++++ title is %@",self.title);
                // 可以在block中随意使用self。
            }
        });
    };
    
    self.block();
}

@end


