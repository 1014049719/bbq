//
//  BBQAttentionBabyViewController.h
//  BBQ
//
//  Created by anymuse on 16/3/2.
//  Copyright © 2016年 bbq. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, BBQAttentionType) {
    BBQAttentionTypeBaby,
    BBQAttentionTypeClass,
};
@interface BBQAttentionBabyViewController : UITableViewController
@property (nonatomic, strong) NSArray *crebabies;
@property (assign, nonatomic) BBQAttentionType type;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) NSArray *imagesource;
@property(nonatomic, strong) NSArray *classinfos;
@property (nonatomic, strong) NSNumber *curBabyID;

@end
