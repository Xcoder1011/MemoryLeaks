//
//  DelegateLeakController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "DelegateLeakController.h"
#import "Item.h"
#import "NSObject+MemoryLeak.h"

@interface DelegateLeakController () <StudentDelegate>

@property (nonatomic, strong) Student *stu;

@end

@implementation DelegateLeakController

- (void)setup {
    
    [super setup];
    
    Student *stu1 = [[Student alloc] init];
    stu1.delegate = self;
    _stu = stu1;
    
    
    /*
     
    self 强引用 stu，
     
    而stu的delegate 属性指向 self，
     
    delegate是用strong修饰的, 所以 stu 也会强引用 self
     
     */
}

- (BOOL)willDealloc {
    
    if (![super willDealloc]) {
        return NO;
    }
    MLCheck(self.viewModel);
    return YES;
}


@end


/*
 
 一般在声明delegate的时候都要使用弱引用weak或者assign
 
 MRC的话只能用assign，在ARC的情况下最好使用weak
 
 因为weak修饰的变量在释放后自动为指向nil，防止不安全的野指针存在
 
 */
