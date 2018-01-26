//
//  TestNormalViewViewController.m
//  ZSTest
//
//  Created by Bjmsp on 2018/1/25.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import "TestCoreTextLabelController.h"
#import "ZSDTCoreTextTools.h"

@interface TestCoreTextLabelController()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate>
@property (strong, nonatomic)  DTAttributedLabel *attributedLabel;
@property (nonatomic,copy)NSString *html;
@property (nonatomic, assign) CGRect viewMaxRect;
@end

@implementation TestCoreTextLabelController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试DTAttributedLabel";
    _html = @"<span style=\"color:#333;font-size:15px;\"><strong>砍价师服务介绍</strong></span><br/><span align=\"right\" style=\"color:#333;font-size:15px;\">我们不是中介。</span><br/> <span style=\"color:#333;font-size:15px;\">我们是一群愿意站在买房人一边的，地产业内人士。</span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>砍不下来，不要钱！</strong></span><br/><span style=\"color:#333;font-size:15px;\">类似你请个律师，完全站在你的立场，帮你谈判。我们发心，用立场和专业，改变中国买房人的被动、挨宰局面！</span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>服务流程：</strong></span><br/><span style=\"color:#333;font-size:15px;\">1.砍前培训。砍价师教你和中介、业主交流，哪些话能说，哪些话不能说；</span><br/><span style=\"color:#333;font-size:15px;\">2.选砍价师。和砍价师约见，确认服务，并做各方信息梳理，确定谈判策略。</span><br/><span style=\"color:#333;font-size:15px;\">3.现场谈判。砍价师陪你去现场，协助把控谈判进程；在你砍不动时，再继续全力争取最好价格。</span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>收费标准：</strong></span><br/><span style=\"color:#333;font-size:15px;\">记住！砍价是由你自己先砍，砍不动时再由砍价师继续砍；由砍价师多砍下的部分，才按照下列标准收费：</span><br/><span style=\"color:#333;font-size:15px;\"><img src=\"http://cn-qinqimaifang-uat.oss-cn-hangzhou.aliyuncs.com/img/specialist/upload/spcetiicwlz1v_54e2e00fa8a6faf66168571654dbfee2.jpg\" _src=\"http://cn-qinqimaifang-uat.oss-cn-hangzhou.aliyuncs.com/img/specialist/upload/spcetiicwlz1v_54e2e00fa8a6faf66168571654dbfee2.jpg\"></span><span style=\"color:#333;font-size:15px;\"><strong>砍不下来，不收费！</strong></span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>举个例子：</strong></span><br/><span style=\"color:#333;font-size:15px;\">李先生看好一套房子，经过自己努力将价格砍到300万，砍价师在李先生的基础上将价格谈到270万，成功砍下30万，其中0~5万元阶梯价格部分为5万元，5~10万元阶梯价格部分为5万元，10万元以上阶梯价格部分为20万元，则</span><br/><span style=\"color:#333;font-size:15px;\"><strong>应收服务费：5x30％+5x40%+20x50%=13.5万</strong></span><br/><br/><span style=\"color:#333;font-size:15px;\">百度:<a href=\"http://www.w3school.com.cn\">my testlink</a></span><br/><br/><span style=\"color:#333;font-size:15px;\">电话：<a href=\"tel:4008001234\">my phoneNum</a></span><br/><br/><span style=\"color:#333;font-size:15px;\">我邮箱:<a href=\"mailto:dreamcoffeezs@163.com\">my mail</a></span>";
    
    _viewMaxRect =  CGRectMake(15, 15, ZSToolScreenWidth - 15*2, CGFLOAT_HEIGHT_UNKNOWN);
    //创建控件，显示富文本
    [self.view addSubview:self.attributedLabel];
    CGSize textSize = [self getAttributedTextHeightHtml:self.html with_viewMaxRect:_viewMaxRect];
    self.attributedLabel.frame = CGRectMake(_viewMaxRect.origin.x, _viewMaxRect.origin.y, _viewMaxRect.size.width, textSize.height);
    self.attributedLabel.attributedString = [self getAttributedStringWithHtml:self.html];
}


