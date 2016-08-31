//
//  UICollectionView+IndexPathHeightCache.m
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/31.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import "UICollectionView+IndexPathHeightCache.h"
#import <objc/runtime.h>

typedef NSMutableArray<NSMutableArray<NSNumber *> *> IndexPathHeightsBySection;

@interface IndexPathHeightCache ()
@property (nonatomic, strong) IndexPathHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) IndexPathHeightsBySection *heightsBySectionForLandscape;
@end

@implementation IndexPathHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (IndexPathHeightsBySection *)heightsBySectionForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait: self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(IndexPathHeightsBySection *heightsBySection))block {
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache {
    [self enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths {
    // Build every section array or row array which is smaller than given index path.
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    [self enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    [self enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @-1;
            }
        }
    }];
}

@end

@implementation UICollectionView (IndexPathHeightCache)

- (IndexPathHeightCache *)indexPathHeightCache {
    IndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [IndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

// We just forward primary call, in crash report, top most method in stack maybe FD's,
// but it's really not our bug, you should check whether your table view's data source and
// displaying cells are not matched when reloading.
static void __FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(void (^callout)(void)) {
    callout();
}
#define FDPrimaryCall(...) do {__FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(^{__VA_ARGS__});} while(0)

@implementation UICollectionView(IndexPathHeightCacheInvalidation)


- (void)cus_reloadDataWithoutInvalidateIndexPathHeightCache {
    FDPrimaryCall([self cus_reloadData];);
}

+ (void)load {
    // All methods that trigger height cache's invalidation
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:),
        @selector(deleteSections:),
        @selector(reloadSections:),
        @selector(moveSection:toSection:),
        @selector(insertItemsAtIndexPaths:),
        @selector(deleteItemsAtIndexPaths:),
        @selector(reloadItemsAtIndexPaths:),
        @selector(moveItemAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"cus_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)cus_reloadData {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    FDPrimaryCall([self cus_reloadData];);
}
-(void)cus_insertSections:(NSIndexSet *)sections
{
    if(self.indexPathHeightCache.automaticallyInvalidateEnabled)
    {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
            [self.indexPathHeightCache buildSectionsIfNeeded:section];
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];

        }];
    }
    FDPrimaryCall([self cus_insertSections:sections];);

}
-(void)cus_deleteSections:(NSIndexSet *)sections
{
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.indexPathHeightCache buildSectionsIfNeeded:section];
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self cus_deleteSections:sections];);
}
-(void)cus_reloadSections:(NSIndexSet *)sections
{
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.indexPathHeightCache buildSectionsIfNeeded:section];
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];

        }];
    }
    FDPrimaryCall([self cus_reloadSections:sections];);
}
-(void)cus_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildSectionsIfNeeded:section];
        [self.indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    FDPrimaryCall([self cus_moveSection:section toSection:newSection];);

}
-(void)cus_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
     if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[indexPath.section] insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    FDPrimaryCall([self cus_insertItemsAtIndexPaths:indexPaths];);
}
-(void)cus_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
     if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        
        NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[key.integerValue] removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    FDPrimaryCall([self cus_deleteItemsAtIndexPaths:indexPaths];);
}
-(void)cus_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
                heightsBySection[indexPath.section][indexPath.row] = @-1;
            }];
        }];
    }
    FDPrimaryCall([self cus_reloadItemsAtIndexPaths:indexPaths];);
}
-(void)cus_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[indexPath, newIndexPath]];
        [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(IndexPathHeightsBySection *heightsBySection) {
            NSMutableArray<NSNumber *> *sourceRows = heightsBySection[indexPath.section];
            NSMutableArray<NSNumber *> *destinationRows = heightsBySection[newIndexPath.section];
            NSNumber *sourceValue = sourceRows[indexPath.row];
            NSNumber *destinationValue = destinationRows[newIndexPath.row];
            sourceRows[indexPath.row] = destinationValue;
            destinationRows[newIndexPath.row] = sourceValue;
        }];
    }
    FDPrimaryCall([self cus_moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];);
}

@end
