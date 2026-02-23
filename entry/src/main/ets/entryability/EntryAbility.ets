import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { distributedDataObject, preferences } from '@kit.ArkData';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { efRcp } from '@yunkss/ef_rcp';
import { updateManager } from '@kit.StoreKit';
import { DynamicInstallManager, Logger, StorageKey, WebUtil, WindowUtil } from '@ohos/common';

const DOMAIN = 0x0000;
const TAG = '[EntryAbility]';
const PREFERENCES_NAME: string = 'shark.db';
const DEVICE_TOKEN_KEY: string = 'deviceToken';
const DEVICE_TOKEN_READY_KEY: string = 'hasDeviceToken';
const DEVICE_KEY: string = 'deviceKey';
const SERVER_BASE_URL_KEY: string = 'serverBaseUrl';
const SERVER_LIST_KEY: string = 'serverList';
const SERVER_BASE_URL_DEFAULT: string = 'https://shark.xiaobingkj.com';
const HISTORY_DATA_KEY: string = 'historyDataObject';
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData';
const HISTORY_TAB_INDEX_KEY: string = 'tabIndex';
const HISTORY_TITLES_KEY: string = 'historyTitles';
const HISTORY_BODIES_KEY: string = 'historyBodies';
const HISTORY_TIMES_KEY: string = 'historyTimes';

class HistoryStoreData {
  titles: Array<string> = [];
  bodies: Array<string> = [];
  times: Array<number> = [];
}

interface ServerInfo {
  url: string;
  key: string;
}

interface PushMessageBody {
  title?: string;
  body?: string;
  notifyId?: number;
}

interface PushMessageHead {
  serverRecTime?: number;
  deliveryTime?: number;
}

interface PushMessageTraceTs {
  rpcRcv?: number;
  inQueue?: number;
  outQueue?: number;
}

interface PushMessage {
  body?: PushMessageBody;
  head?: PushMessageHead;
  msgTraceTs?: PushMessageTraceTs;
}

interface PushWantInfoParameters {
  message?: PushMessage;
}

interface PushWantInfo {
  parameters?: PushWantInfoParameters;
}

interface PushWantAgentInfo {
  wants?: Array<PushWantInfo>;
}

interface WantMessageParameters {
  title?: string;
  body?: string;
  time?: number;
  _push_notifyid?: number;
  push_wantAgentInfo?: PushWantAgentInfo;
}

export default class EntryAbility extends UIAbility {
  private historyDataObject: distributedDataObject.DataObject | null = null;
  private historyStoreData: HistoryStoreData | null = null;
  private pendingHistoryTab: boolean = false;

  private windowObj?: window.Window
  private curBp: string = ''

