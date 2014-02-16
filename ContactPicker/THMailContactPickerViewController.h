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

@interface THMailContactPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, THMailContactPickerDelegate>

@property (nonatomic, strong) THMailContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@end
