import { SymbolGlyphModifier } from '@kit.ArkUI'
import { HistoryView } from './HistoryView'
import { ServerView } from './ServerView'
import { SettingView } from './SettingView'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { privacyManager } from '@kit.StoreKit'
import { common } from '@kit.AbilityKit'
import { hdsMaterial, HdsTabs } from '@kit.UIDesignKit'
import { isApi23OrHigher, isSdkApi23OrHigher } from '../common/utils/ApiVersionUtil'
import { BusinessError } from '@kit.BasicServicesKit'

@Preview
@Entry
@Component
struct TabPage {
  @StorageLink('tabIndex') tabSelectIndex: number = 0
  @StorageProp('currentBreakpoint') currentBreakpoint: string = ''
  @State symbolModifier1: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.cloud_fill'))
  @State symbolModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.clock_fill'))
  @State symbolModifier3: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.gearshape_fill'))

  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()

  private shouldUseHdsTabs(): boolean {
    return isApi23OrHigher()
  }

  private bottomLayoutSafeAreaTypes(): Array<LayoutSafeAreaType> {
    return isSdkApi23OrHigher() ? [LayoutSafeAreaType.SYSTEM] : []
  }

  private bottomLayoutSafeAreaEdges(): Array<LayoutSafeAreaEdge> {
    return isSdkApi23OrHigher() ? [LayoutSafeAreaEdge.BOTTOM] : []
  }

  private handleTabChange(index: number): void {
    this.tabSelectIndex = index
    if (index == 1 || index == 2) {
      AppStorage.setOrCreate('historyRefreshTick', Date.now())
    }
  }

  @Builder
  TabletTabsBar() {
    if (this.shouldUseHdsTabs()) {
      HdsTabs({
        barPosition: BarPosition.Start
      }) {
        TabContent() {
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier1
        }, '服务器'))

        TabContent() {
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier2
        }, '历史消息'))

        TabContent() {
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier3
        }, '设置'))
      }
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK,
        { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .vertical(true)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barWidth(96)
      .barHeight('100%')
      .tabIndex(this.tabSelectIndex)
      .onChange((index: number) => {
        this.handleTabChange(index)
      })
      .width(96)
      .height('100%')
      .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
    } else {
      Tabs({
        barPosition: BarPosition.Start
      }) {
        TabContent() {
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier1
        }, '服务器'))

        TabContent() {
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier2
        }, '历史消息'))

        TabContent() {
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier3
        }, '设置'))
      }
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK,
        { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .vertical(true)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barWidth(96)
      .barHeight('100%')
      .tabIndex(this.tabSelectIndex)
      .onChange((index: number) => {
        this.handleTabChange(index)
      })
      .width(96)
      .height('100%')
      .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
    }
  }

  @Builder
  PhoneTabsBar() {
    if (this.shouldUseHdsTabs()) {
      HdsTabs({
        barPosition: BarPosition.End
      }) {
        TabContent() {
          ServerView()
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier1
        }, '服务器'))
          .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())

        TabContent() {
          HistoryView()
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier2
        }, '历史消息'))
          .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())

        TabContent() {
          SettingView()
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier3
        }, '设置'))
          .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
      }
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK,
        { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .vertical(false)
      .scrollable(false)
      .barOverlap(true)
      .barFloatingStyle({
        barWidth: { smallWidth: 250, mediumWidth: 350, largeWidth: 450 },
        barBottomMargin: 28,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      })
      .tabIndex(this.tabSelectIndex)
      .onChange((index: number) => {
        this.handleTabChange(index)
      })
      .width('100%')
      .height('100%')
      .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
    } else {
      Tabs({
        barPosition: BarPosition.End
      }) {
        TabContent() {
          ServerView()
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier1
        }, '服务器'))
          .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())

        TabContent() {
          HistoryView()
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier2
        }, '历史消息'))
          .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())

        TabContent() {
          SettingView()
        }.tabBar(new BottomTabBarStyle({
          normal: this.symbolModifier3
        }, '设置'))
          .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
      }
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK,
        { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .vertical(false)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight('auto')
      .tabIndex(this.tabSelectIndex)
      .onChange((index: number) => {
        this.handleTabChange(index)
      })
      .width('100%')
      .height('100%')
      .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
    }
  }

  aboutToAppear() {
    try {
      let appPrivacyResults: privacyManager.AppPrivacyResult[] = privacyManager.getAppPrivacyResult();
      hilog.info(0, 'TAG', "Succeeded in getting AppPrivacyResult size = " + appPrivacyResults.length);
      for (let i = 0; i < appPrivacyResults.length; i++) {
        hilog.info(0, 'TAG', "Succeeded in getting AppPrivacyResult type = " + appPrivacyResults[i]["type"] + ", version = " + appPrivacyResults[i]["versionCode"] + ", result = "+appPrivacyResults[i]["result"]);
      }
      if (appPrivacyResults.length != 0 && appPrivacyResults[0].result == 1) {
        //do nothing
      }else{
        const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
        privacyManager.requestAppPrivacyConsent(uiContext).then((consentResult : privacyManager.ConsentResult) => {
          let appPrivacyResults: privacyManager.AppPrivacyResult[] = consentResult["results"];
          for (let i = 0; i < appPrivacyResults.length; i++) {
            hilog.info(0, 'TAG', "GetAppPrivacyResult type = " + appPrivacyResults[i]["type"] + ", version = " + appPrivacyResults[i]["versionCode"] + ", result = " + appPrivacyResults[i]["result"] + ", signingTimeStamp = " + appPrivacyResults[i]["signingTimeStamp"]);
          }
        }).catch((error: BusinessError<Object>) => {
          hilog.error(0, 'TAG', `requestAppPrivacyConsent failed, Code: ${error.code}, message: ${error.message}`);
        });
      }
    } catch (error) {
      hilog.error(0, 'TAG', "GetAppPrivacyResultPublic exception code: " + error.code + ", exception message: " + error.message);
    }
  }

  build() {
    if (this.currentBreakpoint === 'lg') {
      Row() {
        this.TabletTabsBar()
        Navigation(this.navPathStack) {
          if (this.tabSelectIndex === 0) {
            ServerView()
          } else if (this.tabSelectIndex === 1) {
            HistoryView()
          } else if (this.tabSelectIndex === 2) {
            SettingView()
          }
        }
        .hideTitleBar(true)
        .mode(NavigationMode.Stack)
        .layoutWeight(1)
        .height('100%')
        .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
      }
      .width('100%')
      .height('100%')
      .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
    } else {
      Navigation(this.navPathStack){
        this.PhoneTabsBar()
      }
      .hideTitleBar(true)
      .width('100%')
      .height('100%')
      .ignoreLayoutSafeArea(this.bottomLayoutSafeAreaTypes(), this.bottomLayoutSafeAreaEdges())
    }
  }
}
