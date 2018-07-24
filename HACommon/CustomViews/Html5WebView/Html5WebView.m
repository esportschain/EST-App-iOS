//
//  Html5WebView.m
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

#import "Html5WebView.h"
#import <QuartzCore/QuartzCore.h>
#import "HAURLAction.h"

@interface Html5WebView ()
@property(nonatomic, assign)UIInterfaceOrientation previousOrientation;

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;

- (UIInterfaceOrientation)currentOrientation;
//- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation;
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;

- (void)addObservers;
- (void)removeObservers;
@end

@implementation Html5WebView

#pragma mark - ActivityWebView Life Circle
- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // background settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        // add the web view
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.webView setBackgroundColor:[UIColor whiteColor]];
		[self.webView setDelegate:self];
        self.webView.scalesPageToFit = YES;
		[self addSubview:self.webView];
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        // remove shadow view when drag web view
        for (UIView *subView in [self.webView subviews]) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                for (UIView *shadowView in [subView subviews]) {
                    if ([shadowView isKindOfClass:[UIImageView class]]) {
                        shadowView.hidden = YES;
                    }
                }
            }
        }
    }
    
    return self;
}

- (void) layoutSubviews
{
    CGRect frame = [self bounds];
    [self.webView setFrame:frame];
}

- (void) sizeToFit
{
    [self.webView sizeToFit];
    self.width = self.webView.width;
    self.height = self.webView.height;
}

#pragma mark Orientations
- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(-M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	}

    return CGAffineTransformIdentity;
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == self.previousOrientation) {
		return NO;
	}
    else {
		return orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown;
	}
    
    return YES;
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


#pragma mark Animations
- (void)bounceOutAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
	[UIView commitAnimations];
}

- (void)bounceInAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
	[UIView commitAnimations];
}

- (void)bounceNormalAnimationStopped
{
    [self allAnimationsStopped];
}

- (void)allAnimationsStopped
{
    
}

#pragma mark Dismiss
- (void)hideAndCleanUp
{
    [self removeObservers];
	[self removeFromSuperview];
}

- (void)loadRequestWithURL:(NSString *)url
{
    self.curUrl = url;
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                      timeoutInterval:60.0];
    [self.webView loadRequest:request];
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods
- (void)deviceOrientationDidChange:(id)object
{
    //	UIInterfaceOrientation orientation = [self currentOrientation];
    //	if ([self shouldRotateToOrientation:orientation]) {
    //        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //
    //		[UIView beginAnimations:nil context:nil];
    //		[UIView setAnimationDuration:duration];
    //        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //		[self sizeToFitOrientation:orientation];
    //		[UIView commitAnimations];
    //	}
}

#pragma mark - UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:isRefreshing:)]) {
        [self.delegate html5WebView:self isRefreshing:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableRefresh:)]) {
        [self.delegate html5WebView:self enableRefresh:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableGoBack:)]) {
        [self.delegate html5WebView:self enableGoBack:[self.webView canGoBack]];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableGoForward:)]) {
        [self.delegate html5WebView:self enableGoForward:[self.webView canGoForward]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:isRefreshing:)]) {
        [self.delegate html5WebView:self isRefreshing:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableRefresh:)]) {
        [self.delegate html5WebView:self enableRefresh:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableGoBack:)]) {
        [self.delegate html5WebView:self enableGoBack:[self.webView canGoBack]];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableGoForward:)]) {
        [self.delegate html5WebView:self enableGoForward:[self.webView canGoForward]];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebViewDidFinishLoad:)]) {
        [self.delegate html5WebViewDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:isRefreshing:)]) {
        [self.delegate html5WebView:self isRefreshing:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:enableRefresh:)]) {
        [self.delegate html5WebView:self enableRefresh:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:didFailLoadWithError:)]) {
        [self.delegate html5WebView:self didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[HAURLActionCenter sharedInstance] performWithUrl:request.URL.absoluteString]) {
        return NO;
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(html5WebView:shouldStartLoad:)]) {
        return [self.delegate html5WebView:self shouldStartLoad:request.URL.absoluteString];
    }
    
    self.curUrl = request.URL.absoluteString;
    
    return YES;
}

@end
