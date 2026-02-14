import { SymbolGlyphModifier } from '@kit.ArkUI'

@Component
export struct ServerView {
  @State menuItems: Array<NavigationMenuItem> = [
    {
      value: 'server',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.cloud')),
      action: () => {}
    },
    {
      value: 'add',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
      action: () => {}
    }
  ]

  build() {
    Navigation() {
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
    .menus(this.menuItems)
  }
}
