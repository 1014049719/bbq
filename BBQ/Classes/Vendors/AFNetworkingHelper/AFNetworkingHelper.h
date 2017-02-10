//
//  IPWTHttpUtils.h
//  ipWorldTv
//
//  Created by my full name on 5/14/14.
//  Copyright (c) 2014 IPWorldTv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

@interface AFNetworkingHelper : NSObject

+ (void)cancelAllRunningNetworkOperations;

+ (void) executeDeleteWithUrl:(NSString *)url AndParameters:(NSDictionary *)parameters AndHeaders:(NSDictionary *)headers withSuccessHandler:(void (^)(AFHTTPRequestOperation *, id, bool))success withFailureHandler:(void (^)(AFHTTPRequestOperation *, NSError *))failure withLoadingViewOn:(UIView *)parentView;

+ (void)executePostWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters andHeaders:(NSDictionary *)headers constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block withSuccessHandler:(void (^)(AFHTTPRequestOperation *operation, id responseObject, bool apiSuccess))success withErrorHandler:(void (^)(NSDictionary *responseObject))error withFailureHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure withLoadingViewOn:(UIView *)parentView;

+ (void)executePostWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters andHeaders:(NSDictionary *)headers withSuccessHandler:(void (^)(AFHTTPRequestOperation *operation, NSDictionary *responseObject, bool apiSuccess))success withErrorHandler:(void (^)(NSDictionary *responseObject))error withFailureHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure withLoadingViewOn:(UIView *)parentView;

+ (void)executePostWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters andHeaders:(NSDictionary *)headers andAuthorizationHeaderUser:(NSString *)user andAuthrozationHeaderPassword:(NSString *)password withSuccessHandler:(void (^)(AFHTTPRequestOperation *, id, bool))success withFailureHandler:(void (^)(AFHTTPRequestOperation *, NSError *))failure withLoadingViewOn:(UIView *)parentView;

+ (void)executePutWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters andHeaders:(NSDictionary *)headers withSuccessHandler:(void (^)(AFHTTPRequestOperation *, id, bool))success withFailureHandler:(void (^)(AFHTTPRequestOperation *, NSError *))failure withLoadingViewOn:(UIView *)parentView;

+ (void)executeGetWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters andHeaders:(NSDictionary *)headers withSuccessHandler:(void (^)(AFHTTPRequestOperation *, id, bool))success withFailureHandler:(void (^)(AFHTTPRequestOperation *, NSError *))failure withLoadingViewOn:(UIView *)parentView;

+ (void)executePatchWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters andHeaders:(NSDictionary *)headers withSuccessHandler:(void (^)(AFHTTPRequestOperation *, id, bool))success withFailureHandler:(void (^)(AFHTTPRequestOperation *, NSError *))failure withLoadingViewOn:(UIView *)parentView;

@end
