//
//  XXBMoveViewLayout.m
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import "XXBMoveViewLayout.h"
#import "XXBMoveCell.h"

@interface XXBMoveViewLayout()<UIGestureRecognizerDelegate>
{
    UILongPressGestureRecognizer    *longPressGestureRecognizer;
    BOOL                            animating;
    
    
    CGPoint                         offSet;
    UICollectionViewCell            *souceCell;
    UIView                          *repressentationImageView;
    NSIndexPath                     *currentIndexPath;
}
@property(nonatomic , strong) UIView   *canvas;

@end

@implementation XXBMoveViewLayout

- (instancetype)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"collectionView"];
}

- (void)_setup {
    [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    UICollectionView *collectionView = (UICollectionView *)change[@"new"];
    if (collectionView != nil) {
        [self _addLongPressGestureRecognizer];
    }
    
}

#pragma mark -

- (void)_addLongPressGestureRecognizer {
    self.canvas = nil;
    [self.collectionView removeGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    longPressGestureRecognizer.minimumPressDuration = 0.2;
    longPressGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
}
- (void)_handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGesture{
    
    CGPoint dragPointOnCanvas = [longPressGesture locationInView:self.canvas];
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan: {
            souceCell.hidden = YES;
            [self.canvas addSubview:repressentationImageView];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGRect imagViewFrame = repressentationImageView.frame;
            CGPoint point = CGPointZero;
            point.x = dragPointOnCanvas.x - offSet.x;
            point.y = dragPointOnCanvas.y - offSet.y;
            imagViewFrame.origin = point;
            repressentationImageView.frame = imagViewFrame;
            
            CGPoint dragPointOnCollectionView = [longPressGesture locationInView:self.collectionView];
            NSIndexPath *indexpath = [self.collectionView indexPathForItemAtPoint:dragPointOnCollectionView];
            if (![indexpath isEqual:currentIndexPath]) {
                if ([self.delegate respondsToSelector:@selector(moveView:MoveDataItemFromIndexPath:toIndexPath:)]) {
                    [self.delegate moveView:self MoveDataItemFromIndexPath:currentIndexPath toIndexPath:indexpath];
                }
                [self.collectionView moveItemAtIndexPath:currentIndexPath toIndexPath:indexpath];
                currentIndexPath = indexpath;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            [(XXBMoveCell *)souceCell setDranging:NO];
            souceCell.hidden = NO;
            [repressentationImageView removeFromSuperview];
            
            
            souceCell = nil;
            currentIndexPath = nil;
            repressentationImageView = nil;
            
            break;
        }
            
        default: {
            [(XXBMoveCell *)souceCell setDranging:NO];
            souceCell.hidden = NO;
            [repressentationImageView removeFromSuperview];
            
            
            souceCell = nil;
            currentIndexPath = nil;
            repressentationImageView = nil;
        }
            break;
    }
    
    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    UICollectionView *collectionView = self.collectionView;
    CGPoint pointPressInCanvas = [gestureRecognizer locationInView:self.canvas];
    for (UICollectionViewCell *cell in collectionView.visibleCells) {
        CGRect cellInCavasFrame = [self.canvas convertRect:cell.frame fromView:self.collectionView];
        if (CGRectContainsPoint(cellInCavasFrame, pointPressInCanvas)) {
            [(XXBMoveCell *)cell setDranging:YES];
        
            UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0);
            [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndPDFContext();
            
            repressentationImageView = [[UIImageView alloc] initWithImage:image];
            repressentationImageView.frame = cellInCavasFrame;
            offSet = CGPointMake(pointPressInCanvas.x - cellInCavasFrame.origin.x, pointPressInCanvas.y - cellInCavasFrame.origin.y);
            currentIndexPath = [collectionView indexPathForCell:cell];
            souceCell = cell;
        }
        
    }
    return [self shouldGesterStart];
}


- (BOOL)shouldGesterStart {
    if (repressentationImageView == nil) {
        return NO;
    }
    if (souceCell == nil) {
        return NO;
    }
    if (currentIndexPath == nil) {
        return NO;
    }
    return YES;
}


#pragma mark - layz load

- (UIView *)canvas {
    if (_canvas == nil) {
        _canvas = self.collectionView.superview;
    }
    return _canvas;
}

@end
