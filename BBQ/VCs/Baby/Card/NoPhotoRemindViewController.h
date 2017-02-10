//
//  NoPhotoRemindViewController.h
//  BBQ
//
//  Created by wth on 15/10/15.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NoPhotoRemindTypeNormal,
    NoPhotoRemindTypeBaby,
    NoPhotoRemindTypeClass,
} NoPhotoRemindType;

@interface NoPhotoRemindViewController : BBQBaseViewController

@property (nonatomic, assign) NoPhotoRemindType type;

@end
