//
//  BBQDailyReportOption.m
//  BBQ
//
//  Created by 朱琨 on 15/10/14.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQDailyReportOption.h"
#import "BBQDailyReportOptionModel.h"
#import "BBQDailyreportOptionsApi.h"

@implementation BBQDailyReportOption

- (void)fetchData {
    BBQDailyreportOptionsApi *api = [BBQDailyreportOptionsApi new];
    @weakify(self)
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
        @strongify(self)
        [self writeData:request.responseJSONObject];
    } failure:nil];
}

- (void)writeData:(NSDictionary *)data {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm removeItemAtPath:[self filePath] error:nil];
    [fm createFileAtPath:[self filePath] contents:nil attributes:nil];
    [data writeToFile:[self filePath] atomically:YES];
}

- (NSArray *)optionsForType:(NSInteger)typeID {
    NSDictionary *data =
    [NSDictionary dictionaryWithContentsOfFile:[self filePath]];
    NSArray *typeArray = data[@"data"][@"typearr"];
    NSDictionary *statusArray = typeArray[typeID];
    NSArray *configarr = statusArray[@"configarr"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in configarr) {
        BBQDailyReportOptionModel *model =
        [[BBQDailyReportOptionModel alloc] initWithDictionary:dic];
        [array addObject:model];
    }
    return array;
}

- (BOOL)fileExists {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:[self filePath]];
}

- (NSString *)filePath {
    return [[self applicationDocumentsDirectory]
            stringByAppendingPathComponent:@"option.plist"];
}

- (NSString *)applicationDocumentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                               NSUserDomainMask, YES)
    .firstObject;
}

@end
