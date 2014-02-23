//
//  THMailContactPickerViewController.m
//  ContactPicker
//
//  Created by xutao on 14-2-16.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//

#import "THMailContactPickerViewController.h"
#import "mailContactCell.h"

#define kKeyboardHeight          216.0
#define kTableCellheight         54
#define kTableCellDetailHeight   400
#define KContactViewHeight       50

@interface THMailContactPickerViewController (){
    BOOL _shouldShowThumbCell;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) THMailContactPickerView *recipientPickerView;
@property (nonatomic, strong) THMailContactPickerView *CCPickerView;
@property (nonatomic, strong) THMailContactPickerView *BCCPickerView;
@property (nonatomic, strong) THMailContactViewController *contactViewController;
@property (nonatomic, strong) THMailContactViewController *filterContactViewController;
@property (nonatomic, assign) MailContactType currentContactType;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation THMailContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"新邮件";
        self.contacts=[NSArray arrayWithObjects:@"Tristan Himmelman", @"John Himmelman", @"Nicole Robertson", @"Nicholas Barss", @"Andrew Sarasin", @"Mike Slon", @"Eric Salpeter", nil];
        
        self.selectedRecipientContacts = [NSMutableArray array];
        self.selectedCCContacts = [NSMutableArray array];
        self.selectedBCCContacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _shouldShowThumbCell=NO;
    // Do any additional setup after loading the view from its nib.
    //    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(removeAllContacts:)];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMail:)];
    sendButton.enabled=NO;
    self.navigationItem.rightBarButtonItem = sendButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelMail:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    _recipientPickerView = [[THMailContactPickerView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, KContactViewHeight)];
    NSLog(@"%f",_recipientPickerView.frame.size.height);
    _recipientPickerView.delegate = self;
    _recipientPickerView.font=[UIFont systemFontOfSize:14];
    [_recipientPickerView setTitleString:@"发件人"];
    [_recipientPickerView disableDropShadow];
    _recipientPickerView.contactType=MailRecipient;
    
    
    _CCPickerView = [[THMailContactPickerView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, KContactViewHeight)];
    _CCPickerView.delegate = self;
    _CCPickerView.font=[UIFont systemFontOfSize:14];
    [_CCPickerView setTitleString:@"抄送"];
    [_CCPickerView disableDropShadow];
    _CCPickerView.contactType=MailCC;
    
    _BCCPickerView = [[THMailContactPickerView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20, KContactViewHeight)];
    _BCCPickerView.delegate = self;
    _BCCPickerView.font=[UIFont systemFontOfSize:14];
    [_BCCPickerView setTitleString:@"密送"];
    [_BCCPickerView disableDropShadow];
    _BCCPickerView.contactType=MailBCC;
    
    _currentContactType=MailRecipient;//当前光标在收件人
    
    
    // Fill the rest of the view with the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    //过滤的table
    _filterContactViewController=[[THMailContactViewController alloc] init];
    _filterContactViewController.delegate=self;
    _filterContactViewController.view.frame=CGRectZero;
    _filterContactViewController.view.hidden=YES;
    [self.view addSubview:_filterContactViewController.view];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self ShouldSelectTextView];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame {
     CGRect frame = self.tableView.frame;
    if(_currentContactType==MailRecipient){
        frame.origin.y = 0;
    }else if(_currentContactType==MailCC){
        frame.origin.y = -(self.recipientPickerView.frame.size.height+4);
    }else if(_currentContactType==MailBCC){
        frame.origin.y = -(self.recipientPickerView.frame.size.height+4+self.CCPickerView.frame.size.height+4);
    }else{
        frame.origin.y = 0;
    }
    self.tableView.frame=frame;
    
    if(!_filterContactViewController.view.hidden){
        frame.origin.x=0;
        NSLog(@"%f---%f",self.view.frame.size.height,self.recipientPickerView.frame.size.height);
        CGFloat cellHeight=kTableCellheight;
        if(_currentContactType==MailRecipient){
            if(_recipientPickerView.frame.size.height+4>kTableCellheight){
               cellHeight=_recipientPickerView.frame.size.height+4;
            }
        }else if(_currentContactType==MailCC){
            if(_CCPickerView.frame.size.height+4>kTableCellheight){
                cellHeight= _CCPickerView.frame.size.height+4;
            }
        }else if(_currentContactType==MailBCC){
            if(_BCCPickerView.frame.size.height+4>kTableCellheight){
                cellHeight= _BCCPickerView.frame.size.height+4;
            }
            
        }
        frame.origin.y = cellHeight+64;
        frame.size.height = self.view.frame.size.height - cellHeight - kKeyboardHeight-64;
        frame.size.width=self.view.frame.size.width;
        _filterContactViewController.view.frame = frame;
        _filterContactViewController.tableView.frame = CGRectMake(0, 0, _filterContactViewController.view.frame.size.width, _filterContactViewController.view.frame.size.height);
        [_filterContactViewController.tableView reloadData];
    }
    
}

