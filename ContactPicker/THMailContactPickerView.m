//
//  THMailContactPickerView.m
//  ContactPicker
//
//  Created by xtturing on 14-2-15.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//

#import "THMailContactPickerView.h"

#define kViewPadding 5 // the amount of padding on top and bottom of the view
#define kHorizontalPadding 2 // the amount of padding to the left and right of each contact bubble
#define kVerticalPadding 4 // amount of padding above and below each contact bubble
#define kTextViewMinWidth 130
#define kTitlePadding 8 //titleLable与左边的空隙

@interface THMailContactPickerView (){
    BOOL _shouldSelectTextView;
}

@property (nonatomic, strong) UIView *tokenView;
@property (nonatomic, strong) NSMutableDictionary *contacts;
@property (nonatomic, strong) NSMutableArray *contactKeys; // an ordered set of the keys placed in the contacts dictionary
@property (nonatomic, strong) UILabel *titleLabel;//输入框的标题
@property (nonatomic, strong) UIButton *addButton;//添加按钮
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) THBubbleColor *bubbleColor;
@property (nonatomic, strong) THBubbleColor *bubbleSelectedColor;

@end

@implementation THMailContactPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadView];
    }
    return self;
}

- (void)loadView{
    self.viewPadding = kViewPadding;
    
    self.contacts = [NSMutableDictionary dictionary];
    self.contactKeys = [NSMutableArray array];
    
    // Create a contact bubble to determine the height of a line
    THMailContactBubble *contactBubble = [[THMailContactBubble alloc] initWithName:@"Sample"];
    self.lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
    
    self.tokenView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.tokenView];
    
    // Create TextView
    // It would make more sense to use a UITextField (because it doesnt wrap text), however, there is no easy way to detect the "delete" key press using a UITextField when there is no string in the field
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.font = contactBubble.label.font;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.contentInset = UIEdgeInsetsMake(-4,-2, 0, 0);
    self.textView.scrollEnabled = NO;
    self.textView.scrollsToTop = NO;
    self.textView.clipsToBounds = NO;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Add shadow to bottom border
    self.backgroundColor = [UIColor whiteColor];
    CALayer *layer = [self layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Add titleLabel
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.numberOfLines=0;
    self.titleLabel.font = contactBubble.label.font;
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.tokenView addSubview:self.titleLabel];
    
    //add button
    self.addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addButton.frame=CGRectMake(self.frame.size.width-24,kVerticalPadding + self.viewPadding, 20,20);
    [self.addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    self.addButton.hidden=YES;
    [self addSubview:self.addButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

#pragma mark -
#pragma mark Override Methods

- (void)layoutView {
    CGRect frameOfLastBubble = CGRectNull;
    int lineCount = 0;
    
    // Loop through selectedContacts and position/add them to the view
    for (id contactKey in self.contactKeys){
        THMailContactBubble *contactBubble = (THMailContactBubble *)[self.contacts objectForKey:contactKey];
        CGRect bubbleFrame = contactBubble.frame;
        
        if (CGRectIsNull(frameOfLastBubble)){ // first line
            bubbleFrame.origin.x = kHorizontalPadding+self.titleLabel.frame.size.width+kTitlePadding+24;//需要加上标题的宽度
            bubbleFrame.origin.y = kVerticalPadding + self.viewPadding;
        } else {
            // Check if contact bubble will fit on the current line
            CGFloat width = bubbleFrame.size.width + 2 * kHorizontalPadding;
            if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - width >= 0){ // add to the same line
                // Place contact bubble just after last bubble on the same line
                bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding * 2;
                bubbleFrame.origin.y = frameOfLastBubble.origin.y;
            } else { // No space on line, jump to next line
                lineCount++;
                bubbleFrame.origin.x = kHorizontalPadding;
                bubbleFrame.origin.y = (lineCount * self.lineHeight) + kVerticalPadding + 	self.viewPadding;
            }
        }
        frameOfLastBubble = bubbleFrame;
        contactBubble.frame = bubbleFrame;
        // Add contact bubble if it hasn't been added
        if (contactBubble.superview == nil){
            [self.tokenView addSubview:contactBubble];
        }
    }
    
    // Now add a textView after the comment bubbles
    CGFloat minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;//去掉添加按钮的宽度
    CGRect textViewFrame = CGRectMake(0, 0, self.textView.frame.size.width, self.lineHeight/* - 2 * kVerticalPadding*/);
    // Check if we can add the text field on the same line as the last contact bubble
    if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
        textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x;
    } else { // place text view on the next line
        lineCount++;
        
        textViewFrame.origin.x = kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding;
        
        if (self.contacts.count == 0){
            lineCount = 0;
            textViewFrame.origin.x = kHorizontalPadding+self.titleLabel.frame.size.width+kTitlePadding;//需要加上标题的宽度
        }
    }
    textViewFrame.origin.y = lineCount * self.lineHeight + kVerticalPadding + self.viewPadding;
    self.textView.frame = textViewFrame;
    
    // Add text view if it hasn't been added
    if (self.textView.superview == nil){
        [self.tokenView addSubview:self.textView];
    }
    
    // Hide the text view if we are limiting number of selected contacts to 1 and a contact has already been added
    if (self.limitToOne && self.contacts.count >= 1){
        self.textView.hidden = YES;
        lineCount = 0;
    }
    
    // Adjust scroll view content size
    CGRect frame = self.bounds;
//    CGFloat maxFrameHeight = 2 * self.lineHeight + 2 * self.viewPadding; // limit frame to two lines of content
    CGFloat newHeight = (lineCount + 1) * self.lineHeight + 2 * self.viewPadding;
    self.tokenView.frame=CGRectMake(self.tokenView.frame.origin.x, self.tokenView.frame.origin.y, self.tokenView.frame.size.width,newHeight);
    // Adjust frame of view if necessary
//    newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
    if (self.frame.size.height != newHeight){
        // Adjust self height
        CGRect selfFrame = self.frame;
        selfFrame.size.height = newHeight;
        self.frame = selfFrame;
        
        // Adjust scroll view height
        frame.size.height = newHeight;
        self.tokenView.frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(mailContactPickerDidResize:)]){
            [self.delegate mailContactPickerDidResize:self];
        }
    }
}

