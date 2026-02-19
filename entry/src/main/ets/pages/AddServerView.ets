import { scanBarcode, scanCore } from '@kit.ScanKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Preview
@Component
export struct AddServerView {
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @State serverUrl: string = 'https://'

  private startScan(): void {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: false,
      enableAlbum: true
    }
    try {
      scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options).then((result: scanBarcode.ScanResult) => {
        let scanValue: string = result.originalValue
        if (scanValue.length > 0) {
          this.serverUrl = scanValue
        }
      }).catch((error: BusinessError) => {
        error
      })
    } catch (error) {
      error
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('服务器地址')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .margin({ bottom: $r('sys.float.padding_level2') })
        Row() {
          TextInput({ text: this.serverUrl, placeholder: '输入服务器地址，例如：https://shark.xiaobingkj.com' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .fontColor($r('sys.color.font_primary'))
            .onChange((value: string) => {
              this.serverUrl = value
            })
          SymbolGlyph($r('sys.symbol.qrcode'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon')])
            .onClick(() => {
              this.startScan()
            })
        }
        .width('100%')

        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth(1)

        Text('查看服务端部署教程')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_emphasize'))
          .margin({ top: $r('sys.float.padding_level6') })
      }
      .padding($r('sys.float.padding_level6'))
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .title('添加私有服务器')
    .onBackPressed(() => {
      this.tabBarHidden = false
      this.navPathStack.pop()
      return true
    })
  }
}
