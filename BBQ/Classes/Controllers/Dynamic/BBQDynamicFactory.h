//
//  BBQDynamicFactory.h
//  BBQ
//
//  Created by 朱琨 on 16/1/18.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQDynamicView.h"
#import "BBQDynamicLayout.h"

@interface BBQDynamicFactory : NSObject

/**
 *  动态View工厂方法
 *
 *  @param identifier Cell的identifier
 *
 *  @return 动态View
 */
+ (BBQDynamicView *)dynamicViewWithIdentifier:(NSString *)identifier;
+ (BBQDynamicLayout *)layoutWithDynamic:(Dynamic *)dynamic style:(BBQDynamicLayoutStyle)style;

@end