#pragma mark - Public functions

- (void)disableDropShadow {
    CALayer *layer = [self layer];
    [layer setShadowRadius:0];
    [layer setShadowOpacity:0];
}

- (void)disableAddButton {
    if(!self.addButton.hidden){
        self.addButton.hidden=YES;
    }
}
- (void)setFont:(UIFont *)font {
    _font = font;
    // Create a contact bubble to determine the height of a line
    THMailContactBubble *contactBubble = [[THMailContactBubble alloc] initWithName:@"Sample"];
    [contactBubble setFont:font];
    self.lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
    
    self.textView.font = font;
    [self.textView sizeToFit];
    
    self.titleLabel.font = font;
}

- (void)addContact:(id)contact withName:(NSString *)name {
    id contactKey = [NSValue valueWithNonretainedObject:contact];
    if ([self.contactKeys containsObject:contactKey]){
        NSLog(@"Cannot add the same object twice to ContactPickerView");
        return;
    }
    
    self.textView.text = @"";
    
    THMailContactBubble *contactBubble = [[THMailContactBubble alloc] initWithName:name color:self.bubbleColor selectedColor:self.bubbleSelectedColor];
    contactBubble.delegate = self;
    [self.contacts setObject:contactBubble forKey:contactKey];
    [self.contactKeys addObject:contactKey];
    
    // update layout
    [self layoutView];
    
    // scroll to bottom
    _shouldSelectTextView = YES;
    // after scroll animation [self selectTextView] will be called
    [self selectTextView];
}

- (void)selectTextView {
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (void)removeAllContacts
{
    for(id contact in [self.contacts allKeys]){
        THMailContactBubble *contactBubble = [self.contacts objectForKey:contact];
        [contactBubble removeFromSuperview];
    }
    [self.contacts removeAllObjects];
    [self.contactKeys removeAllObjects];
    
    // update layout
    [self layoutView];
    
    self.textView.hidden = NO;
    self.textView.text = @"";
    
}

- (void)removeContact:(id)contact {
    id contactKey = [NSValue valueWithNonretainedObject:contact];
    // Remove contactBubble from view
    THMailContactBubble *contactBubble = [self.contacts objectForKey:contactKey];
    [contactBubble removeFromSuperview];
    
    // Remove contact from memory
    [self.contacts removeObjectForKey:contactKey];
    [self.contactKeys removeObject:contactKey];
    
    // update layout
    [self layoutView];
    
    [self.textView becomeFirstResponder];
    self.textView.hidden = NO;
    self.textView.text = @"";
}

- (void)setTitleString:(NSString *)titleString {
    self.titleLabel.text =[NSString stringWithFormat:@"%@:",titleString];
    //titleLabel自适应标题的宽度
    CGSize size = CGSizeMake(300,self.lineHeight);
    CGSize labelsize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    self.titleLabel.frame = CGRectMake(kTitlePadding,kVerticalPadding + self.viewPadding, labelsize.width, labelsize.height);
    [self layoutView];
}

- (void)resignKeyboard {
    [self.textView resignFirstResponder];
    
}

- (void)setViewPadding:(CGFloat)viewPadding {
    _viewPadding = viewPadding;
    
    [self layoutView];
}



#pragma mark - Private functions

- (void)setBubbleColor:(THBubbleColor *)color selectedColor:(THBubbleColor *)selectedColor {
    self.bubbleColor = color;
    self.bubbleSelectedColor = selectedColor;
    
    for (id contactKey in self.contactKeys){
        THMailContactBubble *contactBubble = (THMailContactBubble *)[self.contacts objectForKey:contactKey];
        
        contactBubble.color = color;
        contactBubble.selectedColor = selectedColor;
        
        // thid stuff reloads bubble
        if (contactBubble.isSelected){
            [contactBubble select];
        } else {
            [contactBubble unSelect];
        }
    }
}


- (void)removeContactBubble:(THMailContactBubble *)contactBubble {
    id contact = [self contactForContactBubble:contactBubble];
    if (contact == nil){
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(mailContactPickerDidRemoveContact:)]){
        [self.delegate mailContactPickerDidRemoveContact:[contact nonretainedObjectValue]];
    }
    
    [self removeContactByKey:contact];
}

