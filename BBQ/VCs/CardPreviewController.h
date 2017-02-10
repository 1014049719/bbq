//
//  CardPreviewController.h
//  BBQ
//
//  Created by wth on 15/10/14.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    BBQCZSPreviewTypeNormal,
    BBQCZSPreviewTypeBaby,
    BBQCZSPreviewTypeClass,
} BBQCZSPreviewType;

@interface CardPreviewController : BBQBaseViewController

//传值UrlStr
@property (copy, nonatomic) NSString *CZS_URL;
//-(void)UpLoadWebUrlData:(NSString *)CZS_UrlStr;
//传值数据源数组
@property(strong,nonatomic)NSDictionary *CZS_dic;
//入口标志
@property(strong,nonatomic)NSString *accessType;
//消息处理参数
@property (strong, nonatomic) NSDictionary *messageDic;

@property (nonatomic, assign) BBQCZSPreviewType previewType;

@end
