import { distributedDataObject } from '@kit.ArkData'

const HISTORY_DATA_KEY: string = 'historyDataObject'
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData'

class HistoryStoreData {
  titles: Array<string> = []
  bodies: Array<string> = []
  times: Array<number> = []
}

class HistoryMessage {
  id: string
  title: string
  body: string
  time: number

  constructor(id: string, title: string, body: string, time: number) {
    this.id = id
    this.title = title
    this.body = body
    this.time = time
  }
}

@Component
export struct HistoryView {
  @State messages: Array<HistoryMessage> = []
  @Watch('onRefreshTickChange')
  @StorageLink('historyRefreshTick') refreshTick: number = 0
  private historyDataObject: distributedDataObject.DataObject | null = null
  private historyStoreData: HistoryStoreData | null = null
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
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
      list.push(new HistoryMessage(id, titles[i], bodies[i], times[i]))
    }
    list.sort((left: HistoryMessage, right: HistoryMessage) => {
      return right.time - left.time
    })
    this.messages = list
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

  build() {
    Navigation() {
      Grid() {
        ForEach(this.messages, (item: HistoryMessage) => {
          GridItem() {
            Column({ space: 6 }) {
              Text(item.title)
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.body)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(this.formatTime(item.time))
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding($r('sys.float.padding_level8'))
            .width('100%')
            .height(undefined)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius($r('sys.float.corner_radius_level8'))
          }
          .borderRadius($r('sys.float.corner_radius_level8'))
          .clip(true)
        }, (item: HistoryMessage) => item.id)
      }
      .columnsTemplate('1fr')
      .rowsGap($r('sys.float.padding_level8'))
      .padding($r('sys.float.padding_level8'))
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title('历史消息')
  }
}
