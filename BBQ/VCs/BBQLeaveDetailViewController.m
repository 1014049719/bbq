//
//  BBQLeaveDetailViewController.m
//  BBQ
//
//  Created by slovelys on 15/12/3.
//  Copyright © 2015年 bbq. All rights reserved.
//

#import "BBQLeaveDetailViewController.h"
#import <Masonry.h>
#import "BBQDeleteLeaveApi.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TestJSObject.h"

@interface BBQLeaveDetailViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation BBQLeaveDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCustomView];
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[CS_URL_BASE stringByAppendingString:[NSString stringWithFormat:@"bbq.php?mod=bbq&ac=qjinfo&jid=%d", _sid]]]]];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"https://" stringByAppendingString:[NSString stringWithFormat:@"www.baidu.com"]]]]];
    //接收JS调用通知跳转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CZS_Action:)
                                                 name:@"CZS_Action"
                                               object:nil];
    
#ifdef TARGET_TEACHER
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationItem.leftBarButtonItem = item;
#endif
}

- (void)backClick {
    if (self.block) {
        self.block(NO);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)CZS_Action:(NSNotification *)notification {
    if ([notification.userInfo[@"action"] isEqual:@"cmd_delqj"]) {
        [self delegateBtnClick];
    }
}

- (void)setupCustomView {
    self.title = @"请假详情";
#ifdef TARGET_PARENT
//    _deleteBtn.layer.cornerRadius = 25;
//    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
//    [_deleteBtn setBackgroundColor:[UIColor colorWithHexString:@"ff6440"]];
//    [_deleteBtn addTarget:self action:@selector(delegateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn = nil;
    [_deleteBtn removeFromSuperview];
    [_webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.view).offset(@0);
    }];
#else
    _deleteBtn = nil;
    [_deleteBtn removeFromSuperview];
    [_webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.view).offset(@0);
    }];
#endif
}

- (void)delegateBtnClick {
    [SVProgressHUD showWithStatus:@"请稍候"];
    BBQDeleteLeaveApi *api = [[BBQDeleteLeaveApi alloc] initWithSid:_sid];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                if (self.block) {
                    self.block(YES);
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
            
        });
    } failure:^(YTKBaseRequest *request) {
        if (request.responseStatusCode == 200) {
            [SVProgressHUD showErrorWithStatus:request.responseJSONObject[@"msg"]];
        } else {
            [SVProgressHUD showErrorWithStatus:request.requestOperation.error.localizedDescription];
        }
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [SVProgressHUD showWithStatus:@"请稍候"];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    JSContext *context = [webView
                          valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    TestJSObject *testJO = [TestJSObject new];
    context[@"client"] = testJO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"加载出错"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end