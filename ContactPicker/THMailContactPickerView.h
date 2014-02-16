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

//定义了收件人，抄送或密送的联系人类型
typedef NS_ENUM(NSInteger, MailContactType) {
    MailRecipient = 0,
    MailCC,
    MailBCC,
};

@class THMailContactPickerView;

@protocol THMailContactPickerDelegate <NSObject>

- (void)mailContactPickerTextViewDidChange:(NSString *)textViewText;
- (void)mailContactPickerDidRemoveContact:(id)contact;
- (void)mailContactPickerDidResize:(THMailContactPickerView *)contactPickerView;
- (void)mailContactPickerWillAddContact:(MailContactType )currentType;//显示添加联系人按钮
- (void)mailContactPickerShouldAddContact;//可以显示添加联系人

@end

@interface THMailContactPickerView : UIView<UITextViewDelegate, THMailContactBubbleDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) THMailContactBubble *selectedContactBubble;
@property (nonatomic, assign) IBOutlet id <THMailContactPickerDelegate> delegate;
@property (nonatomic, assign) BOOL limitToOne;
@property (nonatomic, assign) CGFloat viewPadding;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) MailContactType contactType;//联系人类型

- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
- (void)removeAllContacts;
- (void)setTitleString:(NSString *)titleString;//输入框的标题
- (void)disableAddButton;
- (void)disableDropShadow;
- (void)resignKeyboard;
- (void)selectTextView;

@end
