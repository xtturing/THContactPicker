//
//  mailContactCell.m
//  ContactPicker
//
//  Created by xutao on 14-2-18.
//  Copyright (c) 2014年 Tristan Himmelman. All rights reserved.
//

#import "mailContactCell.h"
#define LEFTGAP     5


@implementation mailContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //NSLog(@"%@",self.textLabel.font);
    CGSize titleSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(MAXFLOAT, self.frame.size.height)];//获得主标题字数长度
    //NSLog(@"宽%f高%f",titleSize.width,titleSize.height);
    self.detailTextLabel.frame = CGRectMake(LEFTGAP*3+titleSize.width, 0, self.frame.size.width-titleSize.width-LEFTGAP*3, self.frame.size.height);
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
}
@end