- (void)removeContactByKey:(id)contactKey {
    // Remove contactBubble from view
    THMailContactBubble *contactBubble = [self.contacts objectForKey:contactKey];
    [contactBubble removeFromSuperview];
    
    // Remove contact from memory
    [self.contacts removeObjectForKey:contactKey];
    [self.contactKeys removeObject:contactKey];
    
    // update layout
    [self layoutView];
    
    [self.textView becomeFirstResponder];
    self.textView.hidden = NO;
    self.textView.text = @"";
}

- (id)contactForContactBubble:(THMailContactBubble *)contactBubble {
    NSArray *keys = [self.contacts allKeys];
    
    for (id contact in keys){
        if ([[self.contacts objectForKey:contact] isEqual:contactBubble]){
            return contact;
        }
    }
    return nil;
}

- (void) addContact:(id)sender{
    if([self.delegate respondsToSelector:@selector(mailContactPickerShouldAddContact)]){
        [self.delegate mailContactPickerShouldAddContact];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if(self.addButton.hidden){
        if([self.delegate respondsToSelector:@selector(mailContactPickerWillAddContact:)]){
            [self.delegate mailContactPickerWillAddContact:self.contactType];
        }
        self.addButton.hidden=NO;
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    self.textView.hidden = NO;
    
    if ( [text isEqualToString:@"\n"] ) { // Return key was pressed
        return NO;
    }
    
    // Capture "delete" key press when cell is empty
    if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
        // If no contacts are selected, select the last contact
        self.selectedContactBubble = [self.contacts objectForKey:[self.contactKeys lastObject]];
        [self.selectedContactBubble select];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
    textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height- ( textView.contentOffset.y + textView.bounds.size.height- textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
    // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
    // Scroll caret to visible area
    CGPoint offset = textView.contentOffset;
    offset.y += overflow + 7; // leave 7 pixels margin
    // Cannot animate with setContentOffset:animated: or caret will not appear
    [UIView animateWithDuration:.2 animations:^{
           [textView setContentOffset:offset];
        }];
    }
    if ([self.delegate respondsToSelector:@selector(mailContactPickerTextViewDidChange:)]){
        [self.delegate mailContactPickerTextViewDidChange:textView.text];
    }
    
}

#pragma mark - THMailContactBubbleDelegate Functions

- (void)mailContactBubbleWasSelected:(THMailContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        [self.selectedContactBubble unSelect];
    }
    self.selectedContactBubble = contactBubble;
    
    [self.textView resignFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = YES;
    if([self.delegate respondsToSelector:@selector(mailContactBubbleDoSelect:)]){
        [self.delegate mailContactBubbleDoSelect:_contactType];
    }
}

- (void)mailContactBubbleWasUnSelected:(THMailContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        
    }
    [self.textView becomeFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = NO;
}

- (void)mailContactBubbleShouldBeRemoved:(THMailContactBubble *)contactBubble {
    [self removeContactBubble:contactBubble];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.contactKeys.count == 1){
        return;
    }
    
    // Show textField
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
    
    // Unselect contact bubble
    [self.selectedContactBubble unSelect];
    self.selectedContactBubble = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_shouldSelectTextView){
        _shouldSelectTextView = NO;
        [self selectTextView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
