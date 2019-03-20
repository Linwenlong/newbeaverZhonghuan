//
//  EBSelectView.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/23/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBSelectView.h"
#import "EBSelectElement.h"
#import "EBElementStyle.h"

@interface EBSelectView() <UITextFieldDelegate>
{
    UITextField *inputTextField;
}
@end

@implementation EBSelectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawView
{
    EBSelectElement *selectElement;
    EBElementStyle *style;
    if (!self.element) {
        selectElement = [EBSelectElement new];
        selectElement.suffixImg = [UIImage imageNamed:@"images.bundle/arrow_right"];
        self.element = selectElement;
    } else {
        ((EBSelectElement *)self.element).suffixImg = [UIImage imageNamed:@"images.bundle/arrow_right"];
        selectElement = (EBSelectElement *)self.element;
    }
    
    if (!self.style) {
        style = [EBElementStyle new];
        style.fontSize = FontSizeDefault;
        style.font = [UIFont systemFontOfSize:style.fontSize];
        style.fontColor = [UIColor darkTextColor];
        style.prefixFont = style.suffixFont = style.font;
        style.prefixFontColor = style.suffixFontColor = style.fontColor;
        self.style = style;
    } else {
        style = self.style;
    }
    
    [super drawView];
    
    CGFloat requiredWidth, prefixWidth, suffixImgWidth, suffixWidth;
    requiredWidth = prefixWidth = suffixImgWidth = suffixWidth = 0;
    
    requiredWidth = self.requiredLabel ? self.requiredLabel.frame.size.width : 0 ;
    prefixWidth = self.preLabel ? self.preLabel.frame.size.width : 0;
    suffixImgWidth = self.sufImageView ? self.sufImageView.frame.size.width : 0;
    suffixWidth = self.sufLabel ? self.sufLabel.frame.size.width : 0;
//    CGFloat marginLeft = style.padding.left == 0 ? requiredWidth + prefixWidth : style.padding.left;
    CGFloat marginLeft = requiredWidth + prefixWidth;
    CGFloat marginRight = style.padding.right == 0 ? suffixWidth + suffixImgWidth : style.padding.right;
    inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(marginLeft, 0, self.frame.size.width - marginLeft - marginRight, self.frame.size.height)];
    [self addSubview:inputTextField];
    if (selectElement.placeholder && (selectElement.placeholder.length > 0))
    {
        inputTextField.placeholder = selectElement.placeholder;
    }
    else
    {
        inputTextField.placeholder = @"请选择";
    }
    inputTextField.textAlignment = style.textAlignment;
    inputTextField.textColor = style.fontColor;
    inputTextField.font = style.font;
    inputTextField.borderStyle = UITextBorderStyleNone;
    inputTextField.delegate = self;
    if (selectElement.selectedIndex > -1 && selectElement.selectedIndex < selectElement.options.count) {
        inputTextField.text = selectElement.options[selectElement.selectedIndex];
    }
    
    if (selectElement.text) {
        [self setValueOfView:selectElement.text];
    }
}

//- (void)setSelectValue:(NSInteger)selectedIndex
//{
//    EBSelectElement *selectElement = (EBSelectElement *)self.element;
//    if (selectedIndex < 0 || selectedIndex >= selectElement.options.count) {
//        selectElement.selectedIndex = -1;
//        inputTextField.text = @"";
//        return;
//    }
//    
//    selectElement.selectedIndex = selectedIndex;
//    selectElement.text = selectElement.options[selectedIndex];
//    inputTextField.text = selectElement.text;
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectViewShouldShowOptions:options:selectedIndex:)]) {
        [(id<EBSelectViewDelegate>)self.delegate selectViewShouldShowOptions:self options:((EBSelectElement *)self.element).options selectedIndex:((EBSelectElement *)self.element).selectedIndex];
    }
    
    return NO;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    inputTextField.frame = [self contentFrame];
}

