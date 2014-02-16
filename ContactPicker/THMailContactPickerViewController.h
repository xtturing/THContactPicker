//
//  THMailContactPickerViewController.h
//  ContactPicker
//
//  Created by xutao on 14-2-16.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//
/*
 
 发送邮件页
 
 */
#import <UIKit/UIKit.h>
#import "THMailContactPickerView.h"
#import "THMailContactViewController.h"

@interface THMailContactPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, THMailContactPickerDelegate,THMailContactDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *selectedRecipientContacts;//选择的收件人数组
@property (nonatomic, strong) NSMutableArray *selectedCCContacts;//选择的抄送人数组
@property (nonatomic, strong) NSMutableArray *selectedBCCContacts;//选择的密送人数组
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) NSArray *contacts;
@end
