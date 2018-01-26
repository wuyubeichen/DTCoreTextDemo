//
//  ZSDTCoreTextCell.m
//  ZSTest
//
//  Created by Bjmsp on 2018/1/25.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import "ZSDTCoreTextCell.h"

@implementation ZSDTCoreTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHTMLString:(NSString *)html{
    [super setHTMLString:html];
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    CGRect frame = CGRectMake(0, 50, self.attributedTextContextView.bounds.size.width, self.attributedTextContextView.bounds.size.height);
//    self.attributedTextContextView.frame = frame;
}

@end
