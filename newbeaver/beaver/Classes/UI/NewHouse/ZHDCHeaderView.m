//
//  ZHDCHeaderView.m
//  CentralManagerAssistant
//
//  Created by mac on 17/1/8.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//



#define cell_h   50
#define menu_h   50

#import "ZHDCHeaderView.h"
#import <UIKit/UIKit.h>

@interface ZHDCHeaderView ()

@property (nonatomic,strong) UIView         *backView;
@property (nonatomic,strong) UITableView    *tableFirst;
@property (nonatomic,strong) NSMutableArray *dataSourceFirst;
@property (nonatomic,strong) NSMutableArray *dataSourceSecond;
@property (nonatomic,strong) NSMutableArray *allData;
@property (nonatomic,strong) NSMutableArray *allDataSource;
@property (nonatomic,assign) BOOL           firstTableViewShow;
@property (nonatomic,assign) BOOL           secondTableViewShow;
@property (nonatomic,assign) NSInteger      lastSelectedIndex;
@property (nonatomic,strong) NSMutableArray *bgLayers;
@property (nonatomic,strong) NSMutableArray *bgIndicorLayers;

@end

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@implementation ZHDCHeaderView

- (void)createOneMenuTitleArray:(NSArray *)menuTitleArray FirstArray:(NSArray *)FirstArray{
    
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:FirstArray];
    
    [self createTableViewFirst];
}
- (void)createTwoMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr{
    
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:firstArr];
    [self.allDataSource addObject:secondArr];
    
    [self createTableViewFirst];
}

- (void)createThreeMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr threeArr:(NSArray *)threeArr{
    
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:firstArr];
    [self.allDataSource addObject:secondArr];
    [self.allDataSource addObject:threeArr];
    
    [self createTableViewFirst];
}

- (void)createFourMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr threeArr:(NSArray *)threeArr fourArr:(NSArray *)fourArr{
    
    [self createMenuViewWithData:menuTitleArray];
    [self.allDataSource addObject:firstArr];
    [self.allDataSource addObject:secondArr];
    [self.allDataSource addObject:threeArr];
    [self.allDataSource addObject:fourArr];
    
    [self createTableViewFirst];
    //    [self createTableViewSecond];
}

- (void)changeMenuDataWithIndex:(NSInteger)index{
    [self createWithFirstData:self.allDataSource[index]];
}
- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point{
    CAShapeLayer *layer = [CAShapeLayer new];
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(10, 0)];
    [path addLineToPoint:CGPointMake(5, 6)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.8;
    layer.fillColor = [UIColor blackColor].CGColor;
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}


- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position{
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, 20, 20);
    layer.backgroundColor = color.CGColor;
    return layer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ) {
        return NO;
    }
    return YES;
}

- (void)remover{
    self.firstTableViewShow = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), kScreenW, 0);
    }];
    [self hideCarverView];
}
- (void)createMenuViewWithData:(NSArray *)data{
    
    self.lastSelectedIndex = -1;
    self.backgroundColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreenW, 40);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remover)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;

    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, menu_h)];
    
    self.backView.userInteractionEnabled = YES;
    
    self.backView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.backView];
    
    /**创建Btn*/
    CGFloat btn_Width =  kScreenW/data.count;
    CGFloat btn_Height = menu_h;
    CGFloat btn_Img_Width_Height = 5.0f;
    NSInteger num = data.count;
    for (int i = 0; i < num; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenW/num*i, 0, kScreenW/num-1, menu_h)];
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag = 100+i;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.titleLabel.numberOfLines = 0;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:data[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showFirstTableView:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    
        btn.adjustsImageWhenHighlighted = NO;
        btn.imageEdgeInsets = UIEdgeInsetsMake((btn_Height - btn_Img_Width_Height)/2-2.5, btn_Width - 15-2.5, (btn_Height - btn_Img_Width_Height)/2-2.5, 5-2.5);
        NSLog(@"frame = %@",NSStringFromCGRect(btn.imageView.frame));
        btn.imageView.frame = CGRectMake(btn.imageView.frame.origin.x, btn.imageView.frame.origin.y, 12, 12);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        [self.backView addSubview:btn];
    }
    UILabel *VlineLbTop = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.backView.frame.size.width, 1)];
    VlineLbTop.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *VlineLbBom = [[UILabel alloc]initWithFrame:CGRectMake(0, menu_h, self.backView.frame.size.width, 1)];
    VlineLbBom.backgroundColor = [UIColor lightGrayColor];
    
    [self.backView addSubview:VlineLbTop];
    [self.backView addSubview:VlineLbBom];
}