- (void)updateTableViewFrame{
    CGRect frame = self.tableView.frame;
    frame.origin.y = 0;
    self.tableView.frame=frame;
}

- (void)ShouldSelectTextView{
    if(!_shouldShowThumbCell){
        if(_currentContactType==MailRecipient){
            [self.recipientPickerView selectTextView];
        }else if(_currentContactType==MailCC){
            [self.CCPickerView selectTextView];
        }else if(_currentContactType==MailBCC){
            [self.BCCPickerView selectTextView];
        }else{
            [_textField becomeFirstResponder];
        }
    }
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        NSLog(@"%f",_recipientPickerView.frame.size.height);
        if(_shouldShowThumbCell){
            return kTableCellheight;
        }else{
            if(_recipientPickerView.frame.size.height+4<kTableCellheight){
                return kTableCellheight;
            }
            return _recipientPickerView.frame.size.height+4;
        }
        
    }else if(indexPath.row==1){
        if(_shouldShowThumbCell){
            return kTableCellheight;
        }else{
            if(_CCPickerView.frame.size.height+4<kTableCellheight){
                return kTableCellheight;
            }
            return _CCPickerView.frame.size.height+4;
        }
    }else if (indexPath.row==2){
        if(_shouldShowThumbCell){
            return kTableCellheight;
        }else{
            if(_BCCPickerView.frame.size.height+4<kTableCellheight){
                return  kTableCellheight;
            }
            return _BCCPickerView.frame.size.height+4;
        }        
    }else if (indexPath.row==3){
        return kTableCellheight;
    }else{
        return kTableCellDetailHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactCell";
    
    mailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[mailContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row==4) {
        UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(0, 2, 300, kTableCellDetailHeight)];
        textView.text=@"发自我的iPhone";
        textView.contentInset = UIEdgeInsetsMake(100.0,000.0,0,0.0);
        textView.font=[UIFont systemFontOfSize:16];
        cell.textLabel.text=@"";
        cell.detailTextLabel.text=@"";
        cell.accessoryView=textView;
    }else if(indexPath.row==3){
        _textField=[[UITextField alloc] initWithFrame:CGRectMake(0, 2, 252, KContactViewHeight)];
        _textField.delegate=self;
        cell.textLabel.text=@"主题:";
        cell.detailTextLabel.text=@"";
        cell.textLabel.textColor=[UIColor grayColor];
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.accessoryView=_textField;
        
    }else{
        if(_shouldShowThumbCell){
            if (indexPath.row==0){
                if(self.selectedRecipientContacts.count>0){
                    cell.textLabel.text=@"发件人:";
                    cell.textLabel.textColor=[UIColor grayColor];
                    cell.textLabel.font=[UIFont systemFontOfSize:14];
                    if (self.selectedRecipientContacts.count==1) {
                       cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[self.selectedRecipientContacts objectAtIndex:0]];
                        cell.detailTextLabel.textAlignment=UITextAlignmentLeft;
                    }else{
                       cell.detailTextLabel.text=[NSString stringWithFormat:@"%@，及其他%d位...",[self.selectedRecipientContacts objectAtIndex:0],([self.selectedRecipientContacts count]-1)];
                    }
                    cell.detailTextLabel.textColor=[UIColor colorWithRed:24.0/255.0 green:134.0/255.0 blue:242.0/255.0 alpha:1.0];
                    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
                    cell.accessoryView=nil;
                }
            }else if(indexPath.row==1){
                if(self.selectedCCContacts.count>0){
                    cell.textLabel.text=@"抄送:";
                    cell.textLabel.textColor=[UIColor grayColor];
                    cell.textLabel.font=[UIFont systemFontOfSize:14];
                    if (self.selectedCCContacts.count==1) {
                        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[self.selectedCCContacts objectAtIndex:0]];
                    }else{
                        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@，及其他%d位...",[self.selectedCCContacts objectAtIndex:0],([self.selectedCCContacts count]-1)];
                    }
                    cell.detailTextLabel.textColor=[UIColor colorWithRed:24.0/255.0 green:134.0/255.0 blue:242.0/255.0 alpha:1.0];
                    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
                    cell.accessoryView=nil;
                }
                
            }else if(indexPath.row==2){
                if(self.selectedBCCContacts.count>0){
                    cell.textLabel.text=@"密送:";
                    cell.textLabel.textColor=[UIColor grayColor];
                    cell.textLabel.font=[UIFont systemFontOfSize:14];
                    if (self.selectedBCCContacts.count==1) {
                        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[self.selectedBCCContacts objectAtIndex:0]];
                    }else{
                        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@，及其他%d位...",[self.selectedBCCContacts objectAtIndex:0],([self.selectedBCCContacts count]-1)];
                    }
                    cell.detailTextLabel.textColor=[UIColor colorWithRed:24.0/255.0 green:134.0/255.0 blue:242.0/255.0 alpha:1.0];
                    cell.detailTextLabel.font=[UIFont systemFontOfSize:14];
                    cell.accessoryView=nil;
                }
                
            }
        }else{
            if (indexPath.row==0){
                cell.accessoryView=self.recipientPickerView;
                
            }else if(indexPath.row==1){
                cell.accessoryView=self.CCPickerView;
                
            }else if(indexPath.row==2){
                cell.accessoryView=self.BCCPickerView;
                
            }
        }
        
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==3){
         _shouldShowThumbCell=YES;
    }else{
        if(_shouldShowThumbCell){
            _shouldShowThumbCell=NO;
            
        }
    }
    [self.tableView reloadData];
    [self performSelector:@selector(ShouldSelectTextView) withObject:nil afterDelay:0.44];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     _filterContactViewController.view.hidden=YES;
}
#pragma mark - THMailContactPickerDelegate