  // 根据当前窗口尺寸更新断点
  private updateBreakpoint(windowWidth: number) :void {
    // 拿到当前窗口对象获取当前所在displayId
    let displayId = this.windowObj?.getWindowProperties().displayId
    try {
      // 将长度的单位由px换算为vp
      let windowWidthVp = windowWidth / display.getDisplayByIdSync(displayId).densityPixels
      let newBp: string = ''
      if (windowWidthVp < 320) {
        newBp = 'xs'
      } else if (windowWidthVp < 600) {
        newBp = 'sm'
      } else if (windowWidthVp < 840) {
        newBp = 'md'
      } else {
        newBp = 'lg'
      }
      if (this.curBp !== newBp) {
        this.curBp = newBp
        // 使用状态变量记录当前断点值
        AppStorage.setOrCreate('currentBreakpoint', this.curBp)
      }
    } catch (err) {
      console.log("getDisplayByIdSync failed err" + err.code)
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    this.handleWant(want)

    this.checkAndHandleParams(want);
    AppStorage.setOrCreate(StorageKey.COLOR_MODE, this.context.config.colorMode);
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch {
      Logger.error(TAG, `onCreate setColorMode failed`);
    }
  }

  checkAndHandleParams(want: Want): void {
    Logger.info(TAG, `checkAndHandleParams`);
    try {
      if (want === null || want.parameters === null || want === undefined || want.parameters === undefined) {
        return;
      }
    } catch (err) {
      Logger.error(TAG, `checkAndHandleParams failed: ${err}`);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant');
    this.handleWant(want)
  }

  handleWant(want: Want): void {
    hilog.debug(DOMAIN, 'testTag', `want.parameters:${want.parameters}`)
    this.pendingHistoryTab = this.shouldOpenHistoryTab(want)
    if (this.pendingHistoryTab) {
      this.appendHistoryMessage(want)
      this.applyHistoryTabSelection()
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    DynamicInstallManager.unsubscribeDownloadProgress();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    efRcp.setBaseURL('https://shark.xiaobingkj.com')
      .disableLoading()
      .enableLogInterceptor()
      .create()

    AppStorage.setOrCreate('windowStage', windowStage);

    AppStorage.setOrCreate('navPathStack', new NavPathStack())
    AppStorage.setOrCreate('tabBarHidden', false)
    let existingTabIndex = AppStorage.get<number>(HISTORY_TAB_INDEX_KEY)
    if (existingTabIndex == undefined) {
      AppStorage.setOrCreate(HISTORY_TAB_INDEX_KEY, 0)
    }
    let data = preferences.getPreferencesSync(this.context, { name: PREFERENCES_NAME })
    let savedToken = data.getSync(DEVICE_TOKEN_KEY, '') as string
    let savedReady = data.getSync(DEVICE_TOKEN_READY_KEY, false) as boolean
    let savedDeviceKey = data.getSync(DEVICE_KEY, '') as string
    let savedServerBaseUrl = data.getSync(SERVER_BASE_URL_KEY, SERVER_BASE_URL_DEFAULT) as string
    let savedServerListJson = data.getSync(SERVER_LIST_KEY, '[]') as string
    let savedServerList: Array<ServerInfo> = this.parseServerList(savedServerListJson)
    AppStorage.setOrCreate(DEVICE_TOKEN_KEY, savedToken)
    AppStorage.setOrCreate(DEVICE_TOKEN_READY_KEY, savedReady)
    AppStorage.setOrCreate(DEVICE_KEY, savedDeviceKey)
    AppStorage.setOrCreate(SERVER_BASE_URL_KEY, savedServerBaseUrl)
    AppStorage.setOrCreate(SERVER_LIST_KEY, savedServerList)
    this.ensureHistoryDataObject()
    this.applyHistoryTabSelection()
    this.checkAppUpdate()

    windowStage.loadContent('pages/TabPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    windowStage.getMainWindow().then((windowObj) => {
      this.windowObj = windowObj
      WebUtil.initialize(windowStage);
      WindowUtil.initialize(windowStage);
      // 获取应用启动时的窗口尺寸
      this.updateBreakpoint(windowObj.getWindowProperties().windowRect.width)
      // 注册回调函数，监听窗口尺寸变化
      windowObj.on('windowSizeChange', (windowSize)=>{
        this.updateBreakpoint(windowSize.width)
      })
    });
  }

  private ensureHistoryDataObject(): distributedDataObject.DataObject {
    if (this.historyDataObject != null) {
      return this.historyDataObject
    }
    let existingDataObject: distributedDataObject.DataObject | undefined =
      AppStorage.get<distributedDataObject.DataObject>(HISTORY_DATA_KEY)
    let existingData: HistoryStoreData | undefined =
      AppStorage.get<HistoryStoreData>(HISTORY_DATA_VALUE_KEY)
    if (existingDataObject != undefined && existingData != undefined) {
      this.historyDataObject = existingDataObject
      this.historyStoreData = existingData
      return this.historyDataObject
    }
    let data: HistoryStoreData = this.loadHistoryFromPreferences()
    let dataObject: distributedDataObject.DataObject = distributedDataObject.create(this.context, data)
    this.historyDataObject = dataObject
    this.historyStoreData = data
    AppStorage.setOrCreate(HISTORY_DATA_KEY, dataObject)
    AppStorage.setOrCreate(HISTORY_DATA_VALUE_KEY, data)
    return dataObject
  }

  private appendHistoryMessage(want: Want): void {
    let parameters = want.parameters as WantMessageParameters
    let title: string = ''
    let body: string = ''
    let timestamp: number = Date.now()
    if (parameters != undefined && parameters != null) {
      let message: PushMessage | undefined = undefined
      if (parameters.push_wantAgentInfo != undefined &&
        parameters.push_wantAgentInfo.wants != undefined &&
        parameters.push_wantAgentInfo.wants.length > 0) {
        let firstWant = parameters.push_wantAgentInfo.wants[0]
        if (firstWant.parameters != undefined && firstWant.parameters.message != undefined) {
          message = firstWant.parameters.message
        }
      }
      if (message != undefined && message.body != undefined) {
        if (message.body.title != undefined && message.body.title.length > 0) {
          title = message.body.title
        }
        if (message.body.body != undefined && message.body.body.length > 0) {
          body = message.body.body
        }
      }
      if (message != undefined && message.head != undefined && message.head.serverRecTime != undefined &&
        message.head.serverRecTime > 0) {
        timestamp = message.head.serverRecTime
      } else if (message != undefined && message.msgTraceTs != undefined && message.msgTraceTs.rpcRcv != undefined &&
        message.msgTraceTs.rpcRcv > 0) {
        timestamp = message.msgTraceTs.rpcRcv
      }
      if (parameters.title != undefined && parameters.title.length > 0) {
        title = parameters.title
      }
      if (parameters.body != undefined && parameters.body.length > 0) {
        body = parameters.body
      }
      if (parameters.time != undefined && parameters.time > 0) {
        timestamp = parameters.time
      }
    }
    if (title.length == 0) {
      title = '推送标题'
    }
    if (body.length == 0) {
      body = '推送内容'
    }
    this.ensureHistoryDataObject()
    if (this.historyStoreData == null || this.historyDataObject == null) {
      return
    }
    let data = this.historyStoreData
    data.titles = [...data.titles, title]
    data.bodies = [...data.bodies, body]
    data.times = [...data.times, timestamp]
    AppStorage.setOrCreate(HISTORY_DATA_VALUE_KEY, data)
    this.historyDataObject.save('local', (err: BusinessError, result: distributedDataObject.SaveSuccessResponse) => {
      if (err != undefined && err.code != 0) {
        hilog.error(DOMAIN, 'HistoryStore', 'Failed to save history: %{public}s', JSON.stringify(err))
      }
    })
    this.persistHistoryData()
  }

  private applyHistoryTabSelection(): void {
    try {
      AppStorage.setOrCreate(HISTORY_TAB_INDEX_KEY, 1)
    } catch (err) {
      hilog.error(DOMAIN, 'HistoryStore', 'Failed to update tab index: %{public}s', JSON.stringify(err))
    }
  }

  private shouldOpenHistoryTab(want: Want): boolean {
    if (want.action != undefined && want.action == 'com.xiaobingkj.shark.history') {
      return true
    }
    let parameters = want.parameters as WantMessageParameters
    if (parameters == undefined || parameters == null) {
      return false
    }
    if (parameters.push_wantAgentInfo != undefined) {
      return true
    }
    if (parameters._push_notifyid != undefined) {
      return true
    }
    if (parameters.title != undefined && parameters.title.length > 0) {
      return true
    }
    if (parameters.body != undefined && parameters.body.length > 0) {
      return true
    }
    if (parameters.time != undefined && parameters.time > 0) {
      return true
    }
    return false
  }

  private loadHistoryFromPreferences(): HistoryStoreData {
    let data: HistoryStoreData = new HistoryStoreData()
    let pref = preferences.getPreferencesSync(this.context, { name: PREFERENCES_NAME })
    let titlesJson = pref.getSync(HISTORY_TITLES_KEY, '[]') as string
    let bodiesJson = pref.getSync(HISTORY_BODIES_KEY, '[]') as string
    let timesJson = pref.getSync(HISTORY_TIMES_KEY, '[]') as string
    data.titles = this.parseStringArray(titlesJson)
    data.bodies = this.parseStringArray(bodiesJson)
    data.times = this.parseNumberArray(timesJson)
    return data
  }

  private persistHistoryData(): void {
    if (this.historyStoreData == null) {
      return
    }
    let pref = preferences.getPreferencesSync(this.context, { name: PREFERENCES_NAME })
    pref.putSync(HISTORY_TITLES_KEY, JSON.stringify(this.historyStoreData.titles))
    pref.putSync(HISTORY_BODIES_KEY, JSON.stringify(this.historyStoreData.bodies))
    pref.putSync(HISTORY_TIMES_KEY, JSON.stringify(this.historyStoreData.times))
    pref.flushSync()
  }

  private parseStringArray(value: string): Array<string> {
    try {
      let parsed: object = JSON.parse(value) as object
      if (Array.isArray(parsed)) {
        return parsed as Array<string>
      }
    } catch (err) {
      hilog.error(DOMAIN, 'HistoryStore', 'Failed to parse string array: %{public}s', JSON.stringify(err))
    }
    return []
  }

  private parseNumberArray(value: string): Array<number> {
    try {
      let parsed: object = JSON.parse(value) as object
      if (Array.isArray(parsed)) {
        return parsed as Array<number>
      }
    } catch (err) {
      hilog.error(DOMAIN, 'HistoryStore', 'Failed to parse number array: %{public}s', JSON.stringify(err))
    }
    return []
  }

  private parseServerList(value: string): Array<ServerInfo> {
    try {
      let parsed: object = JSON.parse(value) as object
      if (Array.isArray(parsed)) {
        return parsed as Array<ServerInfo>
      }
    } catch (err) {
      hilog.error(DOMAIN, 'ServerStore', 'Failed to parse server list: %{public}s', JSON.stringify(err))
    }
    return []
  }

  private checkAppUpdate(): void {
    const uiContext = this.context as common.UIAbilityContext;
    try {
      updateManager.checkAppUpdate(uiContext)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          hilog.info(DOMAIN, TAG, 'checkAppUpdate result: updateAvailable=%{public}s',
            String(checkResult.updateAvailable));
          if (checkResult.updateAvailable) {
            updateManager.showUpdateDialog(uiContext)
              .then((resultCode: updateManager.ShowUpdateResultCode) => {
                hilog.info(DOMAIN, TAG, 'showUpdateDialog resultCode: %{public}s', String(resultCode));
              })
              .catch((error: BusinessError) => {
                hilog.error(DOMAIN, TAG, 'showUpdateDialog failed: %{public}s', error.message);
              });
          }
        })
        .catch((error: BusinessError) => {
          hilog.error(DOMAIN, TAG, 'checkAppUpdate failed: %{public}s', error.message);
        });
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'checkAppUpdate exception: %{public}s', (e as Error).message);
    }
  }


  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
