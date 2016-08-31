//
//  UICollectionView+IndexPathHeightCache.h
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/31.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexPathHeightCache : NSObject

// Enable automatically if you're using index path driven height cache
@property (nonatomic, assign) BOOL automaticallyInvalidateEnabled;

// Height cache
- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

@end


@interface UICollectionView (IndexPathHeightCache)
/// Height cache by index path. Generally, you don't need to use it directly.
@property (nonatomic, strong, readonly) IndexPathHeightCache *indexPathHeightCache;
@end

@interface UICollectionView (IndexPathHeightCacheInvalidation)
/// Call this method when you want to reload data but don't want to invalidate
/// all height cache by index path, for example, load more data at the bottom of
/// table view.
- (void)cus_reloadDataWithoutInvalidateIndexPathHeightCache;

@end