- (void)mailContactPickerTextViewDidChange:(NSString *)textViewText {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", textViewText];
    self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    if(self.filteredContacts.count>0){
        _filterContactViewController.view.hidden=NO;
        _filterContactViewController.contacts=self.filteredContacts;
        if(_currentContactType==MailRecipient){
            _filterContactViewController.selectedContacts=self.selectedRecipientContacts;
        }else if(_currentContactType==MailCC){
            _filterContactViewController.selectedContacts=self.selectedCCContacts;
        }else if(_currentContactType==MailBCC){
            _filterContactViewController.selectedContacts=self.selectedBCCContacts;
        }

        [self adjustTableViewFrame];
    }
    
}

- (void)mailContactPickerDidResize:(THContactPickerView *)contactPickerView {
    NSIndexPath *indexPath=nil;
    if(_currentContactType==MailRecipient){
        indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width, self.recipientPickerView.frame.size.height);
        
    }else if(_currentContactType==MailCC){
        indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width, self.CCPickerView.frame.size.height);
    }else if(_currentContactType==MailBCC){
        indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width, self.BCCPickerView.frame.size.height);
    }
    [self.tableView reloadData];
    [self performSelector:@selector(ShouldSelectTextView) withObject:nil afterDelay:0.44];
}

- (void)mailContactPickerDidRemoveContact:(id)contact {
    if(_currentContactType==MailRecipient){
        [self.selectedRecipientContacts removeObject:contact];
    }else if(_currentContactType==MailCC){
        [self.selectedCCContacts removeObject:contact];
    }else if(_currentContactType==MailBCC){
        [self.selectedBCCContacts removeObject:contact];
    }
    
}

