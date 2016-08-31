//
//  CollectionViewCell.m
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/22.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *tittleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.bounds=[UIScreen mainScreen].bounds;
}

-(void)setModel:(CellModel *)model
{
    _model=model;
    self.tittleLabel.text=model.tittle;
    self.contentLabel.text=model.tittle;
}

@end
