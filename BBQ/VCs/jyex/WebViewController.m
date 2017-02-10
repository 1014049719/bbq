//
//  WebViewController.m
//  BBQ
//
//  Created by mwt on 15/8/10.
//  Copyright (c) 2015年 bbq. All rights reserved.
//

#import "WebViewController.h"
#import "CreateAnnouncementTableViewController.h"
#import "TestJSObject.h"
#import "ShareView.h"
#import "AppMacro.h"
#import "BBQLeaveListTabbleViewController.h"
#import "BBQLeaveDetailViewController.h"
#import "MessageViewController.h"
#import "ODRefreshControl.h"
#import "PatchUrlTools.h"
#import "BBQDualListViewController.h"
#import "BBQOperationEditViewController.h"
#import "QBImagePickerController.h"

@interface WebViewController () <UIActionSheetDelegate>
@property(weak, nonatomic) IBOutlet UIWebView *webview;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *activityindicator;
@property(nonatomic, strong) NSArray *arrMenu;

@property(nonatomic, assign) BOOL m_bSndRefreshMsgFlag;
@property(nonatomic, assign) BOOL m_bRcvRefreshMsgFlag;

//下拉刷新
@property (strong, nonatomic) ODRefreshControl *refresh;

//分享内容相关
@property(strong,nonatomic)NSString *shareURL;
@property(strong,nonatomic)NSString *shareTitle;
@property(strong,nonatomic)NSString *shareContent;

@end

@interface UIWebView (JavaScriptAlert)
- (void)webView:(UIWebView *)sender
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(CGRect *)frame;
@end

@implementation UIWebView (JavaScriptAlert)

- (void)webView:(UIWebView *)sender
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(CGRect *)frame {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"家园e线"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webview.delegate = self;
    
    //接收通知刷新消息

    
    self.url=[PatchUrlTools patchUrlWithUrlStr:self.url];
    [self.webview
     loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    NSLog(@"加载的拼接好链接地址为：%@",[PatchUrlTools patchUrlWithUrlStr:self.url]);
    
    //接收JS调用通知跳转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CZS_Action:)
                                                 name:@"CZS_Action"
                                               object:nil];
    
    //下拉刷新
    self.refresh = [[ODRefreshControl alloc] initInScrollView:self.webview.scrollView];
    [self.refresh addTarget:self action:@selector(refreshWebview) forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ShareView sharedInstance] dismiss];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//JS数据通知动作
- (void)CZS_Action:(NSNotification *)notification {
    if ([notification.userInfo[@"action"] isEqual:@"cmd_adddyna"]) {
#ifdef TARGET_PARENT
        Dynamic *dynamic;
        switch ([notification.userInfo[@"para"][@"type"] integerValue]) {
            case 0: {
                dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypePhoto object:TheCurBaoBao];
            } break;
            case 1: {
                dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypeBatch object:TheCurBaoBao];
            } break;
            case 2: {
                dynamic = [Dynamic dynamicWithMediaType:BBQDynamicMediaTypeVideo object:TheCurBaoBao];
            }
            default:
                break;
        }
        QBImagePickerController *vc = [[QBImagePickerController alloc] initWithDynamic:dynamic];
#else
        BBQDualListViewController *vc = [[UIStoryboard storyboardWithName:@"Common" bundle:nil] instantiateViewControllerWithIdentifier:@"DualListVC"];
        vc.dualListType = BBQDualListTypePublishDynamic;
        switch ([notification.userInfo[@"para"][@"type"] integerValue]) {
            case 0: {
              vc.mediaType = BBQDynamicMediaTypePhoto;
            } break;
            case 1: {
              vc.mediaType = BBQDynamicMediaTypeBatch;
            } break;
            case 2: {
               vc.mediaType = BBQDynamicMediaTypeVideo;
            }
            default:
                break;
        }
