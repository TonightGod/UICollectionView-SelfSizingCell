//
//  UICollectionView+KeyedHeightCache.h
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/31.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyedHeightCache : NSObject

- (BOOL)existsHeightForKey:(id<NSCopying>)key;
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
- (CGFloat)heightForKey:(id<NSCopying>)key;

// Invalidation
- (void)invalidateHeightForKey:(id<NSCopying>)key;
- (void)invalidateAllHeightCache;
@end

@interface UICollectionView (KeyedHeightCache)

@property (nonatomic, strong, readonly) KeyedHeightCache *keyedHeightCache;


@end
