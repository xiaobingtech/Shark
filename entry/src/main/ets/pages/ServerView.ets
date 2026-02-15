import { common, Want } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { promptAction, PromptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { pushService } from '@kit.PushKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { AddServerView } from './AddServerView'
import { SoundView } from './SoundView'
import { notificationManager } from '@kit.NotificationKit'

const DOMAIN: number = 0x0000
const PREFERENCES_NAME: string = 'shark.db'
const DEVICE_TOKEN_KEY: string = 'deviceToken'
const DEVICE_TOKEN_READY_KEY: string = 'hasDeviceToken'
const DEVICE_KEY: string = 'deviceKey'
const SERVER_BASE_URL: string = 'http://192.168.6.7:8080'

interface RegisterResponseData {
  key: string
  device_key: string
  device_token: string
}

interface RegisterResponse {
  code: number
  message: string
  data: RegisterResponseData
}

@Component
export struct ServerView {
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink(DEVICE_TOKEN_KEY) deviceToken: string = ''
  @StorageLink(DEVICE_TOKEN_READY_KEY) hasDeviceToken: boolean = false
  @StorageLink(DEVICE_KEY) deviceKey: string = ''
  @State pushTitle: string = '推送标题'
  @State pushSoundTitle: string = '推送铃声'
  @State pushBody: string = '这里改成你自己的推送内容'

  @Builder
  pageMap(name: string) {
    if (name === 'AddServerView') {
      AddServerView()
    }
    if (name === 'SoundView') {
      SoundView()
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
          this.tabBarHidden = true
          this.navPathStack.pushPath({ name: 'AddServerView' })
        }
      }
    ]
  }

  private persistDeviceInfo(token: string, hasToken: boolean, deviceKey: string): void {
    let data = preferences.getPreferencesSync(getContext(this), { name: PREFERENCES_NAME })
    data.putSync(DEVICE_TOKEN_KEY, token)
    data.putSync(DEVICE_TOKEN_READY_KEY, hasToken)
    data.putSync(DEVICE_KEY, deviceKey)
    data.flush()
  }

  private registerDevice(): void {
    notificationManager.requestEnableNotification().then(() => {
      hilog.info(0x0000, 'testTag', '%{public}s', `requestEnableNotification success`);
      pushService.getToken().then((token: string) => {
        let hasToken: boolean = token.length > 0
        this.deviceToken = token
        this.hasDeviceToken = hasToken
        this.persistDeviceInfo(token, hasToken, this.deviceKey)
        this.registerDeviceOnServer(token)
        hilog.info(DOMAIN, 'ServerView', 'Succeeded in getting push token')
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'ServerView', 'Failed to get push token: %{public}d %{public}s', err.code, err.message)
      })
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', '%{public}s', `requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  private async registerDeviceOnServer(token: string): Promise<void> {
    let response = await efRcpClientApi.post<RegisterResponse>({
      url: '/register',
      query: {
        'device_key': this.deviceKey,
        'device_token': token,
        'platform': 'harmony'
      }
    })
    if (response.error) {
      hilog.error(DOMAIN, 'ServerView', 'Failed to register device: %{public}s', response.error.message)
      return
    }
    let responseData = response.data?.data
    if (responseData === undefined) {
      return
    }
    let newKey: string = ''
    if (responseData.device_key.length > 0) {
      newKey = responseData.device_key
    } else if (responseData.key.length > 0) {
      newKey = responseData.key
    }
    if (newKey.length > 0) {
      this.deviceKey = newKey
      this.persistDeviceInfo(this.deviceToken, this.hasDeviceToken, newKey)
    }
  }

  private buildPushUrlDisplay(): string {
    let key = this.deviceKey.length > 0 ? this.deviceKey : 'Your Key'
    let url = `${SERVER_BASE_URL}/${key}`
    if (this.pushTitle.length > 0) {
      url = `${url}/${this.pushTitle}`
    }
    if (this.pushBody.length > 0) {
      url = `${url}/${this.pushBody}`
    }
    return url
  }

  private buildPushUrlEncoded(): string {
    let key = this.deviceKey.length > 0 ? this.deviceKey : 'Your Key'
    let url = `${SERVER_BASE_URL}/${key}`
    if (this.pushTitle.length > 0) {
      url = `${url}/${encodeURIComponent(this.pushTitle)}`
    }
    if (this.pushBody.length > 0) {
      url = `${url}/${encodeURIComponent(this.pushBody)}`
    }
    return url
  }

  private buildSoundUrlDisplay(): string {
    let key = this.deviceKey.length > 0 ? this.deviceKey : 'Your Key'
    let url = `${SERVER_BASE_URL}/${key}`
    if (this.pushSoundTitle.length > 0) {
      url = `${url}/${this.pushSoundTitle}`
    }
    if (this.pushBody.length > 0) {
      url = `${url}/${this.pushBody}`
    }
    url = `${url}?sound=minuet`
    return url
  }

  private buildSoundUrlEncoded(): string {
    let key = this.deviceKey.length > 0 ? this.deviceKey : 'Your Key'
    let url = `${SERVER_BASE_URL}/${key}`
    if (this.pushSoundTitle.length > 0) {
      url = `${url}/${encodeURIComponent(this.pushSoundTitle)}`
    }
    if (this.pushBody.length > 0) {
      url = `${url}/${encodeURIComponent(this.pushBody)}`
    }
    url = `${url}?sound=minuet`
    return url
  }

  private copyUrl(url: string): void {
    let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url)
    let systemPasteboard = pasteboard.getSystemPasteboard()
    systemPasteboard.setData(data).catch((err: BusinessError) => {
      hilog.error(DOMAIN, 'ServerView', 'Failed to copy url: %{public}d %{public}s', err.code, err.message)
    })
    promptAction.showToast({
      message: "复制成功"
    })
  }

  private openUrl(url: string): void {
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

  aboutToAppear(): void {
    if (this.hasDeviceToken) {
      let enabled = notificationManager.isNotificationEnabledSync()
      if (!enabled){
        notificationManager.requestEnableNotification().then(() => {
          hilog.info(0x0000, 'testTag', '%{public}s', `requestEnableNotification success`);
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, 'testTag', '%{public}s', `requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
        });
      }
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
                    this.copyUrl(this.buildPushUrlDisplay())
                  })
                  SymbolGlyph($r('sys.symbol.forward_end_fill'))
                    .fontSize($r('sys.float.Title_M'))
                    .fontColor([$r('sys.color.icon_secondary')])
                  .onClick(() => {
                    this.openUrl(this.buildPushUrlEncoded())
                  })
                }
              }
              Text(this.buildPushUrlDisplay())
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
          GridItem() {
            Column({ space: 10 }) {
              Row() {
                Column({ space: 5 }) {
                  Text('推送铃声')
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Row({ space: 15 }) {
                  SymbolGlyph($r('sys.symbol.rectangle_on_rectangle'))
                    .fontSize($r('sys.float.Title_M'))
                    .fontColor([$r('sys.color.icon_secondary')])
                  .onClick(() => {
                    this.copyUrl(this.buildSoundUrlDisplay())
                  })
                  SymbolGlyph($r('sys.symbol.forward_end_fill'))
                    .fontSize($r('sys.float.Title_M'))
                    .fontColor([$r('sys.color.icon_secondary')])
                  .onClick(() => {
                    this.openUrl(this.buildSoundUrlEncoded())
                  })
                }
              }
              Text(this.buildSoundUrlDisplay())
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_primary'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Row() {
                Text('可以为推送设置不同的铃声')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_secondary'))
                Blank()
                Text('查看所有铃声')
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_emphasize'))
                  .onClick(() => {
                    this.tabBarHidden = true
                    this.navPathStack.pushPath({ name: 'SoundView' })
                  })
              }
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
        .rowsGap($r('sys.float.padding_level8'))
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
    .title('http://192.168.6.7:8080')
    .menus(this.buildMenuItems())
    .navDestination(this.pageMap)
  }
}
