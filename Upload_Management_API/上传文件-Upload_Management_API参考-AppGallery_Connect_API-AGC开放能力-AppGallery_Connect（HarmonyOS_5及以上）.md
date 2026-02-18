## 功能介绍

客户端或服务器向AppGallery Connect上传相关文件接口。

浏览器或客户端与服务器之间的接口协议采用HTTPS，Content-Type采用application/octet-stream格式，文件使用application/octet-stream格式编码添加到HTTPS报文中。

此接口当前支持上传的应用软件包包括APP（HarmonyOS应用/元服务）。

接口调用者的角色：账号持有者、管理员、APP管理员、运营。

## 使用约束

+   文件大小上限：针对APP（HarmonyOS应用/元服务）软件包，HarmonyOS应用不超过4GB，元服务不超过10MB。
+   文件类型要求与[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)中请求的文件名后缀相同。
+   用户头像需采用文件加密存储。

## 接口原型

<table id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_table8419125694713" class="layoutFixed idpTab"><tbody><tr id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_row19435115613475"><th class="firstcol" id="mcps1.3.3.2.1.3.1.1"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p10435175617476">承载协议</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p19435155674713">HTTPS PUT</p></td></tr><tr id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_row1443575613476"><th class="firstcol" id="mcps1.3.3.2.1.3.2.1"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p1743510563473">接口方向</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p343595615476">开发者服务器 -&gt; 华为服务器</p></td></tr><tr id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_row10435125616475"><th class="firstcol" id="mcps1.3.3.2.1.3.3.1"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p94351056174715">接口URL</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p443515561477"><a href="https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294">获取上传文件地址</a>接口中获取的URL地址。</p></td></tr><tr id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_row7435185617475"><th class="firstcol" id="mcps1.3.3.2.1.3.4.1"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p843511566479">数据格式</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p043555617476">请求：Content-Type: application/octet-stream</p><p id="ZH-CN_TOPIC_0000002271160621__zh-cn_topic_0000001111845090_p134357568478">响应：Content-Type: application/json</p></td></tr></tbody></table>

### header

展开

| 
参数名称

 | 

必选(M)/可选(O)

 | 

类型

 | 

参数说明

 |
| --- | --- | --- | --- |
| 

Authorization

 | 

M

 | 

String

 | 

校验信息。

对应[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口返回的headers参数中的**Authorization**。

 |
| 

x-amz-content-sha256

 | 

M

 | 

String

 | 

文件对象内容的SHA256哈希值。

对应[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口返回的headers参数中的**x-amz-content-sha256**。

 |
| 

x-amz-date

 | 

M

 | 

String

 | 

文件上传地址生成的时间。

对应[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口返回的headers参数中的**x-amz-date**。

 |
| 

Host

 | 

M

 | 

String

 | 

上传服务器地址。

对应[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口返回的headers参数中的**Host**。

 |
| 

user-agent

 | 

M

 | 

String

 | 

用户代理。

对应[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口返回的headers参数中的**user-agent**。

 |
| 

Content-Type

 | 

M

 | 

String

 | 

对象内容的类型。

对应[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口返回的headers参数中的**Content-Type**。

 |

### Body

请求Body为二进制形式的文件内容，对应**Content-Type**为application/octet-stream，文件的大小必须和获取文件上传地址时填写的**contentLength**一致。

## 响应参数

接口返回的HTTP状态码为200时，表示文件上传成功。