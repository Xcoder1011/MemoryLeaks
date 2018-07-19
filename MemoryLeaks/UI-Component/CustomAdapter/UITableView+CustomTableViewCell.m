//
//  UITableView+CustomTableViewCell.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "UITableView+CustomTableViewCell.h"
#import "CellAdapter.h"
#import "CustomTableViewCell.h"

@implementation UITableView (CustomTableViewCell)

- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                 indexPath:(NSIndexPath *)indexPath
                                                                controller:(UIViewController *)controller {
    
    CustomTableViewCell *cell = [self dequeueReusableCellWithIdentifier:adapter.reuseIdentifier];
    cell.controller = controller;
    cell.indexPath = indexPath;
    cell.cellAdapter = adapter;
    cell.tableView = self;
    [cell loadContent];
    return cell;

}

- (CustomTableViewCell *)dequeueReusableCustomTableViewCellWithCellAdapter:(CellAdapter *)adapter
                                                                 indexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = [self dequeueReusableCellWithIdentifier:adapter.reuseIdentifier];
    cell.indexPath = indexPath;
    cell.cellAdapter = adapter;
    cell.tableView = self;
    [cell loadContent];
    return cell;
}

@end
