//
//  XXBMoveView.h
//  moveTest
//
//  Created by 杨小兵 on 15/6/3.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXBMoveView : UIScrollView
@property(nonatomic , assign) CGFloat           minimumLineSpacing;
@property(nonatomic , assign) CGFloat           minimumInteritemSpacing;
@property(nonatomic , assign) CGFloat           moveCellWidth;
@property(nonatomic , assign) CGFloat           moveCellHeight;
/**
 *   存放数据的数组
 */
@property(nonatomic , strong) NSMutableArray    *dataArray;
// 是否编辑状态
@property (nonatomic, assign) BOOL              isModified;
@end
