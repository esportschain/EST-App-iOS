//
//  SMSSendView.h
//  bbshub
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

#define CONTENT_ACTION_WIDTH        kScreenWidth
#define CONTENT_TEXTINPUT_HEIGHT    44
#define CONTENT_ACTION_HEIGHT       CONTENT_TEXTINPUT_HEIGHT

typedef enum {
    ActionType_SMS = 0,
    ActionType_REPLY = 1
}enumActionType;

typedef enum {
    ActionViewMoveByDefault = 0,
    ActionViewMoveByKeyBoardWillShow,
    ActionViewMoveByKeyBoardWillHiden,
    ActionViewMoveByFacePanelWillShow
}enumActionViewMoveType;

@protocol SMSSendViewDelegate <NSObject>
@optional
- (void) onActionViewMove:(UIView*)actionView Duration:(CGFloat)duration Type:(enumActionViewMoveType)type;        // 界面移动
- (void) onActionViewCancel;                            // 取消输入
- (void) onActionViewInputChange:(NSString*)content;    // 编辑框内容改变
- (void) onActionViewCommit:(NSString*)content;         // 确认发送
- (void) onActionViewFavorite;                          // 点击收藏按钮
- (void) onActionViewShare;                             // 点击分享按钮
@end

@interface SMSSendView : UIView

@property(nonatomic, assign)id<SMSSendViewDelegate> delegate;
@property(nonatomic, assign)NSInteger type;

- (id)initWithFrame:(CGRect)frame type:(enumActionType)type;
- (void) setText:(NSString *)text;
- (void) setTextAndBecomeFirstResponder:(NSString *)text;
- (void) setPlaceHolder:(NSString *)text;
- (NSString*) getText;
- (void) assignFocus;
- (void) resignFocus;

- (void) setIsFavorite:(BOOL)isFavorite;

@end
