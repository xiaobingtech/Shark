import { pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'
import { CommonConstants, ProcessUtil } from '@ohos/common'
import { CardItem } from '../common/CardItem'
import { CardRightItem } from '../common/CardRightItem'
import { CardToogleItem } from '../common/CardToogleItem'
import { AboutViewBuilder } from './AboutView'
import { iap } from '@kit.IAPKit'
import IAPLogger from '../common/IAPLogger'
import { PurchaseData, PurchaseOrderPayload } from '../common/IapDataModel'
import { JWSUtil } from '../common/JWSUtil'
import { commentManager } from '@kit.AppGalleryKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const DEVICE_TOKEN_KEY: string = 'deviceToken'
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData'

class HistoryStoreData {
  titles: string[] = []
  bodies: string[] = []
  times: number[] = []
}

@Builder
export function SettingViewBuilder(name: string, param: Object) {
  SettingView()
}

@Preview
@Component
export struct SettingView {

  @State selectedProductId: string = 'com.xiaobingkj.shark.coffee'

  @StorageProp('currentBreakpoint') currentBreakpoint: string = '';
  @State aboutViewShow: boolean = false;
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @State defaultSave: boolean = true;
  @Watch('onRefreshTickChange')
  @StorageLink('historyRefreshTick') refreshTick: number = 0
  @StorageLink(DEVICE_TOKEN_KEY) deviceToken: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @State historyCount: number = 0

  private uiContext: UIContext = this.getUIContext();
  private context = this.uiContext.getHostContext() as common.UIAbilityContext;

  private computeHistoryCount(): number {
    let data: HistoryStoreData | undefined =
      AppStorage.get<HistoryStoreData>(HISTORY_DATA_VALUE_KEY)
    if (data == undefined) {
      return 0
    }
    let count: number = data.titles.length
    if (data.bodies.length < count) {
      count = data.bodies.length
    }
    if (data.times.length < count) {
      count = data.times.length
    }
    return count
  }

  private showReviewDialog(): void {
    try {
      commentManager.showCommentDialog(this.context).then(() => {
        hilog.info(0x0000, 'SettingView', 'succeeded in showing commentDialog.');
      }).catch((error: BusinessError<Object>) => {
        hilog.error(0x0000, 'SettingView', `showCommentDialog failed, Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      let err = error as BusinessError<Object>;
      hilog.error(0x0000, 'SettingView', `showCommentDialog failed, Code: ${err.code}, message: ${err.message}`);
    }
  }

  private copyDeviceToken(): void {
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.deviceToken)
    let systemPasteboard = pasteboard.getSystemPasteboard()
    systemPasteboard.setDataSync(pasteData)
    promptAction.showToast({ message: '复制成功' })
  }

  private openGithubRun(): void {
    let url = 'https://github.com/xiaobingtech/Shark/actions/runs/' + CommonConstants.GITHUB_RUN_ID
    this.openBrowser(url)
  }

  private openBrowser(url: string): void {
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    }
    ProcessUtil.startAbility(context, want)
  }

  aboutToAppear(): void {
    this.historyCount = this.computeHistoryCount()
  }

  private onRefreshTickChange(): void {
    this.historyCount = this.computeHistoryCount()
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 8 }) {
        List() {
          ListItem() {
            Text('历史消息')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level6') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: '导出/导入',
                rightText: this.historyCount + ' 条消息',
                symbolSrc: $r('sys.symbol.arrow_right_to_line')
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardToogleItem({
                isShow: false,
                textContent: '默认保存',
                symbolSrc: $r('sys.symbol.doc_text'),
                isOn: this.defaultSave,
                onChange: (value: boolean) => {
                  this.defaultSave = value
                }
              })
            }
            .height(undefined)
            .width('100%')
          }
          .divider({
            strokeWidth: 1,
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level24'),
            endMargin: $r('sys.float.padding_level6')
          })
          .margin({ top: $r('sys.float.padding_level6') })
          .padding($r('sys.float.padding_level2'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))

          ListItem() {
            Text('当推送请求URL没有指定 isArchive 参数时，将按照此设置来决定是否保存通知消息')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({
                top: $r('sys.float.padding_level4'),
              })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItem() {
            Text('信息')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level8') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: 'Device Token',
                rightText: this.deviceToken.length > 0 ? this.deviceToken : '未知',
                symbolSrc: $r('sys.symbol.envelope'),
                onclick: () => {
                  this.copyDeviceToken()
                }
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: 'Github Run Id',
                rightText: CommonConstants.GITHUB_RUN_ID,
                symbolSrc: $r('sys.symbol.doc_text_fill'),
                onclick: () => {
                  this.openGithubRun()
                }
              })
            }
            .height(undefined)
            .width('100%')
          }
          .divider({
            strokeWidth: 1,
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level24'),
            endMargin: $r('sys.float.padding_level6')
          })
          .margin({ top: $r('sys.float.padding_level6') })
          .padding($r('sys.float.padding_level2'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))

          ListItem() {
            Text('Shark 由 GitHub Actions 构建上传 Huawei AppGallery，此信息可帮助你确认当前版本是否由开源代码所构建，未经任何人（包含作者）修改')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({
                top: $r('sys.float.padding_level4'),
              })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItem() {
            Text('其他')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level8') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: '常见问题',
                symbolSrc: $r('sys.symbol.exclamationmark_circle'),
                onclick:() => {
                  this.openBrowser("https://bark.day.app/#/faq")
                }
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: '使用文档',
                symbolSrc: $r('sys.symbol.doc_text'),
                onclick:() => {
                  this.openBrowser("https://bark.day.app/#/tutorial")
                }
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: '开源代码',
                symbolSrc: $r('sys.symbol.communicationsharing'),
                onclick:() => {
                  this.openBrowser("https://github.com/xiaobingtech/Shark")
                }
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: $r('app.string.setting_review'),
                symbolSrc: $r('sys.symbol.star'),
                onclick: () => {
                  this.showReviewDialog();
                },
                onClose: () => {
                },
              })
            }
            .height(undefined)
            .width("100%")

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: $r('app.string.setting_more_apps'),
                symbolSrc: $r('sys.symbol.square_grid_2x2'),
                onclick: () => {
                  this.navPathStack.pushPathByName('MyAppView', null);
                  this.tabBarHidden = true
                },
                onClose: () => {
                },
              })
            }
            .height(undefined)
            .width("100%")

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: this.aboutViewShow,
                textContent: $r('app.string.about'),
                symbolSrc: $r('sys.symbol.info_circle'),
                onclick: () => {
                  this.aboutViewShow = !this.aboutViewShow
                },
                onClose: () => {
                  this.aboutViewShow = false
                },
              })
                .bindSheet(this.aboutViewShow, AboutViewBuilder(), {
                  preferType: this.currentBreakpoint === "lg" ? SheetType.CENTER : SheetType.BOTTOM,
                  title: { title: '关于' },
                  height: SheetSize.LARGE,
                  width: undefined,
                  onWillDisappear: () => {
                    this.aboutViewShow = false
                  },
                })
            }
            .height(undefined)
            .width("100%")
          }
          .divider({
            strokeWidth: 1,
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level24'),
            endMargin: $r('sys.float.padding_level6')
          })
          .margin({ top: $r('sys.float.padding_level6') })
          .padding($r('sys.float.padding_level2'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))

          ListItem() {
            Text('捐赠')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level8') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: '一次性捐赠',
                rightText: '¥6.00',
                symbolSrc: $r('sys.symbol.star_fill'),
                onclick: () => {
                  // com.xiaobingkj.shark.coffee
                  const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
                  this.createPurchase(context)
                }
              })
            }
            .height(undefined)
            .width('100%')
          }
          .divider({
            strokeWidth: 1,
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level24'),
            endMargin: $r('sys.float.padding_level6')
          })
          .margin({ top: $r('sys.float.padding_level6') })
          .padding($r('sys.float.padding_level2'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        }
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .height('100%')
        .padding({
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8')
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }
      .width('100%')
      .height('100%')
      .padding({ top: 15 })
    }
    .title('设置')
  }

  createPurchase(context: common.UIAbilityContext) {
    if (!this.selectedProductId) {
      promptAction.showToast({ message: '请先选择一个产品' });
      return;
    }

    try {
      const createPurchaseParam: iap.PurchaseParameter = {
        productId: this.selectedProductId,
        productType: iap.ProductType.CONSUMABLE,
      }
      iap.createPurchase(context, createPurchaseParam).then((result) => {
        IAPLogger.info('PaywallView', 'Succeeded in creating purchase.');
        this.dealPurchaseData(result.purchaseData, iap.ProductType.CONSUMABLE);
      }).catch((err: BusinessError) => {
        IAPLogger.error('PaywallView', `Failed to create purchase. Code is ${err.code}, message is ${err.message}`);
        this.handlePurchaseError(err, context);
      })
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      IAPLogger.error('PaywallView', `Failed to create purchase. Code is ${e.code}, message is ${e.message}`);
      promptAction.showToast({ message: '购买失败，请稍后重试' });
    }
  }

  handlePurchaseError(err: BusinessError, context: common.UIAbilityContext) {
    let errorMessage = '';

    switch (err.code) {
      case iap.IAPErrorCode.USER_CANCELED:
        errorMessage = '您已取消购买';
        break;
      case iap.IAPErrorCode.SYSTEM_ERROR:
        errorMessage = '系统繁忙，请稍后重试';
        break;
      case iap.IAPErrorCode.APP_NOT_AUTHORIZED:
        errorMessage = '应用未授权，请联系客服';
        break;
      case iap.IAPErrorCode.INVALID_PRODUCT:
        errorMessage = '商品信息无效，请稍后重试';
        break;
      case iap.IAPErrorCode.FREQUENT_CALLS:
        errorMessage = '操作过于频繁，请稍后重试';
        break;
      case iap.IAPErrorCode.NETWORK_ERROR:
        errorMessage = '网络连接异常，请检查网络后重试';
        break;
      case iap.IAPErrorCode.PRODUCT_TERRITORY_NOT_SUPPORTED:
        errorMessage = '当前地区暂不支持购买';
        break;
      case iap.IAPErrorCode.ACCOUNT_NOT_LOGGED_IN:
        errorMessage = '请先登录华为账号';
        break;
      case iap.IAPErrorCode.PRODUCT_OWNED:
        errorMessage = '您已拥有该商品';
        break;
      case iap.IAPErrorCode.PURCHASE_NOT_PAID:
        errorMessage = '商品未购买成功';
        break;
      case iap.IAPErrorCode.PURCHASE_FINISHED:
        errorMessage = '该商品已完成购买';
        break;
      case iap.IAPErrorCode.ACCOUNT_TERRITORY_NOT_SUPPORTED:
        errorMessage = '您的账号所在地区暂不支持购买';
        break;
      case iap.IAPErrorCode.USER_NOT_ALLOWED:
        errorMessage = '交易被拒绝，请稍后重试或更换支付方式';
        break;
      case iap.IAPErrorCode.INVALID_PROMOTIONAL_OFFER:
        errorMessage = '优惠信息无效';
        break;
      case iap.IAPErrorCode.INVALID_PURCHASE_SIGNATURE:
        errorMessage = '签名验证失败，请稍后重试';
        break;
      case iap.IAPErrorCode.PURCHASE_ALREADY_REFUNDED:
        errorMessage = '该商品已退款或正在退款中';
        break;
      case iap.IAPErrorCode.REFUND_NOT_ALLOWED:
        errorMessage = '该商品不支持退款';
        break;
      default:
        errorMessage = `支付失败: ${err.message}`;
        break;
    }

    if (errorMessage) {
      promptAction.showToast({ message: errorMessage });
    }
  }

  dealPurchaseData(purchaseData: string, productType: iap.ProductType) {
    try {
      const data = JSON.parse(purchaseData) as PurchaseData;
      let productId = '';
      const jwsPurchaseOrder = data.jwsPurchaseOrder;
      if (!jwsPurchaseOrder) return;
      const purchaseOrderStr = JWSUtil.decodeJwsObj(jwsPurchaseOrder);
      const purchaseOrderPayload = JSON.parse(purchaseOrderStr) as PurchaseOrderPayload;
      if (purchaseOrderPayload) {
        promptAction.showToast({ message: '购买成功' });
      }
    } catch (e) {
      IAPLogger.error('PaywallView', 'dealPurchaseData json error');
    }
  }

  finishPurchase(purchaseOrder: PurchaseOrderPayload) {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const finishPurchaseParam: iap.FinishPurchaseParameter = {
      productType: Number(purchaseOrder.productType),
      purchaseToken: purchaseOrder.purchaseToken,
      purchaseOrderId: purchaseOrder.purchaseOrderId
    };
    iap.finishPurchase(context, finishPurchaseParam).then(() => {
      IAPLogger.info('PaywallView', 'Succeeded in finishing purchase.');
    }).catch((err: BusinessError) => {
      IAPLogger.error('PaywallView', `Failed to finish purchase. Code is ${err.code}, message is ${err.message}`);
    });
  }
}
