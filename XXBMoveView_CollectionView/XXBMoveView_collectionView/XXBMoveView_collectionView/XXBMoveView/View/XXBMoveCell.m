//
//  XXBMoveCell.m
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import "XXBMoveCell.h"

@implementation XXBMoveCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    }
    return self;
}

@end
