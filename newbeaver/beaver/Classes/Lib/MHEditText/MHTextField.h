//
//  MHTextField.h
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHTextField : UITextField

@property (nonatomic) BOOL required;
@property (nonatomic) BOOL hideToolBar;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, setter = setDateField:) BOOL isDateField;
@property (nonatomic, setter = setEmailField:) BOOL isEmailField;
@property (nonatomic, strong) NSMutableArray *textFields;

- (BOOL) validate;
- (void) setDateFieldWithFormat:(NSString *)dateFormat;
- (void)markTextFieldsWithTagInView:(UIView*)view;
- (void) nextButtonIsClicked:(id)sender;
- (void) previousButtonIsClicked:(id)sender;

@end
