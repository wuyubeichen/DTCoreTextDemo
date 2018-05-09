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
@property (nonatomic,strong)NSCache *cellCache;

//表视图数据源
@property (nonatomic, strong) NSArray  *dataSource;
@property (nonatomic,assign)BOOL isScrolling;
@end

@implementation TestTableViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试DTAttributedTextCell";
    self.cellID_Normal = @"UITableViewCellID";
    self.cellID_DTCoreText = @"DTCoreTextTableViewCellID";
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    
    _imageSizeCache = [[NSCache alloc] init];
    _cellCache = [[NSCache alloc] init];
    _cellCache.totalCostLimit = 10;
    _cellCache.countLimit = 10;

    //添加表视图
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    
    //测试一个bug,执行表视图更新的时候回内存激增
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake( 50, 20, 300, 50)];
    [testBtn addTarget:self action:@selector(testBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [testBtn setTitle:@"测试表视图刷新" forState:UIControlStateNormal];
    testBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:testBtn];
}


- (void)testBtnClick:(UIButton *)btn{
    NSLog(@"点击刷新表视图。。。。。。");
    [self.tableView reloadData];
}

- (void)dealloc{
    
}




#pragma mark - UITableViewDelegate
//返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}
//返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource[section] count];
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
        //有新的图片尺寸被缓存记录的时候，需要刷新表视图
        //[self reloadCurrentCell];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadCurrentCell) object:nil];
        self.isScrolling = NO;
        [self performSelector:@selector(reloadCurrentCell) withObject:nil afterDelay:0.2];
    }
}

#pragma mark - private Methods
//创建富文本单元格，并更新单元格上的数据
- (ZSDTCoreTextCell *)tableView:(UITableView *)tableView prepareCellForIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [NSString stringWithFormat:@"dtCoreTextCellKEY%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    ZSDTCoreTextCell *cell = [_cellCache objectForKey:key];

    if (!cell){
//    cell = [self.tableView dequeueReusableCellWithIdentifier:_cellID_DTCoreText];
//        if (!cell) {
            cell = [[ZSDTCoreTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellID_DTCoreText];
//        }
        cell.attributedTextContextView.edgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.hasFixedRowHeight = NO;
        cell.textDelegate = self;
        cell.attributedTextContextView.shouldDrawImages = YES;
        //记录在缓存中
        [_cellCache setObject:cell forKey:key];
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
            [cell.attributedTextContextView relayoutText];
        }
    }
    [cell.attributedTextContextView relayoutText];
    return cell;
}


- (void)reloadCurrentCell{
    //如果当前表视图在滑动就不执行刷新，因为滑动时候会自动调用表视图的刷新方法
    if (self.isScrolling) {
        return;
    }
    //如果当前表视图没有在滑动，就手动刷新当前在屏幕显示的单元格
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    if(indexPaths){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

////显示动画，表视图停止滑动之后调用；没有动画此方法不调用
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//    _isScrolling = NO;
////   [self reloadCurrentCell];
//}
//
////手指拖动表视图，表视图停止滑动之后调用
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    _isScrolling = NO;
////    [self reloadCurrentCell];
//}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _isScrolling = YES;
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
        NSArray *images = @[@"https://i0.hdslb.com/bfs/archive/d5ad3cf95d32f3d2f2e3471a39120237200d84d8.jpg",
                           @"https://i0.hdslb.com/bfs/archive/71d2fed927d9351e759f408ca7d66c556c37a6b4.jpg",
                           @"https://i0.hdslb.com/bfs/archive/7f520b31b67cd5d89dd30b61b40711327bb00288.png",
                           @"https://i0.hdslb.com/bfs/archive/6edbe81bf74c106087ad139aca169d6e8d9d963b.jpg",
                           @"https://i0.hdslb.com/bfs/archive/805aa8f7ae722fcc277f425bb9927e29ec1d2468.jpg",
                           @"https://i0.hdslb.com/bfs/archive/a7c61d94c583363a970d2a2e339eea97f8f32317.jpg",
                           @"https://i0.hdslb.com/bfs/archive/b447ee1fd63b4cf6f4465a5621cc12898867d26b.jpg"];
        
        
        for(int i = 0;i<1000;i++){
            if(i <3){
                [noramDataArray addObject:[NSString stringWithFormat:@"测试普通单元格:%d",i]];
            }
        
            
            //这里提供的Html图片链接，没有宽高属性，代码中已经演示了如何处理
            int k = i % 6;
            NSString *htmlString =[NSString stringWithFormat:@"<span style=\"color:#333;font-size:15px;\"><strong>测试富文本单元格%d：</strong></span><br/><span style=\"color:#333;font-size:15px;\">记住！砍价是由你自己先砍，砍不动时再由砍价师继续砍；由砍价师多砍下的部分，才按照下列标准收费：</span><br/><span style=\"color:#333;font-size:15px;\"><img src=%@ _src=%@></span>",i,images[k],images[k]];

            [htmlDataArray addObject:htmlString];
        }
        _dataSource = @[noramDataArray,htmlDataArray];
    }
    return _dataSource;
}


@end

