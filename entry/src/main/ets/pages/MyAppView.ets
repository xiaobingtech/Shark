import { common } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { Want } from '@kit.AbilityKit';

const HARMONY_APPS_URL = 'https://raw.gitcode.com/xiaobingkj/json/raw/main/harmony_apps.json';
const TAG = 'MyAppView';

interface HarmonyAppItem {
  appIcon: string;
  appName: string;
  appDesc: string;
  bundleId: string;
  appUrl: string;
}

// Deep Linking 方式拉起应用市场详情页
function startAppGalleryDetailAbility(context: common.UIAbilityContext, bundleId: string): void {
  const want: Want = {
    action: 'ohos.want.action.appdetail',
    uri: 'store://appgallery.huawei.com/app/detail?id=' + bundleId
  };
  context.startAbility(want).then(() => {
    hilog.info(0x0001, TAG, 'Succeeded in starting app detail.');
  }).catch((error: BusinessError) => {
    hilog.error(0x0001, TAG, `Failed to startAbility. Code: ${error.code}, message: ${error.message}`);
  });
}

@Builder
export function MyAppViewBuilder(name: string, param: Object) {
  MyAppView()
}

@Entry
@Component
struct MyAppView {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @StorageLink('navPathStack') pathStack: NavPathStack = new NavPathStack();

  @State appList: HarmonyAppItem[] = [];
  @State isLoading: boolean = true;
  @State loadError: string = '';

  aboutToAppear(): void {
    this.fetchApps();
  }

  private async fetchApps(): Promise<void> {
    this.isLoading = true;
    this.loadError = '';
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(HARMONY_APPS_URL, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000,
        header: { 'Content-Type': 'application/json' }
      });
      httpRequest.destroy();
      if (response.responseCode === 200 && response.result) {
        const data = typeof response.result === 'string' ? response.result : JSON.stringify(response.result);
        let appList = JSON.parse(data) as HarmonyAppItem[];
        this.appList = appList.filter(item => item.bundleId != "com.xiaobingkj.shark")
      } else {
        this.loadError = '加载失败';
      }
    } catch (err) {
      httpRequest.destroy();
      const error = err as BusinessError;
      hilog.error(0x0001, TAG, `fetchApps failed: ${error.code}, ${error.message}`);
      this.loadError = '网络请求失败';
    } finally {
      this.isLoading = false;
    }
  }

  private openAppMarket(item: HarmonyAppItem): void {
    startAppGalleryDetailAbility(this.context, item.bundleId);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
            Text('加载中...')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.loadError) {
          Column() {
            Text(this.loadError)
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
            Button('重试')
              .margin({ top: 12 })
              .onClick(() => {
                this.fetchApps();
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.appList.length === 0) {
          Column() {
            Text('暂无推荐应用')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.appList, (item: HarmonyAppItem, index: number) => {
              ListItem() {
                Row() {
                  // appIcon 圆角矩形，类似应用市场
                  Image(item.appIcon)
                    .width(44)
                    .height(44)
                    // .borderRadius(12)
                    .objectFit(ImageFit.Cover)

                  // appName 和 appDesc
                  Column({ space: 4 }) {
                    Text(item.appName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.appDesc)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 16 })

                  // 下载/打开按钮
                  Button($r('app.string.myapp_open'))
                    .buttonStyle(ButtonStyleMode.NORMAL)
                    .fontSize(14)
                    .height(30)
                    .padding({ left: 16, right: 16 })
                    .onClick(() => {
                      this.openAppMarket(item);
                    })
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              }
              .onClick(() => {
                this.openAppMarket(item);
              })
            }, (item: HarmonyAppItem) => item.bundleId)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .divider({
            strokeWidth: 0.5,
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level24'),
            endMargin: $r('sys.float.padding_level6')
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title($r('app.string.setting_more_apps'))
    .hideBackButton(false)
    .onBackPressed(() => {
      this.pathStack.pop()
      return true
    })
  }
}
