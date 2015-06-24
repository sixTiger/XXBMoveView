# moveTest
##一个可以拖动的cell
###使用非常的简单
使用方法如下<br>
``` c
- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviewView.backgroundColor = [UIColor grayColor];
    NSMutableArray  *dataArray = [NSMutableArray array];
    for ( int i = 0; i < 61; i ++)
    {
        [dataArray addObject:[[XXBMoveCellModel alloc] initWithIndex:i]];
    }
    self.moviewView.dataArray = dataArray;
    self.moviewView.moveCellLayout = (XXBMoveCellLayout){10,10,100,100};
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
```
![动画效果如下](/image/moveTest.gif)
