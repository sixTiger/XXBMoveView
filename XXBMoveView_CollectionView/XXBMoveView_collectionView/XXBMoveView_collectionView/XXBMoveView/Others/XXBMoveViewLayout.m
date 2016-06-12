//
//  XXBMoveViewLayout.m
//  XXBMoveView_collectionView
//
//  Created by xiaobing on 16/4/6.
//  Copyright © 2016年 xiaobing. All rights reserved.
//

#import "XXBMoveViewLayout.h"
#import "XXBMoveCell.h"

#define movingCellHeight 60

#define shouldMoveMargin 100

#define animationTime 0.01

@interface XXBMoveViewLayout()<UIGestureRecognizerDelegate>
{
    UILongPressGestureRecognizer    *longPressGestureRecognizer;
    BOOL                            animating;
    
    
    CGPoint                         offSet;
    UICollectionViewCell            *souceCell;
    UIView                          *repressentationImageView;
    NSIndexPath                     *currentIndexPath;
    
    CGFloat                         offSetY;
    BOOL                            shouldMove;
    NSMutableArray                  *attributesArray;
    NSMutableArray                  *heightArray;
    
    //temp var
    CGFloat                         itemX;
    CGFloat                         itemY;
    CGFloat                         itemW;
    CGFloat                         itemH;
}
@property(nonatomic , strong) UIView    *canvas;
@property(nonatomic , strong) NSTimer   *timer;

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
    heightArray = [NSMutableArray array];
    attributesArray = [NSMutableArray array];
    [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    UICollectionView *collectionView = (UICollectionView *)change[@"new"];
    if (collectionView != nil) {
        [self _addLongPressGestureRecognizer];
    }
    
}

#pragma mark - collectionViewLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)prepareLayout {
    [super prepareLayout];
    [attributesArray removeAllObjects];
    [heightArray removeAllObjects];
    int interCount = (int)(self.collectionView.frame.size.width)/(self.itemSize.width + self.minimumInteritemSpacing * 2);
    if (interCount < 1 ) {
        interCount = 1;
    }
    
    for (int i = 0; i < interCount; i++) {
        [heightArray addObject:@"0"];
    }
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (int section = 0; section < sectionCount ; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (int row = 0; row < itemCount; row++) {
            [attributesArray addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]]];
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if (heightArray.count > 0) {
        CGFloat minHeight = [(NSNumber *)[heightArray firstObject] floatValue];
        int flg = 0;
        for (int i = 1; i < heightArray.count; i++) {
            if ([heightArray[i] floatValue] < minHeight) {
                minHeight = [heightArray[i] floatValue];
                flg = i;
            }
        }
        CGFloat maxWidth = self.collectionView.frame.size.width/heightArray.count;
        itemX = maxWidth * flg + (maxWidth - self.itemSize.width) * 0.5;
        itemW = self.itemSize.width;
        if ([indexPath isEqual:currentIndexPath]) {
            itemH = movingCellHeight;
        } else {
            itemH = [self.delegate moveView:self heightForCellAtIndexPath:indexPath];
        }
        itemY = minHeight + self.minimumLineSpacing;
        heightArray[flg] = @(itemH + itemY);
        attributes.frame = CGRectMake(itemX, itemY, itemW, itemH);
        itemX = 0;
        itemY = 0;
        itemH = 0;
        itemW = 0;
    }
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return attributesArray;
    //    NSArray *array = attributesArray;
    //    if (currentIndexPath == nil) {
    //        return array;
    //    }
    //    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
    //        //缩小高度
    //        if([layoutAttributes.indexPath isEqual:currentIndexPath]){
    //            CGPoint origin = layoutAttributes.frame.origin;
    //            CGSize size = layoutAttributes.frame.size;
    //            offSetY = size.height - movingCellHeight;
    //            layoutAttributes.frame = CGRectMake(origin.x, origin.y, size.width, movingCellHeight);
    //        }
    //        //后边的要依次更改y的值
    //        if([self isFirstIndexPath:currentIndexPath smallThanSecondIndexPath:layoutAttributes.indexPath] ){
    //            CGPoint origin = layoutAttributes.frame.origin;
    //            CGSize size = layoutAttributes.frame.size;
    //            layoutAttributes.frame = CGRectMake(origin.x, origin.y - offSetY, size.width, size.height);
    //        }
    //
    //    }
    //    return array;
}

- (BOOL)isFirstIndexPath:(NSIndexPath *)firIndexPath smallThanSecondIndexPath:(NSIndexPath *)secondIndexPath {
    if (firIndexPath == nil || secondIndexPath == nil) {
        return NO;
    }
    if (firIndexPath.section < secondIndexPath.section) {
        return YES;
    } else {
        if (firIndexPath.section == secondIndexPath.section) {
            if (firIndexPath.row < secondIndexPath.row) {
                return YES;
            } else {
                return NO;
            }
        }
        return NO;
    }
}

- (CGSize)collectionViewContentSize {
    CGFloat maxHeight = 0;
    for (NSNumber *height in heightArray) {
        if (height.floatValue > maxHeight) {
            maxHeight = height.floatValue;
        }
    }
    return CGSizeMake(self.collectionView.frame.size.width, maxHeight + self.minimumLineSpacing - offSetY);
}
#pragma mark - handlerGestureRecognizer

