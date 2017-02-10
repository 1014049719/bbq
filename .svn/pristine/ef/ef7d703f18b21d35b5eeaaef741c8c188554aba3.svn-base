//
//  Gift.h
//  BBQ
//
//  Created by 朱琨 on 15/12/6.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kGiftItems;

@interface Gift : NSObject

@property (copy, nonatomic) NSString *guid;

@property (copy, nonatomic) NSString *imgurl;

@property (copy, nonatomic) NSString *imageName;
/// 虚拟物品ID
@property (strong, nonatomic) NSNumber *giftid;

@property (strong, nonatomic) NSNumber *dateline;
/// 虚拟物品名称
@property (copy, nonatomic) NSString *giftname;
/// 数量
@property (strong, nonatomic) NSNumber *giftcount;

@property (copy, nonatomic) NSString *fbztx;

@property (copy, nonatomic) NSString *nickname;
///礼物类型
@property (strong, nonatomic) NSNumber *gifttype;
///学校名称
@property (copy, nonatomic) NSString *schoolname;
///班级名称
@property (copy, nonatomic) NSString *classname;
///发布者身份
@property (strong, nonatomic) NSNumber *groupkey;
///关系id
@property (strong, nonatomic) NSNumber *gxid;
///关系名称
@property (copy, nonatomic) NSString *gxname;

@property (copy, nonatomic) NSString *baobaoname;

@property (strong, nonatomic) NSNumber *baobaouid;
///使用类型
@property (strong, nonatomic) NSNumber *usetype;

- (instancetype)initWithDynamic:(Dynamic *)dynamic giftID:(NSNumber *)giftID count:(NSNumber *)count items:(NSArray *)items;

@end
