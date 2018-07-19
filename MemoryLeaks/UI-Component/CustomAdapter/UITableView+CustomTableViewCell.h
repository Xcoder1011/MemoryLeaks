//
//  UITableView+CustomTableViewCell.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellAdapter;
@class CustomTableViewCell;
@interface UITableView (CustomTableViewCell)


- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                 indexPath:(NSIndexPath *)indexPath
                                                                controller:(UIViewController *)controller;

- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                 indexPath:(NSIndexPath *)indexPath;

@end
