//
//  CustomTableViewCell.m
//  LiveRoomGiftAnimations
//
//  Created by KUN on 17/3/10.
//  Copyright © 2017年 animation. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if (self = [super initWithCoder:aDecoder]) {
        
        [self configureCell];
        
        [self setupSubviews];
    }
    return self;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self configureCell];
        
        [self setupSubviews];
    }
    return self;
}

- (void)configureCell {

}

- (void)setupSubviews {

}

- (void)loadContent {

}

- (void)clickEvent {

}


/**
 *  for UITableView
 */
+ (CellAdapter *)cellAdapterWithData:(id)data
                           cellWidth:(CGFloat)cellWidth
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier
                            cellType:(NSInteger)cellType
                                 tag:(NSInteger)tag {
   
    return [CellAdapter cellAdapterWithData:data cellWidth:cellWidth cellHeight:cellHeight reuseIdentifier:reuseIdentifier cellType:cellType tag:tag];

}

/**
 *  for UITableView
 */
+ (CellAdapter *)cellAdapterWithData:(id)data
                           cellWidth:(CGFloat)cellWidth
                          cellHeight:(CGFloat)cellHeight
                     reuseIdentifier:(NSString *)reuseIdentifier {
    
    return [[self class] cellAdapterWithData:data cellWidth:cellWidth cellHeight:cellHeight reuseIdentifier:reuseIdentifier cellType:0 tag:0];

}



/**
 *  for UITableView
 */
+ (CellAdapter *)cellAdapterWithData:(id)data
                          cellHeight:(CGFloat)cellHeight{

    return [CellAdapter cellAdapterWithData:data cellHeight:cellHeight reuseIdentifier:NSStringFromClass([self class])];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
