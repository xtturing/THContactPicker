//
//  THMailContactPickerViewController.m
//  ContactPicker
//
//  Created by xutao on 14-2-16.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//

#import "THMailContactPickerViewController.h"
#import "THMailContactViewController.h"

#define kKeyboardHeight 216.0

@interface THMailContactPickerViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) THMailContactPickerView *recipientPickerView;
@property (nonatomic, strong) THMailContactPickerView *CCPickerView;
@property (nonatomic, strong) THMailContactPickerView *BCCPickerView;
@property (nonatomic, strong) THMailContactViewController *contactViewController;
@property (nonatomic, assign) MailContactType currentContactType;

@end

@implementation THMailContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"新邮件";
        self.selectedContacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(removeAllContacts:)];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMail:)];
    sendButton.enabled=NO;
    self.navigationItem.rightBarButtonItem = sendButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelMail:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
    // Fill the rest of the view with the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    CGFloat topOffset = 0;
//    if ([self respondsToSelector:@selector(topLayoutGuide)]){
//        topOffset = self.topLayoutGuide.length;
//    }
//    CGRect frame = self.tableView.frame;
//    frame.origin.y = topOffset;
//    self.tableView.frame = frame;
//    [self adjustTableViewFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame {
//    CGRect frame = self.tableView.frame;
//    frame.origin.y = self.contactPickerView.frame.size.height;
//    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight;
//    self.tableView.frame = frame;
}


#pragma mark - private

- (void)sendMail:(id)sender{
    
}

- (void)cancelMail:(id)sender{
    
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==3){
        return 200;
    }else{
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row==3) {
        cell.accessoryView=nil;
        cell.textLabel.text=@"发自我的iPhone";
        cell.textLabel.font=[UIFont systemFontOfSize:24];
    }else{
        if (indexPath.row==0){
            self.recipientPickerView = [[THMailContactPickerView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, 44)];
            self.recipientPickerView.delegate = self;
            self.recipientPickerView.font=[UIFont systemFontOfSize:14];
            [self.recipientPickerView setTitleString:@"发件人"];
            [self.recipientPickerView selectTextView];
            cell.accessoryView=self.recipientPickerView;
        }else if(indexPath.row==1){
            self.CCPickerView = [[THMailContactPickerView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, 44)];
            self.CCPickerView.delegate = self;
            self.CCPickerView.font=[UIFont systemFontOfSize:14];
            [self.CCPickerView setTitleString:@"抄送/密送"];
            cell.accessoryView=self.CCPickerView;
        }else if(indexPath.row==2){
            self.BCCPickerView = [[THMailContactPickerView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, 44)];
            self.BCCPickerView.delegate = self;
            self.BCCPickerView.font=[UIFont systemFontOfSize:14];
            [self.BCCPickerView setTitleString:@"主题"];
            cell.accessoryView=self.BCCPickerView;
        }
        
    }
    cell.userInteractionEnabled=YES;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryCheckmark;
    
    [self.tableView reloadData];
}

#pragma mark - THMailContactPickerDelegate

- (void)mailContactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)mailContactPickerDidResize:(THContactPickerView *)contactPickerView {
    
}

- (void)mailContactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    int index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)mailContactPickerWillAddContact{
    //下一个contactpicker启动前要其他关闭其他的添加按钮
    [self.recipientPickerView disableAddButton];
    [self.CCPickerView disableAddButton];
    [self.BCCPickerView disableAddButton];
}

- (void)mailContactPickerShouldAddContact{
    _contactViewController=[[THMailContactViewController alloc] init];
    _contactViewController.selectedContacts=self.selectedContacts;
    [self.navigationController pushViewController:_contactViewController animated:YES];
}

@end
