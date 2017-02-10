//
//  BBQDynamicDetailViewController.h
//  BBQ
//
//  Created by 朱琨 on 16/1/17.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQTableViewController.h"

@interface BBQDynamicDetailViewController : BBQTableViewController

- (instancetype)initWithDynamic:(Dynamic *)dynamic;
- (instancetype)initWithDynamicGuid:(NSString *)guid;

@end
