//
//  Item.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "Item.h"

@implementation Item

+ (Item *)itemWithName:(NSString *)name object:(id)object {
    
    Item *item = [[Item alloc] init];
    item.name = name;
    item.object = object;
    return item;
}

@end