- (void)mailContactPickerWillAddContact:(MailContactType )currentType{
    //下一个contactpicker启动前要其他关闭其他的添加按钮
    [self.recipientPickerView disableAddButton];
    [self.CCPickerView disableAddButton];
    [self.BCCPickerView disableAddButton];
    //取消所有token状态
    if(self.recipientPickerView.selectedContactBubble!=nil){
        [self.recipientPickerView.selectedContactBubble unSelect];
    }
    if(self.CCPickerView.selectedContactBubble!=nil){
        [self.CCPickerView.selectedContactBubble unSelect];
    }
    if(self.BCCPickerView.selectedContactBubble!=nil){
        [self.BCCPickerView.selectedContactBubble unSelect];
    }
    _currentContactType=currentType;
    
     _shouldShowThumbCell=NO;
}

- (void)mailContactPickerShouldAddContact{
    _contactViewController=[[THMailContactViewController alloc] init];
    if(_currentContactType==MailRecipient){
        _contactViewController.selectedContacts=self.selectedRecipientContacts;
    }else if(_currentContactType==MailCC){
        _contactViewController.selectedContacts=self.selectedCCContacts;
    }else if(_currentContactType==MailBCC){
        _contactViewController.selectedContacts=self.selectedBCCContacts;
    }
    _contactViewController.contacts=self.contacts;
    _contactViewController.delegate=self;
    [self.navigationController pushViewController:_contactViewController animated:YES];
}
//当前做了token选择那么就要关闭其他的token选择
- (void)mailContactBubbleDoSelect:(MailContactType )currentType{
    if(currentType==MailRecipient){
        if(self.CCPickerView.selectedContactBubble!=nil){
            [self.CCPickerView.selectedContactBubble unSelect];
        }
        if(self.BCCPickerView.selectedContactBubble!=nil){
            [self.BCCPickerView.selectedContactBubble unSelect];
        }
    }else if(currentType==MailCC){
        if(self.recipientPickerView.selectedContactBubble!=nil){
            [self.recipientPickerView.selectedContactBubble unSelect];
        }
        
        if(self.BCCPickerView.selectedContactBubble!=nil){
            [self.BCCPickerView.selectedContactBubble unSelect];
        }
        
    }else if(currentType==MailBCC){
        if(self.recipientPickerView.selectedContactBubble!=nil){
             [self.recipientPickerView.selectedContactBubble unSelect];
        }
        if(self.CCPickerView.selectedContactBubble!=nil){
            [self.CCPickerView.selectedContactBubble unSelect];
        }
        
    }
}

#pragma mark - THMailContactDelegate

- (void) FinishSelectedOneContactInTableView:(id)contact{
    if(_currentContactType==MailRecipient){
        [self.selectedRecipientContacts addObject:contact];
        [self.recipientPickerView addContact:contact withName:(NSString *)contact];
    }else if(_currentContactType==MailCC){
        [self.selectedCCContacts addObject:contact];
        [self.CCPickerView addContact:contact withName:(NSString *)contact];
    }else if(_currentContactType==MailBCC){
        [self.selectedBCCContacts addObject:contact];
        [self.BCCPickerView addContact:contact withName:(NSString *)contact];
    }
    _filterContactViewController.view.hidden=YES;
    [self updateTableViewFrame];
    [self performSelector:@selector(ShouldSelectTextView) withObject:nil afterDelay:0.44];
    
}

- (void) FinishRemovedOneContactInTableView:(id)contact{
    if(_currentContactType==MailRecipient){
        [self.selectedRecipientContacts removeObject:contact];
        [self.recipientPickerView removeContact:contact];
    }else if(_currentContactType==MailCC){
        [self.selectedCCContacts removeObject:contact];
        [self.CCPickerView removeContact:contact];
    }else if(_currentContactType==MailBCC){
        [self.selectedBCCContacts removeObject:contact];
        [self.BCCPickerView removeContact:contact];
    }
    _filterContactViewController.view.hidden=YES;
    [self updateTableViewFrame];
    [self performSelector:@selector(ShouldSelectTextView) withObject:nil afterDelay:0.44];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self.recipientPickerView disableAddButton];
    [self.CCPickerView disableAddButton];
    [self.BCCPickerView disableAddButton];
    _shouldShowThumbCell=YES;
    [self.tableView reloadData];
    [self performSelector:@selector(ShouldSelectTextView) withObject:nil afterDelay:0.44];
    return YES;
}

@end
