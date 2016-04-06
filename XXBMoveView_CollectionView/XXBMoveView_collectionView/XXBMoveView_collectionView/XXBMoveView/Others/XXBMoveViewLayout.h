//
//  XXBMoveViewLayout.h
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XXBMoveViewLayout;

@protocol XXBMoveViewLayoutDelegate <NSObject>

- (void)moveView:(XXBMoveViewLayout *)moveViewLayout MoveDataItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface XXBMoveViewLayout : UICollectionViewFlowLayout

@property(nonatomic , weak) id<XXBMoveViewLayoutDelegate>   delegate;
@end