- (void)showFirstAndSecondTableView:(NSInteger)index{
    [self changeMenuDataWithIndex:index-100];
    if (self.firstTableViewShow == NO) {
        self.firstTableViewShow = YES;
        [self showCarverView];
        if (cell_h*self.dataSourceFirst.count>kScreenH-104) {
            [UIView animateWithDuration:0.2 animations:^{
                self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), kScreenW,kScreenH-104 );
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), kScreenW, (cell_h)*self.dataSourceFirst.count);
            }];
        }
    }else{
        self.firstTableViewShow = NO;
        //恢复所有的按钮
        for (UIView *object in self.backView.subviews) {
            if ([object isKindOfClass:[UIButton class]] ) {
                [(UIButton *)object setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [(UIButton *)object setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            }
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), kScreenW, 0);
        }];
        [self hideCarverView];
    }
    self.lastSelectedIndex = index;
}
- (void)showCarverView{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreenW, kScreenH-self.frame.origin.y);
        
    }];
}
- (void)hideCarverView{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreenW, menu_h);
    }];
    
}

#pragma mark -- Method Btn
- (void)showFirstTableView:(UIButton *)btn{
    
    for (UIView *object in self.backView.subviews) {
        if ([object isKindOfClass:[UIButton class]] ) {
             [(UIButton *)object setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [(UIButton *)object setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }
    }
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    if (self.lastSelectedIndex != btn.tag && self.lastSelectedIndex !=-1) {
        [UIView animateWithDuration:0.1 animations:^{
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), kScreenW, 0);
        }completion:^(BOOL finished) {
            self.firstTableViewShow = NO;
            self.secondTableViewShow = NO;
            [self showFirstAndSecondTableView:btn.tag];
        }];
    }else{
        [self showFirstAndSecondTableView:btn.tag];
    }
}

- (void)showSecondTabelView:(BOOL)secondTableViewShow{
    if (self.secondTableViewShow == YES) {
        [self showCarverView];
        
    }else{
        [self showCarverView];
    }
    
}

- (void)createWithFirstData:(NSArray *)dataFirst{
    self.dataSourceFirst = [NSMutableArray arrayWithArray:dataFirst];
    [self.tableFirst reloadData];
}


- (void)createTableViewFirst{
    self.tableFirst = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.backView.frame),kScreenW,0) style:UITableViewStylePlain];
    self.tableFirst.scrollEnabled = YES;
    self.tableFirst.delegate = self;
    self.tableFirst.dataSource = self;
    [self insertSubview:self.tableFirst belowSubview:self.backView];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_h;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceFirst.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableFirst) {
        static NSString *cellID = @"cellFirst";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        cell1.textLabel.text = self.dataSourceFirst[indexPath.row];
        cell1.textLabel.font = [UIFont systemFontOfSize:16];
        cell1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell1;
        
    }else{
        static NSString *cellIde = @"cellSecond";
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (cell2 == nil) {
            cell2 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIde];
        }
        cell2.textLabel.text = self.dataSourceSecond[indexPath.row];
        cell2.textLabel.font = [UIFont systemFontOfSize:12];
        return cell2;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableFirst) {
        //还原button
        for (UIView *object in self.backView.subviews) {
            if ([object isKindOfClass:[UIButton class]] ) {
                [(UIButton *)object setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [(UIButton *)object setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            }
        }
        UIButton *btn = (id)[self viewWithTag:self.lastSelectedIndex];
        [btn setTitle:self.dataSourceFirst[indexPath.row] forState:UIControlStateNormal];
        self.firstTableViewShow = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.tableFirst.frame = CGRectMake(0, CGRectGetMaxY(self.backView.frame), kScreenW, 0);
        }];
      
        [self hideCarverView];
        [_delegate menuCellDidSelected:self.lastSelectedIndex-100 andDetailIndex:indexPath.row];
        
    }
}
- (NSMutableArray *)allDataSource{
    if (_allDataSource == nil) {
        _allDataSource = [NSMutableArray array];
    }
    return _allDataSource;
}

@end

