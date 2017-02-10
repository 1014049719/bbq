//
//  BBQDatePickerPopupController.m
//  BBQ
//
//  Created by 朱琨 on 16/1/20.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDatePickerPopupController.h"
#import "BBQPopupDatePickerView.h"
#import <DateTools.h>

@interface BBQDatePickerPopupController ()

@property (strong, nonatomic) BBQPopupDatePickerView *datePickerView;

@end

@implementation BBQDatePickerPopupController

- (instancetype)init {
    self = [super initWithContents:@[self.datePickerView]];
    if (self) {
        @weakify(self)
        self.datePickerView.cancelBlock = ^{
            @strongify(self)
            [self dismissPopupControllerAnimated:YES];
        };
        self.datePickerView.confirmBlock = ^(NSDate *date) {
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(popupController:didSelectDate:)]) {
                [self.delegate popupController:self didSelectDate:date];
                [self dismissPopupControllerAnimated:YES];
            }
        };
        self.theme.popupContentInsets = UIEdgeInsetsZero;
        self.theme.maxPopupWidth = kScreenWidth;
        self.theme.popupStyle = CNPPopupStyleActionSheet;
    }
    return self;
}

- (void)presentPopupControllerAnimated:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(minimumDateForPopupController:)] && [self.delegate minimumDateForPopupController:self]) {
        self.datePickerView.datePicker.minimumDate = [self.delegate minimumDateForPopupController:self];
    } else {
        self.datePickerView.datePicker.minimumDate = [[NSDate date] dateBySubtractingYears:10];
    }
    
    if ([self.delegate respondsToSelector:@selector(maximumDateForPopupController:)] && [self.delegate maximumDateForPopupController:self]) {
        self.datePickerView.datePicker.maximumDate = [self.delegate maximumDateForPopupController:self];
    } else {
        self.datePickerView.datePicker.maximumDate = [NSDate date];
    }

    if ([self.delegate respondsToSelector:@selector(selectedDateForPopupController:)] && [self.delegate selectedDateForPopupController:self]) {
        self.datePickerView.datePicker.date = [self.delegate selectedDateForPopupController:self];
    }
    [super presentPopupControllerAnimated:flag];
}

#pragma mark - Getter & Setter
- (BBQPopupDatePickerView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[NSBundle mainBundle] loadNibNamed:@"BBQPopupDatePickerView" owner:nil options:nil].firstObject;
    }
    return _datePickerView;
}

@end
