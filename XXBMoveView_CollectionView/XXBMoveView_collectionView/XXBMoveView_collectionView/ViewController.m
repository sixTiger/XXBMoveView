//
//  ViewController.m
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBMoveViewLayout.h"
#import "XXBMoveCell.h"
#import "XXBMoveModel.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,XXBMoveViewLayoutDelegate>
@property(nonatomic , strong) NSMutableArray   *dataSouceArray;
@end

@implementation ViewController

static NSString *moveCellID = @"moveCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupDataSouceArray];
    [self _setupCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)_setupCollectionView {
    XXBMoveViewLayout *moveLayout = [[XXBMoveViewLayout alloc] init];
    moveLayout.delegate = self;
    CGSize cellSize = CGSizeMake(80, 100);
    moveLayout.itemSize = cellSize;
    moveLayout.minimumLineSpacing = 4;
    moveLayout.minimumInteritemSpacing = 4;
    moveLayout.sectionInset = UIEdgeInsetsMake(moveLayout.minimumInteritemSpacing, moveLayout.minimumInteritemSpacing, moveLayout.minimumLineSpacing, moveLayout.minimumInteritemSpacing);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:moveLayout];
    [self.view addSubview:collectionView];
    collectionView.autoresizingMask = (1 << 6) - 1;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[XXBMoveCell class] forCellWithReuseIdentifier:moveCellID];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSouceArray[section] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSouceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XXBMoveCell *moveCell = [collectionView dequeueReusableCellWithReuseIdentifier:moveCellID forIndexPath:indexPath];
    return moveCell;
}

- (void)moveView:(XXBMoveViewLayout *)moveViewLayout MoveDataItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSObject *obj = self.dataSouceArray[fromIndexPath.section][fromIndexPath.row];
    [self.dataSouceArray[fromIndexPath.section] removeObject:obj];
    NSMutableArray *array = self.dataSouceArray[toIndexPath.section];
    [array insertObject:obj atIndex:toIndexPath.row];
    
}
- (void)_setupDataSouceArray {
    _dataSouceArray = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [_dataSouceArray addObject:array];
        for (int j = 0; j < 10; j++) {
            XXBMoveModel *moveModel = [[XXBMoveModel alloc] init];
            moveModel.title = [NSString stringWithFormat:@"%d --->>> %d",i,j];
            moveModel.height = arc4random_uniform(100) + 80;
            [array addObject:moveModel];
        }
    }
}

- (CGFloat)moveView:(XXBMoveViewLayout *)moveViewLayout heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    XXBMoveModel *moveModel = self.dataSouceArray[indexPath.section][indexPath.row];
    return moveModel.height;
}
@end
