//
//  BBQPopupDatePickerView.m
//  BBQ
//
//  Created by 朱琨 on 16/1/20.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQPopupDatePickerView.h"
#import <DateTools.h>

@implementation BBQPopupDatePickerView

-(void)awakeFromNib {
    self.height = 262;
    self.width = kScreenWidth;
}

- (IBAction)didClickCancelButton:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (IBAction)didClickConfirmButton:(id)sender {
    if (self.confirmBlock) {
        self.confirmBlock(self.datePicker.date);
    }
}

@end
