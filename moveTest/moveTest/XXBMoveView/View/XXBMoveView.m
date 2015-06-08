//
//  XXBMoveView.m
//  moveTest
//
//  Created by 杨小兵 on 15/6/3.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBMoveView.h"
#import "XXBMoveCell.h"



@interface XXBMoveView ()<XXBMoveCellDelegate>
/**
 *  存放的View的数组
 */
@property(nonatomic , strong) NSMutableArray    *viewArray;
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
    self.backgroundColor = [UIColor purpleColor];
    self.minimumLineSpacing = 5;
    self.minimumInteritemSpacing = 5;
    self.viewWidth = 100;
    self.viewHeight = 100;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.viewArray.count <= 0)
    {
        [self addViews];
        [self setIsModified:YES];
    }
}
- (void)addViews
{
    [self.viewArray removeAllObjects];
    int toolLine = (self.frame.size.width - self.minimumLineSpacing) / (self.viewWidth + self.minimumLineSpacing);
    CGFloat x;
    CGFloat y;
    CGFloat w = self.viewWidth;
    CGFloat h = self.viewHeight;
    int row;
    int line;
    for (int  i = 0; i < self.dataArray.count;  i ++)
    {
        line = i % toolLine;
        row = i / toolLine;
        x = line * (self.minimumLineSpacing + self.viewWidth) + self.minimumLineSpacing;
        y =  row * (self.minimumInteritemSpacing + self.viewHeight) + self.minimumInteritemSpacing;
        XXBMoveCell *cell = [[XXBMoveCell alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [self addSubview:cell];
        [self.viewArray addObject:cell];
        cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0  blue:arc4random_uniform(255)/255.0  alpha:1.0];
    }
}


- (void)setIsModified:(BOOL)isModified
{
    // 无论什么状态，都需要修改所有按钮的状态
    for (XXBMoveCell *cell in self.viewArray)
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
    [self bringSubviewToFront:moveCell];
}
- (void)XXBMoveCellIsMoving:(XXBMoveCell *)moveCell
{
    // 遍历按钮数组中的所有按钮
    // 检查与当前按钮的区域相交的情况
    // 如果，相交面积大于按钮面积的1/4， (w * h / 4）break
    // 取出了两个按钮，判断按钮的索引数值，根据索引数值递增，或者递减动画
    // 同时调整数据
    int exchangeIndex = -1;
//    
//    for (XXBMoveCell *cell in self.viewArray) {
//        if (cell != moveCell)
//        {
//            CGRect interRect = CGRectIntersection(cell.frame, moveCell.frame);
//            
//            // 判断相交面积是否超过1/4
//            if (interRect.size.width * interRect.size.height * 4 > b.frame.size.width * b.frame.size.height)
//            {
//                exchangeIndex = b.index;
//                
//                break;
//            }
//        }
//    }
//    
//    if (exchangeIndex > 0 && exchangeIndex != button.index) {
//        // 做交换处理
//        if (exchangeIndex > button.index) {
//            // 向前移动
//            [self decreaseMoveFrom:exchangeIndex to:button.index];
//        } else {
//            // 向后移动
//            [self increaseMoveFrom:exchangeIndex to:button.index];
//        }
//        
//#warning 还需要对数组中的数据做一下处理！！！
//        
//        button.index = exchangeIndex;
//        
//        // 需要对数组进行重新的排序，更新数组的索引数值
//        [_buttonList sortUsingComparator:^NSComparisonResult(NCCategoryButton *btn1, NCCategoryButton *btn2) {
//            // 按照按钮的索引降序重新排列数组
//            return btn1.index > btn2.index;
//        }];
//    }
}

- (void)XXBMoveCellDidMoved:(XXBMoveCell *)moveCell
{
    NSLog(@"移动完了");
}

#pragma mark - 私有成员方法
#pragma mark 向后移动
- (void)increaseMoveFrom:(NSInteger)from to:(NSInteger)to
{
//    for (NSInteger i = from; i < to; i++) {
//        NCCategoryButton *button = _buttonList[i];
//        
//        button.frame = [self rectForIndexOfButton:(i + 1)];
//        
//        button.index++;
//    }
}

#pragma mark 向前移动
- (void)decreaseMoveFrom:(NSInteger)from to:(NSInteger)to
{
//    // from 大于 to
//    for (NSInteger i = (to + 1); i <= from; i++) {
//        NCCategoryButton *button = _buttonList[i];
//        
//        // 计算-1的位置，设置按钮的位置
//        button.frame = [self rectForIndexOfButton:(i - 1)];
//        
//        // 按钮的索引需要修改
//        button.index--;
//    }
}




#pragma mark - 懒加载
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
        for ( int i = 0; i < 14; i ++)
        {
            [_dataArray addObject:@"1"];
        }
    }
    return _dataArray;
}
- (NSMutableArray *)viewArray
{
    if (_viewArray == nil)
    {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}
@end
