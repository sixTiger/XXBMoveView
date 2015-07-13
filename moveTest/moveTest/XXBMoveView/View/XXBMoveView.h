//
//  XXBMoveView.h
//  moveTest
//
//  Created by 杨小兵 on 15/6/3.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef struct XXBMoveCellLayout {
    CGFloat           minimumLineSpacing;           //最小列间距
    CGFloat           minimumInteritemSpacing;      //最小行间距
    CGFloat           moveCellWidth;                //cell的宽度
    CGFloat           moveCellHeight;               // cell 的高度
}XXBMoveCellLayout;

@class XXBMoveView;
@protocol XXBMoveViewDelegte <UIScrollViewDelegate>
@optional
/**
 *  XXBMoveView开始移动
 *
 *  @param moveView 移动的XXBMoveView
 */
- (void)moveViewStartMove:(XXBMoveView *)moveView;
/**
 *  XXBMoveView正在移动
 *
 *  @param moveView 移动的XXBMoveView
 */
- (void)moveViewMoveing:(XXBMoveView *)moveView;
/**
 *  XXBMoveView停止移动
 *
 *  @param moveView 移动的XXBMoveView
 */
- (void)moveViewEndMove:(XXBMoveView *)moveView;

@end

@interface XXBMoveView : UIScrollView

@property(nonatomic , assign)XXBMoveCellLayout      moveCellLayout;
/**
 *   存放数据的数组
 */
@property(nonatomic , strong) NSMutableArray        *dataArray;
/**
 *  是否可以移动 默认是可以的 YES
 */
@property (nonatomic, assign) BOOL                  isModified;
/**
 *  自动滚动的边距 默认是20
 */
@property(nonatomic , assign)CGFloat                autoMoveMargin;
@property(nonatomic , weak)id<XXBMoveViewDelegte>   delegate;
@end
