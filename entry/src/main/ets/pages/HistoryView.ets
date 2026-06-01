import { distributedDataObject } from '@kit.ArkData'
import { getPhoneHdsTabsContentEndOffset } from '../common/utils/ApiVersionUtil'

const HISTORY_DATA_KEY: string = 'historyDataObject'
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData'

class HistoryStoreData {
  titles: Array<string> = []
  bodies: Array<string> = []
  times: Array<number> = []
  images: Array<string> = []
  styles: Array<number> = []
  inboxContents: Array<Array<string>> = []
}

class HistoryMessage {
  id: string
  title: string
  body: string
  time: number
  image: string
  style: number
  inboxContents: Array<string>

  constructor(id: string, title: string, body: string, time: number, image: string, style: number,
    inboxContents: Array<string>) {
    this.id = id
    this.title = title
    this.body = body
    this.time = time
    this.image = image
    this.style = style
    this.inboxContents = inboxContents
  }
}

@Component
export struct HistoryView {
  @State messages: Array<HistoryMessage> = []
  @StorageProp('currentBreakpoint') currentBreakpoint: string = ''
  @Watch('onRefreshTickChange')
  @StorageLink('historyRefreshTick') refreshTick: number = 0
  private historyDataObject: distributedDataObject.DataObject | null = null
  private historyStoreData: HistoryStoreData | null = null
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  private listScroller: ListScroller = new ListScroller()
  private dataChangeCallback: distributedDataObject.DataObserver =
    (sessionId: string, fields: Array<string>) => {
      this.loadMessages()
    }

  aboutToAppear(): void {
    this.bindHistoryDataObject()
    this.loadMessages()
  }

  aboutToDisappear(): void {
    if (this.historyDataObject != null) {
      this.historyDataObject.off('change', this.dataChangeCallback)
    }
  }

  private bindHistoryDataObject(): void {
    let existingDataObject: distributedDataObject.DataObject | undefined =
      AppStorage.get<distributedDataObject.DataObject>(HISTORY_DATA_KEY)
    let existingData: HistoryStoreData | undefined =
      AppStorage.get<HistoryStoreData>(HISTORY_DATA_VALUE_KEY)
    if (existingDataObject != undefined && existingData != undefined) {
      this.historyDataObject = existingDataObject
      this.historyStoreData = existingData
      this.historyDataObject.on('change', this.dataChangeCallback)
    }
  }

  private loadMessages(): void {
    let latestData: HistoryStoreData | undefined =
      AppStorage.get<HistoryStoreData>(HISTORY_DATA_VALUE_KEY)
    if (latestData != undefined) {
      this.historyStoreData = latestData
    }
    if (this.historyStoreData == null) {
      this.messages = []
      return
    }
    let data: HistoryStoreData = this.historyStoreData
    let titles = data.titles
    let bodies = data.bodies
    let times = data.times
    let images = this.getHistoryImages(data)
    let styles = this.getHistoryStyles(data)
    let inboxContents = this.getHistoryInboxContents(data)
    let count: number = titles.length
    if (bodies.length < count) {
      count = bodies.length
    }
    if (times.length < count) {
      count = times.length
    }
    let list: Array<HistoryMessage> = []
    for (let i = 0; i < count; i++) {
      let id = `${times[i]}_${i}`
      let image: string = ''
      if (i < images.length) {
        image = images[i]
      }
      let style: number = 0
      if (i < styles.length) {
        style = styles[i]
      }
      let inboxContent: Array<string> = []
      if (i < inboxContents.length) {
        inboxContent = inboxContents[i]
      }
      list.push(new HistoryMessage(id, titles[i], bodies[i], times[i], image, style, inboxContent))
    }
    list.sort((left: HistoryMessage, right: HistoryMessage) => {
      return right.time - left.time
    })
    this.messages = list
  }

  private getHistoryImages(data: HistoryStoreData): Array<string> {
    let images: Array<string> = []
    if (data.images == undefined) {
      images = []
    } else {
      images = data.images
    }
    while (images.length < data.titles.length) {
      images.push('')
    }
    return images
  }

  private getHistoryStyles(data: HistoryStoreData): Array<number> {
    let styles: Array<number> = []
    if (data.styles == undefined) {
      styles = []
    } else {
      styles = data.styles
    }
    while (styles.length < data.titles.length) {
      styles.push(0)
    }
    return styles
  }

  private getHistoryInboxContents(data: HistoryStoreData): Array<Array<string>> {
    let inboxContents: Array<Array<string>> = []
    if (data.inboxContents == undefined) {
      inboxContents = []
    } else {
      inboxContents = data.inboxContents
    }
    while (inboxContents.length < data.titles.length) {
      inboxContents.push([])
    }
    return inboxContents
  }