#endif
        [self.navigationController pushViewController:vc animated:NO];
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_share"]) {
        //弹出分享
        self.shareURL = notification.userInfo[@"para"][@"shareurl"];
        self.shareTitle = notification.userInfo[@"para"][@"sharetitle"];
        self.shareContent = notification.userInfo[@"para"][@"sharecontent"];
        
        [self RightBtnClick];
        
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_disptip"]) {
        //显示提示窗或确认窗
        switch ([notification.userInfo[@"para"][@"type"] intValue]) {
            case 0: {
                NSLog(@"提示窗");
                [SVProgressHUD showImage:nil
                                  status:notification.userInfo[@"para"][@"content"]];
            } break;
            case 1: {
                NSLog(@"确认窗");
                
                UIAlertView *alterView = [[UIAlertView alloc]
                                          initWithTitle:notification.userInfo[@"para"][@"title"]
                                          message:notification.userInfo[@"para"][@"content"]
                                          delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
                [alterView show];
            } break;
            default:
                break;
        }
    }else if ([notification.userInfo[@"action"] isEqual:@"cmd_intoqj"]){
        
        //进入请假管理
        BBQLeaveListTabbleViewController *vc = [[UIStoryboard storyboardWithName:@"Family" bundle:nil] instantiateViewControllerWithIdentifier:@"leaveListVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([notification.userInfo[@"action"] isEqual:@"cmd_general"]){

        UITabBarController *rootController = (UITabBarController *)kKeyWindow.rootViewController;
        [(UINavigationController *)rootController.selectedViewController
         popToRootViewControllerAnimated:NO];
        NSDictionary *dic = notification.userInfo[@"para"];
        int omode = [dic[@"omode"] intValue];
        ;
        NSString *url;
        if (dic) {
            url = [dic jsonStringEncoded];
        }
        
        [MessageViewController
         MessageAction:omode
         url:url
         viewcontroller:rootController.selectedViewController];
        
    }else if ([notification.userInfo[@"action"] isEqual:@"cmd_closewin"]){
        
        //关闭当前窗口
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([notification.userInfo[@"action"] isEqual:@"cmd_delqj"]){
        
        //撤销并删除请假
        BBQLeaveDetailViewController *leaveDetailVC = [[UIStoryboard storyboardWithName:@"Family" bundle:nil] instantiateViewControllerWithIdentifier:@"leaveDetailVC"];
        [self.navigationController pushViewController:leaveDetailVC animated:YES];
    }else if ([notification.userInfo[@"action"] isEqual:@"cmd_intofuture"]){
        
        //跳转写给未来的你
        BBQOperationEditViewController *opeditVC = [[BBQOperationEditViewController alloc] init];
        opeditVC.title = @"编辑";
        opeditVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:opeditVC animated:YES];
    } else if ([notification.userInfo[@"action"] isEqual:@"cmd_dialup"]) {
        // 打电话
        NSString *phonenum = [NSString stringWithFormat:@"%@", notification.userInfo[@"para"][@"phonenum"]];
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phonenum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
    
//    else if ([notification.userInfo[@"action"] isEqual:@"cmd_dispshare"]){
//        
//        //导航右侧加分享图标
//        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
//                                        initWithImage:[UIImage imageNamed:@"fenxiangbaise.png"]
//                                        style:UIBarButtonItemStylePlain
//                                        target:self
//                                        action:@selector(RightBtnClick)];
//        self.navigationItem.rightBarButtonItem=rightButton;
//        
//        self.shareURL = notification.userInfo[@"para"][@"shareurl"];
//        self.shareTitle = notification.userInfo[@"para"][@"sharetitle"];
//        self.shareContent = notification.userInfo[@"para"][@"sharecontent"];
//    }
    
}

//分享按钮事件
- (void)RightBtnClick {
    
    ShareView *shareView = [ShareView sharedInstance];
    shareView.shareType = BBQShareTypeCZS;
    shareView.shareURL = self.shareURL;
    shareView.shareTitle = self.shareTitle;
    shareView.shareContent = self.shareContent;
    [shareView showShareView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    self.activityindicator.hidden = NO;
    if (![self.activityindicator isAnimating]) {
        [self.activityindicator startAnimating];
    }
    
    NSString *path = [[request URL] absoluteString];
    
    NSString *sMethod = [request HTTPMethod];
    
    NSLog(@"UIJYEXSubPage:navigationType=%ld method=%@ url:%@\r\n",
          (long)navigationType, sMethod, path);
    
    if (sMethod &&
        ([sMethod isEqualToString:@"POST"] || [sMethod isEqualToString:@"post"] ||
         navigationType == UIWebViewNavigationTypeFormSubmitted)) {
            return YES;
        }
    
    if ([path hasPrefix:@"yk://"]) { //本地的
        if ([path rangeOfString:ACT_LOGIN].length > 0) {
            // NSNumber *num = [NSNumber numberWithInt:1];
            //[PubFunction SendMessageToViewCenter:NMJYEXLogin :0 :1 :num];
            return NO;
        } else if ([path rangeOfString:ACT_Setting].length > 0) {
            // NSNumber *num = [NSNumber numberWithInt:1];
            //[PubFunction SendMessageToViewCenter:NMJYEXSetting :0 :1 :num];
            return NO;
        }
    }
    
    if ([path rangeOfString:@"http"].location == NSNotFound) {
        return YES;
    }
    
    if (![self.url isEqualToString:path] &&
        ![self.url isEqualToString:@"about:blank"] && !self.bFirstInfo) {
        self.bFirstInfo = NO;
        
        if ([path rangeOfString:@"_self=1"].length > 0 ||
            [path rangeOfString:CS_URL_BASE].length == 0) {
            self.url = path;
            //[self proAppLoadWeb]; //在本窗口打开新链接
            return YES;
        } else {
            self.activityindicator.hidden = YES;
            [self.activityindicator stopAnimating];
            
            NSRange range = [path rangeOfString:@"#PhotoSwipe"];
            NSRange range1 = [path rangeOfString:@"#&ui-state=dialog"];
            if (range.length > 0 || range1.length > 0) {
                //不处理
                return NO;
            }
            
            UIStoryboard *sb =
            [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
            WebViewController *vc =
            [sb instantiateViewControllerWithIdentifier:@"WebViewController"];
            vc.url = path;
            [self.navigationController pushViewController:vc animated:YES];
            
            return NO;
        }
    }
    self.url = path;
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] == -999 || [error code] == 102) {
        return;
    }
    
    [self.activityindicator stopAnimating];
    self.activityindicator.hidden = YES;
    
    NSString *err;
    //  if ([[Global instance] getNetworkStatus] == NotReachable) {
    //    err = @"无法加载页面，请检查网络。";
    //  } else {
    //    err = @"无法加载页面，请稍候...再试。";
    //  }
    [self.webview loadHTMLString:err baseURL:nil];
    
    NSDictionary *dic = [error userInfo];
    NSString *err1 = [[NSString alloc]
                      initWithFormat:@"加载页面%@失败 %@ 请检查网络",
                      ((NSString *)
                       [dic objectForKey:@"NSErrorFailingURLStringKey"]),
                      [error localizedDescription]];
    NSLog(@"%@\r\n", err1);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityindicator stopAnimating];
    self.activityindicator.hidden = YES;
    
    //停止刷新
    [self.refresh endRefreshing];
    
    //网页加载完成，JS调用
    JSContext *context = [self.webview
                          valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    TestJSObject *testJO = [TestJSObject new];
    context[@"client"] = testJO;
    
    
    NSString *htmltitle =
    [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"load finish: title=%@", htmltitle);
    self.navigationItem.title = htmltitle;
    self.annceounmentName = htmltitle;
    
    NSString *path = [[[webView request] URL] absoluteString];
    NSString *method = [[webView request] HTTPMethod];
    NSLog(@"webViewDidFinishLoad method:%@ url:%@\r\n", method, path);
    
    //提取菜单内容
    //提取rightmenu数组
    self.arrMenu = nil;
    
    NSString *strMenu =
    [webView stringByEvaluatingJavaScriptFromString:
     @"document.getElementById(\"rightmenu\").value"];
    if (!strMenu || [strMenu isEqualToString:@""]) {
        ;
    } else {
        if ((![strMenu hasPrefix:@"{"]) && (![strMenu hasPrefix:@"["])) {
            NSRange r1 = [strMenu rangeOfString:@"{"];
            NSRange r2 = [strMenu rangeOfString:@"["];
            if (r1.location == NSNotFound && r2.location == NSNotFound) {
                strMenu = @"";
            } else {
                r1.location =
                ((r1.location <= r2.location) ? r1.location : r2.location);
                strMenu = [strMenu substringFromIndex:r1.location];
            }
        }
        if (strMenu && [strMenu length] > 0) {
            id retJsObj = [strMenu jsonValueDecoded];
            if (![retJsObj isKindOfClass:[NSArray class]] ||
                [(NSArray *)retJsObj count] < 1) {
                ;
            } else {
                self.arrMenu = retJsObj;
            }
        }
    }
    
    if (!self.arrMenu || self.arrMenu.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    } else if (self.arrMenu.count == 1) {
        
        NSLog(@"网页加右边按钮 数据%@",self.arrMenu);
        //      if (<#condition#>) {
        //          <#statements#>
        //      }
        NSDictionary *dic = [self.arrMenu firstObject];
        NSString *strTitle = [dic objectForKey:@"title"];
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:strTitle
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(clickRightButton:)];
    } else {
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"菜单"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(clickRightButton:)];
    }
    
    if ([method isEqualToString:@"POST"]) {
        //发刷新消息页面
        self.m_bSndRefreshMsgFlag = YES;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NOTIFICATION_REFRESH_CONTENT
         object:nil
         userInfo:nil];
        return;
    }
    
    //判断是否需发出刷新内容消息
    if (self.m_bRcvRefreshMsgFlag) {
        self.m_bRcvRefreshMsgFlag = NO; //如果是收到别的消息刷新的，不再触发,清0
        return;
    }
    
    NSString *strAppRefresh =
    [webView stringByEvaluatingJavaScriptFromString:
     @"document.getElementById(\"app_refresh\").value"];
    if ([strAppRefresh length] > 1) {
        //通知刷新
        if (![strAppRefresh hasPrefix:@"{"]) {
            NSRange r1 = [strAppRefresh rangeOfString:@"{"];
            if (r1.location == NSNotFound) {
                strAppRefresh = @"";
            } else {
                strAppRefresh = [strAppRefresh substringFromIndex:r1.location];
            }
        }
        if (strAppRefresh && [strAppRefresh length] > 0) {
            id retJsObj = [strAppRefresh jsonValueDecoded];
            if ([retJsObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = retJsObj;
                NSNumber *refresh_flag = [dic objectForKey:@"refresh_flag"];
                if (refresh_flag && [refresh_flag intValue] == 1) {
                    self.m_bSndRefreshMsgFlag = YES;
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:NOTIFICATION_REFRESH_CONTENT
                     object:nil
                     userInfo:nil];
                    return;
                }
            }
        }
    }
    
    if ([self.url rangeOfString:@"ac=jygt"].length > 0) {
        //进入了家园沟通页面，查看消息，发刷新消息页面
        self.m_bSndRefreshMsgFlag = YES;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NOTIFICATION_REFRESH_CONTENT
         object:nil
         userInfo:nil];
    }
}

