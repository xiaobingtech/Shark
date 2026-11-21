import { distributedDataObject, preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { getPhoneHdsTabsContentEndOffset } from '../common/utils/ApiVersionUtil'

const HISTORY_DATA_KEY: string = 'historyDataObject'
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData'
const PREFERENCES_NAME: string = 'shark.db'
const HISTORY_TITLES_KEY: string = 'historyTitles'
const HISTORY_BODIES_KEY: string = 'historyBodies'
const HISTORY_TIMES_KEY: string = 'historyTimes'
const HISTORY_IMAGES_KEY: string = 'historyImages'
const HISTORY_STYLES_KEY: string = 'historyStyles'
const HISTORY_INBOX_CONTENTS_KEY: string = 'historyInboxContents'
const HISTORY_TITLE_PREVIEW_LINES: number = 1
const HISTORY_BODY_PREVIEW_LINES: number = 2
const HISTORY_INBOX_PREVIEW_LINES: number = 1
const HISTORY_EXPANDED_LINES: number = 2147483647
const IMAGE_DISMISS_DISTANCE: number = 96
const IMAGE_FLICK_DISTANCE: number = 28
const IMAGE_FLICK_VELOCITY: number = 900
const IMAGE_DOUBLE_TAP_SCALE: number = 2.5
const IMAGE_MAX_SCALE: number = 4

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
struct HistoryMessageCard {
  @Prop @Watch('updateCanExpand') item: HistoryMessage
  @Prop timeLabel: string = ''
  onOpenImage: (imageUrl: string) => void = () => {}
  @State private expanded: boolean = false
  @State private canExpand: boolean = false
  private textWidth: number = 0

  private exceedsPreview(text: string, fontSize: Resource, maxLines: number,
    fontWeight: FontWeight = FontWeight.Normal): boolean {
    const measure = this.getUIContext().getMeasureUtils()
    const previewHeight = measure.measureTextSize({
      textContent: text, constraintWidth: this.textWidth, fontSize, fontWeight, maxLines
    }).height
    const nextLineHeight = measure.measureTextSize({
      textContent: text, constraintWidth: this.textWidth, fontSize, fontWeight, maxLines: maxLines + 1
    }).height
    return Number(nextLineHeight) > Number(previewHeight)
  }

  private updateCanExpand(): void {
    if (this.textWidth <= 0) {
      return
    }
    this.canExpand = this.exceedsPreview(this.item.title, $r('sys.float.Subtitle_M'), HISTORY_TITLE_PREVIEW_LINES,
      FontWeight.Medium) || (this.item.style === 3 && this.item.inboxContents.length > 0 ?
      this.item.inboxContents.some((line: string) =>
        this.exceedsPreview(line, $r('sys.float.Body_M'), HISTORY_INBOX_PREVIEW_LINES)) :
      this.exceedsPreview(this.item.body, $r('sys.float.Body_M'), HISTORY_BODY_PREVIEW_LINES))
    if (!this.canExpand) {
      this.expanded = false
    }
  }

  build() {
    Column({ space: 6 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.item.title)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(this.expanded ? HISTORY_EXPANDED_LINES : HISTORY_TITLE_PREVIEW_LINES)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.item.style === 3 && this.item.inboxContents.length > 0) {
            ForEach(this.item.inboxContents, (line: string) => {
              Text(line)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .maxLines(this.expanded ? HISTORY_EXPANDED_LINES : HISTORY_INBOX_PREVIEW_LINES)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }, (line: string, index: number) => `${index}_${line}`)
          } else {
            Text(this.item.body)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(this.expanded ? HISTORY_EXPANDED_LINES : HISTORY_BODY_PREVIEW_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onSizeChange((_, size: SizeOptions) => {
          this.textWidth = Number(size.width ?? 0)
          this.updateCanExpand()
        })
        if (this.item.image.length > 0) {
          Image(this.item.image)
            .width(44)
            .height(44)
            .objectFit(ImageFit.Cover)
            .draggable(false)
            .borderRadius($r('sys.float.corner_radius_level4'))
            .margin({ left: 10 })
            .focusable(true)
            .accessibilityText('查看大图')
            .onClick(() => {
              this.onOpenImage(this.item.image)
            })
        }
      }
      .alignItems(VerticalAlign.Top)
      Row() {
        Text(this.timeLabel)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
        if (this.canExpand) {
          Button(this.expanded ? '收起' : '展开', { buttonStyle: ButtonStyleMode.TEXTUAL })
            .fontSize($r('sys.float.Body_S'))
            .constraintSize({ minHeight: 40 })
            .onClick(() => {
              this.expanded = !this.expanded
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignItems(HorizontalAlign.Start)
    .padding($r('sys.float.padding_level8'))
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}

interface ImageOffset {
  x: number
  y: number
}

@Component
struct HistoryImagePreview {
  @Prop imageUrl: string = ''
  onClose: () => void = () => {}
  @State private dragOffset: number = 0
  @State private loadFailed: boolean = false
  @State private imageScale: number = 1
  @State private imageOffset: ImageOffset = { x: 0, y: 0 }
  private viewportWidth: number = 0
  private viewportHeight: number = 0
  private imageAspectRatio: number = 0
  private pinching: boolean = false
  private pinchStartScale: number = 1
  private pinchStartOffset: ImageOffset = { x: 0, y: 0 }
  private pinchCenter: ImageOffset = { x: 0, y: 0 }
  private panStartOffset: ImageOffset = { x: 0, y: 0 }
  private panningImage: boolean = false
  private draggingToClose: boolean = false

  private clampOffset(x: number, y: number): ImageOffset {
    if (this.imageScale === 1 || this.imageAspectRatio <= 0) {
      return { x: 0, y: 0 }
    }
    const imageWidth = Math.min(this.viewportWidth, this.viewportHeight * this.imageAspectRatio)
    const imageHeight = imageWidth / this.imageAspectRatio
    const maxX = Math.max(0, (imageWidth * this.imageScale - this.viewportWidth) / 2)
    const maxY = Math.max(0, (imageHeight * this.imageScale - this.viewportHeight) / 2)
    return {
      x: Math.max(-maxX, Math.min(x, maxX)),
      y: Math.max(-maxY, Math.min(y, maxY))
    }
  }

  private zoomAt(scale: number, startScale: number, startOffset: ImageOffset, center: ImageOffset): void {
    this.imageScale = Math.max(1, Math.min(scale, IMAGE_MAX_SCALE))
    const factor = this.imageScale / startScale
    this.imageOffset = this.clampOffset(
      startOffset.x * factor + (center.x - this.viewportWidth / 2) * (1 - factor),
      startOffset.y * factor + (center.y - this.viewportHeight / 2) * (1 - factor)
    )
  }

  private toggleZoom(event: GestureEvent): void {
    if (this.pinching || this.imageAspectRatio <= 0) {
      return
    }
    const point = event.fingerInfos?.[0]
    const center: ImageOffset = {
      x: point?.localX ?? this.viewportWidth / 2,
      y: point?.localY ?? this.viewportHeight / 2
    }
    const scale = this.imageScale > 1 ? 1 : IMAGE_DOUBLE_TAP_SCALE
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
      this.zoomAt(scale, this.imageScale, this.imageOffset, center)
    })
  }

  private startPinch(event: GestureEvent): void {
    this.pinching = true
    this.panningImage = false
    this.draggingToClose = false
    this.dragOffset = 0
    this.pinchStartScale = this.imageScale
    this.pinchStartOffset = this.imageOffset
    this.pinchCenter = { x: event.pinchCenterX, y: event.pinchCenterY }
  }

  private startPan(event: GestureEvent): void {
    this.panningImage = !this.pinching && this.imageScale > 1
    this.draggingToClose = !this.pinching && this.imageScale === 1 && event.offsetY > Math.abs(event.offsetX)
    this.panStartOffset = this.imageOffset
  }

  private updatePan(event: GestureEvent): void {
    if (this.panningImage) {
      this.imageOffset = this.clampOffset(
        this.panStartOffset.x + event.offsetX, this.panStartOffset.y + event.offsetY)
    } else if (this.draggingToClose) {
      this.dragOffset = Math.max(0, event.offsetY)
    }
  }

  private endPan(event: GestureEvent): void {
    const flickedDown = event.offsetY >= IMAGE_FLICK_DISTANCE && event.velocityY >= IMAGE_FLICK_VELOCITY
    if (this.draggingToClose && event.offsetY > Math.abs(event.offsetX) &&
      (event.offsetY >= IMAGE_DISMISS_DISTANCE || flickedDown)) {
      this.onClose()
    } else {
      this.resetDrag()
    }
  }

  private resetDrag(): void {
    this.panningImage = false
    this.draggingToClose = false
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
      this.dragOffset = 0
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .opacity(1 - Math.min(this.dragOffset / IMAGE_DISMISS_DISTANCE, 1) * 0.45)
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT])

      Stack() {
        Column() {
          if (this.loadFailed) {
            Text('图片加载失败')
              .fontColor(Color.White)
          } else {
            Image(this.imageUrl)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .draggable(false)
              .scale({ x: this.imageScale, y: this.imageScale })
              .onComplete((event) => {
                if (event && event.width > 0 && event.height > 0) {
                  this.imageAspectRatio = event.width / event.height
                }
              })
              .onError(() => {
                this.loadFailed = true
              })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .translate({ x: this.imageOffset.x, y: this.imageOffset.y + this.dragOffset })
      }
      .width('100%')
      .height('100%')
      .clip(true)
      .hitTestBehavior(HitTestMode.None)
      .onSizeChange((_, size: SizeOptions) => {
        this.viewportWidth = Number(size.width ?? 0)
        this.viewportHeight = Number(size.height ?? 0)
        this.imageOffset = this.clampOffset(this.imageOffset.x, this.imageOffset.y)
      })

      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(20)
          .fontColor([Color.White])
      }
      .width(44)
      .height(44)
      .margin({ top: 8, right: 12 })
      .backgroundColor('#66000000')
      .accessibilityText('关闭图片预览')
      .onClick(() => {
        this.onClose()
      })
    }
    .width('100%')
    .height('100%')
    .gesture(
      GestureGroup(GestureMode.Parallel,
        PinchGesture({ fingers: 2, isFingerCountLimited: true })
          .onActionStart((event: GestureEvent) => this.startPinch(event))
          .onActionUpdate((event: GestureEvent) => {
            if (this.imageAspectRatio > 0) {
              this.zoomAt(this.pinchStartScale * event.scale, this.pinchStartScale,
                this.pinchStartOffset, this.pinchCenter)
            }
          })
          .onActionEnd(() => { this.pinching = false })
          .onActionCancel(() => { this.pinching = false }),
        GestureGroup(GestureMode.Exclusive,
          TapGesture({ count: 2, fingers: 1, isFingerCountLimited: true })
            .onAction((event: GestureEvent) => this.toggleZoom(event)),
          PanGesture({ fingers: 1, isFingerCountLimited: true })
            .onActionStart((event: GestureEvent) => this.startPan(event))
            .onActionUpdate((event: GestureEvent) => this.updatePan(event))
            .onActionEnd((event: GestureEvent) => this.endPan(event))
            .onActionCancel(() => this.resetDrag())
        )
      )
    )
  }
}

@Component
export struct HistoryView {
  @State messages: Array<HistoryMessage> = []
  @State filteredMessages: Array<HistoryMessage> = []
  @State isSearching: boolean = false
  @State searchText: string = ''
  @State private previewImageUrl: string = ''
  @State private showImagePreview: boolean = false
  @StorageProp('currentBreakpoint') currentBreakpoint: string = ''
  @Watch('onRefreshTickChange')
  @StorageLink('historyRefreshTick') refreshTick: number = 0
  private historyDataObject: distributedDataObject.DataObject | null = null
  private historyStoreData: HistoryStoreData | null = null
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  private listScroller: ListScroller = new ListScroller()
  private searchController: SearchController = new SearchController()
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
      this.filterMessages()
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
    this.filterMessages()
  }

  private filterMessages(): void {
    const keyword = this.searchText.trim().toLowerCase()
    this.filteredMessages = keyword.length === 0 ? this.messages :
      this.messages.filter((item: HistoryMessage) =>
        item.title.toLowerCase().includes(keyword) || item.body.toLowerCase().includes(keyword) ||
        item.inboxContents.some((line: string) => line.toLowerCase().includes(keyword)))
  }

  private toggleSearch(): void {
    if (this.isSearching) {
      this.searchController.stopEditing()
    }
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
      this.isSearching = !this.isSearching
    })
    if (!this.isSearching) {
      this.searchText = ''
      this.filterMessages()
    }
  }

  private buildMenuItems(): Array<NavigationMenuItem> {
    return [{
      value: this.isSearching ? '关闭搜索' : '搜索',
      symbolIcon: new SymbolGlyphModifier(this.isSearching ?
        $r('sys.symbol.xmark') : $r('sys.symbol.magnifyingglass')),
      action: () => this.toggleSearch()
    }]
  }

  @Builder
  buildSearchBar() {
    Row() {
      Search({ value: this.searchText, placeholder: '搜索消息标题或内容', controller: this.searchController })
        .id('historyMessageSearch')
        .width('100%')
        .defaultFocus(true)
        .onAppear(() => {
          this.getUIContext().getFocusController().requestFocus('historyMessageSearch')
        })
        .onChange((value: string) => {
          this.searchText = value
          this.filterMessages()
        })
    }
    .width('100%')
    .padding($r('sys.float.padding_level8'))
    .transition(TransitionEffect.OPACITY)
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
      // 持久化到分布式数据对象
      if (this.historyDataObject != null) {
        this.historyDataObject.save('local', (err: BusinessError, result: distributedDataObject.SaveSuccessResponse) => {
          if (err != undefined && err.code != 0) {
            console.error('Failed to save history after deletion: ' + JSON.stringify(err))
          }
        })
      }
      // 持久化到 preferences（磁盘），参考 EntryAbility.persistHistoryData
      let context = getContext(this) as common.UIAbilityContext
      let pref = preferences.getPreferencesSync(context, { name: PREFERENCES_NAME })
      pref.putSync(HISTORY_TITLES_KEY, JSON.stringify(this.historyStoreData.titles))
      pref.putSync(HISTORY_BODIES_KEY, JSON.stringify(this.historyStoreData.bodies))
      pref.putSync(HISTORY_TIMES_KEY, JSON.stringify(this.historyStoreData.times))
      pref.putSync(HISTORY_IMAGES_KEY, JSON.stringify(this.historyStoreData.images))
      pref.putSync(HISTORY_STYLES_KEY, JSON.stringify(this.historyStoreData.styles))
      pref.putSync(HISTORY_INBOX_CONTENTS_KEY, JSON.stringify(this.historyStoreData.inboxContents))
      pref.flushSync()
    }
    let updated: Array<HistoryMessage> = []
    for (let i = 0; i < this.messages.length; i++) {
      if (this.messages[i].id !== item.id) {
        updated.push(this.messages[i])
      }
    }
    this.messages = updated
    this.filterMessages()
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

  @Builder
  buildImagePreview() {
    HistoryImagePreview({
      imageUrl: this.previewImageUrl,
      onClose: () => {
        this.showImagePreview = false
      }
    })
  }

  build() {
    Navigation() {
      Column() {
        if (this.isSearching) {
          this.buildSearchBar()
        }
        List({ scroller: this.listScroller, space: 10 }) {
          if (this.filteredMessages.length === 0) {
            ListItem() {
              Text(this.searchText.trim().length > 0 ? '未找到匹配的消息' : '暂无历史消息')
                .fontColor($r('sys.color.font_secondary'))
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 40, bottom: 40 })
            }
          }
          ForEach(this.filteredMessages, (item: HistoryMessage) => {
            ListItem() {
              HistoryMessageCard({
                item: item,
                timeLabel: this.formatTime(item.time),
                onOpenImage: (imageUrl: string) => {
                  this.previewImageUrl = imageUrl
                  this.showImagePreview = true
                }
              })
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
        .layoutWeight(1)
        .contentEndOffset(getPhoneHdsTabsContentEndOffset(this.currentBreakpoint))
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .backgroundColor($r('sys.color.background_secondary'))
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title('历史消息')
    .menus(this.buildMenuItems())
    .bindContentCover($$this.showImagePreview, this.buildImagePreview(), {
      modalTransition: ModalTransition.ALPHA,
      backgroundColor: Color.Transparent,
      enableSafeArea: true
    })
  }
}
