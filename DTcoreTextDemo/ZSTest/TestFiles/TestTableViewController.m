//
//  TestTableViewController.m
//  ZSTest
//
//  Created by Bjmsp on 2018/1/25.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import "TestTableViewController.h"
#import "ZSDTCoreTextTools.h"
#import "UIImageView+WebCache.h"
@interface TestTableViewController ()<UITableViewDataSource,UITableViewDelegate,DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
//普通单元格与富文本单元格
@property (nonatomic, copy) NSString *cellID_Normal;
@property (nonatomic, copy) NSString *cellID_DTCoreText;

//类似tabelView的缓冲池，用于存放图片大小
@property (nonatomic, strong) NSCache *imageSizeCache;
//表视图数据源
@property (nonatomic, strong) NSArray  *dataSource;
@end

@implementation TestTableViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试DTAttributedTextCell";
    self.cellID_Normal = @"UITableViewCellID";
    //self.cellID_DTCoreText = @"DTCoreTextTableViewCellID";
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    
    _imageSizeCache = [[NSCache alloc] init];
    //添加表视图
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
}

- (void)dealloc{
    
}




#pragma mark - UITableViewDelegate
//返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
//返回单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            //普通单元格
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellID_Normal];
            cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
            return cell;
            break;
        }
        case 1:{
            //富文本单元格
            //自定义方法，创建富文本单元格
            ZSDTCoreTextCell *dtCell = (ZSDTCoreTextCell *) [self tableView:tableView prepareCellForIndexPath:indexPath];
            return dtCell;
            break;
        }
        default:
            break;
    }
    return nil;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            return 50;
            break;
        }
        case 1:{
            ZSDTCoreTextCell *cell = (ZSDTCoreTextCell *)[self tableView:tableView prepareCellForIndexPath:indexPath];
            return [cell requiredRowHeightInTableView:tableView];
            break;
        }
        default:
            break;
    }
    return 0;
}



#pragma mark - DTAttributedTextContentViewDelegate
//对于没有在Html标签里设置宽高的图片，在这里为其设置占位
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    if([attachment isKindOfClass:[DTImageTextAttachment class]]){
        ZSDTLazyImageView *imageView = [[ZSDTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        imageView.image = [(DTImageTextAttachment *)attachment image];
        imageView.textContentView = attributedTextContentView;
        imageView.url = attachment.contentURL;
        return imageView;
    }
    return nil;
}


//对于无宽高懒加载得到的图片，缓存记录其大小,然后执行表视图更新
- (void)lazyImageView:(ZSDTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size{
    BOOL needUpdate = NO;
    NSURL *url = lazyImageView.url;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    /* update all attachments that matchin this URL (possibly multiple
        images with same size)
     */
    for (DTTextAttachment *oneAttachment in [lazyImageView.textContentView.layoutFrame textAttachmentsWithPredicate:pred]){
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero)){
            oneAttachment.originalSize = size;
            NSValue *sizeValue = [_imageSizeCache objectForKey:oneAttachment.contentURL];
            if (!sizeValue) {
                //将图片大小记录在缓存中，但是这种图片的原始尺寸可能很大，所以这里设置图片的最大宽
                //并且计算高
                CGFloat aspectRatio = size.height / size.width;
                CGFloat width = ZSToolScreenWidth - 15*2;
                CGFloat height = width * aspectRatio;
                CGSize newSize = CGSizeMake(width, height);
                [_imageSizeCache setObject:[NSValue valueWithCGSize:newSize]forKey:url];
            }
            needUpdate = YES;
        }
    }

    if (needUpdate){
        [self.tableView  reloadData];
    }
}

#pragma mark - private Methods
//创建富文本单元格，并更新单元格上的数据
- (ZSDTCoreTextCell *)tableView:(UITableView *)tableView prepareCellForIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [NSString stringWithFormat:@"dtCoreTextCellKEY%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    ZSDTCoreTextCell *cell = [tableView dequeueReusableCellWithIdentifier:key];

    if (!cell){
        //cell = [tableView dequeueReusableCellWithIdentifier:key];
        cell = [[ZSDTCoreTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.hasFixedRowHeight = NO;
        cell.textDelegate = self;
        cell.attributedTextContextView.shouldDrawImages = YES;
        //记录在缓存中
        //[_cellCache setObject:cell forKey:key];
    }
    //2.设置数据
    //2.1为富文本单元格设置Html数据
    [cell setHTMLString:self.dataSource[indexPath.section][indexPath.row]];
    //2.2为每个占位图(图片)设置大小，并更新
    for (DTTextAttachment *oneAttachment in cell.attributedTextContextView.layoutFrame.textAttachments) {
        NSValue *sizeValue = [_imageSizeCache objectForKey:oneAttachment.contentURL];
        if (sizeValue) {
            cell.attributedTextContextView.layouter=nil;
            oneAttachment.displaySize = [sizeValue CGSizeValue];
        }
    }
    [cell.attributedTextContextView relayoutText];
    return cell;
}





#pragma mark - set/get方法
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, 0, ZSToolScreenWidth, ZSToolScreenHeight-64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:_cellID_Normal];
        //[_tableView registerClass:[ZSDTCoreTextCell class] forCellReuseIdentifier:_cellID_DTCoreText];
    }
    return _tableView;
}

- (NSArray *)dataSource{
    if(_dataSource == nil){
        NSMutableArray *noramDataArray = @[].mutableCopy;
        NSMutableArray *htmlDataArray = @[].mutableCopy;

        for(int i = 0;i<5;i++){
            [noramDataArray addObject:[NSString stringWithFormat:@"测试普通单元格:%d",i]];
            //这里提供的Html图片链接，没有宽高属性，代码中已经演示了如何处理
            NSString *htmlString =[NSString stringWithFormat:@"<span style=\"color:#333;font-size:15px;\"><strong>收费标准%d：</strong></span><br/><span style=\"color:#333;font-size:15px;\">记住！砍价是由你自己先砍，砍不动时再由砍价师继续砍；由砍价师多砍下的部分，才按照下列标准收费：</span><br/><span style=\"color:#333;font-size:15px;\"><img src=\"http://cn-qinqimaifang-uat.oss-cn-hangzhou.aliyuncs.com/img/specialist/upload/spcetiicwlz1v_54e2e00fa8a6faf66168571654dbfee2.jpg\" _src=\"http://cn-qinqimaifang-uat.oss-cn-hangzhou.aliyuncs.com/img/specialist/upload/spcetiicwlz1v_54e2e00fa8a6faf66168571654dbfee2.jpg\"></span>",i];
            [htmlDataArray addObject:htmlString];
        }
        _dataSource = @[noramDataArray,htmlDataArray];
    }
    return _dataSource;
}


@end

