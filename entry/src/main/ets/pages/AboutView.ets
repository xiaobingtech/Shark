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

const XIAOHONGSHU_URL: string = 'https://www.xiaohongshu.com/user/profile/6020d9b60000000001001f43';
const DOUYIN_URL: string =
  'snssdk1128://user/profile?refer=web&needlaunchlog=1&scene_from=share_reflow&ori_scene_from=default&host=m.douyin.com&group_id=MS4wLjABAAAAEFBc-xLSinUP8NMkEzPk5EEKmcDQLHtqtA3hUernySSUBvSqZE9iOecF3if6r4iC&web_id=7666113840812262975&browser_name=huawei&referrer_host=m.douyin.com&is_edenx=1&__forbid_pasteboard__=1&gd_label=click_schema_ug_filter_v1_click_schema_lhft_62221575a&launch_h5_method=click_wap_profile_bottom_btn&sec_uid=MS4wLjABAAAAEFBc-xLSinUP8NMkEzPk5EEKmcDQLHtqtA3hUernySSUBvSqZE9iOecF3if6r4iC&type=need_follow&is_active_tap=1&sec_uid_path=MS4wLjABAAAAEFBc-xLSinUP8NMkEzPk5EEKmcDQLHtqtA3hUernySSUBvSqZE9iOecF3if6r4iC';

@Component
export struct AboutView {


  build() {
    Scroll() {
      Column() {
        Column() {
          Image($r('app.media.appIcon'))
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
          this.socialMediaSection()
        }
        .margin({ top: $r('sys.float.padding_level8') })
        .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })

        Column({space: 5}) {
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
      .constraintSize({ minHeight: '100%' })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  socialRow(icon: Resource, title: ResourceStr, action: () => void) {
    Row() {
      Image(icon)
        .draggable(false)
        .width(20)
        .height(20)
      Text(title)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('sys.float.padding_level6') })
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor([$r('sys.color.icon_fourth')])
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6'),
    })
    .onClick(action)
  }

  @Builder
  socialMediaSection() {
    Column() {
      this.socialRow($r('app.media.mp'), $r('app.string.about_wechat'), () => {
        this.copyWechatAccount();
      })
      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
      this.socialRow($r('app.media.xhs'), $r('app.string.about_xiaohongshu'), () => {
        this.openExternalLink(XIAOHONGSHU_URL);
      })
      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
      this.socialRow($r('app.media.dy'), $r('app.string.about_douyin'), () => {
        this.openExternalLink(DOUYIN_URL);
      })
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level7'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ top: $r('sys.float.padding_level16') })
  }

  private copyWechatAccount(): void {
    const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    const pasteData: pasteboard.PasteData =
      pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, '范小兵');
    systemPasteboard.setDataSync(pasteData);
    promptAction.showToast({ message: $r('app.string.about_wechat_copied') });
  }

  private openExternalLink(url: string): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext | undefined;
    if (context === undefined) {
      return;
    }
    const want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
    };
    context.startAbility(want).catch((err: BusinessError) => {
      promptAction.showToast({ message: err.message });
    });
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
