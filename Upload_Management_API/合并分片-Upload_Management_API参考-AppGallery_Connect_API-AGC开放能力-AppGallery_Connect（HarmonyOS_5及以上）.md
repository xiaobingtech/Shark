## 功能介绍

此接口用于将已经上传成功后的分片合并为一个文件。

接口调用者的角色：账号持有者、管理员、APP管理员、运营。

## 接口原型

<table id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_table8419125694713" class="layoutFixed idpTab"><tbody><tr id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_row19435115613475"><th class="firstcol" id="mcps1.3.2.2.1.3.1.1"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p10435175617476">承载协议</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p19435155674713">HTTPS POST</p></td></tr><tr id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_row1443575613476"><th class="firstcol" id="mcps1.3.2.2.1.3.2.1"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p1743510563473">接口方向</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p343595615476">开发者服务器 -&gt; 华为服务器</p></td></tr><tr id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_row10435125616475"><th class="firstcol" id="mcps1.3.2.2.1.3.3.1"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p94351056174715">接口URL</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p717910431121">https://connect-api.cloud.huawei.com/api/publish/v2/upload/multipart/compose</p></td></tr><tr id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_row7435185617475"><th class="firstcol" id="mcps1.3.2.2.1.3.4.1"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p843511566479">数据格式</p></th><td class="cellrowborder"><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p043555617476">请求：Content-Type: application/json</p><p id="ZH-CN_TOPIC_0000002271160625__zh-cn_topic_0000001111845098_p134357568478">响应：Content-Type: application/json</p></td></tr></tbody></table>

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

objectId

 | 

M

 | 

String(200)

 | 

对象ID。

参见[分片上传初始化](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-init-0000002271000677)时生成的**objectId**参数。

 |
| 

nspUploadId

 | 

M

 | 

String(64)

 | 

上传ID。

参见[分片上传初始化](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-init-0000002271000677)时生成的**nspUploadId**参数。

 |

### Body

请求Body中使用JSON格式携带分片信息，参数如下所示。

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

[FilePartComposeInfo](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-data-filepartcomposeinfo-0000002272457917)

 | 

分片信息。

其中参数名中的X为分片的编号，例如additionalProp1、additionalProp2，需要与[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)时返回的分片编号一致。

 |

## 请求示例

收起

自动换行

深色代码主题

复制

```
POST /api/publish/v2/upload/multipart/compose?objectId=*******&nspUploadId=***** HTTP/1.1Host: connect-api.cloud.huawei.comclient_id: 41******68Content-Type: application/jsonAuthorization: Bearer ******{    "additionalProp1": {        "partObjectId": "",        "etag": "41a9ba6******fac180e149f94"    },    "additionalProp2": {        "partObjectId": "",        "etag": "2b8dd6a26*****3a364f55d2a92"    }}
```

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