//
//  XXBMoveCellModel.h
//  moveTest
//
//  Created by 杨小兵 on 15/6/14.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXBMoveCellModel : NSObject
// 下标
@property(nonatomic , assign)int index;
// 标志
@property(nonatomic , assign)int flg;
- (instancetype)initWithIndex:(int)index;
@end
