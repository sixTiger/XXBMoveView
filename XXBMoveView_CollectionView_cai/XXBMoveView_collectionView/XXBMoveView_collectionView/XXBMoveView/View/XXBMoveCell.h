//
//  XXBMoveCell.h
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXBMoveModel.h"

@interface XXBMoveCell : UICollectionViewCell
@property(nonatomic , assign) BOOL              dranging;
@property(nonatomic , strong) XXBMoveModel      *moveModel;
@end
