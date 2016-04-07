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
        itemH = [self.delegate moveView:self heightForCellAtIndexPath:indexPath];
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
    NSArray *array = attributesArray;
    if (currentIndexPath == nil) {
        return array;
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        //缩小高度
        if([layoutAttributes.indexPath isEqual:currentIndexPath]){
            CGPoint origin = layoutAttributes.frame.origin;
            CGSize size = layoutAttributes.frame.size;
            offSetY = size.height - movingCellHeight;
            layoutAttributes.frame = CGRectMake(origin.x + 10, origin.y, size.width -= 20, movingCellHeight);
        }
        //后边的一次更改y的值
        if([self isFirstIndexPath:currentIndexPath smallThanSecondIndexPath:layoutAttributes.indexPath] ){
            CGPoint origin = layoutAttributes.frame.origin;
            CGSize size = layoutAttributes.frame.size;
            layoutAttributes.frame = CGRectMake(origin.x, origin.y - offSetY, size.width, size.height);
        }
        
    }
    return array;
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
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
}
- (void)_handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGesture{
    
    CGPoint dragPointOnCanvas = [longPressGesture locationInView:self.canvas];
    [self autoHandlerMove:dragPointOnCanvas andView:self.canvas];
    
    NSLog(@"XXX -- %@",NSStringFromCGPoint(dragPointOnCanvas));
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan: {
            //            souceCell.hidden = YES;
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
            
            [(XXBMoveCell *)souceCell setDranging:NO];
            souceCell.hidden = NO;
            [repressentationImageView removeFromSuperview];
            NSIndexPath *shouReloadIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section];
            
            souceCell = nil;
            currentIndexPath = nil;
            repressentationImageView = nil;
            offSetY = 0;
            [self.collectionView reloadItemsAtIndexPaths:@[shouReloadIndexPath]];
            
            break;
        }
            
        default: {
            [(XXBMoveCell *)souceCell setDranging:NO];
            souceCell.hidden = NO;
            [repressentationImageView removeFromSuperview];
            NSIndexPath *shouReloadIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section];
            
            souceCell = nil;
            currentIndexPath = nil;
            repressentationImageView = nil;
            offSetY = 0;
            [self.collectionView reloadItemsAtIndexPaths:@[shouReloadIndexPath]];
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
            cellInCavasFrame.origin.x  += 10;
            cellInCavasFrame.size.width -= 20;
            cellInCavasFrame.size.height = movingCellHeight;
            repressentationImageView.frame = cellInCavasFrame;
            offSet = CGPointMake(pointPressInCanvas.x - cellInCavasFrame.origin.x, pointPressInCanvas.y - cellInCavasFrame.origin.y);
            currentIndexPath = [collectionView indexPathForCell:cell];
            [collectionView reloadItemsAtIndexPaths:@[currentIndexPath]];
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

- (void)autoHandlerMove:(CGPoint)pointInView andView:(UIView *)view {
    
    if (shouldMove) {
        return;
    }
    shouldMove = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shouldMove = NO;
    });
    CGRect handleRect = view.frame;
    if (pointInView.y - handleRect.origin.y < shouldMoveMargin ) {
        //应该向上移动
        CGFloat actionY =  pointInView.y - handleRect.origin.y + shouldMoveMargin;
        CGPoint newContentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y - actionY);
        if (newContentOffset.y <= 0) {
            newContentOffset.y = 0;
        }
        [self.collectionView setContentOffset:newContentOffset animated:YES];
        
    } else {
        if ( handleRect.size.height - ( pointInView.y - handleRect.origin.y )  < shouldMoveMargin ) {
            //应该向下移动了
            CGFloat actionY = ( pointInView.y - handleRect.origin.y ) - (handleRect.size.height - shouldMoveMargin);
            CGPoint newContentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + actionY);
            if (newContentOffset.y > self.collectionView.contentSize.height - self.collectionView.frame.size.height) {
                newContentOffset.y = self.collectionView.contentSize.height - self.collectionView.frame.size.height;
            }
            [self.collectionView setContentOffset:newContentOffset animated:YES];
        }
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

@end
