//
//  BBQBabyModel.m
//  BBQ
//
//  Created by slovelys on 15/11/30.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQBabyModel.h"
#import "BBQSchoolDataModel.h"

@implementation BBQBabyModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"dynamictags": [DynamicTag class],
             @"baobaoschooldata": [BBQSchoolDataModel class],
             @"shbaobaoschooldata": [BBQSchoolDataModel class]
             };
}

- (BBQSchoolDataModel *)curSchool {
    if (!_curSchool && _baobaoschooldata.count) {
        _curSchool = _baobaoschooldata.firstObject;
    }
    return _curSchool;
}

- (BBQClassDataModel *)curClass {
    if (!_curClass && self.curSchool.classdata.count) {
        _curClass = _curSchool.classdata.firstObject;
    }
    return _curClass;
}

- (BOOL)hasDailyReport {
    BOOL has = NO;
    for (BBQSchoolDataModel *school in self.baobaoschooldata) {
        if (school.schooltype.integerValue == BBQSchoolTypeKindergarten) {
            has = YES;
            break;
        }
    }
    return has;
}

-(void)deleteClassData:(BBQClassDataModel *)classmodel{
    __block BOOL hasFind;
    NSMutableArray *arrayM = [NSMutableArray arrayWithArray:self.baobaoschooldata];
    [self.baobaoschooldata enumerateObjectsUsingBlock:^(BBQSchoolDataModel*  _Nonnull schoolobj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:schoolobj.classdata];
        [schoolobj.classdata enumerateObjectsUsingBlock:^(BBQClassDataModel*  _Nonnull classobj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (classobj == classmodel) {
                hasFind = YES;
                [array removeObject:classobj];
                *stop = YES;
            }
        }];
        if (hasFind) {
            *stop = YES;
            if (array.count) {
                [arrayM replaceObjectAtIndex:idx withObject:array];
            }else{
                [arrayM removeObjectAtIndex:idx];
            }
            
        }
    }];
    self.baobaoschooldata = arrayM;
}
@end
