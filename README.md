## DTCoreTextDemo
DTCoreText是可以将HTML字符串转为为富文本使用的工具，本例提供其基本用法，演示作为Label、ScrollView、Cell的三种用法。

DTCoreText这个工具很强大，但是相关的资料和博客却很少，所以在总结了很多的用法之后，将其基本的使用集中在这个工程里测试。在使用的时候需要注意：

1.html标签的图片链接如果没有自带宽高属性的时候，需要借助DTCoreText的代理先获取宽高再刷新html显示。

2.关于html标签的超链接，如果需要响应处理，我们需要自定义Button等控件，这个也是在代理方法中处理的。

## 效果图：
<img src="https://github.com/DreamcoffeeZS/DTCoreTextDemo/blob/master/Screenshots/DTcoreTextDemoImg1.png" width="375" height="667">
<img src="https://github.com/DreamcoffeeZS/DTCoreTextDemo/blob/master/Screenshots/DTcoreTextDemoImg2.png" width="375" height="667">
<img src="https://github.com/DreamcoffeeZS/DTCoreTextDemo/blob/master/Screenshots/DTcoreTextDemoImg3.png" width="375" height="667">
<img src="https://github.com/DreamcoffeeZS/DTCoreTextDemo/blob/master/Screenshots/DTcoreTextDemoImg5.png" width="375" height="667">

