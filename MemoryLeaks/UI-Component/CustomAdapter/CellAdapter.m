//
//  CellAdapter.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "CellAdapter.h"

@implementation CellAdapter

///  UITableView

+ (CellAdapter *)cellAdapterWithData:(id)data
                           cellWidth:(CGFloat)cellWidth
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier
                            cellType:(NSInteger)cellType
                                 tag:(NSInteger)tag {
    
    CellAdapter *adapter = [[self class] new];
    adapter.data = data;
    adapter.cellWidth = cellWidth;
    adapter.cellHeight = cellHeight;
    adapter.reuseIdentifier = reuseIdentifier;
    adapter.cellType = cellType;
    adapter.tag = tag;
    return adapter;

}

+ (CellAdapter *)cellAdapterWithData:(id)data
                           cellWidth:(CGFloat)cellWidth
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier {
    
    CellAdapter *adapter = [[self class] new];
    adapter.data = data;
    adapter.cellWidth = cellWidth;
    adapter.cellHeight = cellHeight;
    adapter.reuseIdentifier = reuseIdentifier;
    return adapter;
}


+ (CellAdapter *)cellAdapterWithData:(id)data
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier{
    
    CellAdapter *adapter = [[self class] new];
    adapter.data = data;
    adapter.cellHeight = cellHeight;
    adapter.reuseIdentifier = reuseIdentifier;
    return adapter;
}



///  UICollectionView

+ (CellAdapter *)collectionCellAdapterWithData:(id)data reuseIdentifier:(NSString *)reuseIdentifier {
    
    CellAdapter *adapter = [[self class] new];
    adapter.data = data;
    adapter.reuseIdentifier = reuseIdentifier;
    return adapter;
}


@end
