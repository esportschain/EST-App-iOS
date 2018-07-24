//
//  SMSSendView.m
//  bbshub
//


#import "SMSSendView.h"

@interface SMSSendView() <HPGrowingTextViewDelegate>
@property(nonatomic, strong)HPGrowingTextView*  hPGrowingTextView;
@property(nonatomic, strong)UIImageView*        inputViewFG;
@property(nonatomic, strong)UIButton*           cancelButton;
@property(nonatomic, assign)NSRange             selectRange;
@property(nonatomic, strong)UIButton*           photoButton;
@property(nonatomic, strong)UIButton*           shareButton;

- (void) commonInitialiser;
- (void) onClickCancelButton;
- (void) onClickCommitButton;

- (void) registerNotification;
- (void) unregisterNotification;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end

#define CONTENT_ACTION_BOTTOM   kScreenHeight

#define	BUTTON_RIGHT            0
#define	BUTTON_TOP              9
#define	BUTTON_WIDTH            58
#define	BUTTON_HEIGHT           27

#define TEXTVIEW_FONT   kNormalFont(15)
#define	BUTTON_FONT     kBoldFont(15)

#define SWITCHBUTTON_TAG_INIT       0
#define SWITCHBUTTON_TAG_KEYBOARD   1
#define SWITCHBUTTON_TAG_FACE       2

@implementation SMSSendView

- (id)initWithFrame:(CGRect)frame type:(enumActionType)type
{
    if ((self = [super initWithFrame:frame])) {
        self.type = type;
        [self commonInitialiser];
    }
    
    return self;
}

- (void) dealloc
{
    [self unregisterNotification];
}

#pragma mark - public function
- (void) setText:(NSString *)text
{
    [self.hPGrowingTextView setText:text];
}

- (void) setTextAndBecomeFirstResponder:(NSString *)text
{
    [self.hPGrowingTextView becomeFirstResponder];
    [self.hPGrowingTextView setText:text];
}

- (void) setPlaceHolder:(NSString *)text
{
    [self.hPGrowingTextView setPlaceholder:text];
}

- (NSString*) getText
{
    return self.hPGrowingTextView.text;
}

- (void) assignFocus
{
    if(!self.cancelButton.superview) {
        [self.superview insertSubview:self.cancelButton belowSubview:self];
    }
    
    [self.hPGrowingTextView.internalTextView becomeFirstResponder];
}

- (void) resignFocus
{
    if(self.cancelButton.superview) {
        [self.cancelButton removeFromSuperview];
    }
    
    [self.hPGrowingTextView.internalTextView resignFirstResponder];
    self.frame = CGRectMake(0, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    
    // notify move
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewMove:Duration:Type:)]) {
        [self.delegate onActionViewMove:self Duration:0 Type:ActionViewMoveByDefault];
    }
}

