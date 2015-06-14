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

@interface ViewController ()
@property(nonatomic , weak)XXBMoveView *moviewView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviewView.backgroundColor = [UIColor grayColor];
    NSMutableArray  *dataArray = [NSMutableArray array];
    for ( int i = 0; i < 4; i ++)
    {
        [dataArray addObject:[[XXBMoveCellModel alloc] initWithIndex:i]];
    }
    self.moviewView.dataArray = dataArray;
}
- (XXBMoveView *)moviewView
{
    if (_moviewView == nil)
    {
        XXBMoveView *moveView = [[XXBMoveView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:moveView];
        moveView.autoresizingMask = (1 << 6) - 1;
        _moviewView = moveView;
    }
    return _moviewView;
}

@end