//刷新页面
- (void)refreshWebview {
    NSLog(@"JYEXSubPage:%p refreshWebview---", self);
    
    //判断是不是自己发的
    if (self.m_bSndRefreshMsgFlag) {
        self.m_bSndRefreshMsgFlag = NO;
        return;
    }
    
    //置收到标志
    self.m_bRcvRefreshMsgFlag = YES;
    
    if (!self.webview.isLoading) {
        [self.webview
         loadRequest:[NSURLRequest
                      requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

- (void)notifyRefreshContent:(NSDictionary *)dic {
    if (!self.webview.isLoading) {
        [self.webview
         loadRequest:[NSURLRequest
                      requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

- (void)clickRightButton:(UIButton *)btn {
    if (self.arrMenu.count == 0)
        return;
    else if (self.arrMenu.count == 1) {
        [self execAction:0];
    } else {
        [self DispSheetMenu];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)DispSheetMenu {
    if (!self.arrMenu || [self.arrMenu count] < 1)
        return;
    
    int count = (int)[self.arrMenu count];
    NSMutableArray *arrTitle = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = [self.arrMenu objectAtIndex:i];
        [arrTitle addObject:[dic objectForKey:@"title"]];
    }
    
    UIActionSheet *actionsheet;
    if (1 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0], nil];
    else if (2 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1], nil];
    else if (3 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2], nil];
    else if (4 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2],
         [arrTitle objectAtIndex:3], nil];
    else if (5 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2],
         [arrTitle objectAtIndex:3],
         [arrTitle objectAtIndex:4], nil];
    else if (6 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2],
         [arrTitle objectAtIndex:3],
         [arrTitle objectAtIndex:4],
         [arrTitle objectAtIndex:5], nil];
    else if (7 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2],
         [arrTitle objectAtIndex:3],
         [arrTitle objectAtIndex:4],
         [arrTitle objectAtIndex:5],
         [arrTitle objectAtIndex:6], nil];
    else if (8 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2],
         [arrTitle objectAtIndex:3],
         [arrTitle objectAtIndex:4],
         [arrTitle objectAtIndex:5],
         [arrTitle objectAtIndex:6],
         [arrTitle objectAtIndex:7], nil];
    else if (9 == count)
        actionsheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:[arrTitle objectAtIndex:0],
         [arrTitle objectAtIndex:1],
         [arrTitle objectAtIndex:2],
         [arrTitle objectAtIndex:3],
         [arrTitle objectAtIndex:4],
         [arrTitle objectAtIndex:5],
         [arrTitle objectAtIndex:6],
         [arrTitle objectAtIndex:7],
         [arrTitle objectAtIndex:8], nil];
    else
        actionsheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"取消"
                       destructiveButtonTitle:nil
                       otherButtonTitles:
                       [arrTitle objectAtIndex:0], [arrTitle objectAtIndex:1],
                       [arrTitle objectAtIndex:2], [arrTitle objectAtIndex:3],
                       [arrTitle objectAtIndex:4], [arrTitle objectAtIndex:5],
                       [arrTitle objectAtIndex:6], [arrTitle objectAtIndex:7],
                       [arrTitle objectAtIndex:8], [arrTitle objectAtIndex:9], nil];
    
    actionsheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    
    [actionsheet showInView:self.view];
}

