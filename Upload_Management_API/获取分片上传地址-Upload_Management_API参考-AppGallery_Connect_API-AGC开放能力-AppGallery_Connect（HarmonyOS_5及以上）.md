## 功能介绍

此接口用于获取文件所有分片的上传地址，调用此接口前必须先调用[分片上传初始化](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-init-0000002271000677)接口完成分片初始化。

接口调用者的角色：账号持有者、管理员、APP管理员、运营。

## 接口原型

<table id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_table8419125694713" class="layoutFixed idpTab"><tbody><tr id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_row19435115613475"><th class="firstcol" id="mcps1.3.2.2.1.3.1.1"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p10435175617476">承载协议</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p19435155674713">HTTPS POST</p></td></tr><tr id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_row1443575613476"><th class="firstcol" id="mcps1.3.2.2.1.3.2.1"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p1743510563473">接口方向</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p343595615476">开发者服务器 -&gt; 华为服务器</p></td></tr><tr id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_row10435125616475"><th class="firstcol" id="mcps1.3.2.2.1.3.3.1"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p94351056174715">接口URL</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p443515561477">https://connect-api.cloud.huawei.com/api/publish/v2/upload/multipart/parts</p></td></tr><tr id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_row7435185617475"><th class="firstcol" id="mcps1.3.2.2.1.3.4.1"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p843511566479">数据格式</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p043555617476">请求：Content-Type: application/json</p><p id="ZH-CN_TOPIC_0000002236041490__zh-cn_topic_0000001111685208_p134357568478">响应：Content-Type: application/json</p></td></tr></tbody></table>

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

objectId

 | 

M

 | 

String

 | 

对象ID。

必须与[分片上传初始化](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-init-0000002271000677)时生成的**objectId**参数一致。

 |
| 

nspUploadId

 | 

M

 | 

String

 | 

上传ID。

必须与[分片上传初始化](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-init-0000002271000677)时生成的**nspUploadId**参数一致。

 |

### Body

请求Body中使用JSON格式携带详细的分片信息，参数如下所示。

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

additionalProp*X*

 | 

M

 | 

[FilePartInfo](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-data-filepartinfo-0000002237498540)

 | 

详细分片信息。

其中参数名中的X为分片的编号，从1开始顺序编号，例如additionalProp1、additionalProp2。

 |

## 请求示例

收起

自动换行

深色代码主题

复制

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

uploadInfoMap

 | 

M

 | 

HashMap<String, [FilePartUploadInfo](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-data-filepartuploadinfo-0000002237338748)\>

 | 

包含分片地址的Map对象。

+   key为分片的编号。例如“additionalProp1”, “additionalProp2”。
+   value为包含对应分片地址信息的[FilePartUploadInfo](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-data-filepartuploadinfo-0000002237338748)实体类。

 |

## 响应示例

收起

自动换行

深色代码主题

复制

相关推荐

意见反馈

以上内容对您是否有帮助？

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。

本文导读