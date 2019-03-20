//
//  ZHDCDetailHeadView.m
//  beaver
//
//  Created by mac on 17/4/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCDetailHeadView.h"
#import "SDAutoLayout.h"
#import "UIImageView+WebCache.h"

@interface ZHDCDetailHeadView ()<UIScrollViewDelegate>

@property (nonatomic, weak)NSArray *images;

@property (nonatomic, strong)UIScrollView *imageScrollView;
@property (nonatomic, strong)UIPageControl *pageControl;

@property (nonatomic, strong)NSString * callNum;

@end

@implementation ZHDCDetailHeadView

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _imageScrollView.height-25, kScreenW, 30)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    return _pageControl;
}

- (UIScrollView *)imageScrollView{
    if (!_imageScrollView) {
        _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 9*kScreenW/16)];
        _imageScrollView.pagingEnabled = YES;
        _imageScrollView.delegate = self;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
    }
    return _imageScrollView;
}

- (instancetype)initWithFrame:(CGRect)frame ImageArray:(NSArray *)images  andCommission:(NSDictionary*)commission otherDic:(NSDictionary *)dic{
    self = [super initWithFrame:frame];
    if (self) {
        _images = images;
        [self config:images  andCommission:commission andOther:dic];
    }
    return self;
}
//配置图片
- (void)config:(NSArray *)images andCommission:(NSDictionary*)commission andOther:(NSDictionary*)dic{
    //可能images为空

    [self addSubview:self.imageScrollView];
 
    //添加图片(点击图片的方法)
    for (int i=0; i<images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenW*i, 0, _imageScrollView.width, _imageScrollView.height)];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterImageController:)];
        [imageView addGestureRecognizer:tap];
        [imageView sd_setImageWithURL:[NSURL URLWithString:images[i]] placeholderImage:[UIImage imageNamed:@"默认图"]];
//        imageView.image = [UIImage imageNamed:images[i]];
        [_imageScrollView addSubview:imageView];
    }
   
    _imageScrollView.contentSize = CGSizeMake(kScreenW*images.count, 0);
         [self addSubview:self.pageControl];
    _pageControl.numberOfPages = images.count;
    _pageControl.currentPage = 0;
    if (images.count == 0) {
        _imageScrollView.height = 0;
        _pageControl.hidden = YES;
    }
    //设置佣金跟名字
    CGFloat maxY =  [self addCommission:commission];
    //设置其他的
    [self addOther:dic maxY:maxY];
}
- (void)addOther:(NSDictionary *)dic maxY:(CGFloat)maxY{
     CGFloat X = 20;
    CGFloat Y = 10;
    CGFloat H = 30;
    //    [_others setValue:dic[@"address"] forKey:@"address"];//地址
    //    [_others setValue:dic[@"primary_user_name"] forKey:@"primary_user_name"];//维护人
    //    [_others setValue:dic[@"primary_user_tel"] forKey:@"primary_user_tel"];//维护人电话
    //    [_others setValue:dic[@"start_date"] forKey:@"start_date"];//维护人电话
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    //address
    UILabel *address = [UILabel new];
    address.text = [NSString stringWithFormat:@"地 址 : %@",dic[@"address"]];
    address.numberOfLines = 0;
    address.font = font;
    address.textAlignment = NSTextAlignmentLeft;
//    UIImageView *addressImg = [UIImageView new];
//    addressImg.image = [UIImage imageNamed:@"地址"];
    UILabel *addressLine = [UILabel new];
     addressLine.backgroundColor = UIColorFromRGB(0xE7E7E7);
    [self addSubview:address];
//    [self addSubview:addressImg];
    [self addSubview:addressLine];
    address.sd_layout
    .topSpaceToView(self,maxY+Y)
    .leftSpaceToView(self,X)
    .widthIs([self sizeToWith:font content: [NSString stringWithFormat:@"地 址 : %@",dic[@"address"]]])
    .heightIs(H);
//    addressImg.sd_layout
//    .topSpaceToView(self,maxY+Y+5)
//    .rightSpaceToView(self,X)
//    .widthIs(20*29/37)
//    .heightIs(20);
    addressLine.sd_layout
    .topSpaceToView(address,Y)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(1);
    
    //person
    UILabel *person = [UILabel new];
    person.text =  [NSString stringWithFormat:@"维护人 : %@",dic[@"primary_user_name"]];
    person.font  = font;
//    UIImageView *personImg = [UIImageView new];
//    personImg.image = [UIImage imageNamed:@"人"];
    //number
    UILabel *number = [UILabel new];
    number.font = font;
    number.text =  [NSString stringWithFormat:@"电话 : %@",dic[@"primary_user_tel"]];
    _callNum = dic[@"primary_user_tel"];
    UIImageView *numberImg = [UIImageView new];
    numberImg.image = [UIImage imageNamed:@"电话"];
    //手势拨打电话
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(call:)];
    numberImg.userInteractionEnabled = YES;
    [numberImg addGestureRecognizer:tap];
    
    UILabel *numLine = [UILabel new];
    numLine.backgroundColor = UIColorFromRGB(0xE7E7E7);
    [self addSubview:person];
//    [self addSubview:personImg];
    [self addSubview:number];
    [self addSubview:numberImg];
    [self addSubview:numLine];
    person.sd_layout
    .topSpaceToView(addressLine,Y)
    .leftSpaceToView(self,X)
    .widthIs([self sizeToWith:font content:[NSString stringWithFormat:@"维护人 : %@",dic[@"primary_user_name"]]])
    .heightIs(H);
