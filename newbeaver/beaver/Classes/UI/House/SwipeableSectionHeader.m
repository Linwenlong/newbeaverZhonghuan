//
//  SwipeableSectionHeader.m
//  Test1
//
//  Created by 林文龙 on 2018/11/29.
//  Copyright © 2018年 林文龙. All rights reserved.
//

#import "SwipeableSectionHeader.h"


@interface SwipeableSectionHeader()

@property (nonatomic, assign) NSInteger section;//分区索引
@property (nonatomic, strong) UIView * container; //放置文本标签和按钮的容器
@property (nonatomic, strong) UILabel * titleLable;//文本标签
@property (nonatomic, strong) UIButton * transferButton; //转移按钮
@property (nonatomic, strong) UIButton * deleteButton; //删除按钮

@property (nonatomic, strong) UISwipeGestureRecognizer * swiptLeft;//向左滑动手势
@property (nonatomic, strong) UISwipeGestureRecognizer * swiptRight;//向右滑动手势

@property (nonatomic, strong) UITapGestureRecognizer * tapGR;       //点击手势

@property (nonatomic, strong) UILongPressGestureRecognizer * longGR; //长按手势

@property (nonatomic, strong) UIView * coverView;

@property (nonatomic, strong) UIView * line1;
@property (nonatomic, strong) UIView * line2;
@property (nonatomic, strong) UIImageView * img;

@end

@implementation SwipeableSectionHeader

- (instancetype)initWithFrame:(CGRect)frame section:(NSInteger)section imgRatate:(BOOL)ratate title:(NSString *)titleName
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI:ratate title:titleName];
        self.tag = section;
    }
    return self;
}

- (void)setUI:(BOOL)ratate title:(NSString *)titleName{
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    //初始化容器
    self.container = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.frame.size.width+120, self.frame.size.height-20)];
    self.container.userInteractionEnabled = YES;
    self.container.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.container];
    
    self.line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    self.line1.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    [self.container addSubview:self.line1];
    
    //设置标题为本标签
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.frame.size.width, self.container.frame.size.height)];
    self.titleLable.textColor = [UIColor blackColor];
    self.titleLable.text = titleName;
    self.titleLable.font = [UIFont systemFontOfSize:18.0f];
    self.titleLable.textAlignment = NSTextAlignmentLeft;;
    [self.container addSubview:self.titleLable];
    
    self.transferButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width, 0, 60, self.container.frame.size.height)];
    
    self.transferButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.80 alpha:1.00];
    self.transferButton.tag = 1;
    [self.transferButton setTitle:@"转移" forState:UIControlStateNormal];
    [self.transferButton addTarget:self action:@selector(caozuo:) forControlEvents:UIControlEventTouchUpInside];
    [self.transferButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    
    [self.container addSubview:self.transferButton];
    
    
    //设置初始化按钮
    self.deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width + 60, 0, 60, self.container.frame.size.height)];
    self.deleteButton.tag = 2;
    self.deleteButton.backgroundColor = [UIColor redColor];
    [self.deleteButton addTarget:self action:@selector(caozuo:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    
    [self.container addSubview:self.deleteButton];
    
    //点击手势
    self.tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerViewTap:)];
    [self addGestureRecognizer:_tapGR];
    
    //向左滑动手势
    self.swiptLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(headerViewSwiped:)];
    self.swiptLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:self.swiptLeft];
    
    //向右滑动手势
    self.swiptRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(headerViewSwiped:)];
    self.swiptRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:self.swiptRight];
    
    //长按手势
    self.longGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressClick:)];
    [self addGestureRecognizer:self.longGR];
    
    _img = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-14-10, 0, 7, 14)];
    _img.centerY = self.titleLable.centerY;
    _img.userInteractionEnabled = YES;
    UIImage *image = [UIImage imageNamed:@"房源收藏_右键"];
    _img.image = image;
    [self.container addSubview:_img];
    if (ratate == YES) {
        [UIView animateWithDuration:0.3f animations:^{
            self.img.transform = CGAffineTransformMakeRotation(M_PI/2);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    self.line2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.container.frame.size.height-1, self.frame.size.width, 1)];
    self.line2.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    [self.container addSubview:self.line2];
}


- (void)headerViewTap:(UITapGestureRecognizer *)tapGR{
    CGRect newFrame = self.container.frame;
    __weak typeof(self) weakself=self;
    if (newFrame.origin.x != 0) {//点击返回按钮
        newFrame.origin.x = 0;
        [UIView animateWithDuration:0.25 animations:^{
            weakself.container.frame = newFrame;
        }];
    }else{
    
        self.sectionTapClick(self);
    }
    
}

- (void)caozuo:(UIButton *)btn{
    self.btnClick(btn);
}

- (void)longPressClick:(UILongPressGestureRecognizer *)longGR{
    if ([longGR state] == UIGestureRecognizerStateBegan) {//识别一次
        self.longTapClick(self);
    }
}


- (void)headerViewSwiped:(UISwipeGestureRecognizer *)swipeGR{
    if (swipeGR.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.container.frame;
        
        if (swipeGR.direction == UISwipeGestureRecognizerDirectionLeft) {
            newFrame.origin.x = -(self.deleteButton.frame.size.width+self.transferButton.frame.size.width);
        }else{
            newFrame.origin.x = 0;
        }
        __weak typeof(self) weakself=self;
        [UIView animateWithDuration:0.25 animations:^{
            weakself.container.frame = newFrame;
        }];
        
    }
}


@end
