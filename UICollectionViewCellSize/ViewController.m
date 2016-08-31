//
//  ViewController.m
//  UICollectionViewCellSize
//
//  Created by ghy on 16/8/22.
//  Copyright © 2016年 wpc. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#define kCollectionViewCell @"CollectionViewCell1"
#import "CellModel.h"
#import "UICollectionView+selfSizingCell.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


@property(nonatomic,strong) UICollectionView * __nullable collectionview;


@property(nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ViewController

-(UICollectionView *)collectionview
{
    if(!_collectionview)
    {
     
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing=0;
        layout.scrollDirection=UICollectionViewScrollDirectionVertical;
        _collectionview=[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionview.backgroundColor=[UIColor whiteColor];
        [_collectionview registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCollectionViewCell];
        _collectionview.dataSource=self;
        _collectionview.delegate=self;
        _collectionview.alwaysBounceVertical=YES;
        
    }
    return _collectionview;
}

-(NSMutableArray *)dataArray
{
if(!_dataArray)
{
_dataArray=[NSMutableArray array];
    NSArray *tempArray=@[
    @{@"tittle":@"测试1234"},
    @{@"tittle":@"测试测试测试测试测试1234"},
    @{@"tittle":@"测试测试测试测试测试测试测试测试1234"},
    @{@"tittle":@"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试1234"},
    @{@"tittle":@"测试测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" },
    @{@"tittle":@"测试测试测试测试测试测试1234" }
    ];
    NSMutableArray *models=[NSMutableArray array];
    for(NSDictionary *dict in tempArray)
    {
        CellModel *model=[[CellModel alloc]init];
        model.tittle=[dict valueForKey:@"tittle"];
        [models addObject:model];
        
    }
    _dataArray=models;
}
return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionview];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat height=[collectionView heightForCellWithIdentifier:kCollectionViewCell cacheByIndexPath:indexPath andWidth:[UIScreen mainScreen].bounds.size.width configuration:^(CollectionViewCell *cell) {
        cell.model=self.dataArray[indexPath.item];
    }];

    return CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCell forIndexPath:indexPath];
    cell.model=self.dataArray[indexPath.item];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
