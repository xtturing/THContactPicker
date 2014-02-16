//
//  THMailContactPickerView.h
//  ContactPicker
//
//  Created by xtturing on 14-2-15.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//
/*
 用于邮件添加多个联系人，修改输入框的标题可以用作添加收件人，抄送或密送
 */
#import "THContactPickerView.h"
#import "THMailContactBubble.h"


@class THMailContactPickerView;

@protocol THMailContactPickerDelegate <NSObject>

- (void)mailContactPickerTextViewDidChange:(NSString *)textViewText;
- (void)mailContactPickerDidRemoveContact:(id)contact;
- (void)mailContactPickerDidResize:(THMailContactPickerView *)contactPickerView;

@end

@interface THMailContactPickerView : UIView<UITextViewDelegate, THContactBubbleDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) THMailContactBubble *selectedContactBubble;
@property (nonatomic, assign) IBOutlet id <THMailContactPickerDelegate> delegate;
@property (nonatomic, assign) BOOL limitToOne;
@property (nonatomic, assign) CGFloat viewPadding;

- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
- (void)removeAllContacts;
- (void)setTitleString:(NSString *)titleString;//输入框的标题
- (void)disableDropShadow;
- (void)resignKeyboard;


@end
