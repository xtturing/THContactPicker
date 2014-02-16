//
//  THMailContactBubble.m
//  ContactPicker
//
//  Created by xtturing on 14-2-15.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//

#import "THMailContactBubble.h"

#define kHorizontalPadding 10
#define kVerticalPadding 2

#define kBubbleColorSelected                      [UIColor colorWithRed:24.0/255.0 green:134.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kBubbleColor              [UIColor whiteColor]

@interface THMailContactBubble ()

@property (nonatomic, strong) UILabel *comma;//顿号

@end

@implementation THMailContactBubble

- (id)initWithName:(NSString *)name {
    if ([self initWithName:name color:nil selectedColor:nil]) {
    }
    return self;
}

- (id)initWithName:(NSString *)name color:(THBubbleColor *)color selectedColor:(THBubbleColor *)selectedColor {
    self = [super init];
    if (self){
        self.name = name;
        self.isSelected = NO;
        
        if (color == nil){
            color = [[THBubbleColor alloc] initWithGradientTop:kBubbleColor gradientBottom:kBubbleColor border:kBubbleColor];
        }
        
        if (selectedColor == nil){
            selectedColor = [[THBubbleColor alloc] initWithGradientTop:kBubbleColorSelected gradientBottom:kBubbleColorSelected border:kBubbleColorSelected];
        }
        
        self.color = color;
        self.selectedColor = selectedColor;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // Create Label
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = self.name;
    [self addSubview:self.label];
    
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.hidden = YES;
    [self addSubview:self.textView];
    
    // Create a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [self unSelect];
}

- (void)adjustSize {
    // Adjust the label frames
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    frame.origin.x = kHorizontalPadding;
    frame.origin.y = kVerticalPadding;
    self.label.frame = frame;
    
    // Adjust view frame
    self.bounds = CGRectMake(0, 0, frame.size.width + 2 * kHorizontalPadding, frame.size.height + 2 * kVerticalPadding);
    
    // Create gradient layer
    if (self.gradientLayer == nil){
        self.gradientLayer = [CAGradientLayer layer];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = self.bounds;
    
    // Round the corners
    CALayer *viewLayer = [self layer];
    viewLayer.cornerRadius = 4;
    viewLayer.borderWidth = 0;
    viewLayer.masksToBounds = YES;
}

- (void)setFont:(UIFont *)font {
    self.label.font = font;
    
    [self adjustSize];
}

- (void)select {
    if ([self.delegate respondsToSelector:@selector(mailContactBubbleWasSelected:)]){
        [self.delegate mailContactBubbleWasSelected:self];
    }
    
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.selectedColor.border.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.selectedColor.gradientTop CGColor], (id)[self.selectedColor.gradientBottom CGColor], nil];
    
    self.label.textColor = kBubbleColor;
    
    self.isSelected = YES;
    
    [self.textView becomeFirstResponder];
    
    //选中删除隐藏顿号
    self.comma.hidden=YES;
    [self setNeedsDisplay];
    [self adjustSize];
}

- (void)unSelect {
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.color.border.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.color.gradientTop CGColor], (id)[self.color.gradientBottom CGColor], nil];
    
    self.label.textColor = kBubbleColorSelected;
    [self setNeedsDisplay];
    self.isSelected = NO;
    
    [self.textView resignFirstResponder];
    
    [self adjustSize];
    //未选中加入顿号
    if(self.comma==nil){
        self.comma = [[UILabel alloc] init];
        self.comma.backgroundColor = [UIColor clearColor];
        self.comma.text = @"、";
        [self addSubview:self.comma];
        [self.comma sizeToFit];
        CGRect frame = self.comma.frame;
        frame.origin.x = self.label.frame.origin.x+self.label.frame.size.width;
        frame.origin.y = kVerticalPadding;
        self.comma.frame = frame;
    }else{
        self.comma.hidden=NO;
    }
    [self setNeedsDisplay];
    
}

- (void)handleTapGesture {
    if (self.isSelected){
        [self unSelect];
    } else {
        [self select];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    self.textView.hidden = NO;
    
    if ( [text isEqualToString:@"\n"] ) { // Return key was pressed
        return NO;
    }
    
    // Capture "delete" key press when cell is empty
    if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
        if ([self.delegate respondsToSelector:@selector(mailContactBubbleShouldBeRemoved:)]){
            [self.delegate mailContactBubbleShouldBeRemoved:self];
        }
    }
    
    if (self.isSelected){
        self.textView.text = @"";
        [self unSelect];
        if ([self.delegate respondsToSelector:@selector(mailContactBubbleWasUnSelected:)]){
            [self.delegate mailContactBubbleWasUnSelected:self];
        }
    }
    
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
