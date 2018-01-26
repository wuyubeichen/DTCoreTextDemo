//
//  DTCoreTextHandlerButton.h
//  MyCoreTextDemo
//
//  Created by Bjmsp on 2018/1/24.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DTButtonUrlType){
    DTCoreTextUrlType_unKnown,
    DTCoreTextUrlType_Http,
    DTCoreTextUrlType_Tel,
    DTCoreTextUrlType_Mail,
};


//自定义的Button，用于处理富文本中的a标签处理
@interface ZSDTCoreTextButton : UIButton

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) DTButtonUrlType urlType;
/**
 类方法创建Button

 @param url a标签链接
 @param identifier a标签的ID标识，唯一
 @param frame a标签所在位置
 @return 返回一个用于响应的Button
 */
+ (ZSDTCoreTextButton *)getButtonWithURL:(NSString *)url
                               withIdentifier:(NSString *)identifier
                                        frame:(CGRect)frame;


//打开链接
+ (void)openWebPage:(NSString *)url;

//拨打电话
+ (void)dailPhoneNum:(NSString *)phoneNum;



@end
