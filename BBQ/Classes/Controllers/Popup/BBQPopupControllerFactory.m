//
//  BBQPopupControllerFactory.m
//  BBQ
//
//  Created by 朱琨 on 16/1/20.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQPopupControllerFactory.h"

static NSArray * popupControllerTypeArray;

@implementation BBQPopupControllerFactory

+ (BBQPopupController *)popupControllerWithType:(BBQPopupControllerType)type {
    Class cls = NSClassFromString([[self typeArray] objectAtIndex:type]);
    BBQPopupController *popup = [[cls alloc] init];
    return popup;
}

+ (NSArray *)typeArray {
    if (!popupControllerTypeArray) {
        popupControllerTypeArray = @[@"BBQSharePopupController", @"BBQTagPopupController", @"BBQPayPopupController", @"BBQCalendarPopupController", @"BBQDatePickerPopupController"];
    }
    return popupControllerTypeArray;
}

@end
