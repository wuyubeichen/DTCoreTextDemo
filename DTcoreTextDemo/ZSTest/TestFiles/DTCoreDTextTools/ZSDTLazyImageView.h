//
//  ZSDTLazyImageView.h
//  ZSTest
//
//  Created by Bjmsp on 2018/1/25.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>

@interface ZSDTLazyImageView : DTLazyImageView

@property(nonatomic,weak)  DTAttributedTextContentView *textContentView;

@end
