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
import { StorageKey, UpdateService } from "@ohos/common";
import { BundleInfoData } from "@ohos/common";


@Component
export struct AboutItemCard {
  private updateService = UpdateService.getInstance();

  public currentVersion: string = '1.0.0';
  public laterVersionExist: boolean = false;
  public isLoadingUpdate: boolean = false;

  aboutToAppear(): void {
    this.checkVersion()
  }

  build() {
    Row() {
      Column() {
        if (this.laterVersionExist) {
          Badge({
            value: '',
            style: { badgeSize: 6, badgeColor: $r('app.color.about_badge_color') },
            position: BadgePosition.Right,
          }) {
            Text($r('app.string.version_information'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ right: $r('sys.float.padding_level6') })
          }
        } else {
          Text($r('app.string.version_information'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
        }

        Text(AppStorage.get<BundleInfoData>(StorageKey.BUNDLE_INFO)?.versionName as string)
          .margin({ top: $r('sys.float.padding_level2') })
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      Row() {
        if (!this.isLoadingUpdate) {
          Text(this.laterVersionExist ? $r('app.string.updated_version') : $r('app.string.latest_version'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Subtitle_S'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ right: $r('sys.float.padding_level2') })
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize($r('sys.float.Title_S'))
            .fontColor([$r('sys.color.icon_fourth')])
        } else {
          LoadingProgress()
            .width($r('app.float.about_loadingProgress_size'))
            .height($r('app.float.about_loadingProgress_size'))
        }
      }
      .onClick(() => {
        if (this.laterVersionExist) {
          this.updateVersion()
        }
      })
    }
    .width('100%')
    .height($r('app.float.about_item_card_height'))
    .borderRadius($r('sys.float.corner_radius_level7'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('sys.float.padding_level6'),
      top: $r('sys.float.padding_level7'),
      bottom: $r('sys.float.padding_level7'),
      right: $r('sys.float.padding_level6'),
    })
  }

  private checkVersion(): void {
    this.updateService.checkUpdate().then((existNewVersion: boolean) => {
      this.laterVersionExist = existNewVersion;
      this.currentVersion = AppStorage.get<BundleInfoData>(StorageKey.BUNDLE_INFO)?.versionName as string;
    });
  }

  private updateVersion(): void {
    this.isLoadingUpdate = true;
    this.updateService.updateVersion().then(() => {
      this.isLoadingUpdate = false;
    });
  }
}