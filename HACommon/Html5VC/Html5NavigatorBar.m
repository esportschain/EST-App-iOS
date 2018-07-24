//
//  Html5NavigatorBar.m
//

#import "Html5NavigatorBar.h"
#import <QuartzCore/QuartzCore.h>

@interface Html5NavigatorBar()
{
    UIButton*       _goBackButton;      // 回退
    UIButton*       _goForwardButton;   // 前进
    UIButton*       _refreshButton;     // 刷新
    UIActivityIndicatorView* _indicatorView;
}

-(void)onClickGoBack:(id)sender;
-(void)onClickGoForward:(id)sender;
-(void)onClickRefresh:(id)sender;
@end

@implementation Html5NavigatorBar
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor clearColor];
        
        // bottom sepline
        UIImageView* sepLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5f)];
        [sepLineView setImage:[[HAImageUtil imageWithColor:kColorD7D7D7 size:4] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
        
//        UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.5f, frame.size.width, frame.size.height - 0.5f)];
//        [bgImageView setImage:[[UIImage imageNamed:@"menu_item_highlight.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:0]];
//        [self addSubview:bgImageView];
        
        _goBackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66, frame.size.height)];
        [_goBackButton addTarget:self action:@selector(onClickGoBack:) forControlEvents:UIControlEventTouchUpInside];
        [_goBackButton setImage:[UIImage imageNamed:@"html_back_enable.png"] forState:UIControlStateNormal];
        [_goBackButton setImage:[UIImage imageNamed:@"html_back_disable.png"] forState:UIControlStateDisabled];
        [self addSubview:_goBackButton];
        
        _goForwardButton = [[UIButton alloc] initWithFrame:CGRectMake(_goBackButton.right + 20, 0, 66, frame.size.height)];
        [_goForwardButton addTarget:self action:@selector(onClickGoForward:) forControlEvents:UIControlEventTouchUpInside];
        [_goForwardButton setImage:[UIImage imageNamed:@"html_forward_enable.png"] forState:UIControlStateNormal];
        [_goForwardButton setImage:[UIImage imageNamed:@"html_forward_disable.png"] forState:UIControlStateDisabled];
        [self addSubview:_goForwardButton];
        
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 66, 0, 66, frame.size.height)];
        [_refreshButton addTarget:self action:@selector(onClickRefresh:) forControlEvents:UIControlEventTouchUpInside];
        [_refreshButton setImage:[UIImage imageNamed:@"html_refresh.png"] forState:UIControlStateNormal];
        [self addSubview:_refreshButton];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _indicatorView.center = _refreshButton.center;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _indicatorView.hidesWhenStopped = YES;
        [self addSubview:_indicatorView];
    }
    
    return self;
}

- (void)enableGoBack:(BOOL)enable
{
    [_goBackButton setEnabled:enable];
}

- (void)enableGoForward:(BOOL)enable
{
    [_goForwardButton setEnabled:enable];
}

- (void)enableRefresh:(BOOL)enable
{
    [_refreshButton setEnabled:enable];
}

- (void)setIsRefreshing:(BOOL)refreshing
{
    if (refreshing) {
        _refreshButton.hidden = YES;
        _indicatorView.hidden = NO;
        [_indicatorView startAnimating];
    }
    else {
        _refreshButton.hidden = NO;
        [_indicatorView stopAnimating];
    }
}

-(void)onClickGoBack:(id)sender
{
    if (self.delegate && [delegate respondsToSelector:@selector(onHtml5NavigatorBarClickGoBack)]) {
        [self.delegate onHtml5NavigatorBarClickGoBack];
    }
}

-(void)onClickGoForward:(id)sender
{
    if (self.delegate && [delegate respondsToSelector:@selector(onHtml5NavigatorBarClickGoForward)]) {
        [self.delegate onHtml5NavigatorBarClickGoForward];
    }
}

-(void)onClickRefresh:(id)sender
{
    if (self.delegate && [delegate respondsToSelector:@selector(onHtml5NavigatorBarClickRefresh)]) {
        [self.delegate onHtml5NavigatorBarClickRefresh];
    }
}

@end
