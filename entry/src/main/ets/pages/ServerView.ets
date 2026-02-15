import { common, Want } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { promptAction, PromptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { pushService } from '@kit.PushKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AddServerView } from './AddServerView'

const DOMAIN: number = 0x0000
const PREFERENCES_NAME: string = 'shark.db'
const DEVICE_TOKEN_KEY: string = 'deviceToken'
const DEVICE_TOKEN_READY_KEY: string = 'hasDeviceToken'
const SERVER_BASE_URL: string = 'https://api.shark.app'

@Component
export struct ServerView {
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @StorageLink(DEVICE_TOKEN_KEY) deviceToken: string = ''
  @StorageLink(DEVICE_TOKEN_READY_KEY) hasDeviceToken: boolean = false
  @State pushTitle: string = '推送标题'
  @State pushBody: string = '这里改成你自己的推送内容'

  @Builder
  pageMap(name: string) {
    if (name === 'AddServerView') {
      AddServerView()
    }
  }

  private buildMenuItems(): Array<NavigationMenuItem> {
    return [
      {
        value: 'server',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.cloud')),
        action: () => {
        }
      },
      {
        value: 'add',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
        action: () => {
          this.navPathStack.pushPath({ name: 'AddServerView' })
        }
      }
    ]
  }

  private persistDeviceToken(token: string, hasToken: boolean): void {
    let data = preferences.getPreferencesSync(getContext(this), { name: PREFERENCES_NAME })
    data.putSync(DEVICE_TOKEN_KEY, token)
    data.putSync(DEVICE_TOKEN_READY_KEY, hasToken)
    data.flush()
  }

  private registerDevice(): void {
    pushService.getToken().then((token: string) => {
      let hasToken: boolean = token.length > 0
      this.deviceToken = token
      this.hasDeviceToken = hasToken
      this.persistDeviceToken(token, hasToken)
      hilog.info(DOMAIN, 'ServerView', 'Succeeded in getting push token')
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'ServerView', 'Failed to get push token: %{public}d %{public}s', err.code, err.message)
    })
  }

  private buildPushUrl(): string {
    let title: string = encodeURIComponent(this.pushTitle)
    let body: string = encodeURIComponent(this.pushBody)
    return `${SERVER_BASE_URL}/${this.deviceToken}/${title}/${body}`
  }

  private copyPushUrl(): void {
    let url: string = this.buildPushUrl()
    let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url)
    let systemPasteboard = pasteboard.getSystemPasteboard()
    systemPasteboard.setData(data).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'ServerView', 'Failed to copy url: %{public}d %{public}s', err.code, err.message)
    })
    promptAction.showToast({
      message: "复制成功"
    })
  }

  private openPushUrl(): void {
    let url: string = this.buildPushUrl()
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    }
    try {
      let context = getContext(this) as common.UIAbilityContext
      context.startAbility(want)
    } catch (err) {
      hilog.error(DOMAIN, 'ServerView', 'Failed to open url: %{public}s', JSON.stringify(err))
    }
  }

  build() {
    Navigation(this.navPathStack) {
      if (this.hasDeviceToken) {
        Grid() {
          GridItem() {
            Column({ space: 10 }) {
              Row() {
                Column({ space: 5 }) {
                  Text(this.pushTitle)
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  Text(this.pushBody)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_secondary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Row({ space: 15 }) {
                  SymbolGlyph($r('sys.symbol.rectangle_on_rectangle'))
                    .fontSize($r('sys.float.Title_M'))
                    .fontColor([$r('sys.color.icon_secondary')])
                  .onClick(() => {
                    this.copyPushUrl()
                  })
                  SymbolGlyph($r('sys.symbol.forward_end_fill'))
                    .fontSize($r('sys.float.Title_M'))
                    .fontColor([$r('sys.color.icon_secondary')])
                  .onClick(() => {
                    this.openPushUrl()
                  })
                }
              }
              Text(this.buildPushUrl())
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_primary'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('推送标题的字号比推送内容粗一点')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding($r('sys.float.padding_level8'))
            .width('100%')
            .height(undefined)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius($r('sys.float.corner_radius_level8'))
          }
          .borderRadius($r('sys.float.corner_radius_level8'))
          .clip(true)
        }
        .columnsTemplate('1fr')
        .rowsTemplate('1fr')
        .padding($r('sys.float.padding_level8'))
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.background_secondary'))
      } else {
        Column() {
          Button({ type: ButtonType.Circle, buttonStyle: ButtonStyleMode.NORMAL }) {
            Text('注册设备')
              .fontColor($r('sys.color.font_emphasize'))
          }
          .width(160)
          .height(160)
          .onClick(() => {
            this.registerDevice()
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }
    .title('api.shark.app')
    .menus(this.buildMenuItems())
    .navDestination(this.pageMap)
  }
}
