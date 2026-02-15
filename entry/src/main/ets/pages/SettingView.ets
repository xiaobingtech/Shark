import { pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'
import { CommonConstants, ProcessUtil } from '@ohos/common'
import { CardItem } from '../common/CardItem'
import { CardRightItem } from '../common/CardRightItem'
import { CardToogleItem } from '../common/CardToogleItem'

const DEVICE_TOKEN_KEY: string = 'deviceToken'
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData'

class HistoryStoreData {
  titles: string[] = []
  bodies: string[] = []
  times: number[] = []
}

@Builder
export function SettingViewBuilder(name: string, param: Object) {
  SettingView()
}

@Preview
@Component
export struct SettingView {
  @State defaultSave: boolean = true;
  @Watch('onRefreshTickChange')
  @StorageLink('historyRefreshTick') refreshTick: number = 0
  @StorageLink(DEVICE_TOKEN_KEY) deviceToken: string = ''
  @StorageLink(HISTORY_DATA_VALUE_KEY) historyStoreData: HistoryStoreData = new HistoryStoreData()

  private getHistoryCount(): number {
    let titleCount: number = this.historyStoreData.titles.length
    let bodyCount: number = this.historyStoreData.bodies.length
    let timeCount: number = this.historyStoreData.times.length
    let minCount: number = titleCount
    if (bodyCount < minCount) {
      minCount = bodyCount
    }
    if (timeCount < minCount) {
      minCount = timeCount
    }
    return minCount
  }

  private copyDeviceToken(): void {
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.deviceToken)
    let systemPasteboard = pasteboard.getSystemPasteboard()
    systemPasteboard.setDataSync(pasteData)
    promptAction.showToast({ message: '复制成功' })
  }

  private openGithubRun(): void {
    let url: string = 'https://github.com/xiaobingtech/Shark/actions/runs/' + CommonConstants.GITHUB_RUN_ID
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true
      }
    }
    ProcessUtil.startAbility(context, want)
  }

  private onRefreshTickChange(): void {
    let latestData: HistoryStoreData | undefined =
      AppStorage.get<HistoryStoreData>(HISTORY_DATA_VALUE_KEY)
    if (latestData != undefined) {
      this.historyStoreData = latestData
    }
  }

  build() {
    Navigation() {
      Column({ space: 8 }) {
        List() {
          ListItem() {
            Text('历史消息')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level6') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: '导出/导入',
                rightText: this.getHistoryCount() + ' 条消息',
                symbolSrc: $r('sys.symbol.arrow_right_to_line')
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardToogleItem({
                isShow: false,
                textContent: '默认保存',
                symbolSrc: $r('sys.symbol.doc_text'),
                isOn: this.defaultSave,
                onChange: (value: boolean) => {
                  this.defaultSave = value
                }
              })
            }
            .height(undefined)
            .width('100%')
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

          ListItem() {
            Text('当推送请求URL没有指定 isArchive 参数时，将按照此设置来决定是否保存通知消息')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({
                top: $r('sys.float.padding_level4'),
              })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItem() {
            Text('信息')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level8') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: 'Device Token',
                rightText: this.deviceToken.length > 0 ? this.deviceToken : '未知',
                symbolSrc: $r('sys.symbol.envelope'),
                onclick: () => {
                  this.copyDeviceToken()
                }
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: 'Github Run Id',
                rightText: CommonConstants.GITHUB_RUN_ID,
                symbolSrc: $r('sys.symbol.doc_text_fill'),
                onclick: () => {
                  this.openGithubRun()
                }
              })
            }
            .height(undefined)
            .width('100%')
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

          ListItem() {
            Text('Bark 由 GitHub Actions 构建上传 App Store，此信息可帮助你确认当前版本是否由开源代码所构建，未经任何人（包含作者）修改')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({
                top: $r('sys.float.padding_level4'),
              })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItem() {
            Text('其他')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level8') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: '常见问题',
                symbolSrc: $r('sys.symbol.exclamationmark_circle')
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: '使用文档',
                symbolSrc: $r('sys.symbol.doc_text')
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: '开源代码',
                symbolSrc: $r('sys.symbol.communicationsharing')
              })
            }
            .height(undefined)
            .width('100%')
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

          ListItem() {
            Text('捐赠')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: $r('sys.float.padding_level8') })
          }
          .height(undefined)
          .width('100%')
          .align(Alignment.Start)

          ListItemGroup() {
            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: '一次性捐赠',
                rightText: '$2.69',
                symbolSrc: $r('sys.symbol.star_fill')
              })
            }
            .height(undefined)
            .width('100%')

            ListItem({ style: ListItemStyle.CARD }) {
              CardRightItem({
                isShow: false,
                textContent: '持续支持',
                rightText: '$2.69 / 1年',
                symbolSrc: $r('sys.symbol.star_fill')
              })
            }
            .height(undefined)
            .width('100%')
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
        .backgroundColor($r('sys.color.background_secondary'))
      }
      .width('100%')
      .height('100%')
      .padding({ top: 15 })
    }
    .title('设置')
  }
}
