//
//  BBQDynamicViewTimeline.h
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import "BBQDynamicView.h"
#import "IMYThemeConfig.h"

@interface BBQDynamicViewTimeline : BBQDynamicView <UITableViewDelegate, UITableViewDataSource, IMY_ThemeChangeProtocol>

@property (strong, nonatomic) UITableView *commentTableView;

@end
