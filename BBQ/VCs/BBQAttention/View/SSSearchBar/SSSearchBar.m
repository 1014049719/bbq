//
//  SSSearchBar.m

/*
 Copyright (c) 2014 Simon Gislen
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "SSSearchBar.h"

//I like these values; Feel free to play around though :-)

#define kXMargin 8
#define kYMargin 4
#define kIconSize 16

#define kSearchBarHeight 32


@interface SSSearchBar () <UITextFieldDelegate> {
    BOOL _cancelButtonHidden;
}
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *searchButton;
@property (nonatomic) SSRoundedView *backgroundView;

@property (nonatomic) UIImage *searchImage;

@end

@implementation SSSearchBar

#pragma mark - Initializers

- (void)setDefaults {
    
    UIImage *searchIcon = [UIImage imageNamed:@"sc"];
    _searchImage = searchIcon;
    self.backgroundColor = [UIColor clearColor];
    
    NSUInteger boundsWidth = self.bounds.size.width;
    NSUInteger textFieldHeight = self.bounds.size.height - kYMargin;
    
    //Background Rounded White Image
    self.backgroundView = [[SSRoundedView alloc] initWithFrame:CGRectMake(0, 0, boundsWidth, self.bounds.size.height)];
    [self addSubview:self.backgroundView];
    
    //TextField
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(2*kXMargin + kIconSize, kYMargin, boundsWidth - 2*kXMargin-kIconSize, textFieldHeight)];
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.font = [UIFont systemFontOfSize:17];
    self.textField.textColor = [UIColor blackColor];
    [self addSubview:self.textField];
    
    //Search Image
    self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kIconSize, kIconSize)];
    [self.searchButton setBackgroundImage:self.searchImage forState:UIControlStateNormal];
    self.searchButton.center = CGPointMake(boundsWidth - (kIconSize/2 + kXMargin), CGRectGetMidY(self.bounds));
    [self.searchButton addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.searchButton];
    
    
    //Listen to text changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:self.textField];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    
    CGRect newFrame = frame;
    frame.size.height = kSearchBarHeight;
    frame = newFrame;
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectMake(10, 20, 300, 32)];
}

#pragma mark - Properties and actions

- (NSString *)text {
    return self.textField.text;
}
- (void)setText:(NSString *)text {
    self.textField.text = text;
}
- (NSString *)placeholder {
    return self.textField.placeholder;
}
- (void)setPlaceholder:(NSString *)placeholder {
    self.textField.placeholder = placeholder;
}

- (UIFont *)font {
    return self.textField.font;
}
- (void)setFont:(UIFont *)font {
    self.textField.font = font;
}

- (BOOL)isCancelButtonHidden {
    return _cancelButtonHidden;
}
- (void)setCancelButtonHidden:(BOOL)cancelButtonHidden {
    
    if (_cancelButtonHidden != cancelButtonHidden) {
        _cancelButtonHidden = cancelButtonHidden;
        self.cancelButton.hidden = cancelButtonHidden;
    }
}
-(void)startSearch{
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
        [self.delegate searchBarSearchButtonClicked:self];
}
- (void)pressedCancel: (id)sender {
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    [self.delegate searchBarCancelButtonClicked:self];
}

#pragma mark - Text Delegate

- (void)textChanged: (id)sender {
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
        [self.delegate searchBar:self textDidChange:self.text];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)])
        return [self.delegate searchBarShouldBeginEditing:self];
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
        [self.delegate searchBarTextDidBeginEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)])
        [self.delegate searchBarTextDidEndEditing:self];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
        [self.delegate searchBarSearchButtonClicked:self];
    
    return YES;
}

- (BOOL)isFirstResponder {
    return [self.textField isFirstResponder];
}
- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}
- (BOOL)resignFirstResponder {
    [self.textField resignFirstResponder];
    return YES;
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation SSRoundedView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIColor *color = UIColorHex(F5F5F5);
    [color set]; //设置线条颜色
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:18];
    path.lineWidth = 3.0;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    [path stroke];
}

@end
