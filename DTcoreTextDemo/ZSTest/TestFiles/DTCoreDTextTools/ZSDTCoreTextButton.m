
//
//  DTCoreTextHandlerButton.m
//  MyCoreTextDemo
//
//  Created by Bjmsp on 2018/1/24.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import "ZSDTCoreTextButton.h"
@implementation ZSDTCoreTextButton

#pragma mark - Life Cycle
+ (ZSDTCoreTextButton *)getButtonWithURL:(NSString *)url
                               withIdentifier:(NSString *)identifier
                                        frame:(CGRect)frame{
    ZSDTCoreTextButton *button = [[ZSDTCoreTextButton alloc] initWithFrame:frame];
    button.url = url;
    button.identifier = identifier;
    [button addTarget:button action:@selector(onBtnClick:) forControlEvents:UIControlEventAllEvents];
    return button;
}

- (DTButtonUrlType)urlType{
    if ([_url hasPrefix:@"http"]) {
        return DTCoreTextUrlType_Http;
    }else if([_url hasPrefix:@"tel"]){
        return DTCoreTextUrlType_Tel;
    }else if([_url hasPrefix:@"mailto"]){
        return DTCoreTextUrlType_Mail;
    }
    return DTCoreTextUrlType_unKnown;
}


#pragma mark - private Methods
-(void)onBtnClick:(ZSDTCoreTextButton *)btn{
    switch (btn.urlType) {
        case DTCoreTextUrlType_Http:{
            [ZSDTCoreTextButton openWebPage:btn.url];
            break;
        }
        case DTCoreTextUrlType_Tel:{
            NSString *phoneNum = [[btn.url componentsSeparatedByString:@":"] lastObject];
            [ZSDTCoreTextButton dailPhoneNum:phoneNum];
             break;
             }
        case DTCoreTextUrlType_Mail:{
            break;
        }
        default:
            break;
    }
}


#pragma mark - Public Methods
//打开链接
+ (void)openWebPage:(NSString *)url{
    [[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url]];
}

//拨打电话
+ (void)dailPhoneNum:(NSString *)phoneNum{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}




@end
