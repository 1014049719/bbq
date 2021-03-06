//
//  BBQChooseStatusWireframe.h
//  DailyReportDemo
//
//  Created by 朱琨 on 15/10/8.
//  Copyright © 2015年 gzxlt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBQChooseStatusWireframe : NSObject

@property (assign, nonatomic) NSInteger flag;
@property (copy, nonatomic) NSString *classuid;

- (void)presentChooseStatusControllerFromWindow:(UIWindow *)window;
- (void)presentChooseStatusControllerFromNavigationController:(UINavigationController *)navigationController;
- (void)presentChooseStatusControllerFromViewController:(UIViewController *)viewController;
- (void)presentEditWordsController;

@end
