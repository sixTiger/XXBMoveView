//
//  XXBMoveView.m
//  moveTest
//
//  Created by 杨小兵 on 15/6/3.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBMoveView.h"
#import "XXBMoveCell.h"
#import "XXBMoveCellModel.h"


@interface XXBMoveView ()<XXBMoveCellDelegate>
/**
 *  最小列间距
 */
@property(nonatomic , assign) CGFloat           minimumLineSpacing;
/**
 *  最小行间距
 */
@property(nonatomic , assign) CGFloat           minimumInteritemSpacing;
@property(nonatomic , assign) CGFloat           moveCellWidth;
@property(nonatomic , assign) CGFloat           moveCellHeight;
/**
 *  存放的View的数组
 */
@property(nonatomic , strong) NSMutableArray    *moveCellArray;
@property(nonatomic , assign) int               toolLine;
/**
 *  是否自动移动
 */
@property(nonatomic , assign) BOOL              autoMove;
@end
@implementation XXBMoveView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupMoveView];
    }
    return self;
}
- (void)setupMoveView
{
    self.scrollsToTop = YES;
    self.autoMove = YES;
    self.backgroundColor = [UIColor purpleColor];
    self.minimumLineSpacing = 10;
    self.minimumInteritemSpacing = 10;
    self.moveCellWidth = 90;
    self.moveCellHeight = 120;
    [self adjustSpacing];
}
- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    // 1. 删除所有的子视图，避免重复设置时出现问题
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.moveCellArray removeAllObjects];
    [self.dataArray enumerateObjectsUsingBlock:^(XXBMoveCellModel *moveCellModel, NSUInteger index, BOOL *stop) {
        [self createMoveCellForIndex:(int)index data:moveCellModel];
    }];
    [self setIsModified:YES];
    self.contentSize = CGSizeMake(0,CGRectGetMaxY([[self.moveCellArray lastObject] frame]) + self.minimumInteritemSpacing );
}
- (void)setMoveCellLayout:(XXBMoveCellLayout)moveCellLayout
{
    _moveCellLayout = moveCellLayout;
    _minimumLineSpacing = _moveCellLayout.minimumLineSpacing;
    _minimumInteritemSpacing = _moveCellLayout.minimumInteritemSpacing;
    _moveCellWidth = _moveCellLayout.moveCellWidth;
    _moveCellHeight = _moveCellLayout.moveCellHeight;
    [self adjustSpacing];
    
    self.dataArray = self.dataArray;
}
/**
 *  计算最小的间隔
 */
- (void)adjustSpacing
{
    self.toolLine = (self.frame.size.width - _minimumLineSpacing) / (self.moveCellWidth + _minimumLineSpacing);
    _minimumLineSpacing = (self.frame.size.width - self.toolLine * self.moveCellWidth)/(self.toolLine + 1);
}
- (void)setIsModified:(BOOL)isModified
{
    // 无论什么状态，都需要修改所有按钮的状态
    for (XXBMoveCell *cell in self.moveCellArray)
    {
        if (isModified)
        {
            cell.type = XXBMoveCellTypeMoveable;
            cell.delegate = self;
        }
        else
        {
            cell.type = XXBMoveCellTypeEdit;
            cell.delegate = nil;
        }
    }
}

