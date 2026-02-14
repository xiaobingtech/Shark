import { SymbolGlyphModifier } from '@kit.ArkUI'
import { HistoryView } from './HistoryView'
import { ServerView } from './ServerView'
import { SettingView } from './SettingView'

@Preview
@Entry
@Component
struct TabPage {
  @State symbolModifier1: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.cloud'))
  @State symbolModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.clock'))
  @State symbolModifier3: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.gearshape'))

  build() {
    Tabs({
      barPosition: BarPosition.End
    }) {
      TabContent() {
        ServerView()
      }.tabBar(new BottomTabBarStyle({
        normal: this.symbolModifier1
      }, '服务器'))

      TabContent() {
        HistoryView()
      }.tabBar(new BottomTabBarStyle({
        normal: this.symbolModifier2
      }, '历史消息'))

      TabContent() {
        SettingView()
      }.tabBar(new BottomTabBarStyle({
        normal: this.symbolModifier3
      }, '设置'))
    }
    .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK,
      { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
    .vertical(false)
    .scrollable(false)
    .barMode(BarMode.Fixed)
    .barWidth('100%')
    .barHeight('auto')
    .width('100%')
    .height('100%')
  }
}