  private onRefreshTickChange(): void {
    this.loadMessages()
  }

  private formatNumber(value: number): string {
    if (value < 10) {
      return `0${value}`
    }
    return value.toString()
  }

  private formatTime(timestamp: number): string {
    let date = new Date(timestamp)
    let year = date.getFullYear()
    let month = this.formatNumber(date.getMonth() + 1)
    let day = this.formatNumber(date.getDate())
    let hour = this.formatNumber(date.getHours())
    let minute = this.formatNumber(date.getMinutes())
    return `${year}-${month}-${day} ${hour}:${minute}`
  }

  private deleteMessage(item: HistoryMessage): void {
    if (this.historyStoreData == null) {
      return
    }
    let index = -1
    for (let i = 0; i < this.historyStoreData.titles.length; i++) {
      if (this.historyStoreData.titles[i] === item.title &&
        this.historyStoreData.bodies[i] === item.body &&
        this.historyStoreData.times[i] === item.time) {
        index = i
        break
      }
    }
    if (index >= 0) {
      this.historyStoreData.titles.splice(index, 1)
      this.historyStoreData.bodies.splice(index, 1)
      this.historyStoreData.times.splice(index, 1)
      let images = this.getHistoryImages(this.historyStoreData)
      if (index < images.length) {
        images.splice(index, 1)
        this.historyStoreData.images = images
      }
      let styles = this.getHistoryStyles(this.historyStoreData)
      if (index < styles.length) {
        styles.splice(index, 1)
        this.historyStoreData.styles = styles
      }
      let inboxContents = this.getHistoryInboxContents(this.historyStoreData)
      if (index < inboxContents.length) {
        inboxContents.splice(index, 1)
        this.historyStoreData.inboxContents = inboxContents
      }
      AppStorage.setOrCreate<HistoryStoreData>(HISTORY_DATA_VALUE_KEY, this.historyStoreData)
    }
    let updated: Array<HistoryMessage> = []
    for (let i = 0; i < this.messages.length; i++) {
      if (this.messages[i].id !== item.id) {
        updated.push(this.messages[i])
      }
    }
    this.messages = updated
  }

  private showDeleteConfirmDialog(item: HistoryMessage): void {
    this.getUIContext().showAlertDialog({
      title: '删除确认',
      message: '确定要删除这条历史消息吗？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
          this.listScroller.closeAllSwipeActions()
        }
      },
      secondaryButton: {
        enabled: true,
        defaultFocus: true,
        value: '删除',
        fontColor: Color.White,
        backgroundColor: Color.Red,
        action: () => {
          this.deleteMessage(item)
        }
      },
      cancel: () => {
        this.listScroller.closeAllSwipeActions()
      }
    })
  }

  @Builder
  buildDeleteAction(item: HistoryMessage) {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(20)
          .fontColor([Color.White])
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .effectStrategy(SymbolEffectStrategy.SCALE)
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Red)
      .onClick(() => {
        this.showDeleteConfirmDialog(item)
      })
    }
    .width(56)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }

  build() {
    Navigation() {
      List({ scroller: this.listScroller, space: 10}) {
        ForEach(this.messages, (item: HistoryMessage) => {
          ListItem() {
            Column({ space: 6 }) {
              Row() {
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  if (item.style == 3 && item.inboxContents.length > 0) {
                    ForEach(item.inboxContents, (line: string) => {
                      Text(line)
                        .fontSize($r('sys.float.Body_M'))
                        .fontColor($r('sys.color.font_secondary'))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }, (line: string, index: number) => `${item.id}_inbox_${index}`)
                  } else {
                    Text(item.body)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_secondary'))
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                if (item.image.length > 0) {
                  Image(item.image)
                    .width(44)
                    .height(44)
                    .objectFit(ImageFit.Cover)
                    .borderRadius($r('sys.float.corner_radius_level4'))
                    .margin({ left: 10 })
                }
              }
              .alignItems(VerticalAlign.Top)
              Text(this.formatTime(item.time))
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding($r('sys.float.padding_level8'))
            .width('100%')
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius($r('sys.float.corner_radius_level8'))
          }
          .borderRadius($r('sys.float.corner_radius_level8'))
          .clip(true)
          .swipeAction({
            end: {
              builder: () => {
                this.buildDeleteAction(item)
              },
              onAction: () => {
                this.showDeleteConfirmDialog(item)
              },
              actionAreaDistance: 56
            }
          })
          .transition({ type: TransitionType.Delete, opacity: 0 })
        }, (item: HistoryMessage) => item.id)
      }
      .padding($r('sys.float.padding_level8'))
      .width('100%')
      .height('100%')
      .contentEndOffset(getPhoneHdsTabsContentEndOffset(this.currentBreakpoint))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title('历史消息')
  }
}
