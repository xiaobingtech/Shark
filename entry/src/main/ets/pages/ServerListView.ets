import { SymbolGlyphModifier } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { CardServerItem } from '../common/CardServerItem'

interface ServerInfo {
  url: string
  key: string
}

@Preview
@Component
export struct ServerListView {
  @StorageLink('serverBaseUrl') serverBaseUrl: string = 'https://shark.xiaobingkj.com'
  @StorageLink('deviceKey') deviceKey: string = ''
  @StorageLink('serverList') serverList: Array<ServerInfo> = []
  @StorageLink('isServerListVisible') isServerListVisible: boolean = false

  private selectServer(server: ServerInfo): void {
    this.serverBaseUrl = server.url
    if (server.key.length > 0) {
      this.deviceKey = server.key
    }
    this.isServerListVisible = false
    // 持久化选中的服务器
    this.persistSelectedServer()
  }

  private persistSelectedServer(): void {
    let data = preferences.getPreferencesSync(getContext(this), { name: 'shark.db' })
    data.putSync('serverBaseUrl', this.serverBaseUrl)
    data.putSync('deviceKey', this.deviceKey)
    data.flush()
  }

  build() {
    Column() {
      List() {
        ListItemGroup() {
          ForEach(this.serverList, (server: ServerInfo) => {
            ListItem({ style: ListItemStyle.CARD }) {
              CardServerItem({
                titleText: server.url,
                subtitleText: server.key.length > 0 ? server.key : '未注册',
                symbolSrc: $r('sys.symbol.service'),
                showCheckmark: server.url === this.serverBaseUrl,
                onclick: () => {
                  this.selectServer(server)
                }
              })
            }
            .height(undefined)
            .width('100%')
          }, (server: ServerInfo) => server.url)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function ServerListViewBuilder() {
  ServerListView()
}
