//
//  CustomAnnotationView.m
//  beaver
//
//  Created by linger on 16/2/28.
//  Copyright © 2016年 eall. All rights reserved.
//

#import "CustomAnnotationView.h"
@interface CustomAnnotationView ()

@property (nonatomic, strong) UIButton *nameLabel;
@property (nonatomic, strong) UIImage *selImage;
@property (nonatomic, strong) UIImage *normalImage;

@end
@implementation CustomAnnotationView
#pragma mark - Override
@synthesize nameLabel           = _nameLabel;

- (NSString *)name
{
    return self.nameLabel.titleLabel.text;
}

- (CGFloat)singleLineHeight:(UIFont *)font
{
    return [self textSize:@"A" font:font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
}
- (CGSize)textSize:(NSString *)text font:(UIFont *)font bounding:(CGSize)size
{
    if (!(text && font) || [text isEqual:[NSNull null]]) {
        return CGSizeZero;
    }
    CGRect rect = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
    return CGRectIntegral(rect).size;
}
- (void)setName:(NSString *)name
{
    [self.nameLabel setTitle:name forState:UIControlStateNormal];
    CGSize size = [self textSize:name font:self.nameLabel.titleLabel.font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    UIImage *bgImage = nil;
    UIImage *selecImage = nil;
    if (size.height > [self singleLineHeight:self.nameLabel.titleLabel.font]) {
        self.nameLabel.titleLabel.font = [UIFont systemFontOfSize:14.0];
        bgImage = [UIImage imageNamed:@"map_annotation_circle"];
        self.width = self.height = self.nameLabel.width = self.nameLabel.height = bgImage.size.height;
        self.centerOffset = CGPointMake(0, 0);
    }
    else{
        self.nameLabel.titleLabel.font = [UIFont systemFontOfSize:14.0];
        self.nameLabel.titleEdgeInsets = UIEdgeInsetsMake(-5, 0.0, 0.0, 0.0);
        selecImage = [UIImage imageNamed:@"tab_chat_selected"];
        bgImage = [UIImage imageNamed:@"tab_chat_selected"];
        self.height = self.nameLabel.height = 40.0;
        self.width = self.nameLabel.width = size.width + 20;
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height * 0.2f, bgImage.size.width * 0.7f, bgImage.size.height * 0.8f, bgImage.size.width * 0.3f)];
        _normalImage = bgImage;
        selecImage = [selecImage resizableImageWithCapInsets:UIEdgeInsetsMake(selecImage.size.height * 0.2f, selecImage.size.width * 0.7f, selecImage.size.height * 0.8f, selecImage.size.width * 0.3f)];
        _selImage = selecImage;
        self.centerOffset = CGPointMake((self.width/2.0 - 15), - 10);
    }
    [self.nameLabel setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.nameLabel setBackgroundImage:bgImage forState:UIControlStateHighlighted];
    [self.nameLabel setBackgroundImage:selecImage forState:UIControlStateSelected];
    
}
- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.bounds = CGRectMake(0.f, 0.f, 0.0, 0.0);
        self.backgroundColor = [UIColor clearColor];
        
        /* Create name label. */
        self.nameLabel = [[UIButton alloc] initWithFrame:CGRectMake(0.0,0.0,0.0,0.0)];
        self.nameLabel.titleLabel.textAlignment    = NSTextAlignmentCenter;
        self.nameLabel.titleLabel.textColor        = [UIColor whiteColor];
        self.nameLabel.titleLabel.font             = [UIFont systemFontOfSize:14.f];
        self.nameLabel.titleLabel.numberOfLines    = 0;
        self.nameLabel.userInteractionEnabled      = NO;
        [self addSubview:self.nameLabel];
    }
    return self;
}
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self.nameLabel setBackgroundImage:_selImage forState:UIControlStateNormal];
    }else{
        [self.nameLabel setBackgroundImage:_normalImage forState:UIControlStateNormal];
    }
}

@end
