//
//  ViewController.m
//  moveTest
//
//  Created by 杨小兵 on 15/6/3.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBMoveView.h"

@interface ViewController ()
@property(nonatomic , weak)XXBMoveView *moviewView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviewView.backgroundColor = [UIColor grayColor];
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
