//
//  UICollectionView+selfSizingCell.h
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/22.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UICollectionView+KeyedHeightCache.h"
#import "UICollectionView+IndexPathHeightCache.h"


@interface UICollectionView (selfSizingCell)

- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath  andWidth:(CGFloat)width configuration:(void (^)(id cell))configuration;

@end

@interface UICollectionView(selfSizeingHeaderFooterView)
-(CGFloat)heigthForFooterWithIdentifier:(NSString*)identifier configuration:(void(^)(id footer))configuration;

-(CGFloat)heigthForHeaderWithIdentifier:(NSString*)identifier configuration:(void(^)(id header))configuration;
@end