- (NSString *)valueOfView
{
    return [inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setValueOfView:(id)value
{
    if (!value || [value isKindOfClass:NSNull.class]) {
        return;
    }
    EBSelectElement *selectElement = (EBSelectElement *)self.element;
    if (!selectElement.multiSelect) {
        if ([value isKindOfClass:NSString.class]) {
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([value isEqualToString:@""]) {
                [self setValueOfView:[NSNumber numberWithInteger:-1]];
                return;
            }
            NSUInteger index = 0;
            for (NSString *option in selectElement.options) {
                if ([option isEqualToString:value]) {
                    selectElement.selectedIndex = index;
                    selectElement.text = option;
                    inputTextField.text = selectElement.text;
                    return;
                }
                index++;
            }
            NSMutableArray *tmparr = [NSMutableArray arrayWithArray:selectElement.options];
            [tmparr addObject:value];
            selectElement.options = [NSArray arrayWithArray:tmparr];
            tmparr = nil;
            selectElement.selectedIndex = index;
            selectElement.text = value;
            inputTextField.text = selectElement.text;
            return;
        }
        
        NSInteger selectedIndex = [value integerValue];
        if (selectedIndex < 0 || selectedIndex >= selectElement.options.count) {
            selectElement.selectedIndex = -1;
            inputTextField.text = @"";
            return;
        }
        
        selectElement.selectedIndex = selectedIndex;
        selectElement.text = selectElement.options[selectedIndex];
        inputTextField.text = selectElement.text;
    } else {
        if ([value isKindOfClass:NSString.class]) {
            NSMutableArray *tmparr = [NSMutableArray new];
            for (NSString *tmpstr in [value componentsSeparatedByString:@";"]) {
                NSString *tmptmpstr = [tmpstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (![tmptmpstr isEqualToString:@""]) {
                    [tmparr addObject:tmptmpstr];
                }
            }
            NSUInteger flag = 0;
            NSMutableArray *addarr = [NSMutableArray new];
            for (NSString *tmpstr in tmparr) {
                flag = 0;
                for (NSString *tmpoption in selectElement.options) {
                    if ([tmpstr isEqualToString:tmpoption]) {
                        break;
                    }
                    flag++;
                }
                if (flag == selectElement.options.count) {
                    [addarr addObject:tmpstr];
                }
            }
            
            selectElement.options = [selectElement.options arrayByAddingObjectsFromArray:addarr];
            [addarr removeAllObjects];
            for (NSString *tmpstr in tmparr) {
                [addarr addObject:[NSNumber numberWithInteger:[selectElement.options indexOfObject:tmpstr]]];
            }
            selectElement.selectedIndexes = [NSArray arrayWithArray:addarr];
        } else {
            selectElement.selectedIndexes = [NSArray arrayWithArray:value];
        }
        
        inputTextField.text = @"";
        for (NSInteger i = 0; i < selectElement.selectedIndexes.count; i++) {
            if ([selectElement.selectedIndexes[i] integerValue] >= 0 && [selectElement.selectedIndexes[i] integerValue] < selectElement.options.count) {
                if (i != selectElement.selectedIndexes.count - 1) {
                    inputTextField.text = [inputTextField.text stringByAppendingString:[NSString stringWithFormat:@"%@; ", selectElement.options[[selectElement.selectedIndexes[i] integerValue]]]];
                }
                else
                {
                    inputTextField.text = [inputTextField.text stringByAppendingString:[NSString stringWithFormat:@"%@", selectElement.options[[selectElement.selectedIndexes[i] integerValue]]]];
                }
            }
        }
    }
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
    inputTextField.enabled = enable;
}

- (BOOL)valid
{
    if (self.element.required && [[self valueOfView] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)checkEmpty
{
    if ([[self valueOfView] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)onSelect:(id)sender
{
    [self textFieldShouldBeginEditing:inputTextField];
}

@end
