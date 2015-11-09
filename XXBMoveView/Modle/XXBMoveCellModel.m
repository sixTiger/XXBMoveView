//
//  XXBMoveCellModel.m
//  moveTest
//
//  Created by 杨小兵 on 15/6/14.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBMoveCellModel.h"

@implementation XXBMoveCellModel
- (instancetype)initWithIndex:(int)index
{
    if (self = [super init])
    {
        self.index = index;
        self.flg = index;
    }
    return self;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"{<%@ : %p>\n index: %d\n flg : %d \n}",[self class],self,self.index,self.flg];
}
@end
