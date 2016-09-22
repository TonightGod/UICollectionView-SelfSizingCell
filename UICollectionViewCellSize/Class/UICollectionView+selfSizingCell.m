//
//  UICollectionView+selfSizingCell.m
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/22.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import "UICollectionView+selfSizingCell.h"
#import <objc/runtime.h>


@implementation UICollectionView (selfSizingCell)


-(CGFloat)contentWidth
{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

-(void)setContentWidth:(CGFloat)width
{
    objc_setAssociatedObject(self, @selector(contentWidth), @(width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (CGSize)sizeForCellWithIdentifier:(NSString*)identifier configuration:(void(^)(id cell))configuration
{
    if (!identifier) {
        return CGSizeZero;
    }
    UICollectionViewCell *tempCell=[self templateCellForReuseIdentifier:identifier forIndexPath:nil];
    if(configuration)
    {
        configuration(tempCell);
    }
    return [self systemFittingSizeForConfiguratedCell:tempCell];
}

-(CGSize)systemFittingSizeForConfiguratedCell:(UICollectionViewCell*)cell
{
    CGSize fittingHeight = CGSizeZero;
    fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    if (fittingHeight.width==0&&fittingHeight.height==0 ) {
#if DEBUG
        if (cell.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        fittingHeight = [cell sizeThatFits:CGSizeMake(0, 0)];
        
    }
    
    if (fittingHeight.width==0&&fittingHeight.height==0 ) {
        fittingHeight = CGSizeZero;
    }
    
    return fittingHeight;
}

-(CGFloat)systemFittingHeightForConfiguratedCell:(UICollectionViewCell*)cell
{
    CGFloat contentViewWidth = self.contentWidth;
    CGFloat fittingHeight = 0;
    if (contentViewWidth > 0) {
        
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
        [cell.contentView addConstraint:widthFenceConstraint];
        
        fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        [cell.contentView removeConstraint:widthFenceConstraint];
        
    }
    if (fittingHeight == 0) {
#if DEBUG
        if (cell.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        fittingHeight = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
        
    }
    
    if (fittingHeight == 0) {
        fittingHeight = 44;
    }
    
    return fittingHeight;
}

-(CGFloat)heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath andWidth:(CGFloat)width configuration:(void (^)(id))configuration
{
    self.contentWidth=width;
     if (!identifier || !indexPath) {
        return 0;
    }
    
    CGFloat height = [self heightForCellWithIdentifier:identifier forIndexPath:indexPath configuration:configuration];
    
    return height;
}


- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier) {
        return 0;
    }
    
    UICollectionViewCell *templateLayoutCell = [self templateCellForReuseIdentifier:identifier forIndexPath:indexPath];
    
    if([self.indexPathHeightCache existsHeightAtIndexPath:indexPath])
    {
        return [self.indexPathHeightCache heightForIndexPath:indexPath];
    }
    
    if (configuration) {
        configuration(templateLayoutCell);
    }
    CGFloat height=[self systemFittingHeightForConfiguratedCell:templateLayoutCell];
    [self.indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}


- (UICollectionViewCell *)templateCellForReuseIdentifier:(NSString *)identifier  forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSMutableDictionary<NSString *, UICollectionViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
        
    UICollectionViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        NSDictionary *nibDict=[self valueForKey:@"cellNibDict"];
        NSDictionary *classDict=[self valueForKey:@"cellClassDict"];
        if(nibDict[identifier])
        {
            UINib *nib=nibDict[identifier];
            templateCell=[[nib instantiateWithOwner:nil options:nil]lastObject];
        }
        if(classDict[identifier])
        {
            Class class=classDict[identifier];
            templateCell=[[class alloc]init];
        }
        NSAssert(templateCell != nil, @"Cell must be registered to collection view for identifier - %@", identifier);
            templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            templateCellsByIdentifiers[identifier] = templateCell;
    }
    
    return templateCell;
}

@end



@implementation UICollectionView(selfSizeingHeaderFooterView)

-(CGFloat)heigthForFooterWithIdentifier:(NSString*)identifier configuration:(void(^)(id footer))configuration
{
    if (!identifier) {
        return 0;
    }
    UICollectionReusableView *tempReusableView=[self templateCollectionReusableViewForReuseIdentifier:identifier andSupplementaryViewOfKind:UICollectionElementKindSectionFooter];
    if(configuration)
    {
        configuration(tempReusableView);
    }
    return [self systemFittingHeightForConfiguratedReusableView:tempReusableView];
}

-(CGFloat)heigthForHeaderWithIdentifier:(NSString*)identifier configuration:(void(^)(id header))configuration
{
    if (!identifier) {
        return 0;
    }
    UICollectionReusableView *tempReusableView=[self templateCollectionReusableViewForReuseIdentifier:identifier andSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
    if(configuration)
    {
        configuration(tempReusableView);
    }
    return [self systemFittingHeightForConfiguratedReusableView:tempReusableView];

}

-(CGFloat)systemFittingHeightForConfiguratedReusableView:(UICollectionReusableView*)view
{
    CGFloat fittingHeight = 0;
    CGFloat contentViewWidth=self.frame.size.width;
    if (contentViewWidth > 0) {
        
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
        [view addConstraint:widthFenceConstraint];
        
        fittingHeight = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        [view removeConstraint:widthFenceConstraint];
        
    }
    if (fittingHeight == 0) {
#if DEBUG
        if (view.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        fittingHeight = [view sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
        
    }
    
    if (fittingHeight == 0) {
        fittingHeight = 44;
    }
    
    return fittingHeight;
}
- (UICollectionReusableView *)templateCollectionReusableViewForReuseIdentifier:(NSString *)identifier andSupplementaryViewOfKind:(NSString*)kind{
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@ for header or footer", identifier);
    NSMutableDictionary<NSString *, UICollectionReusableView *> *templateReusableViewsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateReusableViewsByIdentifiers) {
        templateReusableViewsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateReusableViewsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
        
    UICollectionReusableView *templateReusableView = templateReusableViewsByIdentifiers[identifier];
    if (!templateReusableView) {
        NSDictionary *nibDict=[self valueForKey:@"supplementaryViewNibDict"];
        NSDictionary *classDict=[self valueForKey:@"supplementaryViewClassDict"];
        NSString *newIdentifier=[NSString stringWithFormat:@"%@/%@",kind,identifier];
        if(nibDict[newIdentifier])
        {
            UINib *nib=nibDict[newIdentifier];
            templateReusableView=[[nib instantiateWithOwner:nil options:nil]lastObject];
        }
        if(classDict[newIdentifier])
        {
            Class class=classDict[newIdentifier];
            templateReusableView=[[class alloc]init];
        }
        NSAssert(templateReusableView != nil, @"ReusableView must be registered to collection view for identifier - %@", identifier);
            templateReusableView.translatesAutoresizingMaskIntoConstraints = NO;
            templateReusableViewsByIdentifiers[identifier] = templateReusableView;
    }
    
    return templateReusableView;
    
}

@end
