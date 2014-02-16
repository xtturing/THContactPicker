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

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *contacts;
@property (nonatomic, strong) NSMutableArray *contactKeys; // an ordered set of the keys placed in the contacts dictionary
@property (nonatomic, strong) UILabel *titleLabel;//输入框的标题
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
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@"Sample"];
    self.lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
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
    [self.textView becomeFirstResponder];
    
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
    [self.scrollView addSubview:self.titleLabel];
    
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
            bubbleFrame.origin.x = kHorizontalPadding+self.titleLabel.frame.size.width+kTitlePadding;//需要加上标题的宽度
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
            [self.scrollView addSubview:contactBubble];
        }
    }
    
    // Now add a textView after the comment bubbles
    CGFloat minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;
    CGRect textViewFrame = CGRectMake(0, 0, self.textView.frame.size.width, self.lineHeight/* - 2 * kVerticalPadding*/);
    // Check if we can add the text field on the same line as the last contact bubble
    if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
        if(lineCount==0){//如果是第一行，需要加上标题的宽度
           textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding+self.titleLabel.frame.size.width+kTitlePadding;//需要加上标题的宽度
        }else{
           textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        }
        
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
        [self.scrollView addSubview:self.textView];
    }
    
    // Hide the text view if we are limiting number of selected contacts to 1 and a contact has already been added
    if (self.limitToOne && self.contacts.count >= 1){
        self.textView.hidden = YES;
        lineCount = 0;
    }
    
    // Adjust scroll view content size
    CGRect frame = self.bounds;
    CGFloat maxFrameHeight = 2 * self.lineHeight + 2 * self.viewPadding; // limit frame to two lines of content
    CGFloat newHeight = (lineCount + 1) * self.lineHeight + 2 * self.viewPadding;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, newHeight);
    
    // Adjust frame of view if necessary
    newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
    if (self.frame.size.height != newHeight){
        // Adjust self height
        CGRect selfFrame = self.frame;
        selfFrame.size.height = newHeight;
        self.frame = selfFrame;
        
        // Adjust scroll view height
        frame.size.height = newHeight;
        self.scrollView.frame = frame;
        
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
    [self scrollToBottomWithAnimation:YES];
    // after scroll animation [self selectTextView] will be called
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
    
    [self scrollToBottomWithAnimation:NO];
}

- (void)setTitleString:(NSString *)titleString {
    self.titleLabel.text =[NSString stringWithFormat:@"%@:",titleString];
    //titleLabel自适应标题的宽度
    CGSize size = CGSizeMake(320,self.lineHeight);
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

#pragma mark - Private functions

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    if (animated){
        CGSize size = self.scrollView.contentSize;
        CGRect frame = CGRectMake(0, size.height - self.scrollView.frame.size.height, size.width, self.scrollView.frame.size.height);
        
        [self.scrollView scrollRectToVisible:frame animated:animated];
    } else {
        // this block is here because scrollRectToVisible with animated NO causes crashes on iOS 5 when the user tries to delete many contacts really quickly
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
        self.scrollView.contentOffset = offset;
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
    
    [self scrollToBottomWithAnimation:NO];
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


#pragma mark - UITextViewDelegate

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
    if ([self.delegate respondsToSelector:@selector(mailContactPickerTextViewDidChange:)]){
        [self.delegate mailContactPickerTextViewDidChange:textView.text];
    }
    
}

#pragma mark - THMailContactBubbleDelegate Functions

- (void)contactBubbleWasSelected:(THMailContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        [self.selectedContactBubble unSelect];
    }
    self.selectedContactBubble = contactBubble;
    
    [self.textView resignFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = YES;
}

- (void)contactBubbleWasUnSelected:(THMailContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        
    }
    [self.textView becomeFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = NO;
}

- (void)contactBubbleShouldBeRemoved:(THMailContactBubble *)contactBubble {
    [self removeContactBubble:contactBubble];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.contactKeys.count == 1){
        return;
    }
    [self scrollToBottomWithAnimation:YES];
    
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
