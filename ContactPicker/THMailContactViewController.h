//
//  THMailContactViewController.h
//  ContactPicker
//
//  Created by xutao on 14-2-16.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol THMailContactDelegate <NSObject>



@end

@interface THMailContactViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

@end
