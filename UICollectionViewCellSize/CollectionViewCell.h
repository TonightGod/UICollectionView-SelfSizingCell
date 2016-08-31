//
//  CollectionViewCell.h
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/22.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellModel.h"
@interface CollectionViewCell : UICollectionViewCell
@property(nonatomic,strong) CellModel *model;
@end
