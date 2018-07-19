//
//  UITableView+CustomTableViewCell.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"

@class CellAdapter;

@interface UITableView (CustomTableViewCell)

- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                 indexPath:(NSIndexPath *)indexPath
                                                                controller:(UIViewController *)controller;

- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                 indexPath:(NSIndexPath *)indexPath;

- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                  delegate:(id <CustomTableViewCellDelegate>)delegate
                                                                 indexPath:(NSIndexPath *)indexPath ;


@end
