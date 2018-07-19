//
//  CellAdapter.h
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellAdapter : NSObject

/**
 *  data source
 */
@property (nonatomic , strong) id data;

@property (nonatomic , strong) NSString * reuseIdentifier;

@property (nonatomic) CGFloat cellWidth;

@property (nonatomic) CGFloat cellHeight;

@property (nonatomic) NSInteger tag;

@property (nonatomic) NSInteger cellType;

#pragma mark -- Optional property

@property (nonatomic , weak) NSIndexPath *indexPath;

@property (nonatomic , weak) UITableView *tableView;

// or

@property (nonatomic , weak) UICollectionView *collectionView;


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
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier;

/**
 *  for UICollectionView
 */
+ (CellAdapter *)collectionCellAdapterWithData:(id)data reuseIdentifier:(NSString *)reuseIdentifier;



@end
