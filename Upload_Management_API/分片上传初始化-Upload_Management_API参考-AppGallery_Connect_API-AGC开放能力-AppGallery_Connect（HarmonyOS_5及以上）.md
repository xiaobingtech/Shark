## 功能介绍

此接口用于分片信息初始化，在获取分片文件上传地址前调用。

接口调用者的角色：账号持有者、管理员、APP管理员、运营。

## 接口原型

<table id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_table8419125694713" class="layoutFixed idpTab"><tbody><tr id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_row19435115613475"><th class="firstcol" id="mcps1.3.2.2.1.3.1.1"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p10435175617476">承载协议</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p19435155674713">HTTPS POST</p></td></tr><tr id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_row1443575613476"><th class="firstcol" id="mcps1.3.2.2.1.3.2.1"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p1743510563473">接口方向</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p343595615476">开发者服务器 -&gt; 华为服务器</p></td></tr><tr id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_row10435125616475"><th class="firstcol" id="mcps1.3.2.2.1.3.3.1"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p94351056174715">接口URL</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p443515561477">https://connect-api.cloud.huawei.com/api/publish/v2/upload/multipart/init</p></td></tr><tr id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_row7435185617475"><th class="firstcol" id="mcps1.3.2.2.1.3.4.1"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p843511566479">数据格式</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p043555617476">请求：Content-Type: application/json</p><p id="ZH-CN_TOPIC_0000002271000677__zh-cn_topic_0000001158365055_p134357568478">响应：Content-Type: application/json</p></td></tr></tbody></table>

### Header

说明

API客户端方式和OAuth客户端方式的区别请参见[获取服务端授权](https://developer.huawei.com/consumer/cn/doc/app/agc-help-connect-api-obtain-server-auth-0000002271134661)。

**API客户端方式：**

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

client\_id

 | 

M

 | 

String

 | 

客户端ID。

 |
| 

Authorization

 | 

M

 | 

String

 | 

认证信息。

格式：Authorization: Bearer *${access\_token}*

 |

说明

**OAuth客户端方式：**

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

teamId

 | 

M

 | 

String(64)

 | 

开发者所在团队的团队ID。

 |
| 

oauth2Token

 | 

M

 | 

String

 | 

认证信息。

请传入[获取用户授权码](https://developer.huawei.com/consumer/cn/doc/app/agc-help-connect-api-obtain-server-auth-0000002271134661#section949717114392)中获取的Access Token。

 |

### Query

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

appId

 | 

M

 | 

String(32)

 | 

应用ID。

 |
| 

fileName

 | 

M

 | 

String(256)

 | 

原始文件名，需要带文件后缀。

 |
| 

contentType

 | 

O

 | 

String

 | 

对象内容的类型。

为HTTP标准的content-type。

例如：image/jpeg

如果不传，则默认值：application/octet-stream

 |
| 

releaseType

 | 

O

 | 

Integer

 | 

应用发布方式。

取值范围：

+   1：全网发布。
+   6：HarmonyOS测试发布（API>=10）。

 |
| 

chineseMainlandFlag

 | 

O

 | 

Integer

 | 

软件包是否分发中国大陆（不包括港澳台）。

取值范围：

+   0：不分发中国大陆
+   1：分发中国大陆

 |

## 响应参数

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

ret

 | 

M

 | 

[ConnectRet](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-data-connectret-0000002273607369)

 | 

包含返回码及描述信息的结果。

 |
| 

objectId

 | 

M

 | 

String(128)

 | 

生成的对象ID。

在[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)时需要使用此ID。

 |
| 

nspPartMinSize

 | 

M

 | 

Integer(64)

 | 

分片文件的最小值。

单位：字节

默认值：5,242,880（即5MB）

 |
| 

nspPartMaxSize

 | 

M

 | 

Integer(64)

 | 

分片文件的最大值。

单位：字节

默认值：1,073,741,824（即1024MB）

 |
| 

nspUploadId

 | 

M

 | 

String(128)

 | 

文件上传ID。

在[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)时需要使用此ID。

 |