- (void)_addLongPressGestureRecognizer {
    self.canvas = nil;
    [self.collectionView removeGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    longPressGestureRecognizer.minimumPressDuration = 0.2;
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)_handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGesture{
    
    CGPoint dragPointOnCanvas = [longPressGesture locationInView:self.canvas];
    [self autoHandlerMove:dragPointOnCanvas andView:self.canvas];
    switch (longPressGesture.state) {
            
        case UIGestureRecognizerStateBegan: {
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
            souceCell.hidden = YES;
            offSet.y -= (dragPointOnCanvas.y - repressentationImageView.center.y);
            repressentationImageView.center = CGPointMake(repressentationImageView.center.x, dragPointOnCanvas.y);
            [self.canvas addSubview:repressentationImageView];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGRect imagViewFrame = repressentationImageView.frame;
            CGPoint point = CGPointZero;
            if(heightArray.count == 0) {
                point.x = repressentationImageView.frame.origin.x;
            } else {
                //FIXME: 只有一列的话没有必要让
                point.x = dragPointOnCanvas.x - offSet.x;
            }
            point.y = dragPointOnCanvas.y - offSet.y;
            imagViewFrame.origin = point;
            repressentationImageView.frame = imagViewFrame;
            
            CGPoint dragPointOnCollectionView = [longPressGesture locationInView:self.collectionView];
            NSIndexPath *indexpath = [self.collectionView indexPathForItemAtPoint:dragPointOnCollectionView];
            if (indexpath == nil) {
                return;
            }
            if (![indexpath isEqual:currentIndexPath]) {
                if ([self.delegate respondsToSelector:@selector(moveView:MoveDataItemFromIndexPath:toIndexPath:)]) {
                    [self.delegate moveView:self MoveDataItemFromIndexPath:currentIndexPath toIndexPath:indexpath];
                }
                NSIndexPath *fromeIndex = currentIndexPath;
                currentIndexPath = indexpath;
                [self.collectionView moveItemAtIndexPath:fromeIndex toIndexPath:currentIndexPath];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            [self.timer invalidate];
            _timer = nil;
            [(XXBMoveCell *)souceCell setDranging:NO];
            souceCell.hidden = NO;
            [repressentationImageView removeFromSuperview];
            souceCell = nil;
            currentIndexPath = nil;
            repressentationImageView = nil;
            offSetY = 0;
            [UIView animateWithDuration:0.25 animations:^{
                [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 0.5)];
            }];
            break;
        }
            
        default: {
            [(XXBMoveCell *)souceCell setDranging:NO];
            souceCell.hidden = NO;
            [repressentationImageView removeFromSuperview];
            souceCell = nil;
            currentIndexPath = nil;
            repressentationImageView = nil;
            offSetY = 0;
            [UIView animateWithDuration:0.25 animations:^{
                [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 0.5)];
            }];
            break;
        }
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
            cellInCavasFrame.origin.x += 10;
            cellInCavasFrame.size.width -= 20;
            cellInCavasFrame.size.height = movingCellHeight;
            repressentationImageView.frame = cellInCavasFrame;
            offSet = CGPointMake(pointPressInCanvas.x - cellInCavasFrame.origin.x, pointPressInCanvas.y - cellInCavasFrame.origin.y);
            currentIndexPath = [collectionView indexPathForCell:cell];
            //            [collectionView reloadItemsAtIndexPaths:@[currentIndexPath]];
            [collectionView setNeedsLayout];
            [UIView animateWithDuration:0.25 animations:^{
                
                [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + 0.5 )];
            }];
            souceCell = [collectionView cellForItemAtIndexPath:currentIndexPath];
            break;
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

- (void)autoHandlerMove:(CGPoint)pointInView andView:(UIView *)view {
    
    if (shouldMove) {
        return;
    }
    shouldMove = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shouldMove = NO;
    });
    CGRect handleRect = view.frame;
    BOOL shouldChangeContentOffset = NO;
    CGPoint newContentOffset = CGPointZero;
    if (pointInView.y - handleRect.origin.y < shouldMoveMargin ) {
        shouldChangeContentOffset = YES;
        //应该向上移动
        CGFloat actionY = handleRect.origin.y + shouldMoveMargin - pointInView.y;
        actionY *= 0.1;
        newContentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y - actionY);
        if (newContentOffset.y <= 0) {
            newContentOffset.y = 0;
        }
        
    } else  if ( handleRect.size.height - ( pointInView.y - handleRect.origin.y )  < shouldMoveMargin ) {
        shouldChangeContentOffset = YES;
        //应该向下移动了
        CGFloat actionY = ( pointInView.y - handleRect.origin.y ) - (handleRect.size.height - shouldMoveMargin);
        actionY *= 0.1;
        newContentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + actionY);
        if (newContentOffset.y > self.collectionView.contentSize.height - self.collectionView.frame.size.height) {
            newContentOffset.y = self.collectionView.contentSize.height - self.collectionView.frame.size.height;
        }
    }
    if (shouldChangeContentOffset) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.collectionView setContentOffset:newContentOffset animated:NO];
        }];
    }
}

- (void)_rehandlerMoving {
    [longPressGestureRecognizer setValue:@(UIGestureRecognizerStateChanged) forKey:@"state"];
    [self _handleLongPressGestureRecognizer:longPressGestureRecognizer];
}

#pragma mark - layz load

- (UIView *)canvas {
    if (_canvas == nil) {
        _canvas = self.collectionView.superview;
    }
    return _canvas;
}

- (NSTimer *)timer {
    if(_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:animationTime target:self selector:@selector(myTouch) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)myTouch {
    [self _handleLongPressGestureRecognizer:longPressGestureRecognizer];
    [self.collectionView becomeFirstResponder];
}
@end
