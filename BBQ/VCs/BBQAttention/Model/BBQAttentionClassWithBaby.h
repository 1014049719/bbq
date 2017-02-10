//
//  BBQAttentionClassWithBaby.h
//  BBQ
//
//  Created by anymuse on 15/11/23.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBQClassDataModel,BBQBabyModel;

@interface BBQAttentionClassWithBaby : NSObject
/** 班级*/
@property (nonatomic, strong) BBQClassDataModel *classmodel;
/** 名字*/
@property (nonatomic, copy) NSString *showname;
/** 学校名字*/
@property (nonatomic, copy) NSString *schoolname;
/** 学校头像*/
@property (nonatomic, copy) NSString *schoolavartar;
/** 学校类型 0-幼儿园、1-小学、2-中学、3-培训机构 */
@property (nonatomic, strong) NSNumber *schooltype;
/** uid*/
@property (nonatomic, strong) BBQBabyModel *babyModel;

/** 权限*/
@property (strong, nonatomic) NSNumber *qx;

@end
