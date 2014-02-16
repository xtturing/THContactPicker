//
//  THMailContactViewController.h
//  ContactPicker
//
//  Created by xutao on 14-2-16.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//
/*
 选择联系人页
 */
#import <UIKit/UIKit.h>

@protocol THMailContactDelegate <NSObject>

- (void) FinishSelectedOneContactInTableView:(id)contact;
- (void) FinishRemovedOneContactInTableView:(id)contact;

@end

@interface THMailContactViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) id <THMailContactDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;

@end
