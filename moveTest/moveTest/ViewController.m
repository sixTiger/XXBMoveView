//
//  ViewController.m
//  moveTest
//
//  Created by 杨小兵 on 15/6/3.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBMoveView.h"
#import "XXBMoveCellModel.h"

@interface ViewController ()<XXBMoveViewDelegte>
@property(nonatomic , weak)XXBMoveView *moviewView;

@property(nonatomic , strong)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviewView.backgroundColor = [UIColor grayColor];
    _dataArray = [NSMutableArray array];
    for ( int i = 0; i < 81; i ++)
    {
        [_dataArray addObject:[[XXBMoveCellModel alloc] initWithIndex:i]];
    }
    self.moviewView.dataArray = _dataArray;
    self.moviewView.moveCellLayout = (XXBMoveCellLayout){10,10,100,100};
}
- (XXBMoveView *)moviewView
{
    if (_moviewView == nil)
    {
        XXBMoveView *moveView = [[XXBMoveView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:moveView];
        moveView.autoresizingMask = (1 << 6) - 1;
        moveView.delegate = self;
        _moviewView = moveView;
    }
    return _moviewView;
}
- (void)moveViewStartMove:(XXBMoveView *)moveView
{
    
    for (XXBMoveCellModel * moveCellModel in self.dataArray)
    {
        NSLog(@"开始移动 %@",moveCellModel);
    }
}
- (void)moveViewMoveing:(XXBMoveView *)moveView
{
    NSLog(@"正在移动");
}
- (void)moveViewEndMove:(XXBMoveView *)moveView
{
    for (XXBMoveCellModel * moveCellModel in self.dataArray)
    {
        NSLog(@"移动结束%@",moveCellModel);
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollView 正在滚动");
}
@end
