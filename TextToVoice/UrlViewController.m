//
//  UrlViewController.m
//  TextToVoice
//
//  Created by FUCK on 2017/12/27.
//  Copyright © 2017年 YHMFK. All rights reserved.
//

#import "UrlViewController.h"

@interface UrlViewController ()<UIWebViewDelegate>
@property (nonatomic , copy)NSString * stringTemp;
@end

@implementation UrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationItem.leftBarButtonItem.title = @"返回";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(right:)];
    //
    [self loadWebview];
}
- (void)right: (UIButton *)btn {
    //回调
    if (self.stringTemp.length == 0){
        self.title = @"着啥急，还没完事儿呢";
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(alertYHMFK) userInfo:nil repeats:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        self.comebackString(self.stringTemp);
    }
}
- (void)alertYHMFK {
    self.title = @"";
}
- (void)loadWebview {
    NSString *strurl=self.urlString;//@"http://www.cnblogs.com/jukaiit/p/7932259.html";
    UIWebView *web = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    web.delegate = self;
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strurl]]];
    [self.view addSubview:web];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    UIWebView *web = webView;
    //获取所有的html
    NSString *allHtml = @"document.documentElement.innerHTML";
    //thisBodyText = document.documentElement.innerText;//获取网页内容文字
    //thisBodyText = document.body.innerText;//获取网页内容文字  怎么和上一个一样？有知道的请解释
    NSString *allHtmlText = @"document.documentElement.innerText";
    //获取网页title
    NSString *htmlTitle = @"document.title";
    //获取网页的一个值
    NSString *htmlNum = @"document.getElementById('title').innerText";
    //获取到得网页内容
    NSString *allHtmlInfo = [web stringByEvaluatingJavaScriptFromString:allHtml];
    NSLog(@"%@",allHtmlInfo);
    NSString *allHtmlInfoText = [web stringByEvaluatingJavaScriptFromString:allHtmlText];
    NSLog(@"%@",allHtmlInfoText);
    NSString *titleHtmlInfo = [web stringByEvaluatingJavaScriptFromString:htmlTitle];
    NSLog(@"%@",titleHtmlInfo);
    NSString *numHtmlInfo = [web stringByEvaluatingJavaScriptFromString:htmlNum];
    NSLog(@"%@",numHtmlInfo);
    //
    self.stringTemp = allHtmlInfoText;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"DidStartLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
