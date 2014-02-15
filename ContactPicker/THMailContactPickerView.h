//
//  THMailContactPickerView.h
//  ContactPicker
//
//  Created by xtturing on 14-2-15.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//
/*
 用于邮件添加多个联系人，可以用作添加收件人，抄送或密送
 */
#import "THContactPickerView.h"
//定义了收件人，抄送或密送的联系人类型
//typedef NS_ENUM(NSInteger, MailContactType) {
//    MailRecipient = 0,
//    MailCC,
//    MailBCC,
//};

@interface THMailContactPickerView : THContactPickerView

@property (nonatomic,strong) NSString *title;


@end
