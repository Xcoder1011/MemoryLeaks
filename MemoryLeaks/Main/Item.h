//
//  Item.h
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Student;

@protocol StudentDelegate <NSObject>

@optional

- (void)student:(Student *)stu event:(id)eventData;
@end

@interface Student : NSObject

@property (nonatomic , weak) id <StudentDelegate> delegate;

@end



@interface Item : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id        object;

+ (Item *)itemWithName:(NSString *)name object:(id)object;
@end





