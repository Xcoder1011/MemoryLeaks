//
//  CustomTableViewCell.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellAdapter.h"


@interface CustomTableViewCell : UITableViewCell

/**
 * CustomTableViewCell ‘s adapter
 */
@property (nonatomic , weak) CellAdapter *cellAdapter;

@property (nonatomic , weak) UIViewController *controller;

@property (nonatomic , weak) UITableView *tableView;

@property (nonatomic , weak) NSIndexPath *indexPath;


/**
 * Over write in subclass
 */
- (void)configureCell;

- (void)setupSubviews;

- (void)loadContent;

- (void)clickEvent;


/**
 *  for UITableView
 */
+ (CellAdapter *)cellAdapterWithData:(id)data
                           cellWidth:(CGFloat)cellWidth
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier
                            cellType:(NSInteger)cellType
                                 tag:(NSInteger)tag;

/**
 *  for UITableView
 */
+ (CellAdapter *)cellAdapterWithData:(id)data
                           cellWidth:(CGFloat)cellWidth
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier;

/**
 *  for UITableView
 */
+ (CellAdapter *)cellAdapterWithData:(id)data
                          cellHeight:(CGFloat)cellHeight;

@end
