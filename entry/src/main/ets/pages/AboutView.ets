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

import { common, Want } from '@kit.AbilityKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { AboutItemCard } from '../common/AboutItemCard';

const TAG: string = '[AboutView]';

@Component
export struct AboutView {


  build() {
    Column() {
      Column() {
        Image($r('app.media.startIcon'))
          .draggable(false)
          .width($r('app.float.about_image_size'))
          .height($r('app.float.about_image_size'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        Text($r('app.string.EntryAbility_label'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: $r('sys.float.padding_level4') })
        AboutItemCard()
          .margin({ top: $r('sys.float.padding_level16') })
      }
      .margin({ top: $r('sys.float.padding_level8') })
      .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })

      Column({space: 5}) {
        Text('微信公众号：范小兵')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_S'))
          .onClick(() => {
            let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
            let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, '范小兵');
            systemPasteboard.setDataSync(pasteData)
            promptAction.showToast({
              message: '公众号"范小兵"已复制到剪贴板，到微信中添加公众号即可'
            })
          })
        Text($r('app.string.copyright1'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .onClick(() => {
            const uiContext: UIContext = this.getUIContext();
            const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
            this.jumpToBrowser(context);
          })
        Text($r('app.string.copyright2'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_S'))
      }
      .margin({ bottom: $r('sys.float.padding_level24') })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .height("100%")
  }

  private jumpToBrowser(context: common.UIAbilityContext): void {
    const want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: 'https://beian.miit.gov.cn/',
    };
    context.startAbility(want)
      .then(() => {
        console.info('Start browsableAbility successfully.');
      })
      .catch((err: BusinessError) => {
        console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }
}

@Builder
export function AboutViewBuilder() {
  AboutView()
}