#pragma mark - 按钮的拖拽代理方法
- (void)XXBMoveCellBeginMoving:(XXBMoveCell *)moveCell
{
    self.scrollEnabled = NO;
    [self bringSubviewToFront:moveCell];
}
- (void)XXBMoveCellIsMoving:(XXBMoveCell *)moveCell
{
    if (self.autoMove)
    {
        self.autoMove = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.autoMove = YES;
        });
        //根据当前的cell的位置判断让scroll 向上移动
        if (moveCell.frame.origin.y - self.contentOffset.y <= self.minimumInteritemSpacing + self.autoMoveMargin )
        {
            if (self.contentOffset.y - self.frame.size.height  >= 0)
            {
                
                [UIView animateWithDuration:0.25 animations:^{
                    moveCell.frame = CGRectMake(moveCell.frame.origin.x, moveCell.frame.origin.y - self.frame.size.height, moveCell.frame.size.width, moveCell.frame.size.height);
                    
                    [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - self.frame.size.height) animated:NO];
                }];
            }
            else
            {
                [UIView animateWithDuration:0.25 animations:^{
                    
                    moveCell.frame = CGRectMake(moveCell.frame.origin.x, self.minimumInteritemSpacing, moveCell.frame.size.width, moveCell.frame.size.height);
                    [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:NO];
                }];
            }
        }
        /**
         *  像下移动
         */
        if (moveCell.frame.origin.y + moveCell.frame.size.height +self.minimumInteritemSpacing - self.contentOffset.y + self.autoMoveMargin >= self.frame.size.height)
        {
            if (self.contentOffset.y + self.frame.size.height <= self.contentSize.height - self.minimumInteritemSpacing - self.frame.size.height)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    
                    moveCell.frame = CGRectMake(moveCell.frame.origin.x, moveCell.frame.origin.y + self.frame.size.height, moveCell.frame.size.width, moveCell.frame.size.height);
                    
                    [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + self.frame.size.height) animated:NO];
                }];
            }
            else
            {
                [UIView animateWithDuration:0.25 animations:^{
                    
                    moveCell.frame = CGRectMake(moveCell.frame.origin.x, moveCell.frame.origin.y + (self.contentSize.height - self.contentOffset.y - self.frame.size.height), moveCell.frame.size.width, moveCell.frame.size.height);
                    
                    [self setContentOffset:CGPointMake(self.contentOffset.x,self.contentSize.height - self.frame.size.height) animated:NO];
                }];
            }
        }
        
    }
    
    // 遍历按钮数组中的所有按钮
    // 检查与当前按钮的区域相交的情况
    // 如果，相交面积大于按钮面积的1/4， (w * h / 4）break
    // 取出了两个按钮，判断按钮的索引数值，根据索引数值递增，或者递减动画
    // 同时调整数据
    int exchangeIndex = -1;
    for (XXBMoveCell *cell in self.moveCellArray)
    {
        if (cell != moveCell)
        {
            CGRect interRect = CGRectIntersection(cell.frame, moveCell.frame);
            // 判断相交面积是否超过1/4
            if (interRect.size.width * interRect.size.height * 4 > cell.frame.size.width * cell.frame.size.height)
            {
                exchangeIndex = cell.index;
                
                break;
            }
        }
    }
    if (exchangeIndex >= 0 && exchangeIndex != moveCell.index)
    {
        // 做交换处理
        if (exchangeIndex > moveCell.index)
        {
            // 向前移动
            [self decreaseMoveFrom:exchangeIndex to:moveCell.index];
        }
        else
        {
            // 向后移动
            [self increaseMoveFrom:exchangeIndex to:moveCell.index];
        }
        moveCell.index = exchangeIndex;
        // 需要对数组进行重新的排序，更新数组的索引数值
        [self.moveCellArray sortUsingComparator:^NSComparisonResult(XXBMoveCell *moveCell1, XXBMoveCell *moveCell2) {
            // 按照按钮的索引降序重新排列数组
            return moveCell1.index > moveCell2.index;
        }];
        [self.dataArray sortUsingComparator:^NSComparisonResult(XXBMoveCellModel *moveCellModel1, XXBMoveCellModel *moveCellModel2) {
            // 按照按钮的索引降序重新排列数组
            return moveCellModel1.index > moveCellModel2.index;
        }];
    }
}

- (void)XXBMoveCellDidMoved:(XXBMoveCell *)moveCell
{
    self.scrollEnabled = YES;
    self.autoMove = YES;
    moveCell.frame = [self rectForIndexOfMoveCell:moveCell.index];
    NSLog(@"移动完了");
    //    for (XXBMoveCellModel * moveCellModel in self.dataArray)
    //    {
    //        NSLog(@"%@",moveCellModel);
    //    }
}
/**
 *  从某个下标移动到某个下标 （向后移动）
 *
 *  @param from 开始下标
 *  @param to   要到的下标
 */
- (void)increaseMoveFrom:(int)from to:(int)to
{
    for (int i = from; i < to; i++)
    {
        XXBMoveCell *moveCell = self.moveCellArray[i];
        [UIView animateWithDuration:0.25 animations:^{
            moveCell.frame = [self rectForIndexOfMoveCell:(i + 1)];
            moveCell.index++;
        }];
    }
}
/**
 *  从某个下标移动到某个下标 （向前移动）
 *
 *  @param from 开始下标
 *  @param to   要到的下标
 */
- (void)decreaseMoveFrom:(int)from to:(int)to
{
    // from 大于 to
    for (int i = (to + 1); i <= from; i++)
    {
        XXBMoveCell *moveCellModle = self.moveCellArray[i];
        // 计算-1的位置，设置按钮的位置
        [UIView animateWithDuration:0.25 animations:^{
            moveCellModle.frame = [self rectForIndexOfMoveCell:(i - 1)];
            // 按钮的索引需要修改
            moveCellModle.index--;
        }];
    }
}
#pragma mark 创建按钮
- (void)createMoveCellForIndex:(int)index data:(XXBMoveCellModel *)moveCellModel
{
    CGRect rect = [self rectForIndexOfMoveCell:index];
    XXBMoveCell *moveCell = [[XXBMoveCell alloc] initWithFrame:rect andMoveCellModel:moveCellModel];
    [self addSubview:moveCell];
    [self.moveCellArray addObject:moveCell];
}
- (CGRect)rectForIndexOfMoveCell:(int)moveCellIndex
{
    // 计算每个按钮的宽度
    CGFloat x;
    CGFloat y;
    CGFloat w = self.moveCellWidth;
    CGFloat h = self.moveCellHeight;
    int line = moveCellIndex % self.toolLine;
    int row = moveCellIndex / self.toolLine;
    x = line * (self.minimumLineSpacing + self.moveCellWidth) + self.minimumLineSpacing;
    y =  row * (self.minimumInteritemSpacing + self.moveCellHeight) + self.minimumInteritemSpacing;
    return CGRectMake(x, y, w, h);
}
#pragma mark - 懒加载
- (NSMutableArray *)moveCellArray
{
    if (_moveCellArray == nil)
    {
        _moveCellArray = [NSMutableArray array];
    }
    return _moveCellArray;
}
- (CGFloat)autoMoveMargin
{
    if (_autoMoveMargin <= 0) {
        _autoMoveMargin = 20;
    }
    return _autoMoveMargin;
}
@end
