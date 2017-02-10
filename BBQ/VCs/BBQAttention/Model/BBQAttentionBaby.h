//
//  BBQAttentionBaby.h
//  BBQ
//
//  Created by anymuse on 16/3/3.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBQAttentionBaby : NSObject
/** 宝宝头像*/
@property (nonatomic, copy) NSString *avartar;
/** 宝宝UID*/
@property (nonatomic, copy) NSString *baobaouid;
/** 是否关注（0-未关注，1-已关注）*/
@property (nonatomic, assign) NSInteger isattention;
/** 宝宝昵称*/
@property (nonatomic, copy) NSString *nickname;
/** 宝宝别名*/
@property (nonatomic, copy) NSString *realname;
/** 宝宝账号名字*/
@property (nonatomic, copy) NSString *username;
@end

@interface BBQAttentionManageBaby : NSObject
/** 申请ID*/
@property (nonatomic, copy) NSString *id;
/** 申请关注用户uid*/
@property (nonatomic, copy) NSString *uid;
/**申请关注用户名称*/
@property (nonatomic, copy) NSString *nickname;
/** 被申请关注宝宝姓名*/
@property (nonatomic, copy) NSString *baobaoname;
/** 被申请关注宝宝uid*/
@property (nonatomic, copy) NSString *baobaouid;
/** 默认0；1同意；-1拒绝*/
@property (nonatomic, assign) NSInteger agree;
/** 处理状态：0未处理；1已处理*/
@property (nonatomic, assign) NSInteger flag;
/** 申请关注时间*/
@property (nonatomic, copy) NSString *dateline;
/** 操作处理时间*/
@property (nonatomic, copy) NSString *dateline_do;
@end

@interface BBQClassByPhone : NSObject
/**班级名称*/
@property (nonatomic, copy) NSString *classname;
/** 班级ID*/
@property (nonatomic, copy) NSString *classuid;
/** 是否已关注*/
@property (nonatomic, assign) NSInteger *isattention;

@end