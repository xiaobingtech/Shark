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
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@ohos/common';
import { promptAction } from '@kit.ArkUI';

const TAG: string = '[FriendAppView]';
const HARMONY_APPS_URL: string = 'http://img.app.xiaobingkj.com/friendship-links/apps.json';
const MY_KEY: string = 'FL-0C36B340D1B0';

interface HarmonyAppItem {
  id: number;
  name: string;
  packageName: string;
  ownerKey?: string;
  brief: string;
  icon: string;
  downloadUrl: string;
  storeUrl: string;
}

interface HarmonyAppsData {
  updatedAt: string;
  total: number;
  apps: HarmonyAppItem[];
}

interface HarmonyAppsResponse {
  code: number;
  message: string;
  data: HarmonyAppsData;
}

function startAppGalleryDetailAbility(
  context: common.UIAbilityContext,
  bundleId: string,
  downloadUrl: string
): void {
  const want: Want = {
    action: 'ohos.want.action.viewData',
    entities: ['entity.system.browsable'],
    uri: downloadUrl
  };
  context.startAbility(want).catch((error: BusinessError) => {
    Logger.error(TAG, `Failed to open download URL. Code: ${error.code}, message: ${error.message}`);
    const appGalleryWant: Want = {
      action: 'ohos.want.action.appdetail',
      uri: 'store://appgallery.huawei.com/app/detail?id=' + bundleId
    };
    context.startAbility(appGalleryWant).catch((appGalleryError: BusinessError) => {
      Logger.error(TAG,
        `Failed to start AppGallery. Code: ${appGalleryError.code}, message: ${appGalleryError.message}`);
      promptAction.showToast({ message: '无法打开应用详情，请稍后重试' });
    });
  });
}

@Component
export struct FriendAppView {
  @StorageLink('navPathStack') pathStack: NavPathStack = new NavPathStack();
  @State appList: HarmonyAppItem[] = [];
  @State isLoading: boolean = true;
  @State loadError: string = '';

  aboutToAppear(): void {
    this.fetchApps();
  }

  private async fetchApps(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext | undefined;
    if (context === undefined) {
      this.loadError = '页面暂不可用，请重试';
      this.isLoading = false;
      return;
    }
    this.isLoading = true;
    this.loadError = '';
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(HARMONY_APPS_URL, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000,
        header: { 'Content-Type': 'application/json' }
      });
      if (response.responseCode === 200 && response.result) {
        const data =
          typeof response.result === 'string' ? response.result : JSON.stringify(response.result);
        const currentBundleId: string = context.abilityInfo.bundleName;
        const result: HarmonyAppsResponse = JSON.parse(data);
        if (result.code === 0) {
          this.appList = result.data.apps.filter((item: HarmonyAppItem) =>
            item.packageName !== currentBundleId && (!MY_KEY || item.ownerKey !== MY_KEY)
          );
        } else {
          this.loadError = result.message || '加载失败';
        }
      } else {
        this.loadError = '加载失败';
      }
    } catch (err) {
      Logger.error(TAG, `fetchApps failed: ${JSON.stringify(err)}`);
      this.loadError = '网络请求失败';
    } finally {
      httpRequest.destroy();
      this.isLoading = false;
    }
  }

  private openAppMarket(item: HarmonyAppItem): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext | undefined;
    if (context !== undefined) {
      startAppGalleryDetailAbility(context, item.packageName, item.downloadUrl || item.storeUrl);
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
            Text($r('app.string.loading'))
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.loadError) {
          Column() {
            Text(this.loadError)
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
            Button($r('app.string.retry'))
              .margin({ top: 12 })
              .onClick(() => {
                this.fetchApps();
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.appList.length === 0) {
          Column() {
            Text($r('app.string.no_apps'))
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.appList, (item: HarmonyAppItem) => {
              ListItem() {
                Row() {
                  Image(item.icon)
                    .width(44)
                    .height(44)
                    .objectFit(ImageFit.Cover)

                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.brief)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 16 })

                  Button($r('app.string.myapp_open'))
                    .buttonStyle(ButtonStyleMode.NORMAL)
                    .fontSize(14)
                    .height(30)
                    .padding({ left: 16, right: 16 })
                    .onClick(() => {
                      this.openAppMarket(item);
                    })
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              }
              .onClick(() => {
                this.openAppMarket(item);
              })
            }, (item: HarmonyAppItem) => item.packageName)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .divider({
            strokeWidth: 0.5,
            color: $r('sys.color.comp_divider'),
            startMargin: $r('sys.float.padding_level24'),
            endMargin: $r('sys.float.padding_level6')
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title($r('app.string.setting_friend_apps'))
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%')
  }
}

@Builder
export function FriendAppViewBuilder() {
  FriendAppView()
}
