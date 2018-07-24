//
//  Html5VC.m
//  aimdev
//  Html5
//  
//  Created by dongjianbo on 14-7-2.
//  Copyright (c) 2014年 salam. All rights reserved.
//

#import "Html5VC.h"
#import "Html5WebView.h"
#import "Html5NavigatorBar.h"

@interface Html5VC ()<Html5WebViewDelegate, Html5NavigatorBarDelegate>
@property(nonatomic, strong) Html5WebView* mainWebView;
@property(nonatomic, strong) Html5NavigatorBar* html5NavigatorBar;
@end

@implementation Html5VC
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.view setBackgroundColor:kRootViewColor];
    
    self.title = self.h5Title;
    
    self.mainWebView = [[Html5WebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 44)];
    self.mainWebView.delegate = self;
    [self.mainWebView.webView setOpaque:NO];
    [self.mainWebView.webView setBackgroundColor:[UIColor clearColor]];
    [self.mainWebView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.mainWebView];
    
    [self.mainWebView loadRequestWithURL:self.h5Url];
    
    // add navigator bar
    self.html5NavigatorBar = [[Html5NavigatorBar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    self.html5NavigatorBar.delegate = self;
    [self.view addSubview:self.html5NavigatorBar];
    [self.html5NavigatorBar enableGoBack:NO];
    [self.html5NavigatorBar enableGoForward:NO];
    [self.html5NavigatorBar enableRefresh:NO];
    [self.html5NavigatorBar setIsRefreshing:NO];
}

#pragma mark - Html5WebViewDelegate
- (void)html5WebView:(Html5WebView *)html5WebView isRefreshing:(BOOL)isRefreshing
{
    [self.html5NavigatorBar setIsRefreshing:isRefreshing];
}

- (void)html5WebView:(Html5WebView *)html5WebView enableRefresh:(BOOL)enable
{
    [self.html5NavigatorBar enableRefresh:enable];
}

- (void)html5WebView:(Html5WebView *)html5WebView enableGoBack:(BOOL)enable
{
    [self.html5NavigatorBar enableGoBack:enable];
}

- (void)html5WebView:(Html5WebView *)html5WebView enableGoForward:(BOOL)enable
{
    [self.html5NavigatorBar enableGoForward:enable];
}

#pragma mark - Html5NavigatorBarDelegate
- (void)onHtml5NavigatorBarClickGoBack
{
    [self.mainWebView.webView goBack];
}

- (void)onHtml5NavigatorBarClickGoForward
{
    [self.mainWebView.webView goForward];
}

- (void)onHtml5NavigatorBarClickRefresh
{
    [self.mainWebView.webView reload];
}

@end
