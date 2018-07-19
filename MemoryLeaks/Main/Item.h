//
//  Item.h
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id        object;

+ (Item *)itemWithName:(NSString *)name object:(id)object;
@end
