//
//  BBQPopupController.h
//  BBQ
//
//  Created by 朱琨 on 16/1/20.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <CNPPopupController/CNPPopupController.h>

@class BBQPopupController;

@protocol BBQPopupControllerDelegate <CNPPopupControllerDelegate>

@optional
//  Date Picker
- (void)popupController:(BBQPopupController *)controller didSelectDate:(NSDate *)date;
- (NSDate *)selectedDateForPopupController:(BBQPopupController *)controller;
- (NSDate *)maximumDateForPopupController:(BBQPopupController *)controller;
- (NSDate *)minimumDateForPopupController:(BBQPopupController *)controller;
//  Share View

@end

@interface BBQPopupController : CNPPopupController

@property (weak, nonatomic) id<BBQPopupControllerDelegate> delegate;

@end
