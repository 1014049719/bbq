//
//  BBQPopupControllerFactory.h
//  BBQ
//
//  Created by 朱琨 on 16/1/20.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQPopupController.h"

typedef NS_ENUM(NSUInteger, BBQPopupControllerType) {
    BBQPopupControllerTypeShare,
    BBQPopupControllerTypeTag,
    BBQPopupControllerTypePay,
    BBQPopupControllerTypeCalendar,
    BBQPopupControllerTypeDatePicker,
};

@interface BBQPopupControllerFactory : NSObject

+ (BBQPopupController *)popupControllerWithType:(BBQPopupControllerType)type;

@end
