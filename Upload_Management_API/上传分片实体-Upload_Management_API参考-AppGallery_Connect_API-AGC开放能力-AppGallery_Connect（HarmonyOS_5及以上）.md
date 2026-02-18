## 功能介绍

此接口用于将分片实体文件上传到AppGallery Connect服务器，每次调用只能上传一个分片，支持多次调用逐个上传多个分片。

接口调用者的角色：账号持有者、管理员、APP管理员、运营。

## 接口原型

<table id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_table8419125694713" class="layoutFixed idpTab"><tbody><tr id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_row19435115613475"><th class="firstcol" id="mcps1.3.2.2.1.3.1.1"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p10435175617476">承载协议</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p16636144820917"><a href="https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490">获取分片上传地址</a>接口中返回的<strong>method</strong>参数中指定的请求方式。</p></td></tr><tr id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_row1443575613476"><th class="firstcol" id="mcps1.3.2.2.1.3.2.1"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p1743510563473">接口方向</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p343595615476">开发者服务器 -&gt; 华为服务器</p></td></tr><tr id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_row10435125616475"><th class="firstcol" id="mcps1.3.2.2.1.3.3.1"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p94351056174715">接口URL</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p443515561477"><a href="https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490">获取分片上传地址</a>接口中返回的分片文件上传地址（参见<strong>FilePartUploadInfo</strong>的<strong>url</strong>参数）。</p></td></tr><tr id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_row7435185617475"><th class="firstcol" id="mcps1.3.2.2.1.3.4.1"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p843511566479">数据格式</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p043555617476">请求：Content-Type: application/octet-stream</p><p id="ZH-CN_TOPIC_0000002236201298__zh-cn_topic_0000001158245067_p134357568478">响应：Content-Type: application/json</p></td></tr></tbody></table>

### Header

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

对应[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)接口返回的headers参数中的**Authorization**。

 |
| 

x-amz-content-sha256

 | 

M

 | 

String

 | 

文件对象内容的SHA256哈希值。

对应[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)接口返回的headers参数中的**x-amz-content-sha256**。

 |
| 

x-amz-date

 | 

M

 | 

String

 | 

文件上传地址生成的时间。

对应[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)接口返回的headers参数中的**x-amz-date**。

 |
| 

Host

 | 

M

 | 

String

 | 

上传服务器地址。

对应[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)接口返回的headers参数中的**Host**。

 |
| 

Content-Type

 | 

M

 | 

String

 | 

对象内容的类型。

对应[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)接口返回的headers参数中的**Content-Type**。

 |

### Body

请求Body为二进制形式的分片文件内容，对应**Content-Type**为application/octet-stream，文件的大小必须和获取文件上传地址时填写的**length**一致，最大不能超过100MB。

## 响应参数

HTTP响应码为200时表示上传成功，成功时在header中会携带如下参数。

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

ETag

 | 

M

 | 

String(header)

 | 

响应消息header中的ETag值。

每个分片Etag不相同，在合并分片时需要使用。

 |

HTTP响应码非200时表示上传失败，请检查[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)时参数是否传入准确。