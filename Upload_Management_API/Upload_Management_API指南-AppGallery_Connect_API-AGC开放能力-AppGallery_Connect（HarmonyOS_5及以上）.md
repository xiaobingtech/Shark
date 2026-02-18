应用信息填写完整后，您需要准备应用的相关文件，例如APP软件包，以及应用的图标、介绍图片、视频文件等。您通过Upload Management API可以将上传应用文件改为服务器对服务器上传，相对于AppGallery Connect中上传文件的上传速度更快，且不受您个人设备所在网络的限制。

**上传文件的具体流程如下：**

1.  获取上传文件地址
    
    在上传文件前，调用[获取上传文件地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-url-0000002236201294)接口获取文件上传的地址。
    
2.  上传文件
    
    调用[上传文件](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-upload-file-0000002271160621)接口将文件上传到华为文件服务器。
    

说明

如果上传文件超过接口的文件大小上限，则需要调用分片上传相关接口进行上传。

**分片上传文件的具体流程如下：**

1.  调用[分片上传初始化](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-init-0000002271000677)接口进行初始化。
2.  使用**objectId**和**nspUploadId**调用[获取分片上传地址](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-uploadurl-0000002236041490)接口获取上传地址。
3.  调用[上传分片实体](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-upload-0000002236201298)接口上传分片到已获取的上传地址。
4.  上传完所有分片后，调用[合并分片](https://developer.huawei.com/consumer/cn/doc/app/agc-help-upload-api-obbfile-compose-0000002271160625)接口合并所有分片。

相关推荐

意见反馈

以上内容对您是否有帮助？

意见反馈

如果您有其他疑问，您也可以通过开发者社区问答频道来和我们联系探讨。