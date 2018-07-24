//
//  Html5NavigatorBar.h
//  wengweng
//

#import <UIKit/UIKit.h>
@protocol Html5NavigatorBarDelegate <NSObject>
    @optional
    - (void)onHtml5NavigatorBarClickGoBack;
    - (void)onHtml5NavigatorBarClickGoForward;
    - (void)onHtml5NavigatorBarClickRefresh;
@end

@interface Html5NavigatorBar : UIView 

@property(nonatomic, weak) id<Html5NavigatorBarDelegate> delegate;

- (void)setIsRefreshing:(BOOL)refreshing;
- (void)enableRefresh:(BOOL)enable;
- (void)enableGoBack:(BOOL)enable;
- (void)enableGoForward:(BOOL)enable;

@end

