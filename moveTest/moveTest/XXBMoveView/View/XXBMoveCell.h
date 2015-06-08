//
//  XXBMoveCell.h
//  moveTest
//
//  Created by 杨小兵 on 15/6/4.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    XXBMoveCellTypeNormal = 0,    // 普通状态
    XXBMoveCellTypeMoveable,      // 可移动，有背景，有图示
    XXBMoveCellTypeEdit           // 编辑，有背景，无图示
} XXBMoveCellType;


@class XXBMoveCell;
@protocol XXBMoveCellDelegate <NSObject>

/**
 *  cell开始移动
 *
 *  @param moveCell 移动的cell
 */
- (void)XXBMoveCellBeginMoving:(XXBMoveCell *)moveCell;
/**
 *  cell正在移动
 *
 *  @param moveCell 移动的cell
 */
- (void)XXBMoveCellIsMoving:(XXBMoveCell *)moveCell;
/**
 *  cell移动完成了
 *
 *  @param moveCell 移动完的cell
 */
- (void)XXBMoveCellDidMoved:(XXBMoveCell *)moveCell;
@end
@interface XXBMoveCell : UIView

@property (nonatomic, weak) id<XXBMoveCellDelegate> delegate;
// moveCell 的类别
@property (nonatomic, assign) XXBMoveCellType type;
// cell对应在数组中的索引，可以用于按钮的排序
@property (nonatomic, assign) NSInteger index;
@end