//    personImg.sd_layout
//    .topSpaceToView(addressLine,Y+5)
//    .leftSpaceToView(person,10)
//    .widthIs(20)
//    .heightIs(20);
    
    numberImg.sd_layout
    .topSpaceToView(addressLine,Y)
    .rightSpaceToView(self,X)
    .widthIs(20)
    .heightIs(20);
    
    number.sd_layout
    .topSpaceToView(addressLine,Y)
    .rightSpaceToView(numberImg,10)
    .widthIs([self sizeToWith:font content: [NSString stringWithFormat:@"电话 : %@",dic[@"primary_user_tel"]]])
    .heightIs(H);
    numLine.sd_layout
    .topSpaceToView(person,Y)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(1);
    
    //date
    UILabel *date = [UILabel new];
    NSString *dateString = [NSString stringWithFormat:@"%@",dic[@"start_date"]];
    date.text =[NSString stringWithFormat:@"合作日期:%@",[self timeWithTimeIntervalString:dateString]];
    date.font = font;
    
    UILabel *dateLine = [UILabel new];
    dateLine.backgroundColor = UIColorFromRGB(0xE7E7E7);
    [self addSubview:date];
    [self addSubview:dateLine];
    date.sd_layout
    .topSpaceToView(numLine,Y)
    .leftSpaceToView(self,X)
    .widthIs([self sizeToWith:font content:[NSString stringWithFormat:@"合作日期:%@",[self timeWithTimeIntervalString:dateString]]])
    .heightIs(H);
    dateLine.sd_layout
    .topSpaceToView(date,Y)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(1);
    
    UIView *endView = [UIView new];
    endView.backgroundColor = UIColorFromRGB(0xEBEBEB);
    [self addSubview:endView];
    endView.sd_layout
    .topSpaceToView(dateLine,0)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(10);
    
    self.height = maxY+160;
    
    NSLog(@"float=%f",self.height);
}

- (CGFloat)addCommission:(NSDictionary *)commissiondic{

    CGFloat X = 20;
    CGFloat Y = 15;
    CGFloat spcing = 5;
    CGFloat H = 30;
    NSLog(@"sale_status=%@",commissiondic[@"sale_status"]);
    UIFont *font = [UIFont systemFontOfSize:20.f];
    UILabel *name = [UILabel new];
    name.text = commissiondic[@"title"] ;
    name.font = [UIFont boldSystemFontOfSize:20.0f];
    [self addSubview:name];
    UIImageView *imageviewicon = [UIImageView new];
    if ([commissiondic[@"sale_status"] isEqualToString:@"认筹"]) {
         imageviewicon.image = [UIImage imageNamed:@"chow.jpeg"];
    }else{
        imageviewicon.image = [UIImage imageNamed:@"sale.jpeg"];
    }
    [self addSubview:imageviewicon];
    name.sd_layout
    .topSpaceToView(_imageScrollView,Y)
    .leftSpaceToView(self,X)
    .widthIs([self sizeToWith:font content:commissiondic[@"title"] ])
    .heightIs(H);
    
    //判断是否有括号
    NSString *nameText = commissiondic[@"title"] ;
    NSString *lastStr = [nameText substringFromIndex:nameText.length-1];
    CGFloat left = 1;
    if ([lastStr isEqualToString:@"）"]) {
        left = -7;
    }

    imageviewicon.sd_layout
    .topSpaceToView(_imageScrollView,Y+5)
    .leftSpaceToView(name,left)
    .widthIs(20)
    .heightIs(20);
    for (int i = 0; i < commissiondic.allKeys.count - 3; i++) {
        UILabel *commission = [UILabel new];
        commission.textColor = [UIColor redColor];
        commission.font = font;
        commission.text = [NSString stringWithFormat:@"佣金%@", commissiondic[@"commission_text"]];
        UILabel *type = [UILabel new];
        type.text = commissiondic[@"purpose"];
        type.backgroundColor = UIColorFromRGB(0xE3F4FB);
        type.font = [UIFont systemFontOfSize:14.f];
        type.textAlignment = NSTextAlignmentCenter;
        type.textColor = [UIColor blueColor];
        [self addSubview:commission];
        [self addSubview:type];
        
        commission.sd_layout
        .topSpaceToView(name,(i+1)*spcing+i*H)
        .leftSpaceToView(self,X)
        .widthIs([self sizeToWith:font content:[NSString stringWithFormat:@"佣金%@", commissiondic[@"commission_text"]]])
        .heightIs(H);
        type.sd_layout
        .topSpaceToView(commission,(i+1)*spcing+i*H)
        .leftSpaceToView(self,X)
        .widthIs([self sizeToWith:[UIFont systemFontOfSize:14.f] content:commissiondic[@"purpose"]])
        .heightIs(20);
    }
    //线
    NSInteger count = commissiondic.allKeys.count;
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, (count-1)*H+(count-2)*spcing+Y*2-1+_imageScrollView.height, kScreenW, 1)];
    line.backgroundColor = UIColorFromRGB(0xE7E7E7);
    [self addSubview:line];
    return CGRectGetMaxY(line.frame);
}

- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-50,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width+10;
}
#pragma mark -- scrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollView.contentOffset.x = %f",scrollView.contentOffset.x);
    NSInteger index = scrollView.contentOffset.x/kScreenW;
    
    _pageControl.currentPage = index;
}

#pragma mark -- ImageDelegate
- (void)enterImageController:(UITapGestureRecognizer *)tap{
    if (_imageClickDelegate && [_imageClickDelegate respondsToSelector:@selector(image: imageTitle: images:)]) {
        [_imageClickDelegate image:(UIImageView*)tap.view imageTitle:_images[tap.view.tag] images:_images];
    }
}

#pragma mark -- call
- (void)call:(UITapGestureRecognizer *)tap{
    NSString *str = [NSString stringWithFormat:@"telprompt:%@",_callNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark -- 时间戳转时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

@end