// ACTIONSHEET的代理
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self execAction:buttonIndex];
}

- (void)execAction:(NSInteger)buttonIndex {
    if (buttonIndex >= [self.arrMenu count])
        return;
    
    NSDictionary *dic = [self.arrMenu objectAtIndex:buttonIndex];
    
    //栏目，类型（url,local),Action, 参数
    // NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
    //                     @"上传精彩瞬间",@"title",@"local",@"type",@"ACT_WriteArticle",@"action",@"精彩瞬间",@"para",
    //                     nil];
    NSString *strType = [dic objectForKey:@"type"];
    NSString *strAction = [dic objectForKey:@"action"];
    id para = [dic objectForKey:@"para"];
    NSString *strSelf = [dic objectForKey:@"_self"];
    int nSelf = 0;
    if (strSelf)
        nSelf = [strSelf intValue];
    
    if ([strType isEqual:@"url"]) {
        //处理url
        if (![strAction hasPrefix:@"file:"] && ![strAction hasPrefix:@"http:"] &&
            ![strAction hasPrefix:@"HTTP"]) {
            strAction = [CS_URL_BASE stringByAppendingString:strAction];
        }
        
        //是否本身加载
        if (nSelf == 1) {
            self.url = strAction;
            [self.webview
             loadRequest:[NSURLRequest
                          requestWithURL:[NSURL URLWithString:self.url]]];
        } else {
            UIStoryboard *sb =
            [UIStoryboard storyboardWithName:@"RootTabBar" bundle:nil];
            WebViewController *vc =
            [sb instantiateViewControllerWithIdentifier:@"WebViewController"];
            vc.url = strAction;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if ([strType isEqual:@"local"]) {
        if ([strAction isEqual:ACT_WriteArticle]) {
            //设置栏目名称
            //      if ([para isKindOfClass:[NSString class]])
            //        [_GLOBAL setLanMu:para];
            //      NSString *strDefaultFolderGUID = [_GLOBAL defaultCateID];
            //      [_GLOBAL setEditorAddNoteInfo:NEWNOTE_TEXT
            //                            catalog:strDefaultFolderGUID
            //                           noteinfo:nil];
            UIStoryboard *storyBoard =
            [UIStoryboard storyboardWithName:@"Teacher" bundle:nil];
            CreateAnnouncementTableViewController *cavc =
            [storyBoard instantiateViewControllerWithIdentifier:@"CreateAnnVC"];
            cavc.annName = self.annceounmentName;
            cavc.block = ^(BOOL needRefresh) {
                if (needRefresh == YES) {
                    [self.webview
                     loadRequest:[NSURLRequest
                                  requestWithURL:[NSURL URLWithString:self.url]]];
                }
            };
            [self.navigationController pushViewController:cavc animated:YES];
            
        } else if ([strAction isEqual:ACT_SendPhoto]) {
            NSDictionary *dicPara = nil;
            if (para && [para isKindOfClass:[NSNumber class]]) {
                dicPara =
                [NSDictionary dictionaryWithObjectsAndKeys:para, @"type", @"0",
                 @"albumflag", nil];
            } else if (para && [para isKindOfClass:[NSDictionary class]]) {
                dicPara = para;
            } else {
                dicPara =
                [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"type", @"0",
                 @"albumflag", nil];
            }
            // NSNumber *albumflag = [dicPara objectForKey:@"albumflag"];
            // NSDictionary *dicAlbum = [dicPara objectForKey:@"album"];
            
            //      [_GLOBAL setAlbumTypeFlag:[type intValue]];
            // if ( [albumflag intValue] != 1 || !dicAlbum ) {
            //    [PubFunction SendMessageToViewCenter:NMJYEXUploadPic :0 :1 :nil];
            //}
            // else {
            //    [PubFunction SendMessageToViewCenter:NMJYEXUploadPic :0 :1
            //    :[MsgParam param:nil :nil :dicAlbum :0]];
            //}
            
        } else if ([strAction isEqual:ACT_Setting]) {
            //[PubFunction SendMessageToViewCenter:NMJYEXSetting :0 :1 :nil];
        } else if ([strAction isEqualToString:ACT_NewAlbum]) {
            
            
            //      [_GLOBAL setAlbumTypeFlag:[type intValue]];
            
            //[PubFunction SendMessageToViewCenter:NMJYEXSelectAlbum :0 :1 :[MsgParam
            //param:self :@selector(notifyRefreshContent:) :@"1" :0]];
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end