//
//  HPTextView.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPGrowingTextView.h"

@interface HPGrowingTextView(private)
-(void)commonInitialiser;
-(void)resizeTextView:(NSInteger)newSizeH;
-(void)growDidStop;
@end

@implementation HPGrowingTextView
@synthesize delegate = _delegate;

@synthesize maxNumberOfLines = _maxNumberOfLines;
@synthesize minNumberOfLines = _minNumberOfLines;
@synthesize minHeight = _minHeight;
@synthesize maxHeight = _maxHeight;
@synthesize animateHeightChange = _animateHeightChange;
@synthesize animationDuration = _animationDuration;
@synthesize placeholder = _placeholder;
@synthesize placeholderColor = _placeholderColor;
@synthesize internalTextView = _internalTextView;

@synthesize text = _text;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize textAlignment = _textAlignment;
@synthesize selectedRange = _selectedRange;
@synthesize editable = _editable;
@synthesize dataDetectorTypes = _dataDetectorTypes;
@synthesize returnKeyType = _returnKeyType;
@synthesize contentInset = _contentInset;

@synthesize maxTextLength = _maxTextLength;
@synthesize isScrollable = _isScrollable;
@synthesize enablesReturnKeyAutomatically = _enablesReturnKeyAutomatically;


// having initwithcoder allows us to use HPGrowingTextView in a Nib. -- aob, 9/2011
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialiser];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialiser];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInitialiser];
    }
    return self;
}

- (void) dealloc
{
    self.delegate = nil;
}

-(void)commonInitialiser
{
    // Initialization code
    CGRect r = self.frame;
    r.origin.y = 0;
    r.origin.x = 0;
    
    _internalTextView = [[HPTextViewInternal alloc] initWithFrame:r];
    _internalTextView.delegate = self;
    _internalTextView.scrollEnabled = NO;
    _internalTextView.font = kNormalFont(14.5);
    _internalTextView.contentInset = UIEdgeInsetsZero;
    _internalTextView.showsHorizontalScrollIndicator = NO;
    _internalTextView.text = @"-";
    [self addSubview:_internalTextView];
    
    _minHeight = self.internalTextView.frame.size.height;
    _minNumberOfLines = 1;
    
    _animateHeightChange = YES;
    _animationDuration = 0.1f;
    
    _internalTextView.text = @"";
    
    //[self setMaxNumberOfLines:3];
    
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    _internalTextView.displayPlaceHolder = YES;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0) {
        size.height = _minHeight;
    }
    return size;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
	CGRect r = self.bounds;
	r.origin.y = 0;
	r.origin.x = _contentInset.left;
    r.size.width -= _contentInset.left + _contentInset.right;
    
    _internalTextView.frame = r;
}

-(void)setContentInset:(UIEdgeInsets)inset
{
    _contentInset = inset;
    
    CGRect r = self.frame;
    r.origin.y = inset.top - inset.bottom;
    r.origin.x = inset.left;
    r.size.width -= inset.left + inset.right;
    
    _internalTextView.frame = r;
    
    [self setMaxNumberOfLines:_maxNumberOfLines];
    [self setMinNumberOfLines:_minNumberOfLines];
}

-(UIEdgeInsets)contentInset
{
    return _contentInset;
}

