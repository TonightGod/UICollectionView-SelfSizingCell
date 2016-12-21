# UICollectionView-SelfSizingCell
UICollectionView-SelfSizingCell

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

CGFloat height=[collectionView heightForCellWithIdentifier:kCollectionViewCell cacheByIndexPath:indexPath andWidth:[UIScreen mainScreen].bounds.size.width configuration:^(CollectionViewCell *cell) {
cell.model=self.dataArray[indexPath.item];
}];

return CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
}
