//
//  XXBMoveCell.m
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import "XXBMoveCell.h"

@interface XXBMoveCell ()
@property(nonatomic , weak) UILabel   *label;
@end

@implementation XXBMoveCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    }
    return self;
}

- (void)setMoveModel:(XXBMoveModel *)moveModel {
    _moveModel = moveModel;
    self.label.text = moveModel.title;
}
- (UILabel *)label {
    if (_label == nil) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:label];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = (1 << 6) - 1;
        _label = label;
    }
    return _label;
}
@end
