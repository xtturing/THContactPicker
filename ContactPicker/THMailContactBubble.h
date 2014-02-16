//
//  THMailContactBubble.h
//  ContactPicker
//
//  Created by xtturing on 14-2-15.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//
/*
 邮件的联系人
 */
#import "THContactBubble.h"
#import <QuartzCore/QuartzCore.h>
#import "THBubbleColor.h"

@class THMailContactBubble;

@protocol THMailContactBubbleDelegate <NSObject>

- (void)mailContactBubbleWasSelected:(THMailContactBubble *)contactBubble;
- (void)mailContactBubbleWasUnSelected:(THMailContactBubble *)contactBubble;
- (void)mailContactBubbleShouldBeRemoved:(THMailContactBubble *)contactBubble;

@end

@interface THMailContactBubble : UIView<UITextViewDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) id <THMailContactBubbleDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) THBubbleColor *color;
@property (nonatomic, strong) THBubbleColor *selectedColor;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name
             color:(THBubbleColor *)color
     selectedColor:(THBubbleColor *)selectedColor;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;
@end
