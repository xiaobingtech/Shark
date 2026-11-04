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
  private listScroller: ListScroller = new ListScroller()

  private selectServer(server: ServerInfo): void {
    this.serverBaseUrl = server.url
    this.deviceKey = server.key
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

  private deleteServer(server: ServerInfo): void {
    this.listScroller.closeAllSwipeActions()
    this.serverList = this.serverList.filter((item: ServerInfo) => item.url !== server.url)
    if (this.serverBaseUrl === server.url) {
      const nextServer: ServerInfo | undefined = this.serverList[0]
      this.serverBaseUrl = nextServer?.url ?? 'https://shark.xiaobingkj.com'
      this.deviceKey = nextServer?.key ?? ''
    }
    const data = preferences.getPreferencesSync(getContext(this), { name: 'shark.db' })
    data.putSync('serverList', JSON.stringify(this.serverList))
    data.putSync('serverBaseUrl', this.serverBaseUrl)
    data.putSync('deviceKey', this.deviceKey)
    data.flushSync()
  }

  private showDeleteConfirmDialog(server: ServerInfo): void {
    this.getUIContext().showAlertDialog({
      title: '删除服务器',
      message: `确定要删除服务器 ${server.url} 吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => this.listScroller.closeAllSwipeActions()
      },
      secondaryButton: {
        value: '删除',
        fontColor: Color.White,
        backgroundColor: Color.Red,
        action: () => this.deleteServer(server)
      },
      cancel: () => this.listScroller.closeAllSwipeActions()
    })
  }

  @Builder
  buildDeleteAction(server: ServerInfo) {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(20)
          .fontColor([Color.White])
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Red)
      .accessibilityText('删除服务器')
      .onClick(() => this.showDeleteConfirmDialog(server))
    }
    .width(56)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }

  build() {
    Column() {
      List({ scroller: this.listScroller }) {
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
            .swipeAction({
              end: {
                builder: () => this.buildDeleteAction(server)
              }
            })
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
