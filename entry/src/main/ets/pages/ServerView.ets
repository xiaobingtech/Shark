import { SymbolGlyphModifier } from '@kit.ArkUI'
import { AddServerView } from './AddServerView'

@Component
export struct ServerView {
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()

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

  build() {
    Navigation(this.navPathStack) {
      Column() {
        Button({ type: ButtonType.Circle }) {
          Text('注册设备')
            .fontColor($r('sys.color.font_emphasize'))
        }
        .width(160)
        .height(160)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .title('api.shark.app')
    .menus(this.buildMenuItems())
    .navDestination(this.pageMap)
  }
}
