//
//  Html5WebView.h
//  aimdev
//
//  Created by dongjianbo on 15-1-4.
//  Copyright 2015 www.aimdev.cn
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import <Foundation/Foundation.h>

@class Html5WebView;

@protocol Html5WebViewDelegate <NSObject>
@optional
- (void)html5WebView:(Html5WebView *)html5WebView isRefreshing:(BOOL)isRefreshing;
- (void)html5WebView:(Html5WebView *)html5WebView enableRefresh:(BOOL)enable;
- (void)html5WebView:(Html5WebView *)html5WebView enableGoBack:(BOOL)enable;
- (void)html5WebView:(Html5WebView *)html5WebView enableGoForward:(BOOL)enable;
- (BOOL)html5WebView:(Html5WebView *)html5WebView shouldStartLoad:(NSString*)url;
- (void)html5WebViewDidFinishLoad:(Html5WebView *)html5WebView;
- (void)html5WebView:(Html5WebView *)html5WebView didFailLoadWithError:(NSError *)error;
@end

@interface Html5WebView : UIView <UIWebViewDelegate>

@property(nonatomic, weak) id<Html5WebViewDelegate> delegate;
@property(nonatomic, strong) UIWebView* webView;
@property(nonatomic, strong) NSString* curUrl;

- (void)loadRequestWithURL:(NSString *) url;

@end