//
//  BBQDynamicViewFactory.h
//  BBQ
//
//  Created by 朱琨 on 16/1/13.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBQDynamicView.h"

@interface BBQDynamicViewFactory : NSObject

+ (BBQDynamicView *)dynamicViewWithIdentifier:(NSString *)style;

@end
