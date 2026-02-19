/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


@Component
export struct CardServerItem {
  @Prop isShow: boolean = false
  titleText?: Resource | string
  subtitleText?: Resource | string
  symbolSrc?: Resource
  showCheckmark: boolean = false
  onclick: Function = () => {
  }

  build() {
    Row() {
      SymbolGlyph(this.symbolSrc)
        .fontSize($r('sys.float.Title_M'))
        .fontColor([$r('sys.color.icon_secondary')])
      Column() {
        Text(this.titleText)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.subtitleText !== undefined) {
          Text(this.subtitleText)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: $r('sys.float.padding_level1') })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: $r('sys.float.padding_level8') })
      Blank()
      if (this.showCheckmark) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.icon_emphasize')])
      }
    }
    .width('100%')
    .height(56)
    .onClick(() => {
      this.onclick()
    })
  }
}