-(void)setMaxNumberOfLines:(int)n
{
    if(n == 0 && _maxHeight > 0) return; // the user specified a maxHeight themselves.
    
    // Use _internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = _internalTextView.text, *newText = @"-";
    
    _internalTextView.delegate = nil;
    _internalTextView.hidden = YES;
    
    for (int i = 1; i < n; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    _internalTextView.text = newText;
    
    _maxHeight = [self measureHeight];
    
    _internalTextView.text = saveText;
    _internalTextView.hidden = NO;
    _internalTextView.delegate = self;
    
    [self sizeToFit];
    
    _maxNumberOfLines = n;
}

-(int)maxNumberOfLines
{
    return _maxNumberOfLines;
}

- (void)setMaxHeight:(int)height
{
    _maxHeight = height;
    _maxNumberOfLines = 0;
}

-(void)setMinNumberOfLines:(int)m
{
    if(m == 0 && _minHeight > 0) return; // the user specified a minHeight themselves.
    
	// Use _internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = _internalTextView.text, *newText = @"-";
    
    _internalTextView.delegate = nil;
    _internalTextView.hidden = YES;
    
    for (int i = 1; i < m; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    _internalTextView.text = newText;
    
    _minHeight = [self measureHeight];
    
    _internalTextView.text = saveText;
    _internalTextView.hidden = NO;
    _internalTextView.delegate = self;
    
    [self sizeToFit];
    
    _minNumberOfLines = m;
}

-(int)minNumberOfLines
{
    return _minNumberOfLines;
}

- (void)setMinHeight:(int)height
{
    _minHeight = height;
    _minNumberOfLines = 0;
}

- (NSString *)placeholder
{
    return _internalTextView.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [_internalTextView setPlaceholder:placeholder];
}

- (UIColor *)placeholderColor
{
    return _internalTextView.placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [_internalTextView setPlaceholderColor:placeholderColor];
    [self.internalTextView setNeedsDisplay];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshHeight];
}

- (void)refreshHeight
{
	//size of content, so we can set the frame of self
	NSInteger newSizeH = [self measureHeight];
	if(newSizeH < _minHeight || !_internalTextView.hasText) newSizeH = _minHeight; //not smalles than minHeight
    if (_internalTextView.frame.size.height > _maxHeight) newSizeH = _maxHeight; // not taller than maxHeight
    
	if (_internalTextView.frame.size.height != newSizeH)
	{
        // [fixed] Pasting too much text into the view failed to fire the height change,
        // thanks to Gwynne <http://blog.darkrainfall.org/>
        
        if (newSizeH > _maxHeight && _internalTextView.frame.size.height <= _maxHeight)
        {
            newSizeH = _maxHeight;
        }
        
		if (newSizeH <= _maxHeight)
		{
            if(_animateHeightChange) {
                
                if ([UIView resolveClassMethod:@selector(animateWithDuration:animations:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
                    [UIView animateWithDuration:_animationDuration
                                          delay:0
                                        options:(UIViewAnimationOptionAllowUserInteraction|
                                                 UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^(void) {
                                         [self resizeTextView:newSizeH];
                                     }
                                     completion:^(BOOL finished) {
                                         if ([_delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                                             [_delegate growingTextView:self didChangeHeight:newSizeH];
                                         }
                                     }];
#endif
                } else {
                    [UIView beginAnimations:@"" context:nil];
                    [UIView setAnimationDuration:_animationDuration];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                    [UIView setAnimationBeginsFromCurrentState:YES];
                    [self resizeTextView:newSizeH];
                    [UIView commitAnimations];
                }
            } else {
                [self resizeTextView:newSizeH];
                // [fixed] The growingTextView:didChangeHeight: delegate method was not called at all when not animating height changes.
                // thanks to Gwynne <http://blog.darkrainfall.org/>
                
                if ([_delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                    [_delegate growingTextView:self didChangeHeight:newSizeH];
                }
            }
		}
        
        // if our new height is greater than the maxHeight
        // sets not set the height or move things
        // around and enable scrolling
		if (newSizeH >= _maxHeight)
		{
			if(!_internalTextView.scrollEnabled){
				_internalTextView.scrollEnabled = YES;
				[_internalTextView flashScrollIndicators];
			}
			
		} else {
			_internalTextView.scrollEnabled = NO;
		}
		
        // scroll to caret (needed on iOS7)
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        {
            CGRect r = [_internalTextView caretRectForPosition:_internalTextView.selectedTextRange.end];
            CGFloat caretY =  MAX(r.origin.y - _internalTextView.frame.size.height + r.size.height + 8, 0);
            if(_internalTextView.contentOffset.y < caretY && r.origin.y != INFINITY)
                _internalTextView.contentOffset = CGPointMake(0, MIN(caretY, _internalTextView.contentSize.height));
        }
	}
    // Display (or not) the placeholder string
    
    BOOL wasDisplayingPlaceholder = _internalTextView.displayPlaceHolder;
    _internalTextView.displayPlaceHolder = _internalTextView.text.length == 0;
	
    if (wasDisplayingPlaceholder != _internalTextView.displayPlaceHolder) {
        [_internalTextView setNeedsDisplay];
    }
    
    // Tell the delegate that the text view changed
	
    if ([_delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
		[_delegate growingTextViewDidChange:self];
	}
	
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        CGRect frame = _internalTextView.bounds;
        CGSize fudgeFactor;
        // The padding added around the text on iOS6 and iOS7 is different.
        fudgeFactor = CGSizeMake(10.0, 16.0);
        
        frame.size.height -= fudgeFactor.height;
        frame.size.width -= fudgeFactor.width;
        
        NSMutableAttributedString* textToMeasure;
        if(_internalTextView.attributedText && _internalTextView.attributedText.length > 0){
            textToMeasure = [[NSMutableAttributedString alloc] initWithAttributedString:_internalTextView.attributedText];
        }
        else{
            textToMeasure = [[NSMutableAttributedString alloc] initWithString:_internalTextView.text];
            [textToMeasure addAttribute:NSFontAttributeName value:_internalTextView.font range:NSMakeRange(0, textToMeasure.length)];
        }
        
        if ([textToMeasure.string hasSuffix:@"\n"])
        {
            [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: _internalTextView.font}]];
        }
        
        // NSAttributedString class method: boundingRectWithSize:options:context is
        // available only on ios7.0 sdk.
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil];
        return CGRectGetHeight(size) + fudgeFactor.height;
    }
    else {
        return _internalTextView.contentSize.height;
    }
#else
    return self._internalTextView.contentSize.height;
#endif
}

-(void)resizeTextView:(NSInteger)newSizeH
{
    if ([_delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [_delegate growingTextView:self willChangeHeight:newSizeH];
    }
    
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH; // + padding
    self.frame = internalTextViewFrame;
    
    internalTextViewFrame.origin.y = _contentInset.top - _contentInset.bottom;
    internalTextViewFrame.origin.x = _contentInset.left;
    internalTextViewFrame.size.width = _internalTextView.contentSize.width;
    
    if(!CGRectEqualToRect(_internalTextView.frame, internalTextViewFrame)) _internalTextView.frame = internalTextViewFrame;
}

- (void)growDidStop
{
	if ([_delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
		[_delegate growingTextView:self didChangeHeight:self.frame.size.height];
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_internalTextView becomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [_internalTextView becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [_internalTextView resignFirstResponder];
}

-(BOOL)isFirstResponder
{
    return [_internalTextView isFirstResponder];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextView properties
///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)newText
{
    NSRange r = _internalTextView.selectedRange;
    
    _internalTextView.text = newText;
    
    NSInteger nl = _internalTextView.text.length;
    if (r.location > nl) {
        r.location = nl;
        r.length = 0;
    } else if (r.location + r.length > nl) {
        r.length = nl - r.location;
    }
    _internalTextView.selectedRange = r;
    
    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    [self performSelector:@selector(textViewDidChange:) withObject:_internalTextView];
}

-(NSString*) text
{
    return _internalTextView.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setFont:(UIFont *)afont
{
	_internalTextView.font= afont;
	
	[self setMaxNumberOfLines:_maxNumberOfLines];
	[self setMinNumberOfLines:_minNumberOfLines];
}

-(UIFont *)font
{
	return _internalTextView.font;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextColor:(UIColor *)color
{
	_internalTextView.textColor = color;
}

-(UIColor*)textColor{
	return _internalTextView.textColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
	_internalTextView.backgroundColor = backgroundColor;
}

-(UIColor*)backgroundColor
{
    return _internalTextView.backgroundColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextAlignment:(NSTextAlignment)aligment
{
	_internalTextView.textAlignment = aligment;
}

-(NSTextAlignment)textAlignment
{
	return _internalTextView.textAlignment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setSelectedRange:(NSRange)range
{
	_internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return _internalTextView.selectedRange;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setIsScrollable:(BOOL)isScrollable
{
    _internalTextView.scrollEnabled = isScrollable;
}

- (BOOL)isScrollable
{
    return _internalTextView.scrollEnabled;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setEditable:(BOOL)beditable
{
	_internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return _internalTextView.editable;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	_internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return _internalTextView.returnKeyType;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
    _internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return _internalTextView.enablesReturnKeyAutomatically;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	_internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return _internalTextView.dataDetectorTypes;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasText{
	return [_internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[_internalTextView scrollRangeToVisible:range];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([_delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [_delegate growingTextViewShouldBeginEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([_delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [_delegate growingTextViewShouldEndEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([_delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[_delegate growingTextViewDidBeginEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([_delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		[_delegate growingTextViewDidEndEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
// replacementText:(NSString *)atext {
//
//	//weird 1 pixel bug when clicking backspace when textView is empty
//	if(![textView hasText] && [atext isEqualToString:@""]) return NO;
//
//	//Added by bretdabaker: sometimes we want to handle this ourselves
//    	if ([delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
//        	return [delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
//
//	if ([atext isEqualToString:@"\n"]) {
//		if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
//			if (![delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
//				return YES;
//			} else {
//				[textView resignFirstResponder];
//				return NO;
//			}
//		}
//	}
//
//	return YES;
//
//
//}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([_delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
		[_delegate growingTextViewDidChangeSelection:self];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext
{
    // 添加数据
	if(range.length == 0)
	{
		// 当前内容长度
		NSString *content = [textView text];
		NSInteger contentLength = (content != nil) ? [content length] : 0;
		
		// 计算总长度
		NSInteger totalLength = contentLength + [atext length];
		if(totalLength > _maxTextLength)
		{
			return NO;
		}
        
        // 代理响应文本变化
        //        if ([delegate respondsToSelector:@selector(shouldChangeTextInRange:)])
        //        {
        //            [delegate performSelector:@selector(shouldChangeTextInRange:) withObject:[NSNumber numberWithInt:(totalLength)]];
        //        }
	}
	// 替换数据
	else
	{
		// 当前内容长度
		NSString *content = [textView text];
		NSInteger contentLength = (content != nil) ? [content length] : 0;
		
		// 计算总长度
		NSInteger totalLength = contentLength + [atext length] - range.length;
		if(totalLength > _maxTextLength)
		{
			return NO;
		}
        
        // 代理响应文本变化
        //        if ([delegate respondsToSelector:@selector(shouldChangeTextInRange:)])
        //        {
        //            [delegate performSelector:@selector(shouldChangeTextInRange:) withObject:[NSNumber numberWithInt:totalLength]];
        //        }
	}
	
	//weird 1 pixel bug when clicking backspace when textView is empty
	if(![textView hasText] && [atext isEqualToString:@""]) return NO;
	
	//Added by bretdabaker: sometimes we want to handle this ourselves
    if ([_delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
        return [_delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
	
	if ([atext isEqualToString:@"\n"]) {
		if ([_delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
			if (![_delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
				return YES;
			} else {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	
	return YES;
}

- (void)backSpace
{
    if([_internalTextView hasText])
    {
        NSRange range;
        range.location = [_internalTextView.text length] - 1;
        range.length = 1;
        
        if ([_delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)]) {
            BOOL ret = [_delegate growingTextView:self shouldChangeTextInRange:range replacementText:@""];
            if(ret) {
                _internalTextView.text = [_internalTextView.text substringToIndex:[_internalTextView.text length] - 1];
            }
        }
        
    }
}

@end
