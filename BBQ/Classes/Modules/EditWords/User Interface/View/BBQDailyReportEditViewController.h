//
//  BBQDailyReportEditViewController.h
//  BBQ
//
//  Created by 朱琨 on 15/10/19.
//  Copyright © 2015年 bbq. All rights reserved.
//



@interface BBQDailyReportEditViewController : BBQBaseViewController

@property (copy, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *typeID;
@property (copy, nonatomic) NSString *typeval;

@end
