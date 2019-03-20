//
//  EBElementView.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define RequiredLabelWidth 10
#define EBElementViewStarVisible 1
#define EBElementViewStarHidden 0

@class EBElement, EBElementStyle, EBElementView;

@protocol EBElementViewDelegate <NSObject>

@optional
- (void)viewDidSelect:(EBElementView *)elementView;
- (void)viewDidChanged:(EBElementView *)elementView;

@end

@protocol EBElementView <NSObject>

- (void)drawView;
//- (void)required;
//- (void)textFieldDidBeginEditing:(NSNotification *) notification;
- (NSString *)valueOfView;
- (void)setValueOfView:(id)value;
- (void)enableView:(BOOL)enable;

@optional
- (BOOL)matchRegex;
- (BOOL)valid;

@end

@interface EBElementView : UIView <EBElementView>

@property (nonatomic, strong) UILabel *requiredLabel;
@property (nonatomic, strong) UIView *underlineView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) EBElement *element;
@property (nonatomic, strong) EBElementStyle *style;
@property (nonatomic, weak) id<EBElementViewDelegate> delegate;

+ (CGRect)defaultFrame;

- (id)initWithStyle:(CGRect)frame element:(EBElement *)element style:(EBElementStyle *)style;
- (void)onSelect:(id)sender;
- (void)deSelect:(id)sender;

- (CGRect)contentFrame;
- (CGSize)actualSize:(NSString *)text constrainedToSize:(CGSize)size font:(UIFont *)font;

@end
