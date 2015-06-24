//
//  XXBMoveCell.m
//  moveTest
//
//  Created by 杨小兵 on 15/6/4.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBMoveCell.h"
#import "XXBMoveCellModel.h"


@interface XXBMoveCell ()<UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer              *_panGesture;       // 拖拽手势
    UILongPressGestureRecognizer        *_longPress;        // 长按手势
}
@property(nonatomic , strong)UIPanGestureRecognizer         *panGesture;
@property(nonatomic , strong)UILongPressGestureRecognizer   *longPress;
/**
 *  是否可以移动
 */
@property(nonatomic , assign)BOOL                           shouldMove;
@end
@implementation XXBMoveCell


#pragma mark 设置按钮类型，针对不同的类型，改变按钮的外观

- (instancetype)initWithFrame:(CGRect)frame andMoveCellModel:(XXBMoveCellModel *)moveCellModel
{
    if (self = [super initWithFrame:frame])
    {
        self.moveCellModel = moveCellModel;
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    }
    return self;
}
- (void)setMoveCellModel:(XXBMoveCellModel *)moveCellModel
{
    _moveCellModel = moveCellModel;
    self.index = _moveCellModel.index;
}
- (void)setIndex:(int)index
{
    _index = index;
    self.moveCellModel.index = index;
}
- (void)setType:(XXBMoveCellType)type
{
    _type = type;
    if (_panGesture != nil)
    {
        [self removeGestureRecognizer:self.panGesture];
    }
    if (_type == XXBMoveCellTypeNormal)
    {
    }
    else
    {
        // 添加按钮的手势监听
        [self addGestureRecognizer:self.panGesture];
        [self addGestureRecognizer:self.longPress];
    }
}

#pragma mark - 手势拖动
- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    if (!self.shouldMove )
        return;
    CGPoint location = [recognizer translationInView:self];
    if (UIGestureRecognizerStateChanged == recognizer.state)
    {
        CGPoint point = self.center;
        point.x += location.x;
        point.y += location.y;
        self.center = point;
        [recognizer setTranslation:CGPointZero inView:self];
        [_delegate XXBMoveCellIsMoving:self];
    }
    else
    {
        if (UIGestureRecognizerStateEnded == recognizer.state)
        {
            self.shouldMove = NO;
            [_delegate XXBMoveCellDidMoved:self];
        }
    }
}
- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.shouldMove = YES;
            if([self.delegate respondsToSelector:@selector(XXBMoveCellBeginMoving:)])
            {
                [self.delegate XXBMoveCellBeginMoving:self];
            }
            self.transform = CGAffineTransformScale(self.transform, 1.2, 1.2);
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            self.shouldMove = NO;
            self.transform = CGAffineTransformScale(self.transform, 0.83334, 0.83334);
            if ([self.delegate respondsToSelector:@selector(XXBMoveCellDidMoved:)] )
            {
                [self.delegate XXBMoveCellDidMoved:self];
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark - 懒加载
- (UIPanGestureRecognizer *)panGesture
{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}
- (UILongPressGestureRecognizer *)longPress
{
    if(_longPress == nil)
    {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        //至少长按的时间
        _longPress.minimumPressDuration = 1;
        _longPress.allowableMovement = 10;
        _longPress.delegate = self;
    }
    return _longPress;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
