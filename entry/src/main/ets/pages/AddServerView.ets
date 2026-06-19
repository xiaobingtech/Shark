import { scanBarcode, scanCore } from '@kit.ScanKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { common, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { efRcpClientApi } from '@yunkss/ef_rcp'

const DOMAIN: number = 0x0000
const PREFERENCES_NAME: string = 'shark.db'
const SERVER_BASE_URL_KEY: string = 'serverBaseUrl'
const SERVER_LIST_KEY: string = 'serverList'
const DEVICE_KEY: string = 'deviceKey'

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

interface ServerInfo {
  url: string
  key: string
}

@Builder
export function AddServerViewBuilder(name: string, param: Object) {
  AddServerView()
}


@Preview
@Component
export struct AddServerView {
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @StorageLink(SERVER_BASE_URL_KEY) serverBaseUrl: string = 'https://shark.xiaobingkj.com'
  @StorageLink('deviceToken') deviceToken: string = ''
  @StorageLink(DEVICE_KEY) deviceKey: string = ''
  @StorageLink(SERVER_LIST_KEY) serverList: Array<ServerInfo> = []
  @State serverUrl: string = 'https://'

  private openTutorialUrl(): void {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: 'https://github.com/xiaobingtech/bark-server/blob/master/README.md',
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    }
    try {
      let context = getContext(this) as common.UIAbilityContext
      context.startAbility(want)
    } catch (err) {
      hilog.error(DOMAIN, 'AddServerView', 'Failed to open url: %{public}s', JSON.stringify(err))
    }
  }

  private buildMenuItems(): Array<NavigationMenuItem> {
    return [
      {
        value: '保存',
        symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
        action: () => {
          this.saveServerUrl()
        }
      }
    ]
  }

  private saveServerUrl(): void {
    let targetServerUrl = this.normalizeServerUrl(this.serverUrl)
    if (!this.isValidServerUrl(targetServerUrl)) {
      promptAction.showToast({
        message: '请输入正确的服务器地址'
      })
      return
    }
    this.registerAndSaveServer(targetServerUrl)
  }

  private async registerAndSaveServer(targetServerUrl: string): Promise<void> {
    let response = await efRcpClientApi.post<RegisterResponse>({
      baseURL: targetServerUrl,
      url: '/register',
      query: {
        'device_key': '',
        'device_token': this.deviceToken,
        'platform': 'harmony'
      }
    })

    if (response.error) {
      hilog.error(DOMAIN, 'AddServerView', 'Failed to register: %{public}s', response.error.message)
      promptAction.showToast({
        message: '注册失败: ' + response.error.message
      })
      return
    }

    let responseData = response.data?.data
    let key: string = ''
    if (responseData !== undefined) {
      if (responseData.device_key.length > 0) {
        key = responseData.device_key
      } else if (responseData.key.length > 0) {
        key = responseData.key
      }
    }

    this.serverUrl = targetServerUrl
    this.serverBaseUrl = targetServerUrl
    if (key.length > 0) {
      this.deviceKey = key
    }
    this.addToServerList(targetServerUrl, key)
    this.persistSelectedServer()

    promptAction.showToast({
      message: '保存成功'
    })
    this.navPathStack.pop()
  }

  private addToServerList(url: string, key: string): void {
    // 检查是否已存在
    let existingIndex = -1
    for (let i = 0; i < this.serverList.length; i++) {
      if (this.serverList[i].url === url) {
        existingIndex = i
        break
      }
    }

    // 创建新的服务器信息
    let serverInfo: ServerInfo = { url: url, key: key }

    if (existingIndex >= 0) {
      // 更新已存在的服务器
      let nextServerList = [...this.serverList]
      nextServerList[existingIndex] = serverInfo
      this.serverList = nextServerList
    } else {
      // 添加新服务器
      this.serverList = [...this.serverList, serverInfo]
    }

    // 持久化
    this.persistServerList()
  }

  private persistServerList(): void {
    let data = preferences.getPreferencesSync(getContext(this), { name: PREFERENCES_NAME })
    data.putSync(SERVER_LIST_KEY, JSON.stringify(this.serverList))
    data.flush()
  }

  private persistSelectedServer(): void {
    let data = preferences.getPreferencesSync(getContext(this), { name: PREFERENCES_NAME })
    data.putSync(SERVER_BASE_URL_KEY, this.serverBaseUrl)
    data.putSync(DEVICE_KEY, this.deviceKey)
    data.flush()
  }

  private normalizeServerUrl(url: string): string {
    let normalizedUrl = url.trim()
    while (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.slice(0, normalizedUrl.length - 1)
    }
    return normalizedUrl
  }

  private isValidServerUrl(url: string): boolean {
    if (url.length === 0 || url === 'https://' || url === 'http://') {
      return false
    }
    return url.startsWith('https://') || url.startsWith('http://')
  }

  private startScan(): void {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: false,
      enableAlbum: true
    }
    try {
      scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options).then((result: scanBarcode.ScanResult) => {
        let scanValue: string = result.originalValue
        if (scanValue.length > 0) {
          this.serverUrl = scanValue
        }
      }).catch((error: BusinessError) => {
        error
      })
    } catch (error) {
      error
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('服务器地址')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .margin({ bottom: $r('sys.float.padding_level2') })
        Row() {
          TextInput({ text: this.serverUrl, placeholder: '输入服务器地址，例如：https://shark.xiaobingkj.com' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .fontColor($r('sys.color.font_primary'))
            .onChange((value: string) => {
              this.serverUrl = value
            })
          SymbolGlyph($r('sys.symbol.qrcode'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon')])
            .onClick(() => {
              this.startScan()
            })
        }
        .width('100%')

        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth(1)

        Text('查看服务端部署教程')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_emphasize'))
          .margin({ top: $r('sys.float.padding_level6') })
          .onClick(() => {
            this.openTutorialUrl()
          })
      }
      .padding($r('sys.float.padding_level6'))
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .title('添加私有服务器')
    .menus(this.buildMenuItems())
    .onBackPressed(() => {
      this.navPathStack.pop()
      return true
    })
  }
}