#pragma mark - Delegate：DTAttributedTextContentViewDelegate
//图片占位
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    
    if([attachment isKindOfClass:[DTImageTextAttachment class]]){
        NSString *imageURL = [NSString stringWithFormat:@"%@", attachment.contentURL];
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [(DTImageTextAttachment *)attachment image];
        imageView.url = attachment.contentURL;
        
        if ([imageURL containsString:@"gif"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *gifData = [NSData dataWithContentsOfURL:attachment.contentURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = DTAnimatedGIFFromData(gifData);
                });
            });
        }
        return imageView;
    }
    return nil;
}

//根据a标签，自定义响应按钮，处理点击事件
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame{
    ZSDTCoreTextButton *button = [ZSDTCoreTextButton getButtonWithURL:url.absoluteString withIdentifier:identifier frame:frame];
    button.backgroundColor = [UIColor purpleColor];
    button.alpha = 0.5;
    return button;
}



#pragma mark  Delegate：DTLazyImageViewDelegate
//懒加载获取图片大小
- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    BOOL didUpdate = NO;
    // update all attachments that match this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.attributedLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize];
            didUpdate = YES;
        }
    }
    
    //    if (didUpdate)
    //    {
    //        self.attributedLabel.attributedTextContentView.layouter = nil;
    //        [self.attributedLabel relayoutText];
    //    }
}


//字符串中一些图片没有宽高，懒加载图片之后，在此方法中得到图片宽高
//这个把宽高替换原来的html,然后重新设置富文本
- (void)configNoSizeImageView:(NSString *)url size:(CGSize)size
{
    CGFloat imgSizeScale = size.height/size.width;
    CGFloat widthPx = _viewMaxRect.size.width;
    CGFloat heightPx = widthPx * imgSizeScale;
    
    NSString *imageInfo = [NSString stringWithFormat:@"_src=\"%@\"",url];
    NSString *sizeString = [NSString stringWithFormat:@" style=\"width:%.fpx; height:%.fpx;\"",widthPx,heightPx];
    NSString *newImageInfo = [NSString stringWithFormat:@"_src=\"%@\"%@",url,sizeString];
    
    if ([self.html containsString:imageInfo]) {
        NSString *newHtml = [self.html stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
        // reload newHtml
        
        self.html = newHtml;
        CGSize textSize = [self getAttributedTextHeightHtml:self.html with_viewMaxRect:_viewMaxRect];
        self.attributedLabel.frame = CGRectMake(_viewMaxRect.origin.x, _viewMaxRect.origin.y, _viewMaxRect.size.width, textSize.height);
        self.attributedLabel.attributedString = [self getAttributedStringWithHtml:self.html];
        //self.attributedLabel.attributedString = [self getAttributedStringWithHtml:@"<span style=\"color:#333;font-size:15px;\"><strong>砍价师服务介绍</strong></span>"];
        [self.attributedLabel relayoutText];
    }
}

#pragma mark - private Methods
//使用HtmlString,和最大左右间距，计算视图的高度
- (CGSize)getAttributedTextHeightHtml:(NSString *)htmlString with_viewMaxRect:(CGRect)_viewMaxRect{
    //获取富文本
    NSAttributedString *attributedString =  [self getAttributedStringWithHtml:htmlString];
    //获取布局器
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedString];
    NSRange entireString = NSMakeRange(0, [attributedString length]);
    //获取Frame
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:_viewMaxRect range:entireString];
    //得到大小
    CGSize sizeNeeded = [layoutFrame frame].size;
    return sizeNeeded;
}

//Html->富文本NSAttributedString
- (NSAttributedString *)getAttributedStringWithHtml:(NSString *)htmlString{
    //获取富文本
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
    return attributedString;
}

#pragma mark - Getter && Setter
//懒加载创建
- (DTAttributedLabel *)attributedLabel{
    if (_attributedLabel == nil) {
        _attributedLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _attributedLabel.delegate = self;
        //        _attributedLabel.backgroundColor = [UIColor lightGrayColor];
    }
    return _attributedLabel;
}

@end