- (void) setIsFavorite:(BOOL)isFavorite
{
    if (self.photoButton) {
        if (isFavorite) {
            [self.photoButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        }
        else {
            [self.photoButton setImage:[UIImage imageNamed:@"unfavorite.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    
    // notify move
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewMove:Duration:Type:)]) {
        [self.delegate onActionViewMove:self Duration:0 Type:ActionViewMoveByDefault];
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewInputChange:)]) {
        [self.delegate onActionViewInputChange:growingTextView.text];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if (text.length == 0 && range.location != NSNotFound && range.length == 1) {
        NSString * text = [growingTextView text];
        NSRange del = NSMakeRange(NSNotFound, 0);
        if (self.selectRange.length > 1) {
            if (self.selectRange.location + self.selectRange.length < [text length]) {
                del = self.selectRange;
            }
        }
        else if (self.selectRange.location <= [text length]) {
            if (self.selectRange.location > 2) {
                unichar ch = [text characterAtIndex:self.selectRange.location-2];
                if (ch >= 0xD800 && ch <= 0xDFFF) {
                    del = NSMakeRange(self.selectRange.location-2, 2);
                }
                else {
                    del = NSMakeRange(self.selectRange.location-1, 1);
                }
            }
            else {
                del = NSMakeRange(self.selectRange.location-1, 1);
            }
        }
        if (del.location != NSNotFound) {
            _selectRange.location = del.location;
            _selectRange.length = 0;
        }
    }
    
    return YES;
}

#pragma mark - private function
-(void)commonInitialiser
{
    [self registerNotification];
    [self setBackgroundColor:[HAColorUtil colorWithInt:0xf7f7f7]];
    
    // 输入背景 ImageView
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    [line setBackgroundColor:[HAColorUtil colorWithInt:0xdedede]];
    [self addSubview:line];
    
    NSInteger left = (self.type == ActionType_SMS) ? 18 : 80;
    NSInteger width = self.width - left - BUTTON_WIDTH - 3;
    
    // 设置TextView
    self.hPGrowingTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(left, 6, width, 32)];
    [self.hPGrowingTextView setBackgroundColor:[UIColor clearColor]];
    [self.hPGrowingTextView setFont:TEXTVIEW_FONT];
    [self.hPGrowingTextView setMinNumberOfLines:1];
    [self.hPGrowingTextView setMaxNumberOfLines:3];
    [self.hPGrowingTextView setReturnKeyType:UIReturnKeyDefault];
    [self.hPGrowingTextView setMaxTextLength:500];
    [[self.hPGrowingTextView internalTextView] setScrollIndicatorInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    [self.hPGrowingTextView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.hPGrowingTextView setDelegate:self];
    [self addSubview:self.hPGrowingTextView];
    
    // 输入前景 ImageView
    self.inputViewFG = [[UIImageView alloc] initWithFrame:CGRectMake(left - 3, 1, width + 6, 43)];
    [self.inputViewFG setImage:[[UIImage imageNamed:@"input_field.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:22]];
    [self.inputViewFG setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self addSubview:self.inputViewFG];
    
    // 发送按钮
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitButton setFrame:CGRectMake(CONTENT_ACTION_WIDTH - BUTTON_WIDTH - BUTTON_RIGHT, BUTTON_TOP, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [commitButton setTitle:@"发送" forState:UIControlStateNormal];
    [commitButton setTitleColor:kColorNavButton forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(onClickCommitButton) forControlEvents:UIControlEventTouchUpInside];
    [[commitButton titleLabel] setFont:BUTTON_FONT];
    [commitButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
    [self addSubview:commitButton];
    
    // 相机按钮
    if (self.type == ActionType_REPLY) {
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photoButton setFrame:CGRectMake(5, (CONTENT_TEXTINPUT_HEIGHT - 22) / 2, 30, 22)];
        [self.photoButton addTarget:self action:@selector(onClickFavoriteButton) forControlEvents:UIControlEventTouchUpInside];
        [self.photoButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [self.photoButton setImage:[UIImage imageNamed:@"unfavorite.png"] forState:UIControlStateNormal];
        [self addSubview:self.photoButton];
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setFrame:CGRectMake(self.photoButton.right + 2, (CONTENT_TEXTINPUT_HEIGHT - 30) / 2, 30, 30)];
        [self.shareButton addTarget:self action:@selector(onClickShareButton) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [self.shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        [self addSubview:self.shareButton];
    }
    
    // cancel button
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.cancelButton addTarget:self action:@selector(onClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void) onClickCancelButton
{
    [self resignFocus];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewCancel)]) {
        [self.delegate onActionViewCancel];
    }
}

- (void) onClickFavoriteButton
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewFavorite)]) {
        [self.delegate onActionViewFavorite];
    }
}

- (void) onClickShareButton
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewShare)]) {
        [self.delegate onActionViewShare];
    }
}

- (void) onClickCommitButton
{
    NSString* content = self.hPGrowingTextView.text;
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(content == nil && [content length] == 0) {
        return;
    }
    
    //    self.hPGrowingTextView.text = @"";
    //    self.selectRange = self.hPGrowingTextView.selectedRange;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewCommit:)]) {
        [self.delegate onActionViewCommit:content];
    }
}

// 注册消息
- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// 注销消息
- (void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 键盘将要显示
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (![self.hPGrowingTextView.internalTextView isFirstResponder]) {
        return;
    }
    
    if(!self.cancelButton.superview) {
        [self.superview insertSubview:self.cancelButton belowSubview:self];
    }
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.superview convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.bounds.size.height - keyboardBounds.size.height - self.frame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    // 修改界面布局
    if (self.type == ActionType_REPLY) {
        NSInteger left = 18;
        NSInteger width = self.width - left - BUTTON_WIDTH - 3;
        self.hPGrowingTextView.frame = CGRectMake(left, self.hPGrowingTextView.y, width, self.hPGrowingTextView.height);
        self.inputViewFG.frame = CGRectMake(left - 3, self.inputViewFG.y, width + 6, self.inputViewFG.height);
        self.photoButton.hidden = YES;
        self.shareButton.hidden = YES;
    }
    
    // commit animations
    [UIView commitAnimations];
    
    // notify move
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewMove:Duration:Type:)]) {
        [self.delegate onActionViewMove:self Duration:duration.doubleValue Type:ActionViewMoveByKeyBoardWillShow];
    }
}

// 键盘消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    if (![self.hPGrowingTextView.internalTextView isFirstResponder]) {
        return;
    }
    
    if(self.cancelButton.superview) {
        [self.cancelButton removeFromSuperview];
    }
    
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    
    containerFrame.origin.y = self.superview.bounds.size.height - self.frame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // 修改界面布局
    if (self.type == ActionType_REPLY) {
        NSInteger left = 80;
        NSInteger width = self.width - left - BUTTON_WIDTH - 3;;
        self.hPGrowingTextView.frame = CGRectMake(left, self.hPGrowingTextView.y, width, self.hPGrowingTextView.height);
        self.inputViewFG.frame = CGRectMake(left - 3, self.inputViewFG.y, width + 6, self.inputViewFG.height);
        self.photoButton.hidden = NO;
        self.shareButton.hidden = NO;
    }
    
    // set views with new info
    self.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    
    // notify move
    if(self.delegate && [self.delegate respondsToSelector:@selector(onActionViewMove:Duration:Type:)]) {
        [self.delegate onActionViewMove:self Duration:[duration doubleValue] Type:ActionViewMoveByKeyBoardWillHiden];
    }
}

@end
