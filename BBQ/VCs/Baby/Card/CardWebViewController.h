//
//  CardWebViewController.h
//  BBQ
//
//  Created by wth on 15/10/13.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardWebViewController : BBQBaseViewController

//请求数据连接
@property (copy, nonatomic) NSString *URL_Str;

//宝宝id
@property (copy, nonatomic) NSString *baobaouid;

@property (strong, nonatomic) id model;         //请求成长书的对象

@end
