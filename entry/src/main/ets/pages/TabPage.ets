import { SymbolGlyphModifier } from '@kit.ArkUI'
import { HistoryView } from './HistoryView'
import { ServerView } from './ServerView'
import { SettingView } from './SettingView'

@Preview
@Entry
@Component
struct TabPage {
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('tabIndex') tabSelectIndex: number = 0
  @State symbolModifier1: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.cloud_fill'))
  @State symbolModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.clock_fill'))
  @State symbolModifier3: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.gearshape_fill'))

  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.navPathStack){
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
      .barHeight(this.tabBarHidden ? 0 : 'auto')
      .tabIndex(this.tabSelectIndex)
      .onChange((index: number) => {
        this.tabSelectIndex = index
        if (index == 1 || index == 2) {
          AppStorage.setOrCreate('historyRefreshTick', Date.now())
        }
      })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}
