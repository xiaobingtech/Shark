## 功能介绍

上传文件至AppGallery Connect前需要先调用此接口获取上传地址，包括图片、视频、APP、PDF等文件。

此接口当前支持获取上传地址的应用软件包格式包括APP（HarmonyOS应用/元服务）。

接口调用者的角色：账号持有者、管理员、APP管理员、运营。

## 接口原型

<table id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_table8419125694713" class="layoutFixed idpTab"><tbody><tr id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_row19435115613475"><th class="firstcol" id="mcps1.3.2.2.1.3.1.1"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p10435175617476">承载协议</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p19435155674713">HTTPS GET</p></td></tr><tr id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_row1443575613476"><th class="firstcol" id="mcps1.3.2.2.1.3.2.1"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p1743510563473">接口方向</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p343595615476">开发者服务器 -&gt; 华为服务器</p></td></tr><tr id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_row10435125616475"><th class="firstcol" id="mcps1.3.2.2.1.3.3.1"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p94351056174715">接口URL</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p443515561477">https://connect-api.cloud.huawei.com/api/publish/v2/upload-url/for-obs</p></td></tr><tr id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_row7435185617475"><th class="firstcol" id="mcps1.3.2.2.1.3.4.1"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p843511566479">数据格式</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p043555617476">请求：Content-Type: application/json</p><p id="ZH-CN_TOPIC_0000002236201294__zh-cn_topic_0000001111685200_p134357568478">响应：Content-Type: application/json</p></td></tr></tbody></table>

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

原始文件名，包含文件后缀。

主要用于在生成上传地址时获取原始文件后缀。

 |
| 

sha256

 | 

O

 | 

String(64)

 | 

文件内容的SHA256哈希值。

+   如果传入此参数，文件在上传到文件服务器后会执行完整性校验。
+   如果不传则不做校验。

 |
| 

contentLength

 | 

M

 | 

Integer

 | 

文件内容的大小。

单位：字节。

 |
| 

releaseType

 | 

O

 | 

Integer

 | 

发布方式。

取值范围：

+   1：全网发布。

+   6：HarmonyOS测试发布（API>=10）。

默认值：1

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

说明

当开发者注册地非中国大陆时，必须设置**chineseMainlandFlag**参数。



 |

## 响应参数

说明

获取的上传URL有效期约为5分钟，超时后此URL将失效，需重新调用接口获取上传URL。

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

urlInfo

 | 

M

 | 

[CommonUrlInfo](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-data-commonurlinfo-0000002272577809)

 | 

文件上传信息，包含请求方法、文件上传URL、请求头等信息。

 |

相关推荐

意见反馈

以上内容对您是否有帮助？

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

本文导读