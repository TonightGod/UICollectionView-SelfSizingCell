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
/**return cell height*/
- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath  andWidth:(CGFloat)width configuration:(void (^)(id cell))configuration;
/**return cell size*/
- (CGSize)sizeForCellWithIdentifier:(NSString*)identifier configuration:(void(^)(id cell))configuration;

@end

@interface UICollectionView(selfSizeingHeaderFooterView)
/**return CollectionViewFooter height*/
-(CGFloat)heigthForFooterWithIdentifier:(NSString*)identifier configuration:(void(^)(id footer))configuration;
/**return CollectionViewHeader height*/
-(CGFloat)heigthForHeaderWithIdentifier:(NSString*)identifier configuration:(void(^)(id header))configuration;
@end
